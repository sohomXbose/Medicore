const express = require('express');
const router = express.Router();
const billController = require('../controllers/billController');
const { verifyToken, requireRole } = require('../middlewares/authMiddleware');

// Route: GET /api/bills
router.get('/', verifyToken, billController.getAllBills);

// Route: GET /api/bills/:id
router.get('/:id', verifyToken, billController.getBillById);

// Route: POST /api/bills/generate (Atomic transaction: Admin, Receptionist, or Accountant)
router.post('/generate', verifyToken, requireRole(['ADMIN', 'RECEPTIONIST', 'ACCOUNTANT']), billController.generateBill);

// Route alias: POST /api/bills
router.post('/', verifyToken, requireRole(['ADMIN', 'RECEPTIONIST', 'ACCOUNTANT']), billController.generateBill);

module.exports = router;
