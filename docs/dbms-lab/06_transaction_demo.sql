SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 06: Transactions and ACID Properties Demo
-- =============================================================================
-- Purpose: Implements Phase 4c of the Blueprint — Demonstrates ACID properties:
--          Atomicity, Consistency, Isolation, and Durability using explicit
--          transactions (BEGIN, COMMIT, ROLLBACK, SAVEPOINT).
-- Scenario: Multi-table financial workflow (Patient Bill -> Line Items -> Payment -> Balance Update)
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. ACID OVERVIEW:
PROMPT   - Atomicity   : All-or-nothing execution of multi-table inserts.
PROMPT   - Consistency : Balance due reflects exact sum of bills minus payments.
PROMPT   - Isolation   : Row-level locks prevent uncommitted reads or concurrent double-payment.
PROMPT   - Durability  : Once COMMIT executes, changes survive system crashes.
PROMPT =========================================================================

-- Clean up any residual test records from prior runs
DELETE FROM payment WHERE bill_id IN (SELECT bill_id FROM bill WHERE patient_id = 99);
DELETE FROM bill_item WHERE bill_id IN (SELECT bill_id FROM bill WHERE patient_id = 99);
DELETE FROM bill WHERE patient_id = 99;
DELETE FROM patient WHERE patient_id = 99;
COMMIT;

-- Create dedicated test patient for this transaction demo
INSERT INTO patient (patient_id, full_name, dob, gender, phone, blood_group, balance_due)
VALUES (99, 'Transaction Demo Patient', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'MALE', '9999999999', 'O+', 0);
COMMIT;


PROMPT =========================================================================
PROMPT 2. SCENARIO A: Full Successful Transaction (All steps commit together)
PROMPT =========================================================================

DECLARE
    v_patient_id NUMBER := 99;
    v_bill_id    NUMBER;
    v_total      NUMBER := 2500;
    v_payment_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting Transaction A: Complete Bill + Payment ---');

    -- Step 1: Create Bill Header
    INSERT INTO bill (patient_id, bill_date, total_amount)
    VALUES (v_patient_id, SYSDATE, v_total)
    RETURNING bill_id INTO v_bill_id;
    DBMS_OUTPUT.PUT_LINE('Step 1: Created Bill #' || v_bill_id || ' for Rs. ' || v_total);

    -- Step 2: Create Bill Items
    INSERT INTO bill_item (bill_id, item_type, description, amount)
    VALUES (v_bill_id, 'CONSULTATION', 'Specialist Doctor Consultation', 1000);

    INSERT INTO bill_item (bill_id, item_type, description, amount)
    VALUES (v_bill_id, 'LAB_TEST', 'Comprehensive Blood Profile', 1500);
    DBMS_OUTPUT.PUT_LINE('Step 2: Inserted 2 Bill Line Items');

    -- Step 3: Set SAVEPOINT before recording payment
    SAVEPOINT sp_before_payment;
    DBMS_OUTPUT.PUT_LINE('Step 3: Established SAVEPOINT sp_before_payment');

    -- Step 4: Record Full Payment
    INSERT INTO payment (bill_id, payment_date, amount_paid, payment_mode)
    VALUES (v_bill_id, SYSDATE, v_total, 'UPI')
    RETURNING payment_id INTO v_payment_id;
    DBMS_OUTPUT.PUT_LINE('Step 4: Recorded Payment #' || v_payment_id || ' via UPI');

    -- Step 5: Update Patient Balance (0 net change because fully paid)
    UPDATE patient
    SET balance_due = balance_due + (v_total - v_total)
    WHERE patient_id = v_patient_id;
    DBMS_OUTPUT.PUT_LINE('Step 5: Patient balance synchronized');

    -- COMMIT ALL CHANGES
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Step 6: Transaction A COMMITTED successfully!');
END;
/

PROMPT
PROMPT Verification of Scenario A in Database:
SELECT b.bill_id, b.patient_id, b.total_amount, p.amount_paid, p.payment_mode
FROM bill b
JOIN payment p ON b.bill_id = p.bill_id
WHERE b.patient_id = 99;


PROMPT
PROMPT =========================================================================
PROMPT 3. SCENARIO B: Forced Failure with Partial Rollback to SAVEPOINT
PROMPT =========================================================================
PROMPT Demonstrates: If payment gateway fails mid-transaction, rollback to SAVEPOINT
PROMPT preserves the bill draft rather than losing the entire invoice data.

