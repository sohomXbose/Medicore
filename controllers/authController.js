const oracledb = require('oracledb');
const jwt = require('jsonwebtoken');

const bcrypt = require('bcryptjs');

async function login(req, res) {
    const { email, password } = req.body || {};
    
    // Input validation (Phase 2 Task 5)
    if (!email || typeof email !== 'string' || !email.trim()) {
        return res.status(400).json({ error: 'Email is required.' });
    }
    if (!password || typeof password !== 'string') {
        return res.status(400).json({ error: 'Password is required.' });
    }

    let connection;

    try {
        connection = await oracledb.getConnection();
        
        // Parameterized query using bind variable
        const result = await connection.execute(
            `SELECT staff_id, full_name, password_hash, role 
             FROM staff 
             WHERE LOWER(email) = LOWER(:email)`,
            { email: email.trim() },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        if (!result.rows || result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const user = result.rows[0];

        // Check password: direct match (for seeded hash strings) or bcrypt comparison
        let isMatch = (password === user.PASSWORD_HASH);
        if (!isMatch && user.PASSWORD_HASH && user.PASSWORD_HASH.startsWith('$2')) {
            try {
                isMatch = await bcrypt.compare(password, user.PASSWORD_HASH);
            } catch (bErr) {
                isMatch = false;
            }
        }

        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Generate JWT Token (scoped by role for Gate 2 verification)
        const token = jwt.sign(
            { 
                staff_id: user.STAFF_ID, 
                role: user.ROLE,
                email: email.trim().toLowerCase()
            },
            process.env.JWT_SECRET,
            { expiresIn: '8h' }
        );

        res.json({
            message: 'Login successful',
            token: token,
            user: {
                id: user.STAFF_ID,
                name: user.FULL_NAME,
                role: user.ROLE
            }
        });

    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Internal server error during login' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (err) {}
        }
    }
}

module.exports = { login };
