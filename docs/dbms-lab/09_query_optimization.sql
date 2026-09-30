SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 09: Query Optimization and Heuristic Rewriting
-- =============================================================================
-- Purpose: Implements Phase 4f of the Blueprint — Demonstrates Relational Algebra
--          Heuristic Optimization:
--          1. Selection Pushdown (Filtering rows before JOINs)
--          2. Projection Pushdown (Eliminating unneeded columns early)
--          3. Subquery Unnesting vs IN subqueries
--          4. EXPLAIN PLAN cost comparison between Naive and Optimized queries
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. THEORETICAL FOUNDATION: HEURISTIC OPTIMIZATION RULES
PROMPT =========================================================================
PROMPT Rule 1: Perform Selection (σ) as early as possible (Selection Pushdown)
PROMPT         σ_{cond}(R ⋈ S) ≡ (σ_{cond}(R)) ⋈ S
PROMPT         Reduces cardinality of intermediate tables before expensive join loops.
PROMPT
PROMPT Rule 2: Perform Projection (π) as early as possible (Projection Pushdown)
PROMPT         Drops non-essential columns early, reducing row size and buffer cache usage.
PROMPT =========================================================================


PROMPT =========================================================================
PROMPT 2. SCENARIO: Completed Appointments for Cardiology Patients
PROMPT =========================================================================

-- VERSION A: NAIVE QUERY (Cartesian / Late Filter)
-- Joins all tables unconditionally first, and applies the filter on Department and Status last.
PROMPT === VERSION A: Naive Query Execution Plan ===
EXPLAIN PLAN SET STATEMENT_ID = 'NAIVE_QUERY' FOR
SELECT p.patient_id, p.full_name, a.appointment_id, s.full_name AS doctor_name, d.department_name
FROM patient p, appointment a, doctor doc, staff s, department d
WHERE p.patient_id = a.patient_id
  AND a.doctor_id = doc.doctor_id
  AND doc.staff_id = s.staff_id
  AND doc.department_id = d.department_id
  AND a.status = 'COMPLETED'
  AND d.department_name = 'Cardiology';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'NAIVE_QUERY', 'TYPICAL'));


-- VERSION B: OPTIMIZED QUERY (Heuristic Selection and Projection Pushdown)
-- Filters Cardiology doctors and COMPLETED appointments FIRST, using modern explicit ANSI JOINs.
PROMPT === VERSION B: Optimized Query (Selection Pushdown via Filtered Inline Views) ===
EXPLAIN PLAN SET STATEMENT_ID = 'OPTIMIZED_QUERY' FOR
WITH cardio_doctors AS (
    -- Selection Pushdown: Filter department='Cardiology' before joining
    SELECT doc.doctor_id, st.full_name AS doctor_name
    FROM doctor doc
    JOIN staff st ON doc.staff_id = st.staff_id
    JOIN department d ON doc.department_id = d.department_id
    WHERE d.department_name = 'Cardiology'
),
completed_appts AS (
    -- Selection Pushdown: Filter status='COMPLETED' before joining
    SELECT appointment_id, patient_id, doctor_id, appointment_date
    FROM appointment
    WHERE status = 'COMPLETED'
)
SELECT p.patient_id, p.full_name, ca.appointment_id, cd.doctor_name
FROM completed_appts ca
JOIN cardio_doctors cd ON ca.doctor_id = cd.doctor_id
JOIN patient p ON ca.patient_id = p.patient_id;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'OPTIMIZED_QUERY', 'TYPICAL'));


PROMPT =========================================================================
PROMPT 3. SUBQUERY OPTIMIZATION: Correlated Subquery vs JOIN
PROMPT =========================================================================

-- Case 3a: Non-optimized correlated subquery with row-by-row re-evaluation
PROMPT === Case 3a: Correlated Subquery ===
EXPLAIN PLAN SET STATEMENT_ID = 'CORRELATED_SUBQ' FOR
SELECT p.patient_id, p.full_name
FROM patient p
WHERE (
    SELECT COUNT(*) 
    FROM appointment a 
    WHERE a.patient_id = p.patient_id AND a.status = 'SCHEDULED'
) > 0;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'CORRELATED_SUBQ', 'BASIC +COST'));

-- Case 3b: Optimized query using semi-join (EXISTS)
PROMPT === Case 3b: Semi-Join Rewrite (EXISTS) ===
EXPLAIN PLAN SET STATEMENT_ID = 'SEMI_JOIN_EXISTS' FOR
SELECT p.patient_id, p.full_name
FROM patient p
WHERE EXISTS (
    SELECT 1 
    FROM appointment a 
    WHERE a.patient_id = p.patient_id AND a.status = 'SCHEDULED'
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'SEMI_JOIN_EXISTS', 'BASIC +COST'));


PROMPT =========================================================================
PROMPT Query Optimization Script 09 Complete!
PROMPT =========================================================================
