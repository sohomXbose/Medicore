SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 02: Normalization Proof (UNF -> 1NF -> 2NF -> 3NF -> BCNF)
-- =============================================================================
-- Purpose: Demonstrates the database normalization theory from Blueprint §5.
--          Constructs an unnormalized flat table (UNF/1NF) with redundancy and
--          anomalies, and compares it directly with the decomposed BCNF schema.
-- =============================================================================

PROMPT =========================================================================
PROMPT STEP 1: Create an Unnormalized Patient Record Table (UNF / 1NF)
PROMPT =========================================================================

-- Clean up demo table if it already exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE unnormalized_patient_record PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- The Unnormalized Flat Schema:
-- Stores patient personal details, doctor details, department, prescribed medicine,
-- and billing all packed in a single table.
CREATE TABLE unnormalized_patient_record (
    record_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id      NUMBER,
    patient_name    VARCHAR2(100),
    doctor_id       NUMBER,
    doctor_name     VARCHAR2(100),
    department_name VARCHAR2(100),
    medicine_id     NUMBER,
    medicine_name   VARCHAR2(100),
    dosage          VARCHAR2(50),
    bill_id         NUMBER,
    bill_amount     NUMBER(10,2)
);

-- Seed with representative rows demonstrating anomalies
INSERT INTO unnormalized_patient_record 
(patient_id, patient_name, doctor_id, doctor_name, department_name, medicine_id, medicine_name, dosage, bill_id, bill_amount)
VALUES (1, 'Aarav Sharma', 1, 'Dr. Rahul Sharma', 'Cardiology', 1, 'Atorvastatin', '20 mg', 101, 1500.00);

INSERT INTO unnormalized_patient_record 
(patient_id, patient_name, doctor_id, doctor_name, department_name, medicine_id, medicine_name, dosage, bill_id, bill_amount)
VALUES (1, 'Aarav Sharma', 1, 'Dr. Rahul Sharma', 'Cardiology', 3, 'Aspirin', '75 mg', 101, 1500.00);

INSERT INTO unnormalized_patient_record 
(patient_id, patient_name, doctor_id, doctor_name, department_name, medicine_id, medicine_name, dosage, bill_id, bill_amount)
VALUES (2, 'Ananya Verma', 2, 'Dr. Priya Verma', 'Neurology', 4, 'Gabapentin', '300 mg', 102, 2200.00);

INSERT INTO unnormalized_patient_record 
(patient_id, patient_name, doctor_id, doctor_name, department_name, medicine_id, medicine_name, dosage, bill_id, bill_amount)
VALUES (3, 'Rohan Joshi', 1, 'Dr. Rahul Sharma', 'Cardiology', 1, 'Atorvastatin', '10 mg', 103, 850.00);

COMMIT;

PROMPT
PROMPT Current contents of UNNORMALIZED table (notice massive duplicate text):
SELECT record_id, patient_id, patient_name, doctor_name, department_name, medicine_name, dosage, bill_id, bill_amount
FROM unnormalized_patient_record;

PROMPT
PROMPT =========================================================================
PROMPT STEP 2: Anomaly Demonstration in the Unnormalized Table
PROMPT =========================================================================

-- 1. Redundancy: Doctor name and Department are duplicated for every medicine prescribed.
-- 2. Update Anomaly:
-- If Dr. Rahul Sharma transfers from 'Cardiology' to 'Cardiac Surgery',
-- multiple rows must be updated. If an update misses one row, data becomes inconsistent!
PROMPT === Demonstration of Update Anomaly ===
UPDATE unnormalized_patient_record
SET department_name = 'Cardiac Surgery'
WHERE record_id = 1; -- Accidentally updated only one row

PROMPT Notice inconsistent department names for the SAME Doctor ID (1):
SELECT record_id, doctor_id, doctor_name, department_name 
FROM unnormalized_patient_record
WHERE doctor_id = 1;

-- Rollback the anomaly demo update
ROLLBACK;

-- 3. Insertion Anomaly:
-- You cannot record a new Medicine or new Doctor without an active patient prescription.
-- 4. Deletion Anomaly:
-- Deleting Patient 2 (Ananya Verma) completely erases the existence of Gabapentin (Medicine 4)
-- and Dr. Priya Verma from our records!

PROMPT
PROMPT =========================================================================
PROMPT STEP 3: Normalization Proof Breakdown (FDs and Decomposition)
PROMPT =========================================================================
PROMPT
PROMPT Functional Dependencies (FDs):
PROMPT   FD1: patient_id   -> patient_name
PROMPT   FD2: doctor_id    -> doctor_name, department_id
PROMPT   FD3: department_id-> department_name
PROMPT   FD4: medicine_id  -> medicine_name
PROMPT   FD5: bill_id      -> bill_amount
PROMPT   FD6: (patient_id, medicine_id) -> dosage
PROMPT
PROMPT Decomposition Stages:
PROMPT   1NF  : Multi-valued attributes removed; each prescription row is atomic.
PROMPT   2NF  : Partial dependencies eliminated (Attributes depending on part of composite key).
PROMPT          -> Split off PATIENT, DOCTOR, MEDICINE, BILL.
PROMPT   3NF  : Transitive dependencies removed:
PROMPT          doctor_id -> department_id -> department_name (Split off DEPARTMENT).
PROMPT   BCNF : Every determinant is a candidate key.

PROMPT
PROMPT =========================================================================
PROMPT STEP 4: Querying the Decomposed, Lossless BCNF Schema (Live MediCore Tables)
PROMPT =========================================================================

-- Reconstructing the complete clinical record from the 6 normalized tables
-- via lossless relational join:
SELECT p.patient_id,
       p.full_name AS patient_name,
       doc.doctor_id,
       s.full_name AS doctor_name,
       d.department_name,
       m.medicine_id,
       m.medicine_name,
       pi.dosage,
       b.bill_id,
       b.total_amount AS bill_amount
FROM patient p
JOIN treatment t ON p.patient_id = t.patient_id
JOIN doctor doc ON t.doctor_id = doc.doctor_id
JOIN staff s ON doc.staff_id = s.staff_id
JOIN department d ON doc.department_id = d.department_id
JOIN prescription pr ON t.treatment_id = pr.treatment_id
JOIN prescription_item pi ON pr.prescription_id = pi.prescription_id
JOIN medicine m ON pi.medicine_id = m.medicine_id
LEFT JOIN bill b ON p.patient_id = b.patient_id
WHERE ROWNUM <= 10;

PROMPT
PROMPT =========================================================================
PROMPT CONCLUSION:
PROMPT The normalized BCNF schema eliminates:
PROMPT   1. Redundant Doctor/Department/Medicine string storage.
PROMPT   2. Update Anomalies (Department name stored in exactly 1 row in DEPARTMENT).
PROMPT   3. Insertion Anomalies (Doctors and Medicines exist independently).
PROMPT   4. Deletion Anomalies (Removing a patient preserves medical and doctor data).
PROMPT =========================================================================

-- Clean up demo table
DROP TABLE unnormalized_patient_record PURGE;
