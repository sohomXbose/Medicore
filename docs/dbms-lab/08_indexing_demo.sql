SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 08: B-Tree Indexing and EXPLAIN PLAN Cost Analysis
-- =============================================================================
-- Purpose: Implements Phase 4e of the Blueprint — Demonstrates the physical storage
--          layer, B-Tree index creation, and compares the Oracle Cost-Based Optimizer
--          (CBO) execution plan before and after indexing using DBMS_XPLAN.DISPLAY.
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. SETUP: Create High-Volume Table to Demonstrate Optimizer Cost Differences
PROMPT =========================================================================

-- Clean up any prior test table
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE appointment_archive PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create high-volume table (10,000 appointment rows)
CREATE TABLE appointment_archive AS
SELECT 
    ROWNUM AS archive_id,
    MOD(ROWNUM, 20) + 1 AS patient_id,
    MOD(ROWNUM, 8) + 1 AS doctor_id,
    TO_DATE('2025-01-01', 'YYYY-MM-DD') + MOD(ROWNUM, 365) AS appointment_date,
    '10:00' AS appointment_time,
    'Clinical consultation archive record #' || ROWNUM AS notes
FROM DUAL
CONNECT BY LEVEL <= 10000;

-- Gather table statistics so Oracle Optimizer has accurate cost estimates
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'APPOINTMENT_ARCHIVE');

PROMPT Created and analyzed APPOINTMENT_ARCHIVE with 10,000 rows.


PROMPT =========================================================================
PROMPT 2. EXPLAIN PLAN BEFORE INDEXING (Full Table Scan)
PROMPT =========================================================================
PROMPT Query: Search appointments on a specific date (2025-06-15)

EXPLAIN PLAN FOR
SELECT archive_id, patient_id, doctor_id, appointment_date, notes
FROM appointment_archive
WHERE appointment_date = TO_DATE('2025-06-15', 'YYYY-MM-DD');

PROMPT
PROMPT Execution Plan BEFORE Index (Observe: TABLE ACCESS FULL):
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST +BYTES'));


PROMPT =========================================================================
PROMPT 3. CREATE B-TREE INDEX
PROMPT =========================================================================
PROMPT Creating standard B-Tree index on APPOINTMENT_ARCHIVE(appointment_date)...

CREATE INDEX idx_appt_archive_date ON appointment_archive (appointment_date);

-- Refresh statistics after index creation
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'APPOINTMENT_ARCHIVE');


PROMPT =========================================================================
PROMPT 4. EXPLAIN PLAN AFTER INDEXING (Index Range Scan)
PROMPT =========================================================================

EXPLAIN PLAN FOR
SELECT archive_id, patient_id, doctor_id, appointment_date, notes
FROM appointment_archive
WHERE appointment_date = TO_DATE('2025-06-15', 'YYYY-MM-DD');

PROMPT
PROMPT Execution Plan AFTER Index (Observe: INDEX RANGE SCAN + Reduced Cost):
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST +BYTES'));


PROMPT =========================================================================
PROMPT 5. COMPOSITE INDEX DEMONSTRATION: (doctor_id, appointment_date)
PROMPT =========================================================================
PROMPT Demonstrates multi-column B-tree index for doctor schedule lookups.

CREATE INDEX idx_doctor_date ON appointment_archive (doctor_id, appointment_date);

EXPLAIN PLAN FOR
SELECT archive_id, notes
FROM appointment_archive
WHERE doctor_id = 3 AND appointment_date = TO_DATE('2025-06-15', 'YYYY-MM-DD');

PROMPT Execution Plan for Composite Index Search:
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST +BYTES'));


PROMPT =========================================================================
PROMPT 6. CLEANUP
PROMPT =========================================================================
DROP TABLE appointment_archive PURGE;

PROMPT Indexing Demo Script 08 Complete!
