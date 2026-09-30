SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

-- =============================================================================
-- MediCore DBMS Lab — Script 05: Triggers Demo
-- =============================================================================
-- Purpose: Implements the 4 hospital database triggers specified in Blueprint §7:
--   1. trg_prescription_stock_deduct:
--      AFTER INSERT ON PRESCRIPTION_ITEM: Automatically deducts medicine inventory
--      by (frequency_per_day * duration_days).
--   2. trg_low_stock_alert:
--      AFTER UPDATE OF stock_quantity ON MEDICINE: Automatically logs a low-stock
--      alert into AUDIT_LOG when stock drops below reorder_level.
--   3. trg_patient_audit:
--      BEFORE UPDATE OR DELETE ON PATIENT: Automatically captures old row data into
--      AUDIT_LOG before any modification or deletion.
--   4. trg_bill_audit:
--      BEFORE UPDATE OR DELETE ON BILL: Automatically audits bill alterations.
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. TRIGGER: trg_prescription_stock_deduct (Stock Deduction)
PROMPT =========================================================================

CREATE OR REPLACE TRIGGER trg_prescription_stock_deduct
AFTER INSERT ON prescription_item
FOR EACH ROW
DECLARE
    v_qty_needed NUMBER;
    v_curr_stock NUMBER;
    v_med_name   VARCHAR2(200);
BEGIN
    v_qty_needed := :NEW.frequency_per_day * :NEW.duration_days;

    -- Fetch current stock
    SELECT stock_quantity, medicine_name
    INTO v_curr_stock, v_med_name
    FROM medicine
    WHERE medicine_id = :NEW.medicine_id
    FOR UPDATE;

    -- Check sufficiency
    IF v_curr_stock < v_qty_needed THEN
        RAISE_APPLICATION_ERROR(-20010, 'Insufficient inventory for ' || v_med_name || 
                                '. Requested: ' || v_qty_needed || ', Available: ' || v_curr_stock);
    END IF;

    -- Deduct stock
    UPDATE medicine
    SET stock_quantity = stock_quantity - v_qty_needed
    WHERE medicine_id = :NEW.medicine_id;
END;
/


PROMPT =========================================================================
PROMPT 2. TRIGGER: trg_low_stock_alert (Automatic Inventory Warning)
PROMPT =========================================================================

CREATE OR REPLACE TRIGGER trg_low_stock_alert
AFTER UPDATE OF stock_quantity ON medicine
FOR EACH ROW
WHEN (NEW.stock_quantity < NEW.reorder_level)
BEGIN
    INSERT INTO audit_log (table_name, record_id, operation, old_data, changed_by, changed_at)
    VALUES (
        'MEDICINE',
        :NEW.medicine_id,
        'UPDATE',
        'LOW STOCK ALERT: ' || :NEW.medicine_name || ' stock dropped to ' || 
        :NEW.stock_quantity || ' (Reorder threshold is ' || :NEW.reorder_level || ')',
        NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER),
        SYSTIMESTAMP
    );
END;
/


PROMPT =========================================================================
PROMPT 3. TRIGGER: trg_patient_audit (Pre-Modification Audit Trail)
PROMPT =========================================================================

CREATE OR REPLACE TRIGGER trg_patient_audit
BEFORE UPDATE OR DELETE ON patient
FOR EACH ROW
DECLARE
    v_old_data VARCHAR2(2000);
    v_op       VARCHAR2(10);
BEGIN
    IF UPDATING THEN
        v_op := 'UPDATE';
    ELSE
        v_op := 'DELETE';
    END IF;

    v_old_data := 'full_name=' || :OLD.full_name || 
                  ', phone=' || :OLD.phone || 
                  ', balance_due=' || :OLD.balance_due;

    INSERT INTO audit_log (table_name, record_id, operation, old_data, changed_by, changed_at)
    VALUES (
        'PATIENT',
        :OLD.patient_id,
        v_op,
        v_old_data,
        NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER),
        SYSTIMESTAMP
    );
END;
/


PROMPT =========================================================================
PROMPT 4. TRIGGER: trg_bill_audit (Pre-Modification Audit on Billing)
PROMPT =========================================================================

CREATE OR REPLACE TRIGGER trg_bill_audit
BEFORE UPDATE OR DELETE ON bill
FOR EACH ROW
DECLARE
    v_old_data VARCHAR2(2000);
    v_op       VARCHAR2(10);
BEGIN
    IF UPDATING THEN
        v_op := 'UPDATE';
    ELSE
        v_op := 'DELETE';
    END IF;

    v_old_data := 'patient_id=' || :OLD.patient_id || 
                  ', total_amount=' || :OLD.total_amount || 
                  ', bill_date=' || TO_CHAR(:OLD.bill_date, 'YYYY-MM-DD');

    INSERT INTO audit_log (table_name, record_id, operation, old_data, changed_by, changed_at)
    VALUES (
        'BILL',
        :OLD.bill_id,
        v_op,
        v_old_data,
        NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER),
        SYSTIMESTAMP
    );
END;
/


PROMPT =========================================================================
PROMPT 5. LIVE DEMO: Demonstrating the Triggers in Action
PROMPT =========================================================================

-- Demo 5a: Stock Deduction Trigger in Action
PROMPT === Step 1: Check initial stock of Medicine 1 (Paracetamol) ===
SELECT medicine_id, medicine_name, stock_quantity, reorder_level 
FROM medicine 
WHERE medicine_id = 1;

PROMPT === Step 2: Insert a new Prescription Item (2 pills/day for 5 days = 10 units) ===
-- Create a dummy prescription for treatment 1
INSERT INTO prescription (treatment_id, prescribed_date)
VALUES (1, SYSDATE);

-- Insert prescription item (this will fire trg_prescription_stock_deduct)
INSERT INTO prescription_item (prescription_id, medicine_id, dosage, frequency_per_day, duration_days)
VALUES (
    (SELECT MAX(prescription_id) FROM prescription),
    1,
    '500 mg',
    2,
    5
);

PROMPT === Step 3: Inspect Medicine stock again (Trigger visibly reduced stock by 10) ===
SELECT medicine_id, medicine_name, stock_quantity, reorder_level 
FROM medicine 
WHERE medicine_id = 1;


-- Demo 5b: Patient Audit Trigger in Action
PROMPT === Step 4: Update Patient 1's phone number ===
UPDATE patient
SET phone = '9999888877'
WHERE patient_id = 1;

PROMPT === Step 5: Check AUDIT_LOG table to show trigger trg_patient_audit fired! ===
SELECT audit_id, table_name, record_id, operation, old_data, changed_by, TO_CHAR(changed_at, 'YYYY-MM-DD HH24:MI:SS') AS change_time
FROM audit_log
WHERE table_name = 'PATIENT' AND record_id = 1
ORDER BY audit_id DESC
FETCH FIRST 1 ROW ONLY;

-- Commit the demo transactions
COMMIT;

PROMPT =========================================================================
PROMPT Triggers Script 05 Complete!
PROMPT =========================================================================
