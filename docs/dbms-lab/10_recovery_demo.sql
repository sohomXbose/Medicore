SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 10: Crash Recovery and Atomicity Demo
-- =============================================================================
-- Purpose: Implements Phase 4g of the Blueprint — Demonstrates Database Recovery,
--          Redo Logging, Undo Rollback, and Atomicity preservation during sudden
--          session failure or mid-transaction disconnect.
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. RECOVERY CONCEPTS IN ORACLE DATABASE:
PROMPT   - REDO LOG (Write-Ahead Logging / WAL):
PROMPT     Records all database block changes before they are flushed to data files.
PROMPT     Used during crash recovery (Instance Recovery: Roll-Forward phase).
PROMPT   - UNDO TABLESPACE:
PROMPT     Maintains before-images of modified blocks. Used for transaction rollback
PROMPT     and statement-level read consistency.
PROMPT   - ATOMICITY GUARANTEE:
PROMPT     If a system crashes or session disconnects before COMMIT, Oracle's SMON
PROMPT     (System Monitor) background process reads UNDO blocks and rolls back all
PROMPT     uncommitted modifications.
PROMPT =========================================================================


PROMPT =========================================================================
PROMPT 2. TEST CASE 1: Programmable Mid-Transaction Failure (PL/SQL Abort)
PROMPT =========================================================================

-- Clean up any residual demo patient
DELETE FROM patient WHERE patient_id = 8888;
COMMIT;

DECLARE
    v_patient_id NUMBER := 8888;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Step 1: Inserting patient 8888 into database buffer cache ---');
    INSERT INTO patient (patient_id, full_name, dob, gender, phone, blood_group, balance_due)
    VALUES (v_patient_id, 'Recovery Test Patient', TO_DATE('1992-04-10', 'YYYY-MM-DD'), 'FEMALE', '8888888888', 'B+', 0);

    DBMS_OUTPUT.PUT_LINE('--- Step 2: Patient inserted into session private memory. NO COMMIT executed! ---');

    -- Simulating sudden process termination / crash before COMMIT:
    DBMS_OUTPUT.PUT_LINE('--- Step 3: CRASH! Simulating unhandled hardware/network failure ---');
    RAISE_APPLICATION_ERROR(-20999, 'SIMULATED NETWORK DISCONNECT / POWER FAILURE BEFORE COMMIT');

    -- Notice COMMIT is NEVER reached
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('--- Step 4: Exception caught: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('--- Step 5: Rolling back uncommitted transaction using UNDO records ---');
        ROLLBACK;
END;
/

PROMPT
PROMPT Verification of Test Case 1:
PROMPT Checking if Patient 8888 exists in database:
SELECT COUNT(*) AS patient_count_should_be_zero 
FROM patient 
WHERE patient_id = 8888;


PROMPT =========================================================================
PROMPT 3. TEST CASE 2: Live Session Kill Simulation (Faculty Demonstration)
PROMPT =========================================================================
PROMPT Instructions for live faculty demonstration:
PROMPT
PROMPT Step 1 (In Session A / Tab 1):
PROMPT   -- Execute an INSERT without COMMIT:
PROMPT   INSERT INTO patient (patient_id, full_name, dob, gender, phone, balance_due)
PROMPT   VALUES (7777, 'Killed Session Patient', TO_DATE('1990-01-01','YYYY-MM-DD'), 'MALE', '7777777777', 0);
PROMPT   -- DO NOT COMMIT!
PROMPT
PROMPT Step 2 (In Session B / Tab 2 as SYSTEM or DBA):
PROMPT   -- Find the SID and SERIAL# of Session A:
PROMPT   SELECT sid, serial#, username, status FROM v$session WHERE username = 'SYSTEM';
PROMPT
PROMPT   -- Force kill Session A to simulate an abrupt server / client crash:
PROMPT   -- ALTER SYSTEM KILL SESSION '<sid>,<serial#>' IMMEDIATE;
PROMPT
PROMPT Step 3 (In Session B):
PROMPT   -- Immediately query the table to verify atomicity:
PROMPT   SELECT * FROM patient WHERE patient_id = 7777;
PROMPT   -- Result: NO ROWS RETURNED.
PROMPT   -- Explanation: Oracle's PMON/SMON background process detected the dead session
PROMPT   -- and rewound all uncommitted changes back to consistent state via UNDO.
PROMPT =========================================================================

PROMPT Recovery Demo Script 10 Complete!
