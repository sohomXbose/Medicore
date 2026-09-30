SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 03: SQL Queries Library
-- =============================================================================
-- Purpose: Covers Unit 3 of the syllabus — complex multi-table JOINs,
--          aggregations (GROUP BY / HAVING), nested subqueries (correlated,
--          scalar, membership), and analytic/window functions on live data.
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. MULTI-TABLE JOINS (INNER, LEFT OUTER, FULL OUTER)
PROMPT =========================================================================

-- 1a. Three-table INNER JOIN: Patients with scheduled appointments and their assigned doctors
PROMPT === 1a. Inner Join: Patient, Appointment, Doctor and Staff ===
SELECT a.appointment_id,
       p.full_name AS patient_name,
       p.phone AS patient_phone,
       s.full_name AS doctor_name,
       d.specialization,
       TO_CHAR(a.appointment_date, 'YYYY-MM-DD') AS appt_date,
       a.appointment_time,
       a.status
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN staff s ON d.staff_id = s.staff_id
ORDER BY a.appointment_date, a.appointment_time;

-- 1b. LEFT OUTER JOIN: All patients and their active admission / bed status (even if not admitted)
PROMPT === 1b. Left Outer Join: All Patients and their Bed Admissions (includes non-admitted) ===
SELECT p.patient_id,
       p.full_name,
       NVL(TO_CHAR(ad.room_id), 'Not Admitted') AS room_id,
       NVL(TO_CHAR(ad.bed_number), '-') AS bed_number,
       NVL(TO_CHAR(ad.admission_date, 'YYYY-MM-DD'), '-') AS admitted_on
FROM patient p
LEFT JOIN admission ad ON p.patient_id = ad.patient_id AND ad.discharge_date IS NULL
ORDER BY p.patient_id;


PROMPT =========================================================================
PROMPT 2. AGGREGATIONS WITH GROUP BY AND HAVING
PROMPT =========================================================================

-- 2a. Total Revenue and Bill Count per Department
PROMPT === 2a. Revenue Aggregation by Department (JOIN + GROUP BY) ===
SELECT dept.department_name,
       COUNT(DISTINCT b.bill_id) AS total_bills,
       NVL(SUM(b.total_amount), 0) AS total_billed_amount,
       NVL(SUM(p.amount_paid), 0) AS total_collected_revenue
FROM department dept
JOIN doctor d ON dept.department_id = d.department_id
JOIN treatment t ON d.doctor_id = t.doctor_id
JOIN patient pt ON t.patient_id = pt.patient_id
JOIN bill b ON pt.patient_id = b.patient_id
LEFT JOIN payment p ON b.bill_id = p.bill_id
GROUP BY dept.department_name
ORDER BY total_collected_revenue DESC;

-- 2b. HAVING Clause: Departments with more than 5 scheduled/completed appointments
PROMPT === 2b. HAVING Filter: Departments with high appointment volume (> 5) ===
SELECT dept.department_name,
       COUNT(a.appointment_id) AS appointment_count
FROM department dept
JOIN doctor d ON dept.department_id = d.department_id
JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY dept.department_name
HAVING COUNT(a.appointment_id) >= 5
ORDER BY appointment_count DESC;

-- 2c. Medicine Stock Reorder Alert: Stock quantity compared to reorder level
PROMPT === 2c. Medicines at or below reorder threshold ===
SELECT medicine_id,
       medicine_name,
       stock_quantity,
       reorder_level,
       (reorder_level - stock_quantity) AS units_needed
FROM medicine
WHERE stock_quantity <= reorder_level
ORDER BY units_needed DESC;


PROMPT =========================================================================
PROMPT 3. NESTED AND SUBQUERIES (SCALAR, IN, CORRELATED)
PROMPT =========================================================================

-- 3a. Scalar Subquery: Find patients whose total bill is ABOVE the average hospital bill
PROMPT === 3a. Scalar Subquery: Patients billed above hospital average ===
SELECT b.bill_id,
       p.full_name AS patient_name,
       b.total_amount
FROM bill b
JOIN patient p ON b.patient_id = p.patient_id
WHERE b.total_amount > (
    SELECT AVG(total_amount) FROM bill
)
ORDER BY b.total_amount DESC;

-- 3b. Correlated Subquery with EXISTS: Doctors who have treated at least one admitted patient
PROMPT === 3b. Correlated Subquery (EXISTS): Doctors treating admitted inpatients ===
SELECT d.doctor_id, s.full_name, d.specialization
FROM doctor d
JOIN staff s ON d.staff_id = s.staff_id
WHERE EXISTS (
    SELECT 1
    FROM treatment t
    JOIN admission adm ON t.patient_id = adm.patient_id
    WHERE t.doctor_id = d.doctor_id
);

-- 3c. NOT IN Subquery: Medicines that have NEVER been prescribed
PROMPT === 3c. NOT IN Subquery: Unused / Stagnant Medicines in Inventory ===
SELECT medicine_id, medicine_name, unit_price, stock_quantity
FROM medicine
WHERE medicine_id NOT IN (
    SELECT DISTINCT medicine_id FROM prescription_item
);


PROMPT =========================================================================
PROMPT 4. ANALYTIC AND WINDOW FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK)
PROMPT =========================================================================

-- 4a. Ranking Doctors within their department by number of completed appointments
PROMPT === 4a. Window Function: Doctor ranking within department by appointment count ===
SELECT s.full_name AS doctor_name,
       dept.department_name,
       COUNT(a.appointment_id) AS total_appts,
       DENSE_RANK() OVER (
           PARTITION BY dept.department_id 
           ORDER BY COUNT(a.appointment_id) DESC
       ) AS dept_rank
FROM doctor d
JOIN staff s ON d.staff_id = s.staff_id
JOIN department dept ON d.department_id = dept.department_id
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, s.full_name, dept.department_id, dept.department_name
ORDER BY dept.department_name, dept_rank;

-- =============================================================================
-- End of Script 03
-- =============================================================================
