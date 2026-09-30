const express = require('express');
const router = express.Router();
const prescriptionController = require('../controllers/prescriptionController');
const { verifyToken, requireRole } = require('../middlewares/authMiddleware');

// Route: GET /api/prescriptions/medicines/all (List medicines and current stock for demo)
router.get('/medicines/all', verifyToken, prescriptionController.getMedicines);

// Route: GET /api/prescriptions/:id
router.get('/:id', verifyToken, prescriptionController.getPrescriptionById);

// Route: POST /api/prescriptions (Doctor or Admin can prescribe)
router.post('/', verifyToken, requireRole(['ADMIN', 'DOCTOR']), prescriptionController.createPrescription);

module.exports = router;
