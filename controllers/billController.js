const oracledb = require('oracledb');

// POST /api/bills/generate
// Demonstrates atomic multi-table transaction: Bill + Bill Items + Payment + Patient Balance Update
async function generateBill(req, res) {
    const { patient_id, items, payment, force_error } = req.body || {};

    if (!patient_id || isNaN(Number(patient_id))) {
        return res.status(400).json({ error: 'Valid patient_id is required.' });
    }
    if (!items || !Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ error: 'At least one bill item is required.' });
    }

    const validItemTypes = ['CONSULTATION', 'TREATMENT', 'MEDICINE', 'LAB_TEST'];
    let calculatedTotal = 0;

    for (let i = 0; i < items.length; i++) {
        const itm = items[i];
        if (!itm.item_type || !validItemTypes.includes(String(itm.item_type).toUpperCase())) {
            return res.status(400).json({
                error: `Item ${i + 1}: Invalid item_type. Must be one of: ${validItemTypes.join(', ')}`
            });
        }
        if (itm.amount === undefined || isNaN(Number(itm.amount)) || Number(itm.amount) < 0) {
            return res.status(400).json({ error: `Item ${i + 1}: amount must be a non-negative number.` });
        }
        calculatedTotal += Number(itm.amount);
    }

    const amountPaid = payment && !isNaN(Number(payment.amount_paid)) ? Number(payment.amount_paid) : 0;
    const paymentMode = payment && payment.payment_mode ? String(payment.payment_mode).toUpperCase() : null;

    if (amountPaid > 0 && !paymentMode) {
        return res.status(400).json({ error: 'payment_mode is required when amount_paid > 0.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();

        // 1. Verify Patient exists
        const patientCheck = await connection.execute(
            `SELECT patient_id, balance_due FROM patient WHERE patient_id = :pid`,
            { pid: Number(patient_id) }
        );
        if (patientCheck.rows.length === 0) {
            return res.status(404).json({ error: `Patient with ID ${patient_id} does not exist.` });
        }
        const initialBalance = Number(patientCheck.rows[0].BALANCE_DUE);

        // 2. Insert Bill Record (Master Table)
        const insertBillSql = `
            INSERT INTO bill (patient_id, bill_date, total_amount)
            VALUES (:patient_id, SYSDATE, :total_amount)
            RETURNING bill_id INTO :bill_id
        `;
        const billRes = await connection.execute(
            insertBillSql,
            {
                patient_id: Number(patient_id),
                total_amount: calculatedTotal,
                bill_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
            },
            { autoCommit: false }
        );
        const newBillId = billRes.outBinds.bill_id[0];

        // 3. Insert Bill Line Items (Child Table)
        for (const itm of items) {
            await connection.execute(
                `INSERT INTO bill_item (bill_id, item_type, description, amount)
                 VALUES (:bill_id, :item_type, :description, :amount)`,
                {
                    bill_id: newBillId,
                    item_type: String(itm.item_type).toUpperCase(),
                    description: (itm.description || '').trim(),
                    amount: Number(itm.amount)
                },
                { autoCommit: false }
            );
        }

        // Optional Demo Feature: Forced Error to prove complete transaction rollback (Atomicity)
        if (force_error) {
            throw new Error('DEMO_FORCED_ROLLBACK: Deliberate failure triggered to demonstrate ACID Atomicity.');
        }

        // 4. Record Payment if provided
        let newPaymentId = null;
        if (amountPaid > 0) {
            const insertPaymentSql = `
                INSERT INTO payment (bill_id, payment_date, amount_paid, payment_mode)
                VALUES (:bill_id, SYSDATE, :amount_paid, :payment_mode)
                RETURNING payment_id INTO :payment_id
            `;
            const payRes = await connection.execute(
                insertPaymentSql,
                {
                    bill_id: newBillId,
                    amount_paid: amountPaid,
                    payment_mode: paymentMode,
                    payment_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                },
                { autoCommit: false }
            );
            newPaymentId = payRes.outBinds.payment_id[0];
        }

        // 5. Synchronize Patient Balance Due
        const netDebtIncrease = calculatedTotal - amountPaid;
        const newBalance = initialBalance + netDebtIncrease;
        await connection.execute(
            `UPDATE patient SET balance_due = :new_balance WHERE patient_id = :pid`,
            { new_balance: newBalance, pid: Number(patient_id) },
            { autoCommit: false }
        );

        // 6. Commit Atomic Transaction
        await connection.commit();

        res.status(201).json({
            message: 'Bill and payment processed atomically.',
            transaction: {
                bill_id: newBillId,
                patient_id: Number(patient_id),
                total_amount: calculatedTotal,
                amount_paid: amountPaid,
                payment_id: newPaymentId,
                payment_mode: paymentMode,
                previous_balance: initialBalance,
                new_balance: newBalance,
                status: amountPaid >= calculatedTotal ? 'PAID' : (amountPaid > 0 ? 'PARTIAL' : 'UNPAID')
            }
        });

    } catch (err) {
        if (connection) {
            try {
                await connection.rollback();
                console.log('[TRANSACTION ROLLBACK] Rolled back successfully due to:', err.message);
            } catch (rErr) {}
        }
        console.error('Error in generateBill transaction:', err);
        res.status(err.message.includes('DEMO_FORCED_ROLLBACK') ? 400 : 500).json({
            error: err.message || 'Database transaction error during bill generation.',
            rolled_back: true
        });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/bills
async function getAllBills(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const sql = `
            SELECT 
                b.bill_id,
                b.patient_id,
                p.full_name AS patient_name,
                b.total_amount,
                NVL(SUM(py.amount_paid), 0) AS total_paid,
                (b.total_amount - NVL(SUM(py.amount_paid), 0)) AS balance_remaining,
                TO_CHAR(b.bill_date, 'YYYY-MM-DD HH24:MI') AS bill_date
            FROM bill b
            JOIN patient p ON b.patient_id = p.patient_id
            LEFT JOIN payment py ON b.bill_id = py.bill_id
            GROUP BY b.bill_id, b.patient_id, p.full_name, b.total_amount, b.bill_date
            ORDER BY b.bill_id DESC
        `;
        const result = await connection.execute(sql, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.json({ bills: result.rows });
    } catch (err) {
        console.error('Error fetching bills:', err);
        res.status(500).json({ error: err.message || 'Error fetching bills.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/bills/:id
async function getBillById(req, res) {
    const id = Number(req.params.id);
    if (!id || isNaN(id)) {
        return res.status(400).json({ error: 'Valid bill ID is required.' });
    }

    let connection;
    try {
        connection = await oracledb.getConnection();
        const billSql = `
            SELECT 
                b.bill_id,
                b.patient_id,
                p.full_name AS patient_name,
                p.phone AS patient_phone,
                b.total_amount,
                TO_CHAR(b.bill_date, 'YYYY-MM-DD HH24:MI') AS bill_date
            FROM bill b
            JOIN patient p ON b.patient_id = p.patient_id
            WHERE b.bill_id = :id
        `;
        const billRes = await connection.execute(billSql, { id }, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        if (billRes.rows.length === 0) {
            return res.status(404).json({ error: `Bill with ID ${id} not found.` });
        }

        const itemsSql = `
            SELECT bill_item_id, item_type, description, amount
            FROM bill_item
            WHERE bill_id = :id
            ORDER BY bill_item_id ASC
        `;
        const itemsRes = await connection.execute(itemsSql, { id }, { outFormat: oracledb.OUT_FORMAT_OBJECT });

        const paymentsSql = `
            SELECT payment_id, amount_paid, payment_mode, TO_CHAR(payment_date, 'YYYY-MM-DD HH24:MI') AS payment_date
            FROM payment
            WHERE bill_id = :id
            ORDER BY payment_id ASC
        `;
        const payRes = await connection.execute(paymentsSql, { id }, { outFormat: oracledb.OUT_FORMAT_OBJECT });

        const totalPaid = payRes.rows.reduce((sum, r) => sum + Number(r.AMOUNT_PAID), 0);
        const totalAmount = Number(billRes.rows[0].TOTAL_AMOUNT);

        res.json({
            bill: billRes.rows[0],
            items: itemsRes.rows,
            payments: payRes.rows,
            summary: {
                total_amount: totalAmount,
                total_paid: totalPaid,
                balance_remaining: totalAmount - totalPaid,
                is_settled: totalPaid >= totalAmount
            }
        });

    } catch (err) {
        console.error('Error fetching bill details:', err);
        res.status(500).json({ error: err.message || 'Error fetching bill details.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

module.exports = {
    generateBill,
    getAllBills,
    getBillById
};
