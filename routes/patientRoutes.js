const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');

// Import authentication middleware
const { verifyToken, requireRole } = require('../middlewares/authMiddleware');

// Route: GET /api/patients (Any logged in user can see patients)
router.get('/', verifyToken, patientController.getAllPatients);

// Route: GET /api/patients/:id (Any logged in user can view a single patient)
router.get('/:id', verifyToken, patientController.getPatientById);

// Route: POST /api/patients (Only Admin or Receptionist can create)
router.post('/', verifyToken, requireRole(['ADMIN', 'RECEPTIONIST']), patientController.createPatient);

// Route: PUT /api/patients/:id (Update patient)
router.put('/:id', verifyToken, requireRole(['ADMIN', 'RECEPTIONIST']), patientController.updatePatient);

// Route: DELETE /api/patients/:id (Delete patient)
router.delete('/:id', verifyToken, requireRole(['ADMIN']), patientController.deletePatient);

module.exports = router;