DECLARE
    v_patient_id NUMBER := 99;
    v_bill_id    NUMBER;
    v_total      NUMBER := 1200;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting Transaction B: Bill Generation with Payment Failure ---');

    -- Step 1: Create Bill Draft
    INSERT INTO bill (patient_id, bill_date, total_amount)
    VALUES (v_patient_id, SYSDATE, v_total)
    RETURNING bill_id INTO v_bill_id;
    DBMS_OUTPUT.PUT_LINE('Step 1: Created Bill Draft #' || v_bill_id || ' for Rs. ' || v_total);

    -- Step 2: Line Item
    INSERT INTO bill_item (bill_id, item_type, description, amount)
    VALUES (v_bill_id, 'TREATMENT', 'Physical Therapy Session', 1200);

    -- Step 3: Establish SAVEPOINT
    SAVEPOINT sp_bill_draft_saved;
    DBMS_OUTPUT.PUT_LINE('Step 3: Established SAVEPOINT sp_bill_draft_saved');

    -- Step 4: Simulate a Payment Failure (e.g. invalid payment mode violating CHECK constraint)
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Step 4: Attempting payment with invalid payment mode (triggering check constraint)...');
        INSERT INTO payment (bill_id, payment_date, amount_paid, payment_mode)
        VALUES (v_bill_id, SYSDATE, 1200, 'BITCOIN'); -- Fails: CHECK constraint rejects non-allowed mode
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('PAYMENT FAILED! Error caught: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Executing ROLLBACK TO SAVEPOINT sp_bill_draft_saved...');
            ROLLBACK TO SAVEPOINT sp_bill_draft_saved;
    END;

    -- Step 5: Mark the bill as unpaid on patient record since payment failed
    UPDATE patient
    SET balance_due = balance_due + v_total
    WHERE patient_id = v_patient_id;

    -- Commit the bill draft and patient balance (payment was discarded, bill remains pending)
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Step 5: Bill #' || v_bill_id || ' saved as UNPAID with balance due Rs. ' || v_total);
END;
/

PROMPT
PROMPT Verification of Scenario B in Database:
PROMPT Notice Bill exists, but NO payment row exists, and Patient balance reflects debt:
SELECT b.bill_id, b.total_amount, p.balance_due AS patient_current_debt
FROM bill b
JOIN patient p ON b.patient_id = p.patient_id
WHERE b.patient_id = 99 AND b.bill_id NOT IN (SELECT bill_id FROM payment);


PROMPT
PROMPT =========================================================================
PROMPT 4. SCENARIO C: Complete Atomicity Rollback (Zero Orphaned Rows)
PROMPT =========================================================================
PROMPT Demonstrates: An unhandled failure completely rolls back all steps.

DECLARE
    v_patient_id NUMBER := 99;
    v_bill_id    NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting Transaction C: Fatal Error Complete Rollback ---');

    INSERT INTO bill (patient_id, bill_date, total_amount)
    VALUES (v_patient_id, SYSDATE, 5000)
    RETURNING bill_id INTO v_bill_id;

    INSERT INTO bill_item (bill_id, item_type, description, amount)
    VALUES (v_bill_id, 'CONSULTATION', 'Emergency Triage', 5000);

    -- Simulate fatal system error (e.g. division by zero or network crash)
    RAISE ZERO_DIVIDE;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Fatal error encountered: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Rolling back ENTIRE transaction to guarantee ATOMICITY...');
        ROLLBACK;
END;
/

PROMPT Verification: No 5000 Rs bill exists in database (Atomicity Held):
SELECT COUNT(*) AS should_be_zero FROM bill WHERE patient_id = 99 AND total_amount = 5000;

-- Clean up test records
DELETE FROM payment WHERE bill_id IN (SELECT bill_id FROM bill WHERE patient_id = 99);
DELETE FROM bill_item WHERE bill_id IN (SELECT bill_id FROM bill WHERE patient_id = 99);
DELETE FROM bill WHERE patient_id = 99;
DELETE FROM patient WHERE patient_id = 99;
COMMIT;

PROMPT =========================================================================
PROMPT Transaction Script 06 Complete!
PROMPT =========================================================================
