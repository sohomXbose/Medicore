SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 07: Concurrency and Lock-Wait Demo
-- =============================================================================
-- Purpose: Implements Phase 4d of the Blueprint — Demonstrates Concurrency Control,
--          Row-Level Exclusive Locking (TX Lock), Lock Contention, and Serialization.
-- Instructions for Faculty Demo:
--   Open TWO separate tabs/connections in SQL Developer / DBeaver / SQL*Plus.
--   Run Session 1 instructions in Tab 1, then Session 2 instructions in Tab 2.
-- =============================================================================

PROMPT =========================================================================
PROMPT CONCURRENCY CONTROL LAB GUIDE: TWO-SESSION CONFLICT DEMO
PROMPT =========================================================================
PROMPT 
PROMPT Objective: Prove that Oracle Database enforces Isolation (ACID) by acquiring
PROMPT an Exclusive Row Lock (TX) on UPDATE, preventing lost updates and dirty reads.
PROMPT

-- -----------------------------------------------------------------------------
-- PART A: SESSION 1 SCRIPT (Run in TAB 1)
-- -----------------------------------------------------------------------------
PROMPT === [TAB 1 - SESSION 1 COMMANDS] ===
PROMPT Copy and run the following in Tab 1:
PROMPT
PROMPT   -- 1. Check patient balance before update
PROMPT   SELECT patient_id, full_name, balance_due FROM patient WHERE patient_id = 1;
PROMPT
PROMPT   -- 2. Session 1 updates Patient 1's balance (ACQUIRES EXCLUSIVE ROW LOCK)
PROMPT   UPDATE patient
PROMPT   SET balance_due = balance_due + 500
PROMPT   WHERE patient_id = 1;
PROMPT
PROMPT   -- DO NOT COMMIT YET! The lock is held actively by Session 1.
PROMPT   PROMPT >>> Session 1 holds the lock. Now switch to Tab 2 and run Session 2! <<<


-- -----------------------------------------------------------------------------
-- PART B: SESSION 2 SCRIPT (Run in TAB 2 while Session 1 is uncommitted)
-- -----------------------------------------------------------------------------
PROMPT
PROMPT === [TAB 2 - SESSION 2 COMMANDS] ===
PROMPT Copy and run the following in Tab 2:
PROMPT
PROMPT   -- Session 2 attempts to modify the SAME row that Session 1 locked:
PROMPT   UPDATE patient
PROMPT   SET balance_due = balance_due + 200
PROMPT   WHERE patient_id = 1;
PROMPT
PROMPT   -- OBSERVATION: Tab 2 hangs / freezes in "Executing query..."
PROMPT   -- Why? Oracle detects conflicting Exclusive Lock and puts Session 2 into LOCK WAIT.


-- -----------------------------------------------------------------------------
-- PART C: LOCK INSPECTION QUERY (Run in a 3rd tab or Session 1 to show faculty)
-- -----------------------------------------------------------------------------
PROMPT
PROMPT === [DIAGNOSTIC QUERY: Proving the Lock Wait in the Data Dictionary] ===
PROMPT Run this query to show faculty the blocking session ID and the waiting session ID:

SELECT 
    s1.sid AS blocking_sid,
    s1.serial# AS blocking_serial,
    s1.username AS blocking_user,
    s2.sid AS waiting_sid,
    s2.serial# AS waiting_serial,
    s2.username AS waiting_user,
    l1.type AS lock_type,
    l1.lmode AS lock_mode_held,
    l2.request AS lock_mode_requested
FROM v$lock l1
JOIN v$session s1 ON l1.sid = s1.sid
JOIN v$lock l2 ON l1.id1 = l2.id1 AND l1.id2 = l2.id2 AND l2.request > 0
JOIN v$session s2 ON l2.sid = s2.sid
WHERE l1.block = 1;


-- -----------------------------------------------------------------------------
-- PART D: RESOLUTION (Releasing the Lock)
-- -----------------------------------------------------------------------------
PROMPT
PROMPT === [RESOLUTION STEPS] ===
PROMPT 1. In Tab 1 (Session 1), execute:
PROMPT      COMMIT;
PROMPT 
PROMPT 2. Look immediately at Tab 2 (Session 2):
PROMPT    Tab 2 INSTANTLY unblocks and completes its UPDATE ("1 row updated")!
PROMPT
PROMPT 3. In Tab 2, execute:
PROMPT      COMMIT;
PROMPT
PROMPT 4. Verification: Check final balance of Patient 1:
PROMPT      SELECT patient_id, full_name, balance_due FROM patient WHERE patient_id = 1;
PROMPT    (Both updates succeeded sequentially without losing either payment: +500 then +200).

-- Reset patient 1 balance back to original 0 for clean repeatability
UPDATE patient SET balance_due = 0 WHERE patient_id = 1;
COMMIT;

PROMPT
PROMPT =========================================================================
PROMPT Concurrency Demo Script 07 Guide Complete!
PROMPT =========================================================================
