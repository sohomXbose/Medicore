const oracledb = require('oracledb');

// POST /api/prescriptions
// Creates a prescription and inserts prescription items, triggering stock deduction
async function createPrescription(req, res) {
    const { treatment_id, items } = req.body || {};

    if (!treatment_id || isNaN(Number(treatment_id))) {
        return res.status(400).json({ error: 'Valid treatment_id is required.' });
    }
    if (!items || !Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ error: 'At least one prescription item is required.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();

        // 1. Verify Treatment exists
        const treatmentCheck = await connection.execute(
            `SELECT treatment_id, patient_id, doctor_id FROM treatment WHERE treatment_id = :treatment_id`,
            { treatment_id: Number(treatment_id) }
        );
        if (treatmentCheck.rows.length === 0) {
            return res.status(404).json({ error: `Treatment with ID ${treatment_id} does not exist.` });
        }

        // 2. Validate all medicines in items array
        for (let i = 0; i < items.length; i++) {
            const itm = items[i];
            if (!itm.medicine_id || isNaN(Number(itm.medicine_id))) {
                return res.status(400).json({ error: `Item ${i + 1}: Valid medicine_id is required.` });
            }
            if (!itm.dosage || typeof itm.dosage !== 'string') {
                return res.status(400).json({ error: `Item ${i + 1}: Dosage is required (e.g. '500 mg').` });
            }
            if (!itm.frequency_per_day || Number(itm.frequency_per_day) <= 0) {
                return res.status(400).json({ error: `Item ${i + 1}: frequency_per_day must be > 0.` });
            }
            if (!itm.duration_days || Number(itm.duration_days) <= 0) {
                return res.status(400).json({ error: `Item ${i + 1}: duration_days must be > 0.` });
            }

            // Check medicine stock
            const medCheck = await connection.execute(
                `SELECT medicine_id, medicine_name, stock_quantity FROM medicine WHERE medicine_id = :mid`,
                { mid: Number(itm.medicine_id) }
            );
            if (medCheck.rows.length === 0) {
                return res.status(404).json({ error: `Medicine with ID ${itm.medicine_id} does not exist.` });
            }
            const med = medCheck.rows[0];
            const neededUnits = Number(itm.frequency_per_day) * Number(itm.duration_days);
            if (med.STOCK_QUANTITY < neededUnits) {
                return res.status(400).json({
                    error: `Insufficient stock for '${med.MEDICINE_NAME}'. Required: ${neededUnits}, Available: ${med.STOCK_QUANTITY}`
                });
            }
        }

        // 3. Insert Master Prescription record
        const insertPrescSql = `
            INSERT INTO prescription (treatment_id, prescribed_date)
            VALUES (:treatment_id, SYSDATE)
            RETURNING prescription_id INTO :prescription_id
        `;
        const prescResult = await connection.execute(
            insertPrescSql,
            {
                treatment_id: Number(treatment_id),
                prescription_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
            },
            { autoCommit: false }
        );
        const newPrescriptionId = prescResult.outBinds.prescription_id[0];

        // 4. Insert each Prescription Item (fires trg_prescription_stock_deduct automatically)
        const insertedItems = [];
        for (const itm of items) {
            const insertItemSql = `
                INSERT INTO prescription_item (prescription_id, medicine_id, dosage, frequency_per_day, duration_days)
                VALUES (:prescription_id, :medicine_id, :dosage, :frequency_per_day, :duration_days)
                RETURNING prescription_item_id INTO :item_id
            `;
            const itemResult = await connection.execute(
                insertItemSql,
                {
                    prescription_id: newPrescriptionId,
                    medicine_id: Number(itm.medicine_id),
                    dosage: String(itm.dosage).trim(),
                    frequency_per_day: Number(itm.frequency_per_day),
                    duration_days: Number(itm.duration_days),
                    item_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                },
                { autoCommit: false }
            );
            insertedItems.push({
                prescription_item_id: itemResult.outBinds.item_id[0],
                medicine_id: Number(itm.medicine_id),
                dosage: itm.dosage,
                frequency_per_day: Number(itm.frequency_per_day),
                duration_days: Number(itm.duration_days),
                deducted_units: Number(itm.frequency_per_day) * Number(itm.duration_days)
            });
        }

        // 5. Commit atomic transaction
        await connection.commit();

        res.status(201).json({
            message: 'Prescription created successfully. Medicine stock decremented by database trigger.',
            prescription_id: newPrescriptionId,
            treatment_id: Number(treatment_id),
            items: insertedItems
        });

    } catch (err) {
        if (connection) {
            try { await connection.rollback(); } catch (rErr) {}
        }
        console.error('Error creating prescription:', err);
        res.status(500).json({ error: err.message || 'Database error creating prescription.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/prescriptions/:id
async function getPrescriptionById(req, res) {
    const id = Number(req.params.id);
    if (!id || isNaN(id)) {
        return res.status(400).json({ error: 'Valid prescription ID is required.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const headerSql = `
            SELECT 
                pr.prescription_id,
                pr.treatment_id,
                TO_CHAR(pr.prescribed_date, 'YYYY-MM-DD HH24:MI') AS prescribed_date,
                t.diagnosis,
                p.patient_id,
                p.full_name AS patient_name,
                s.full_name AS doctor_name
            FROM prescription pr
            JOIN treatment t ON pr.treatment_id = t.treatment_id
            JOIN patient p ON t.patient_id = p.patient_id
            JOIN doctor doc ON t.doctor_id = doc.doctor_id
            JOIN staff s ON doc.staff_id = s.staff_id
            WHERE pr.prescription_id = :id
        `;
        const headerRes = await connection.execute(headerSql, { id }, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        if (headerRes.rows.length === 0) {
            return res.status(404).json({ error: `Prescription with ID ${id} not found.` });
        }

        const itemsSql = `
            SELECT 
                pi.prescription_item_id,
                pi.medicine_id,
                m.medicine_name,
                m.unit_price,
                pi.dosage,
                pi.frequency_per_day,
                pi.duration_days,
                (pi.frequency_per_day * pi.duration_days) AS total_units
            FROM prescription_item pi
            JOIN medicine m ON pi.medicine_id = m.medicine_id
            WHERE pi.prescription_id = :id
        `;
        const itemsRes = await connection.execute(itemsSql, { id }, { outFormat: oracledb.OUT_FORMAT_OBJECT });

        res.json({
            prescription: headerRes.rows[0],
            items: itemsRes.rows
        });
    } catch (err) {
        console.error('Error fetching prescription:', err);
        res.status(500).json({ error: err.message || 'Error fetching prescription.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/prescriptions/medicines/all
// Helper to inspect current stock levels for Postman demo assertions
async function getMedicines(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT medicine_id, medicine_name, unit_price, stock_quantity, reorder_level 
             FROM medicine 
             ORDER BY medicine_id ASC`,
            [],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        res.json({ medicines: result.rows });
    } catch (err) {
        console.error('Error fetching medicines:', err);
        res.status(500).json({ error: err.message || 'Error fetching medicines.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

module.exports = {
    createPrescription,
    getPrescriptionById,
    getMedicines
};
