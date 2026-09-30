const oracledb = require('oracledb');

// POST /api/treatments
// Records diagnosis and treatment notes for a patient and doctor
async function createTreatment(req, res) {
    const { patient_id, doctor_id, appointment_id, diagnosis, treatment_notes } = req.body || {};

    if (!patient_id || isNaN(Number(patient_id))) {
        return res.status(400).json({ error: 'Valid patient_id is required.' });
    }
    if (!doctor_id || isNaN(Number(doctor_id))) {
        return res.status(400).json({ error: 'Valid doctor_id is required.' });
    }
    if (!diagnosis || typeof diagnosis !== 'string' || !diagnosis.trim()) {
        return res.status(400).json({ error: 'Diagnosis is required.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();

        // 1. Verify Patient exists
        const patientCheck = await connection.execute(
            `SELECT patient_id FROM patient WHERE patient_id = :patient_id`,
            { patient_id: Number(patient_id) }
        );
        if (patientCheck.rows.length === 0) {
            return res.status(404).json({ error: `Patient with ID ${patient_id} does not exist.` });
        }

        // 2. Verify Doctor exists
        const doctorCheck = await connection.execute(
            `SELECT doctor_id FROM doctor WHERE doctor_id = :doctor_id`,
            { doctor_id: Number(doctor_id) }
        );
        if (doctorCheck.rows.length === 0) {
            return res.status(404).json({ error: `Doctor with ID ${doctor_id} does not exist.` });
        }

        // 3. Verify Appointment if provided
        if (appointment_id) {
            const apptCheck = await connection.execute(
                `SELECT appointment_id, status FROM appointment WHERE appointment_id = :appt_id`,
                { appt_id: Number(appointment_id) }
            );
            if (apptCheck.rows.length === 0) {
                return res.status(404).json({ error: `Appointment with ID ${appointment_id} does not exist.` });
            }
        }

        // 4. Insert Treatment record
        const insertSql = `
            INSERT INTO treatment (patient_id, doctor_id, appointment_id, diagnosis, treatment_notes, treatment_date)
            VALUES (:patient_id, :doctor_id, :appointment_id, :diagnosis, :treatment_notes, SYSDATE)
            RETURNING treatment_id INTO :treatment_id
        `;

        const bindVars = {
            patient_id: Number(patient_id),
            doctor_id: Number(doctor_id),
            appointment_id: appointment_id ? Number(appointment_id) : null,
            diagnosis: diagnosis.trim(),
            treatment_notes: (treatment_notes || '').trim(),
            treatment_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
        };

        const result = await connection.execute(insertSql, bindVars, { autoCommit: false });
        const newTreatmentId = result.outBinds.treatment_id[0];

        // 5. Update appointment status to COMPLETED if linked
        if (appointment_id) {
            await connection.execute(
                `UPDATE appointment SET status = 'COMPLETED' WHERE appointment_id = :appt_id`,
                { appt_id: Number(appointment_id) },
                { autoCommit: false }
            );
        }

        await connection.commit();

        res.status(201).json({
            message: 'Treatment recorded successfully',
            treatment: {
                treatment_id: newTreatmentId,
                patient_id: Number(patient_id),
                doctor_id: Number(doctor_id),
                appointment_id: appointment_id ? Number(appointment_id) : null,
                diagnosis: diagnosis.trim(),
                treatment_notes: (treatment_notes || '').trim()
            }
        });

    } catch (err) {
        if (connection) {
            try { await connection.rollback(); } catch (rErr) {}
        }
        console.error('Error creating treatment:', err);
        res.status(500).json({ error: err.message || 'Database error while recording treatment.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/treatments
async function getAllTreatments(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const sql = `
            SELECT 
                t.treatment_id,
                t.patient_id,
                p.full_name AS patient_name,
                t.doctor_id,
                s.full_name AS doctor_name,
                doc.specialization,
                t.appointment_id,
                t.diagnosis,
                t.treatment_notes,
                TO_CHAR(t.treatment_date, 'YYYY-MM-DD HH24:MI') AS treatment_date
            FROM treatment t
            JOIN patient p ON t.patient_id = p.patient_id
            JOIN doctor doc ON t.doctor_id = doc.doctor_id
            JOIN staff s ON doc.staff_id = s.staff_id
            ORDER BY t.treatment_id DESC
        `;
        const result = await connection.execute(sql, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.json({ treatments: result.rows });
    } catch (err) {
        console.error('Error fetching treatments:', err);
        res.status(500).json({ error: err.message || 'Error fetching treatments.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/treatments/:id
async function getTreatmentById(req, res) {
    const id = Number(req.params.id);
    if (!id || isNaN(id)) {
        return res.status(400).json({ error: 'Valid treatment ID is required.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const sql = `
            SELECT 
                t.treatment_id,
                t.patient_id,
                p.full_name AS patient_name,
                p.phone AS patient_phone,
                t.doctor_id,
                s.full_name AS doctor_name,
                doc.specialization,
                t.appointment_id,
                t.diagnosis,
                t.treatment_notes,
                TO_CHAR(t.treatment_date, 'YYYY-MM-DD HH24:MI') AS treatment_date
            FROM treatment t
            JOIN patient p ON t.patient_id = p.patient_id
            JOIN doctor doc ON t.doctor_id = doc.doctor_id
            JOIN staff s ON doc.staff_id = s.staff_id
            WHERE t.treatment_id = :id
        `;
        const result = await connection.execute(sql, { id }, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        if (result.rows.length === 0) {
            return res.status(404).json({ error: `Treatment with ID ${id} not found.` });
        }
        res.json({ treatment: result.rows[0] });
    } catch (err) {
        console.error('Error fetching treatment:', err);
        res.status(500).json({ error: err.message || 'Error fetching treatment details.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

module.exports = {
    createTreatment,
    getAllTreatments,
    getTreatmentById
};
