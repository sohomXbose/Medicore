const express = require('express');
const router = express.Router();
const treatmentController = require('../controllers/treatmentController');
const { verifyToken, requireRole } = require('../middlewares/authMiddleware');

// Route: GET /api/treatments
router.get('/', verifyToken, treatmentController.getAllTreatments);

// Route: GET /api/treatments/:id
router.get('/:id', verifyToken, treatmentController.getTreatmentById);

// Route: POST /api/treatments (Doctor or Admin can create treatments)
router.post('/', verifyToken, requireRole(['ADMIN', 'DOCTOR']), treatmentController.createTreatment);

module.exports = router;
