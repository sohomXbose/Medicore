const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Route: GET /api/reports/revenue (Live SQL aggregation from Oracle)
router.get('/revenue', verifyToken, reportController.getRevenueReport);

// Route: GET /api/reports/pending-balances
router.get('/pending-balances', verifyToken, reportController.getPendingBalancesReport);

module.exports = router;
