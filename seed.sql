SET SQLBLANKLINES ON
SET DEFINE OFF

-- =========================================================
-- MEDICORE - SEED DATA (FIXED)
-- =========================================================
-- Phase 1 Database Seed
-- Departments : 4
-- Doctors     : 8
-- Patients    : 20
-- Appointments: 30
-- Treatments  : 8  (one per completed appointment)
-- =========================================================

-- =========================================================
-- 0. RESET (so this script can be re-run without ORA-00001)
-- =========================================================

DELETE FROM notification;
DELETE FROM doctor_schedule;
DELETE FROM user_session;
DELETE FROM audit_log;
DELETE FROM payment;
DELETE FROM bill_item;
DELETE FROM bill;
DELETE FROM lab_test;
DELETE FROM admission;
DELETE FROM bed;
DELETE FROM room;
DELETE FROM prescription_item;
DELETE FROM prescription;
DELETE FROM medicine;
DELETE FROM treatment;
DELETE FROM appointment;
DELETE FROM patient;
DELETE FROM doctor;
DELETE FROM staff;
DELETE FROM department;
COMMIT;


-- =========================================================
-- 1. DEPARTMENT
-- =========================================================

INSERT INTO department (department_id, department_name)
VALUES (1, 'Cardiology');

INSERT INTO department (department_id, department_name)
VALUES (2, 'Neurology');

INSERT INTO department (department_id, department_name)
VALUES (3, 'Orthopedics');

INSERT INTO department (department_id, department_name)
VALUES (4, 'Pediatrics');


