const jwt = require('jsonwebtoken');

// Middleware to check if the user is logged in (has a valid token)
function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Format: "Bearer <token>"

    if (!token) {
        return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Adds the user data (id, role) to the request
        next();
    } catch (err) {
        res.status(403).json({ error: 'Invalid token.' });
    }
}

// Middleware to check if the user has a specific role (e.g., 'ADMIN', 'DOCTOR')
function requireRole(allowedRoles) {
    const roles = (Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles]).map(r => String(r).toUpperCase());
    return (req, res, next) => {
        const userRole = req.user && req.user.role ? String(req.user.role).toUpperCase() : null;
        if (!userRole || !roles.includes(userRole)) {
            return res.status(403).json({ error: 'Access denied. You do not have the required role.' });
        }
        next();
    };
}

module.exports = {
    verifyToken,
    requireRole
};
