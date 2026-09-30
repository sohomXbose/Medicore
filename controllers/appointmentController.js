const oracledb = require('oracledb');

// Helper to validate date YYYY-MM-DD
function isValidDate(dateStr) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return false;
    const d = new Date(dateStr);
    return !isNaN(d.getTime()) && dateStr === d.toISOString().slice(0, 10);
}

// Helper to validate time (HH:MM)
function isValidTime(timeStr) {
    return /^([01]\d|2[0-3]):[0-5]\d$/.test(timeStr);
}

// GET /api/appointments
async function getAppointments(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const { patient_id, doctor_id, status, date } = req.query;

        let query = `
            SELECT a.appointment_id, 
                   a.patient_id, 
                   p.full_name AS patient_name,
                   a.doctor_id, 
                   s.full_name AS doctor_name,
                   TO_CHAR(a.appointment_date, 'YYYY-MM-DD') AS appointment_date, 
                   a.appointment_time, 
                   a.reason, 
                   a.status 
            FROM appointment a
            JOIN patient p ON a.patient_id = p.patient_id
            JOIN doctor d ON a.doctor_id = d.doctor_id
            JOIN staff s ON d.staff_id = s.staff_id
            WHERE 1=1
        `;
        const binds = {};

        if (patient_id) {
            query += ` AND a.patient_id = :patient_id`;
            binds.patient_id = parseInt(patient_id, 10);
        }
        if (doctor_id) {
            query += ` AND a.doctor_id = :doctor_id`;
            binds.doctor_id = parseInt(doctor_id, 10);
        }
        if (status) {
            query += ` AND a.status = :status`;
            binds.status = status.toUpperCase();
        }
        if (date) {
            if (!isValidDate(date)) {
                return res.status(400).json({ error: 'Invalid date filter format (YYYY-MM-DD).' });
            }
            query += ` AND a.appointment_date = TO_DATE(:date_filter, 'YYYY-MM-DD')`;
            binds.date_filter = date;
        }

        query += ` ORDER BY a.appointment_date ASC, a.appointment_time ASC`;

        const result = await connection.execute(query, binds, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.json(result.rows);
    } catch (err) {
        console.error('getAppointments error:', err);
        res.status(500).json({ error: 'Database error fetching appointments.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// GET /api/appointments/:id
async function getAppointmentById(req, res) {
    const { id } = req.params;
    const appointmentId = parseInt(id, 10);
    if (isNaN(appointmentId) || appointmentId <= 0) {
        return res.status(400).json({ error: 'Invalid appointment ID. Must be a positive integer.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT a.appointment_id, 
                    a.patient_id, 
                    p.full_name AS patient_name,
                    a.doctor_id, 
                    s.full_name AS doctor_name,
                    TO_CHAR(a.appointment_date, 'YYYY-MM-DD') AS appointment_date, 
                    a.appointment_time, 
                    a.reason, 
                    a.status 
             FROM appointment a
             JOIN patient p ON a.patient_id = p.patient_id
             JOIN doctor d ON a.doctor_id = d.doctor_id
             JOIN staff s ON d.staff_id = s.staff_id
             WHERE a.appointment_id = :id`,
            { id: appointmentId },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        if (!result.rows || result.rows.length === 0) {
            return res.status(404).json({ error: 'Appointment not found.' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error('getAppointmentById error:', err);
        res.status(500).json({ error: 'Database error fetching appointment.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// POST /api/appointments (Book Appointment)
async function bookAppointment(req, res) {
    const { patient_id, doctor_id, appointment_date, appointment_time, reason } = req.body || {};

    // 1. Strict Input Validation (Blueprint Phase 2 Task 5 & Gate 2)
    const pId = parseInt(patient_id, 10);
    if (isNaN(pId) || pId <= 0) {
        return res.status(400).json({ error: 'Valid patient_id (positive integer) is required.' });
    }

    const dId = parseInt(doctor_id, 10);
    if (isNaN(dId) || dId <= 0) {
        return res.status(400).json({ error: 'Valid doctor_id (positive integer) is required.' });
    }

    if (!appointment_date || !isValidDate(appointment_date)) {
        return res.status(400).json({ error: 'Valid appointment_date (YYYY-MM-DD) is required.' });
    }

    if (!appointment_time || !isValidTime(appointment_time)) {
        return res.status(400).json({ error: 'Valid appointment_time in 24-hr format (HH:MM, e.g. 09:30, 14:00) is required.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        
        // 2. Check for double booking (Blueprint Phase 2 Gate 2 requirement)
        // Checks if an active appointment already occupies this slot for the doctor
        const checkResult = await connection.execute(
            `SELECT COUNT(*) AS slot_count FROM appointment 
             WHERE doctor_id = :doctor_id 
               AND appointment_date = TO_DATE(:appointment_date, 'YYYY-MM-DD') 
               AND appointment_time = :appointment_time
               AND status != 'CANCELLED'`,
            { doctor_id: dId, appointment_date, appointment_time },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        const count = checkResult.rows[0].SLOT_COUNT || checkResult.rows[0].slot_count || 0;
        if (count > 0) {
            return res.status(409).json({ error: 'This time slot is already booked for this doctor.' });
        }

        // 3. Book the appointment using parameterized query
        const insertResult = await connection.execute(
            `INSERT INTO appointment (patient_id, doctor_id, appointment_date, appointment_time, reason, status)
             VALUES (:patient_id, :doctor_id, TO_DATE(:appointment_date, 'YYYY-MM-DD'), :appointment_time, :reason, 'SCHEDULED')
             RETURNING appointment_id INTO :out_id`,
            { 
                patient_id: pId, 
                doctor_id: dId, 
                appointment_date, 
                appointment_time, 
                reason: reason ? String(reason).trim() : null,
                out_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
            },
            { autoCommit: true }
        );

        const newId = insertResult.outBinds && insertResult.outBinds.out_id ? insertResult.outBinds.out_id[0] : null;

        res.status(201).json({ 
            message: 'Appointment booked successfully',
            appointment_id: newId
        });
    } catch (err) {
        // Handle Oracle constraint violations with appropriate 4xx status codes
        // ORA-00001: Unique constraint violated (double booking race condition)
        if (err.message && (err.message.includes('ORA-00001') || err.errorNum === 1)) {
            return res.status(409).json({ error: 'This time slot is already booked for this doctor.' });
        }
        // ORA-02291: Foreign key violation (nonexistent patient_id or doctor_id)
        if (err.message && (err.message.includes('ORA-02291') || err.errorNum === 2291)) {
            return res.status(400).json({ error: 'Invalid reference: Specified patient_id or doctor_id does not exist.' });
        }
        // ORA-01858 / ORA-01847: Date conversion errors
        if (err.message && (err.message.includes('ORA-01858') || err.message.includes('ORA-01847') || err.errorNum === 1858 || err.errorNum === 1847)) {
            return res.status(400).json({ error: 'Malformed date format.' });
        }

        console.error('bookAppointment error:', err);
        res.status(500).json({ error: err.message || 'Error booking appointment.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// PATCH /api/appointments/:id/status (Update appointment status e.g. COMPLETED or CANCELLED)
async function updateAppointmentStatus(req, res) {
    const { id } = req.params;
    const appointmentId = parseInt(id, 10);
    if (isNaN(appointmentId) || appointmentId <= 0) {
        return res.status(400).json({ error: 'Invalid appointment ID. Must be a positive integer.' });
    }

    const { status } = req.body || {};
    if (!status || !['SCHEDULED', 'COMPLETED', 'CANCELLED'].includes(status.toUpperCase())) {
        return res.status(400).json({ error: "Status must be one of: 'SCHEDULED', 'COMPLETED', 'CANCELLED'." });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `UPDATE appointment SET status = :status WHERE appointment_id = :id`,
            { status: status.toUpperCase(), id: appointmentId },
            { autoCommit: true }
        );

        if (result.rowsAffected === 0) {
            return res.status(404).json({ error: 'Appointment not found.' });
        }

        res.json({ message: `Appointment status updated to ${status.toUpperCase()} successfully.` });
    } catch (err) {
        console.error('updateAppointmentStatus error:', err);
        res.status(500).json({ error: err.message || 'Error updating appointment status.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

module.exports = { 
    getAppointments, 
    getAppointmentById, 
    bookAppointment, 
    updateAppointmentStatus 
};