-- =========================================================
-- 2. STAFF
-- =========================================================

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(1, 'Admin User', 'admin@medicore.com', 'hash_admin', 'ADMIN',
 TO_DATE('2026-01-01','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(2, 'Dr. Rahul Sharma', 'rahul@medicore.com', 'hash_rahul', 'DOCTOR',
 TO_DATE('2026-01-02','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(3, 'Dr. Priya Verma', 'priya@medicore.com', 'hash_priya', 'DOCTOR',
 TO_DATE('2026-01-03','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(4, 'Dr. Amit Patel', 'amit@medicore.com', 'hash_amit', 'DOCTOR',
 TO_DATE('2026-01-04','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(5, 'Dr. Neha Singh', 'neha@medicore.com', 'hash_neha', 'DOCTOR',
 TO_DATE('2026-01-05','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(6, 'Dr. Arjun Mehta', 'arjun@medicore.com', 'hash_arjun', 'DOCTOR',
 TO_DATE('2026-01-06','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(7, 'Dr. Sneha Gupta', 'sneha@medicore.com', 'hash_sneha', 'DOCTOR',
 TO_DATE('2026-01-07','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(8, 'Dr. Rohan Joshi', 'rohan@medicore.com', 'hash_rohan', 'DOCTOR',
 TO_DATE('2026-01-08','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(9, 'Dr. Kavita Rao', 'kavita@medicore.com', 'hash_kavita', 'DOCTOR',
 TO_DATE('2026-01-09','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(10, 'Reception Desk', 'reception@medicore.com', 'hash_reception', 'RECEPTIONIST',
 TO_DATE('2026-01-10','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(11, 'Pharmacy Staff', 'pharmacy@medicore.com', 'hash_pharmacy', 'PHARMACIST',
 TO_DATE('2026-01-11','YYYY-MM-DD'));

INSERT INTO staff
(staff_id, full_name, email, password_hash, role, created_at)
VALUES
(12, 'Accounts Staff', 'accounts@medicore.com', 'hash_accounts', 'ACCOUNTANT',
 TO_DATE('2026-01-12','YYYY-MM-DD'));


-- =========================================================
-- 3. DOCTOR
-- =========================================================

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(1, 2, 1, 'Cardiology');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(2, 3, 2, 'Neurology');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(3, 4, 3, 'Orthopedics');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(4, 5, 2, 'Neurology');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(5, 6, 3, 'Orthopedics');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(6, 7, 3, 'Orthopedics');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(7, 8, 4, 'Pediatrics');

INSERT INTO doctor
(doctor_id, staff_id, department_id, specialization)
VALUES
(8, 9, 4, 'Child Medicine');


-- =========================================================
-- 4. PATIENT
-- =========================================================

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(1, 'Aarav Sharma', TO_DATE('1995-03-15','YYYY-MM-DD'),
 'MALE', '9000000001', 'A+', 0,
 TO_DATE('2026-01-15','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(2, 'Ananya Verma', TO_DATE('1998-07-21','YYYY-MM-DD'),
 'FEMALE', '9000000002', 'B+', 500,
 TO_DATE('2026-01-16','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(3, 'Rohan Patel', TO_DATE('1992-11-10','YYYY-MM-DD'),
 'MALE', '9000000003', 'O+', 0,
 TO_DATE('2026-01-17','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(4, 'Priya Singh', TO_DATE('2000-02-05','YYYY-MM-DD'),
 'FEMALE', '9000000004', 'AB+', 300,
 TO_DATE('2026-01-18','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(5, 'Vikram Mehta', TO_DATE('1988-06-18','YYYY-MM-DD'),
 'MALE', '9000000005', 'A-', 0,
 TO_DATE('2026-01-19','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(6, 'Neha Gupta', TO_DATE('1996-09-25','YYYY-MM-DD'),
 'FEMALE', '9000000006', 'B-', 200,
 TO_DATE('2026-01-20','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(7, 'Aditya Joshi', TO_DATE('1990-12-12','YYYY-MM-DD'),
 'MALE', '9000000007', 'O-', 0,
 TO_DATE('2026-01-21','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(8, 'Kavya Rao', TO_DATE('2005-04-30','YYYY-MM-DD'),
 'FEMALE', '9000000008', 'AB-', 150,
 TO_DATE('2026-01-22','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(9, 'Manish Kumar', TO_DATE('1985-08-14','YYYY-MM-DD'),
 'MALE', '9000000009', 'A+', 0,
 TO_DATE('2026-01-23','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(10, 'Simran Kaur', TO_DATE('1999-10-09','YYYY-MM-DD'),
 'FEMALE', '9000000010', 'B+', 400,
 TO_DATE('2026-01-24','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(11, 'Raj Malhotra', TO_DATE('1991-01-19','YYYY-MM-DD'),
 'MALE', '9000000011', 'O+', 0,
 TO_DATE('2026-01-25','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(12, 'Isha Kapoor', TO_DATE('1997-05-27','YYYY-MM-DD'),
 'FEMALE', '9000000012', 'A+', 250,
 TO_DATE('2026-01-26','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(13, 'Karan Shah', TO_DATE('1989-03-03','YYYY-MM-DD'),
 'MALE', '9000000013', 'B+', 0,
 TO_DATE('2026-01-27','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(14, 'Meera Nair', TO_DATE('1994-07-16','YYYY-MM-DD'),
 'FEMALE', '9000000014', 'O+', 350,
 TO_DATE('2026-01-28','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(15, 'Sahil Agarwal', TO_DATE('1987-11-23','YYYY-MM-DD'),
 'MALE', '9000000015', 'AB+', 0,
 TO_DATE('2026-01-29','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(16, 'Pooja Mishra', TO_DATE('2001-06-11','YYYY-MM-DD'),
 'FEMALE', '9000000016', 'A+', 100,
 TO_DATE('2026-01-30','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(17, 'Nitin Yadav', TO_DATE('1993-09-08','YYYY-MM-DD'),
 'MALE', '9000000017', 'B+', 0,
 TO_DATE('2026-01-31','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(18, 'Riya Das', TO_DATE('1998-12-29','YYYY-MM-DD'),
 'FEMALE', '9000000018', 'O+', 450,
 TO_DATE('2026-02-01','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(19, 'Arjun Soni', TO_DATE('1986-04-17','YYYY-MM-DD'),
 'MALE', '9000000019', 'AB-', 0,
 TO_DATE('2026-02-02','YYYY-MM-DD'));

INSERT INTO patient
(patient_id, full_name, dob, gender, phone, blood_group, balance_due, created_at)
VALUES
(20, 'Tanya Jain', TO_DATE('2003-02-24','YYYY-MM-DD'),
 'FEMALE', '9000000020', 'A-', 200,
 TO_DATE('2026-02-03','YYYY-MM-DD'));


-- =========================================================
-- 5. APPOINTMENT
-- =========================================================

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(1,1,1,TO_DATE('2026-09-10','YYYY-MM-DD'),'09:00',
 'Chest pain','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(2,2,2,TO_DATE('2026-09-10','YYYY-MM-DD'),'10:00',
 'Headache','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(3,3,3,TO_DATE('2026-09-10','YYYY-MM-DD'),'11:00',
 'Knee pain','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(4,4,4,TO_DATE('2026-09-10','YYYY-MM-DD'),'12:00',
 'Fever','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(5,5,5,TO_DATE('2026-09-11','YYYY-MM-DD'),'09:30',
 'Heart checkup','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(6,6,6,TO_DATE('2026-09-11','YYYY-MM-DD'),'10:30',
 'Migraine','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(7,7,7,TO_DATE('2026-09-11','YYYY-MM-DD'),'11:30',
 'Back pain','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(8,8,8,TO_DATE('2026-09-11','YYYY-MM-DD'),'12:30',
 'Child consultation','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(9,9,1,TO_DATE('2026-09-12','YYYY-MM-DD'),'09:00',
 'Blood pressure','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(10,10,2,TO_DATE('2026-09-12','YYYY-MM-DD'),'10:00',
 'Memory problems','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(11,11,3,TO_DATE('2026-09-12','YYYY-MM-DD'),'11:00',
 'Shoulder pain','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(12,12,4,TO_DATE('2026-09-12','YYYY-MM-DD'),'12:00',
 'Cold and fever','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(13,13,5,TO_DATE('2026-09-13','YYYY-MM-DD'),'09:30',
 'Palpitations','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(14,14,6,TO_DATE('2026-09-13','YYYY-MM-DD'),'10:30',
 'Severe headache','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(15,15,7,TO_DATE('2026-09-13','YYYY-MM-DD'),'11:30',
 'Joint pain','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(16,16,8,TO_DATE('2026-09-13','YYYY-MM-DD'),'12:30',
 'Routine checkup','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(17,17,1,TO_DATE('2026-09-14','YYYY-MM-DD'),'09:00',
 'Chest discomfort','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(18,18,2,TO_DATE('2026-09-14','YYYY-MM-DD'),'10:00',
 'Dizziness','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(19,19,3,TO_DATE('2026-09-14','YYYY-MM-DD'),'11:00',
 'Leg pain','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(20,20,4,TO_DATE('2026-09-14','YYYY-MM-DD'),'12:00',
 'Fever and cough','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(21,1,5,TO_DATE('2026-09-15','YYYY-MM-DD'),'09:30',
 'Follow-up','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(22,2,6,TO_DATE('2026-09-15','YYYY-MM-DD'),'10:30',
 'Migraine follow-up','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(23,3,7,TO_DATE('2026-09-15','YYYY-MM-DD'),'11:30',
 'Knee follow-up','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(24,4,8,TO_DATE('2026-09-15','YYYY-MM-DD'),'12:30',
 'Pediatric review','COMPLETED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(25,5,1,TO_DATE('2026-09-16','YYYY-MM-DD'),'09:00',
 'Cardiac review','CANCELLED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(26,6,2,TO_DATE('2026-09-16','YYYY-MM-DD'),'10:00',
 'Neurology review','CANCELLED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(27,7,3,TO_DATE('2026-09-16','YYYY-MM-DD'),'11:00',
 'Back pain review','CANCELLED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(28,8,4,TO_DATE('2026-09-16','YYYY-MM-DD'),'12:00',
 'Child fever','CANCELLED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(29,9,5,TO_DATE('2026-09-17','YYYY-MM-DD'),'09:30',
 'Heart consultation','SCHEDULED');

INSERT INTO appointment
(appointment_id, patient_id, doctor_id, appointment_date,
 appointment_time, reason, status)
VALUES
(30,10,6,TO_DATE('2026-09-17','YYYY-MM-DD'),'10:30',
 'Neurological check','SCHEDULED');


-- =========================================================
-- 6. TREATMENT  (8 rows — one per completed appointment)
-- =========================================================

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(1,17,1,17,'Mild cardiac discomfort','ECG advised and medication prescribed',
 TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(2,18,2,18,'Migraine','Pain management and rest advised',
 TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(3,19,3,19,'Knee strain','Physiotherapy recommended',
 TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(4,20,4,20,'Viral fever','Fluids and medication advised',
 TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(5,1,5,21,'Heart palpitations','Cardiac monitoring advised',
 TO_DATE('2026-09-15','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(6,2,6,22,'Migraine follow-up','Continue prescribed medication',
 TO_DATE('2026-09-15','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(7,3,7,23,'Knee pain','Exercise and physiotherapy advised',
 TO_DATE('2026-09-15','YYYY-MM-DD'));

INSERT INTO treatment
(treatment_id, patient_id, doctor_id, appointment_id,
 diagnosis, treatment_notes, treatment_date)
VALUES
(8,4,8,24,'Child fever','Syrup and hydration advised',
 TO_DATE('2026-09-15','YYYY-MM-DD'));


-- =========================================================
-- 7. MEDICINE
-- =========================================================

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(1,'Paracetamol',20,100,20);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(2,'Ibuprofen',35,80,15);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(3,'Amlodipine',50,60,10);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(4,'Azithromycin',75,50,10);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(5,'Omeprazole',40,90,20);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(6,'Cetirizine',25,70,15);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(7,'Sumatriptan',120,30,5);

INSERT INTO medicine
(medicine_id, medicine_name, unit_price, stock_quantity, reorder_level)
VALUES
(8,'Calcium Tablets',60,100,20);


-- =========================================================
-- 8. PRESCRIPTION
-- =========================================================

INSERT INTO prescription
(prescription_id, treatment_id, prescribed_date)
VALUES
(1,1,TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO prescription
(prescription_id, treatment_id, prescribed_date)
VALUES
(2,2,TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO prescription
(prescription_id, treatment_id, prescribed_date)
VALUES
(3,3,TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO prescription
(prescription_id, treatment_id, prescribed_date)
VALUES
(4,4,TO_DATE('2026-09-14','YYYY-MM-DD'));

INSERT INTO prescription
(prescription_id, treatment_id, prescribed_date)
VALUES
(5,5,TO_DATE('2026-09-15','YYYY-MM-DD'));

INSERT INTO prescription
(prescription_id, treatment_id, prescribed_date)
VALUES
(6,6,TO_DATE('2026-09-15','YYYY-MM-DD'));


-- =========================================================
-- 9. PRESCRIPTION_ITEM
-- =========================================================

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(1,1,1,'500 mg',2,5);

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(2,2,7,'50 mg',1,3);

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(3,3,2,'400 mg',2,5);

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(4,4,1,'500 mg',3,5);

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(5,5,3,'5 mg',1,30);

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(6,6,7,'50 mg',1,5);

INSERT INTO prescription_item
(prescription_item_id, prescription_id, medicine_id,
 dosage, frequency_per_day, duration_days)
VALUES
(7,6,5,'20 mg',1,10);


-- =========================================================
-- 10. ROOM
-- =========================================================

INSERT INTO room
(room_id, room_number, ward_type)
VALUES
(1,'101','General');

INSERT INTO room
(room_id, room_number, ward_type)
VALUES
(2,'102','General');

INSERT INTO room
(room_id, room_number, ward_type)
VALUES
(3,'201','ICU');

INSERT INTO room
(room_id, room_number, ward_type)
VALUES
(4,'202','Private');

INSERT INTO room
(room_id, room_number, ward_type)
VALUES
(5,'301','Pediatric');


-- =========================================================
-- 11. BED
-- =========================================================

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(1,1,1);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(1,2,0);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(2,1,1);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(2,2,0);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(3,1,1);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(3,2,1);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(4,1,0);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(4,2,1);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(5,1,0);

INSERT INTO bed
(room_id, bed_number, is_occupied)
VALUES
(5,2,1);


-- =========================================================
-- 12. ADMISSION
-- =========================================================

INSERT INTO admission
(admission_id, patient_id, room_id, bed_number,
 admission_date, discharge_date)
VALUES
(1,1,1,1,
 TO_DATE('2026-09-01','YYYY-MM-DD'),
 TO_DATE('2026-09-04','YYYY-MM-DD'));

INSERT INTO admission
(admission_id, patient_id, room_id, bed_number,
 admission_date, discharge_date)
VALUES
(2,3,2,1,
 TO_DATE('2026-09-02','YYYY-MM-DD'),
 TO_DATE('2026-09-06','YYYY-MM-DD'));

INSERT INTO admission
(admission_id, patient_id, room_id, bed_number,
 admission_date, discharge_date)
VALUES
(3,5,3,1,
 TO_DATE('2026-09-03','YYYY-MM-DD'),
 NULL);

INSERT INTO admission
(admission_id, patient_id, room_id, bed_number,
 admission_date, discharge_date)
VALUES
(4,8,4,2,
 TO_DATE('2026-09-05','YYYY-MM-DD'),
 TO_DATE('2026-09-07','YYYY-MM-DD'));

INSERT INTO admission
(admission_id, patient_id, room_id, bed_number,
 admission_date, discharge_date)
VALUES
(5,12,5,2,
 TO_DATE('2026-09-06','YYYY-MM-DD'),
 NULL);


-- =========================================================
-- 13. LAB_TEST
-- =========================================================

INSERT INTO lab_test
(lab_test_id, patient_id, doctor_id, test_type,
 requested_date, result, result_date, status)
VALUES
(1,1,1,'ECG',
 TO_DATE('2026-09-01','YYYY-MM-DD'),
 'Normal',
 TO_DATE('2026-09-01','YYYY-MM-DD'),
 'COMPLETED');

INSERT INTO lab_test
(lab_test_id, patient_id, doctor_id, test_type,
 requested_date, result, result_date, status)
VALUES
(2,2,2,'MRI Brain',
 TO_DATE('2026-09-02','YYYY-MM-DD'),
 'No abnormality detected',
 TO_DATE('2026-09-03','YYYY-MM-DD'),
 'COMPLETED');

INSERT INTO lab_test
(lab_test_id, patient_id, doctor_id, test_type,
 requested_date, result, result_date, status)
VALUES
(3,3,3,'X-Ray Knee',
 TO_DATE('2026-09-03','YYYY-MM-DD'),
 'Minor inflammation',
 TO_DATE('2026-09-03','YYYY-MM-DD'),
 'COMPLETED');

INSERT INTO lab_test
(lab_test_id, patient_id, doctor_id, test_type,
 requested_date, result, result_date, status)
VALUES
(4,5,1,'Blood Test',
 TO_DATE('2026-09-04','YYYY-MM-DD'),
 'Normal',
 TO_DATE('2026-09-04','YYYY-MM-DD'),
 'COMPLETED');

INSERT INTO lab_test
(lab_test_id, patient_id, doctor_id, test_type,
 requested_date, result, result_date, status)
VALUES
(5,10,2,'CT Scan',
 TO_DATE('2026-09-05','YYYY-MM-DD'),
 'Normal',
 TO_DATE('2026-09-06','YYYY-MM-DD'),
 'COMPLETED');

INSERT INTO lab_test
(lab_test_id, patient_id, doctor_id, test_type,
 requested_date, result, result_date, status)
VALUES
(6,15,3,'Joint X-Ray',
 TO_DATE('2026-09-06','YYYY-MM-DD'),
 'Mild joint inflammation',
 TO_DATE('2026-09-06','YYYY-MM-DD'),
 'COMPLETED');


-- =========================================================
-- 14. BILL
-- =========================================================

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(1,1,TO_DATE('2026-09-01','YYYY-MM-DD'),2500);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(2,2,TO_DATE('2026-09-02','YYYY-MM-DD'),1800);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(3,3,TO_DATE('2026-09-03','YYYY-MM-DD'),3200);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(4,4,TO_DATE('2026-09-04','YYYY-MM-DD'),1500);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(5,5,TO_DATE('2026-09-05','YYYY-MM-DD'),4500);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(6,6,TO_DATE('2026-09-06','YYYY-MM-DD'),2100);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(7,7,TO_DATE('2026-09-07','YYYY-MM-DD'),1700);

INSERT INTO bill
(bill_id, patient_id, bill_date, total_amount)
VALUES
(8,8,TO_DATE('2026-09-08','YYYY-MM-DD'),1200);


-- =========================================================
-- 15. BILL_ITEM
-- =========================================================

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(1,1,'CONSULTATION','Cardiology consultation',500);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(2,1,'LAB_TEST','ECG test',500);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(3,1,'MEDICINE','Medicines',1500);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(4,2,'CONSULTATION','Neurology consultation',600);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(5,2,'LAB_TEST','MRI Brain',1000);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(6,2,'MEDICINE','Migraine medicine',200);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(7,3,'CONSULTATION','Orthopedic consultation',700);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(8,3,'LAB_TEST','Knee X-Ray',1000);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(9,3,'TREATMENT','Physiotherapy',1500);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(10,4,'CONSULTATION','Pediatric consultation',500);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(11,4,'MEDICINE','Medicines',1000);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(12,5,'CONSULTATION','Cardiology follow-up',800);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(13,5,'LAB_TEST','Blood Test',700);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(14,5,'TREATMENT','Cardiac care and monitoring',3000);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(15,6,'CONSULTATION','Neurology consultation',600);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(16,6,'LAB_TEST','Follow-up test',1000);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(17,6,'MEDICINE','Medicines',500);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(18,7,'CONSULTATION','Orthopedic consultation',700);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(19,7,'TREATMENT','Physiotherapy session',1000);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(20,8,'CONSULTATION','Pediatric consultation',400);

INSERT INTO bill_item
(bill_item_id, bill_id, item_type, description, amount)
VALUES
(21,8,'MEDICINE','Syrup and supplements',800);


-- =========================================================
-- 16. PAYMENT
-- =========================================================

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(1,1,TO_DATE('2026-09-01','YYYY-MM-DD'),2500,'UPI');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(2,2,TO_DATE('2026-09-02','YYYY-MM-DD'),1300,'CASH');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(3,3,TO_DATE('2026-09-03','YYYY-MM-DD'),3200,'CARD');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(4,4,TO_DATE('2026-09-04','YYYY-MM-DD'),1200,'UPI');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(5,5,TO_DATE('2026-09-05','YYYY-MM-DD'),4500,'INSURANCE');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(6,6,TO_DATE('2026-09-06','YYYY-MM-DD'),1900,'CASH');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(7,7,TO_DATE('2026-09-07','YYYY-MM-DD'),1700,'CARD');

INSERT INTO payment
(payment_id, bill_id, payment_date, amount_paid, payment_mode)
VALUES
(8,8,TO_DATE('2026-09-08','YYYY-MM-DD'),1050,'UPI');


-- =========================================================
-- 17. AUDIT_LOG
-- =========================================================

INSERT INTO audit_log
(audit_id, table_name, record_id, operation,
 old_data, changed_by, changed_at)
VALUES
(1,'PATIENT',1,'UPDATE',
 'old_balance_due:500|new_balance_due:0 (paid via bill 1)','admin',
 TO_DATE('2026-09-01','YYYY-MM-DD'));

INSERT INTO audit_log
(audit_id, table_name, record_id, operation,
 old_data, changed_by, changed_at)
VALUES
(2,'BILL',2,'UPDATE',
 'total_amount:2000','accounts',
 TO_DATE('2026-09-02','YYYY-MM-DD'));

INSERT INTO audit_log
(audit_id, table_name, record_id, operation,
 old_data, changed_by, changed_at)
VALUES
(3,'APPOINTMENT',25,'UPDATE',
 'status:SCHEDULED','reception',
 TO_DATE('2026-09-03','YYYY-MM-DD'));

INSERT INTO audit_log
(audit_id, table_name, record_id, operation,
 old_data, changed_by, changed_at)
VALUES
(4,'MEDICINE',4,'UPDATE',
 'old_stock:20|new_stock:50','pharmacy',
 TO_DATE('2026-09-04','YYYY-MM-DD'));


-- =========================================================
-- 18. USER_SESSION
-- =========================================================

INSERT INTO user_session
(session_id, staff_id, login_time, logout_time)
VALUES
(1,1,
 TO_DATE('2026-09-10 08:00','YYYY-MM-DD HH24:MI'),
 TO_DATE('2026-09-10 17:00','YYYY-MM-DD HH24:MI'));

INSERT INTO user_session
(session_id, staff_id, login_time, logout_time)
VALUES
(2,10,
 TO_DATE('2026-09-10 08:30','YYYY-MM-DD HH24:MI'),
 TO_DATE('2026-09-10 16:30','YYYY-MM-DD HH24:MI'));

INSERT INTO user_session
(session_id, staff_id, login_time, logout_time)
VALUES
(3,11,
 TO_DATE('2026-09-10 09:00','YYYY-MM-DD HH24:MI'),
 TO_DATE('2026-09-10 18:00','YYYY-MM-DD HH24:MI'));

INSERT INTO user_session
(session_id, staff_id, login_time, logout_time)
VALUES
(4,12,
 TO_DATE('2026-09-10 09:30','YYYY-MM-DD HH24:MI'),
 TO_DATE('2026-09-10 17:30','YYYY-MM-DD HH24:MI'));


-- =========================================================
-- 19. DOCTOR_SCHEDULE
-- =========================================================

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(1,1,'MONDAY','09:00','13:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(2,2,'TUESDAY','10:00','14:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(3,3,'WEDNESDAY','09:00','13:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(4,4,'THURSDAY','10:00','14:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(5,5,'FRIDAY','09:00','13:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(6,6,'SATURDAY','10:00','14:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(7,7,'MONDAY','11:00','15:00');

INSERT INTO doctor_schedule
(schedule_id, doctor_id, day_of_week, start_time, end_time)
VALUES
(8,8,'WEDNESDAY','11:00','15:00');


-- =========================================================
-- 20. NOTIFICATION
-- =========================================================

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(1,1,10,'Your appointment is scheduled for tomorrow.',
 'APPOINTMENT',0,
 TO_DATE('2026-09-09','YYYY-MM-DD'));

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(2,2,10,'Your MRI report is available.',
 'LAB_RESULT',1,
 TO_DATE('2026-09-03','YYYY-MM-DD'));

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(3,3,10,'Your follow-up appointment is confirmed.',
 'APPOINTMENT',0,
 TO_DATE('2026-09-10','YYYY-MM-DD'));

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(4,4,10,'Please bring previous medical reports.',
 'REMINDER',0,
 TO_DATE('2026-09-10','YYYY-MM-DD'));

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(5,5,10,'Your cardiac test report is ready.',
 'LAB_RESULT',1,
 TO_DATE('2026-09-05','YYYY-MM-DD'));

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(6,6,11,'Please continue your prescribed medication.',
 'MEDICATION',0,
 TO_DATE('2026-09-06','YYYY-MM-DD'));

INSERT INTO notification
(notification_id, patient_id, staff_id, message,
 notification_type, is_read, created_at)
VALUES
(7,8,10,'Pediatric follow-up is due next week.',
 'REMINDER',0,
 TO_DATE('2026-09-08','YYYY-MM-DD'));


-- =========================================================
-- =========================================================
-- FINAL COMMIT
-- =========================================================

COMMIT;

-- =========================================================
-- FIX UPS
-- =========================================================

-- 1. Reset identity sequences to current max IDs
ALTER TABLE department        MODIFY (department_id        GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE staff             MODIFY (staff_id             GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE doctor            MODIFY (doctor_id            GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE patient           MODIFY (patient_id           GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE appointment       MODIFY (appointment_id       GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE treatment         MODIFY (treatment_id         GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE medicine          MODIFY (medicine_id          GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE prescription      MODIFY (prescription_id      GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE prescription_item MODIFY (prescription_item_id GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE room              MODIFY (room_id              GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE admission         MODIFY (admission_id         GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE lab_test          MODIFY (lab_test_id          GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE bill              MODIFY (bill_id              GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE bill_item         MODIFY (bill_item_id         GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE payment           MODIFY (payment_id           GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE audit_log         MODIFY (audit_id             GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE user_session      MODIFY (session_id           GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE doctor_schedule   MODIFY (schedule_id          GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE notification      MODIFY (notification_id      GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));

-- 2. Recompute bed occupancy from active admissions
UPDATE bed SET is_occupied = 0;

UPDATE bed b
SET is_occupied = 1
WHERE EXISTS (
    SELECT 1
    FROM admission a
    WHERE a.room_id = b.room_id
      AND a.bed_number = b.bed_number
      AND a.discharge_date IS NULL
);

COMMIT;

-- =========================================================
-- END OF MEDICORE SEED
-- =========================================================