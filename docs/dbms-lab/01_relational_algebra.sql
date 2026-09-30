SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 01: Relational Algebra Operations
-- =============================================================================
-- Purpose: Demonstrates how fundamental relational algebra operations map directly
--          to SQL queries running against live, seeded MediCore tables.
-- Operations covered:
--   1. Selection (σ)
--   2. Projection (π)
--   3. Cartesian Product (×)
--   4. Natural Join and Theta Join (⋈)
--   5. Set Union (∪)
--   6. Set Difference (−)
--   7. Set Intersection (∩)
--   8. Relational Division (÷)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SELECTION (σ)
-- Concept: σ_{condition}(Relation)
-- Filter rows that satisfy a specific predicate.
-- Real-world query: Find all patients who have an outstanding balance due > 0.
-- -----------------------------------------------------------------------------
PROMPT === 1. SELECTION: Patients with outstanding balance (σ_{balance_due > 0}(PATIENT)) ===
SELECT patient_id, full_name, phone, balance_due
FROM patient
WHERE balance_due > 0;

-- Another Selection: Doctors specialized in 'Neurology'
PROMPT === SELECTION: Doctors in Neurology (σ_{specialization='Neurology'}(DOCTOR)) ===
SELECT doctor_id, specialization
FROM doctor
WHERE specialization = 'Neurology';


-- -----------------------------------------------------------------------------
-- 2. PROJECTION (π)
-- Concept: π_{attributes}(Relation)
-- Extract specific columns, eliminating duplicates if duplicate suppression is applied.
-- Real-world query: List distinct ward types available across hospital rooms.
-- -----------------------------------------------------------------------------
PROMPT === 2. PROJECTION: Distinct ward types (π_{ward_type}(ROOM)) ===
SELECT DISTINCT ward_type
FROM room;

-- Projection: Doctor names and their hospital contact emails
PROMPT === PROJECTION: Doctor names and emails (π_{full_name, email}(STAFF)) ===
SELECT full_name, email
FROM staff
WHERE role = 'DOCTOR';


-- -----------------------------------------------------------------------------
-- 3. CARTESIAN PRODUCT (CROSS JOIN) (×)
-- Concept: Relation1 × Relation2
-- Generates all possible pairings between tuples of two relations.
-- Real-world query: Matrix of all departments paired with all ward types.
-- -----------------------------------------------------------------------------
PROMPT === 3. CARTESIAN PRODUCT: Departments × Ward Types (DEPARTMENT × ROOM) ===
SELECT d.department_name, r.ward_type
FROM department d
CROSS JOIN (SELECT DISTINCT ward_type FROM room) r
ORDER BY d.department_name, r.ward_type;


-- -----------------------------------------------------------------------------
-- 4. THETA JOIN and EQUI-JOIN (⋈_{condition})
-- Concept: Relation1 ⋈_{R1.attr = R2.attr} Relation2
-- Pairs tuples matching the join predicate.
-- Real-world query: Join Appointments with Doctors and Patients to show details.
-- -----------------------------------------------------------------------------
PROMPT === 4. EQUI-JOIN: Appointment details with Patient and Doctor names ===
SELECT a.appointment_id,
       p.full_name AS patient_name,
       s.full_name AS doctor_name,
       doc.specialization,
       TO_CHAR(a.appointment_date, 'YYYY-MM-DD') AS appt_date,
       a.appointment_time,
       a.status
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN doctor doc ON a.doctor_id = doc.doctor_id
JOIN staff s ON doc.staff_id = s.staff_id
ORDER BY a.appointment_id;


-- -----------------------------------------------------------------------------
-- 5. SET UNION (∪)
-- Concept: Relation1 ∪ Relation2 (Union-compatible relations)
-- Combines tuples from two relations, eliminating duplicates.
-- Real-world query: Combine all contact phone numbers (Patients + Staff).
-- -----------------------------------------------------------------------------
PROMPT === 5. UNION: Directory of all contact parties (Patients + Staff) ===
SELECT full_name, phone, 'PATIENT' AS person_type
FROM patient
UNION
SELECT full_name, 'N/A' AS phone, role AS person_type
FROM staff
ORDER BY person_type, full_name;


-- -----------------------------------------------------------------------------
-- 6. SET INTERSECTION (∩)
-- Concept: Relation1 ∩ Relation2
-- Tuples present in both relations.
-- Real-world query: Doctors who have BOTH scheduled appointments AND recorded treatments.
-- -----------------------------------------------------------------------------
PROMPT === 6. INTERSECT: Doctors with both appointments AND recorded treatments ===
SELECT doctor_id
FROM appointment
INTERSECT
SELECT doctor_id
FROM treatment;


-- -----------------------------------------------------------------------------
-- 7. SET DIFFERENCE (MINUS) (−)
-- Concept: Relation1 − Relation2
-- Tuples present in Relation1 but NOT in Relation2.
-- Real-world query: Patients who are registered but have NEVER booked an appointment.
-- -----------------------------------------------------------------------------
PROMPT === 7. SET DIFFERENCE (MINUS): Patients with NO appointments ===
SELECT patient_id, full_name
FROM patient
WHERE patient_id IN (
    SELECT patient_id FROM patient
    MINUS
    SELECT patient_id FROM appointment
);


-- -----------------------------------------------------------------------------
-- 8. RELATIONAL DIVISION (÷)
-- Concept: Relation1(X, Y) ÷ Relation2(Y)
-- Finds tuples in X associated with ALL tuples in Relation2.
-- Real-world query: Find patients who have been treated by ALL doctors in Department 2 (Neurology).
-- Formulated in SQL via Double Negation (NOT EXISTS ... NOT EXISTS):
-- "Find Patient P such that there does NOT exist a Neurology Doctor D for whom
--  there does NOT exist a Treatment connecting P to D."
-- -----------------------------------------------------------------------------
PROMPT === 8. DIVISION: Patients treated by ALL Neurology Doctors (Double Negation) ===
SELECT p.patient_id, p.full_name
FROM patient p
WHERE NOT EXISTS (
    -- Set of all Neurology doctors
    SELECT d.doctor_id
    FROM doctor d
    WHERE d.department_id = 2 -- Neurology
    MINUS
    -- Set of doctors who have treated this specific patient
    SELECT t.doctor_id
    FROM treatment t
    WHERE t.patient_id = p.patient_id
);

-- =============================================================================
-- End of Script 01
-- =============================================================================
