const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointmentController');
const { verifyToken, requireRole } = require('../middlewares/authMiddleware');

// Get all appointments
router.get('/', verifyToken, appointmentController.getAppointments);

// Get single appointment by ID
router.get('/:id', verifyToken, appointmentController.getAppointmentById);

// Book new appointment (Only Receptionist or Admin can book)
router.post('/', verifyToken, requireRole(['ADMIN', 'RECEPTIONIST']), appointmentController.bookAppointment);

// Update appointment status (Doctor, Receptionist, or Admin)
router.patch('/:id/status', verifyToken, requireRole(['ADMIN', 'RECEPTIONIST', 'DOCTOR']), appointmentController.updateAppointmentStatus);

module.exports = router;
