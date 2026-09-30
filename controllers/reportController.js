const oracledb = require('oracledb');

// GET /api/reports/revenue
// Blueprint Step 7 requirement: live JSON aggregation (GROUP BY / SUM) straight from Oracle
async function getRevenueReport(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();

        // 1. Department revenue breakdown using GROUP BY, SUM, COUNT
        const deptRevenueSql = `
            SELECT 
                d.department_id,
                d.department_name,
                COUNT(DISTINCT a.appointment_id) AS total_appointments,
                COUNT(DISTINCT doc.doctor_id) AS total_doctors,
                NVL(SUM(bi.amount), 0) AS total_department_revenue
            FROM department d
            LEFT JOIN doctor doc ON d.department_id = doc.department_id
            LEFT JOIN appointment a ON doc.doctor_id = a.doctor_id
            LEFT JOIN treatment t ON a.appointment_id = t.appointment_id
            LEFT JOIN bill b ON b.patient_id = t.patient_id
            LEFT JOIN bill_item bi ON b.bill_id = bi.bill_id
            GROUP BY d.department_id, d.department_name
            ORDER BY total_department_revenue DESC, d.department_name ASC
        `;
        const deptResult = await connection.execute(deptRevenueSql, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });

        // 2. High-level hospital financial metrics
        const totalsSql = `
            SELECT 
                (SELECT COUNT(*) FROM patient) AS total_patients,
                (SELECT COUNT(*) FROM appointment) AS total_appointments,
                (SELECT NVL(SUM(total_amount), 0) FROM bill) AS total_invoiced,
                (SELECT NVL(SUM(amount_paid), 0) FROM payment) AS total_collected,
                (SELECT NVL(SUM(balance_due), 0) FROM patient) AS total_outstanding_debt
            FROM DUAL
        `;
        const totalsResult = await connection.execute(totalsSql, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });

        res.json({
            title: 'MediCore Hospital Live Revenue & Performance Analytics',
            generated_at: new Date().toISOString(),
            hospital_totals: totalsResult.rows[0],
            department_breakdown: deptResult.rows
        });

    } catch (err) {
        console.error('Error generating revenue report:', err);
        res.status(500).json({ error: err.message || 'Error generating revenue report.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

// GET /api/reports/pending-balances
// Lists all patients with outstanding hospital debts
async function getPendingBalancesReport(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const sql = `
            SELECT 
                p.patient_id,
                p.full_name,
                p.phone,
                p.balance_due,
                COUNT(b.bill_id) AS total_bills,
                TO_CHAR(MAX(b.bill_date), 'YYYY-MM-DD') AS last_bill_date
            FROM patient p
            LEFT JOIN bill b ON p.patient_id = b.patient_id
            WHERE p.balance_due > 0
            GROUP BY p.patient_id, p.full_name, p.phone, p.balance_due
            ORDER BY p.balance_due DESC
        `;
        const result = await connection.execute(sql, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
        res.json({
            patients_with_balance: result.rows,
            total_debtors: result.rows.length,
            sum_debt: result.rows.reduce((sum, r) => sum + Number(r.BALANCE_DUE), 0)
        });
    } catch (err) {
        console.error('Error fetching pending balances report:', err);
        res.status(500).json({ error: err.message || 'Error fetching pending balances.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (cErr) {}
        }
    }
}

module.exports = {
    getRevenueReport,
    getPendingBalancesReport
};
