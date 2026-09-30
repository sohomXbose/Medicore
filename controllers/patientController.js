const oracledb = require('oracledb');

// Helper to validate date YYYY-MM-DD
function isValidDate(dateStr) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return false;
    const d = new Date(dateStr);
    return !isNaN(d.getTime()) && dateStr === d.toISOString().slice(0, 10);
}

// GET /api/patients
async function getAllPatients(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const search = req.query.search ? `%${req.query.search.trim().toLowerCase()}%` : null;
        
        let query = `SELECT patient_id, full_name, TO_CHAR(dob, 'YYYY-MM-DD') as dob, gender, phone, blood_group, balance_due FROM patient`;
        const binds = {};

        if (search) {
            query += ` WHERE LOWER(full_name) LIKE :search OR phone LIKE :search`;
            binds.search = search;
        }

        query += ` ORDER BY patient_id ASC`;

        const result = await connection.execute(query, binds, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.json(result.rows);
    } catch (err) {
        console.error('getAllPatients error:', err);
        res.status(500).json({ error: 'Database error fetching patients.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// GET /api/patients/:id
async function getPatientById(req, res) {
    const { id } = req.params;
    const patientId = parseInt(id, 10);
    if (isNaN(patientId) || patientId <= 0) {
        return res.status(400).json({ error: 'Invalid patient ID. Must be a positive integer.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT patient_id, full_name, TO_CHAR(dob, 'YYYY-MM-DD') as dob, gender, phone, blood_group, balance_due 
             FROM patient WHERE patient_id = :id`,
            { id: patientId },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        if (!result.rows || result.rows.length === 0) {
            return res.status(404).json({ error: 'Patient not found.' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error('getPatientById error:', err);
        res.status(500).json({ error: 'Database error fetching patient.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// POST /api/patients (Create)
async function createPatient(req, res) {
    let { full_name, dob, gender, phone, blood_group } = req.body || {};

    // Validation (Phase 2 Task 5)
    if (!full_name || typeof full_name !== 'string' || !full_name.trim()) {
        return res.status(400).json({ error: 'Full name is required.' });
    }
    if (!dob || !isValidDate(dob)) {
        return res.status(400).json({ error: 'Valid Date of Birth (YYYY-MM-DD) is required.' });
    }
    if (!phone || typeof phone !== 'string' || !phone.trim()) {
        return res.status(400).json({ error: 'Phone number is required.' });
    }

    gender = gender ? gender.trim().toUpperCase() : null;
    if (gender && !['MALE', 'FEMALE', 'OTHER'].includes(gender)) {
        return res.status(400).json({ error: 'Gender must be MALE, FEMALE, or OTHER.' });
    }

    blood_group = blood_group ? blood_group.trim().toUpperCase() : null;
    if (blood_group && !['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].includes(blood_group)) {
        return res.status(400).json({ error: 'Invalid blood group. Allowed: A+, A-, B+, B-, AB+, AB-, O+, O-.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `INSERT INTO patient (full_name, dob, gender, phone, blood_group, balance_due) 
             VALUES (:full_name, TO_DATE(:dob, 'YYYY-MM-DD'), :gender, :phone, :blood_group, 0)
             RETURNING patient_id INTO :out_id`,
            {
                full_name: full_name.trim(),
                dob,
                gender,
                phone: phone.trim(),
                blood_group,
                out_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
            },
            { autoCommit: true }
        );

        const newId = result.outBinds && result.outBinds.out_id ? result.outBinds.out_id[0] : null;
        res.status(201).json({
            message: 'Patient created successfully',
            patient_id: newId
        });
    } catch (err) {
        console.error('createPatient error:', err);
        res.status(500).json({ error: err.message || 'Error creating patient.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// PUT /api/patients/:id (Update)
async function updatePatient(req, res) {
    const { id } = req.params;
    const patientId = parseInt(id, 10);
    if (isNaN(patientId) || patientId <= 0) {
        return res.status(400).json({ error: 'Invalid patient ID. Must be a positive integer.' });
    }

    const { full_name, phone, blood_group } = req.body || {};
    if (!full_name && !phone && !blood_group) {
        return res.status(400).json({ error: 'At least one field (full_name, phone, blood_group) is required to update.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        
        // Fetch current row first to keep existing values
        const current = await connection.execute(
            `SELECT full_name, phone, blood_group FROM patient WHERE patient_id = :id`,
            { id: patientId },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        if (!current.rows || current.rows.length === 0) {
            return res.status(404).json({ error: 'Patient not found.' });
        }

        const updatedName = (full_name && full_name.trim()) ? full_name.trim() : current.rows[0].FULL_NAME;
        const updatedPhone = (phone && phone.trim()) ? phone.trim() : current.rows[0].PHONE;
        const updatedBlood = (blood_group && blood_group.trim()) ? blood_group.trim().toUpperCase() : current.rows[0].BLOOD_GROUP;

        const result = await connection.execute(
            `UPDATE patient 
             SET full_name = :full_name, phone = :phone, blood_group = :blood_group 
             WHERE patient_id = :id`,
            { full_name: updatedName, phone: updatedPhone, blood_group: updatedBlood, id: patientId },
            { autoCommit: true }
        );

        if (result.rowsAffected === 0) {
            return res.status(404).json({ error: 'Patient not found.' });
        }

        res.json({ message: 'Patient updated successfully' });
    } catch (err) {
        console.error('updatePatient error:', err);
        res.status(500).json({ error: err.message || 'Error updating patient.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

// DELETE /api/patients/:id (Delete)
async function deletePatient(req, res) {
    const { id } = req.params;
    const patientId = parseInt(id, 10);
    if (isNaN(patientId) || patientId <= 0) {
        return res.status(400).json({ error: 'Invalid patient ID. Must be a positive integer.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `DELETE FROM patient WHERE patient_id = :id`,
            { id: patientId },
            { autoCommit: true }
        );

        if (result.rowsAffected === 0) {
            return res.status(404).json({ error: 'Patient not found.' });
        }

        res.json({ message: 'Patient deleted successfully' });
    } catch (err) {
        // ORA-02292: integrity constraint violated - child record found
        if (err.message && (err.message.includes('ORA-02292') || err.errorNum === 2292)) {
            return res.status(409).json({
                error: 'Cannot delete patient: Active appointments, treatments, admissions, or bills exist for this patient.'
            });
        }
        console.error('deletePatient error:', err);
        res.status(500).json({ error: err.message || 'Error deleting patient.' });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) {} }
    }
}

module.exports = { getAllPatients, getPatientById, createPatient, updatePatient, deletePatient };
