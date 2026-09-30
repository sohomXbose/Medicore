SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200

-- =============================================================================
-- MediCore DBMS Lab — Script 04: PL/SQL Procedures, Functions, Cursors and Exceptions
-- =============================================================================
-- Purpose: Implements the full PL/SQL suite specified in Blueprint §6:
--   1. Procedure: get_patient_details (SYS_REFCURSOR output)
--   2. Procedure: book_appointment (Slot checking and validation)
--   3. Procedure: generate_bill (Multi-item atomic bill generation)
--   4. Function : calculate_patient_bill (Sums outstanding patient balances)
--   5. Function : get_doctor_appointment_count (Daily appointment volume counter)
--   6. Explicit Cursor: patients_with_pending_bills (Row-by-row cursor loop)
--   7. Custom Exceptions: invalid_patient_exc (-20001) and slot_unavailable_exc (-20002)
--   8. Test Execution blocks demonstrating live execution with DBMS_OUTPUT.
-- =============================================================================

PROMPT =========================================================================
PROMPT 1. PROCEDURE: get_patient_details (Returns Profile + Balance via REFCURSOR)
PROMPT =========================================================================

CREATE OR REPLACE PROCEDURE get_patient_details (
    p_id     IN  NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
    v_count NUMBER;
BEGIN
    -- Check if patient exists
    SELECT COUNT(*) INTO v_count FROM patient WHERE patient_id = p_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid patient ID: ' || p_id || ' does not exist.');
    END IF;

    OPEN p_cursor FOR
        SELECT patient_id,
               full_name,
               TO_CHAR(dob, 'YYYY-MM-DD') AS dob,
               gender,
               phone,
               blood_group,
               balance_due,
               TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI') AS registered_on
        FROM patient
        WHERE patient_id = p_id;
END get_patient_details;
/


PROMPT =========================================================================
PROMPT 2. PROCEDURE: book_appointment (Validates Patient, Doctor and Slot Availability)
PROMPT =========================================================================

CREATE OR REPLACE PROCEDURE book_appointment (
    p_patient_id IN  NUMBER,
    p_doctor_id  IN  NUMBER,
    p_date       IN  DATE,
    p_time       IN  VARCHAR2,
    p_reason     IN  VARCHAR2,
    p_result     OUT VARCHAR2
) AS
    v_patient_count NUMBER;
    v_doctor_count  NUMBER;
    v_slot_count    NUMBER;
    v_new_appt_id   NUMBER;
BEGIN
    -- 1. Validate Patient Existence
    SELECT COUNT(*) INTO v_patient_count FROM patient WHERE patient_id = p_patient_id;
    IF v_patient_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid Patient ID: ' || p_patient_id);
    END IF;

    -- 2. Validate Doctor Existence
    SELECT COUNT(*) INTO v_doctor_count FROM doctor WHERE doctor_id = p_doctor_id;
    IF v_doctor_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid Doctor ID: ' || p_doctor_id);
    END IF;

    -- 3. Check for existing active booking in the same slot
    SELECT COUNT(*) INTO v_slot_count
    FROM appointment
    WHERE doctor_id = p_doctor_id
      AND appointment_date = TRUNC(p_date)
      AND appointment_time = p_time
      AND status != 'CANCELLED';

    IF v_slot_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Doctor ' || p_doctor_id || ' is already booked on ' 
                                || TO_CHAR(p_date, 'YYYY-MM-DD') || ' at ' || p_time);
    END IF;

    -- 4. Insert Appointment
    INSERT INTO appointment (patient_id, doctor_id, appointment_date, appointment_time, reason, status)
    VALUES (p_patient_id, p_doctor_id, TRUNC(p_date), p_time, p_reason, 'SCHEDULED')
    RETURNING appointment_id INTO v_new_appt_id;

    COMMIT;
    p_result := 'SUCCESS: Appointment booked with ID: ' || v_new_appt_id;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END book_appointment;
/


PROMPT =========================================================================
PROMPT 3. PROCEDURE: generate_bill (Multi-Item Bill with SAVEPOINT and Balance Update)
PROMPT =========================================================================

CREATE OR REPLACE PROCEDURE generate_bill (
    p_patient_id IN NUMBER,
    p_items      IN sys.odcivarchar2list,
    p_amounts    IN sys.odcinumberlist
) AS
    v_patient_count NUMBER;
    v_bill_id       NUMBER;
    v_total         NUMBER(10,2) := 0;
BEGIN
    -- Validate Patient
    SELECT COUNT(*) INTO v_patient_count FROM patient WHERE patient_id = p_patient_id;
    IF v_patient_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid Patient ID: ' || p_patient_id);
    END IF;

    IF p_items.COUNT = 0 OR p_items.COUNT != p_amounts.COUNT THEN
        RAISE_APPLICATION_ERROR(-20004, 'Item list and amount list must have matching non-zero counts.');
    END IF;

    -- Compute total
    FOR i IN 1 .. p_amounts.COUNT LOOP
        IF p_amounts(i) < 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Negative line item amount not allowed: ' || p_amounts(i));
        END IF;
        v_total := v_total + p_amounts(i);
    END LOOP;

    -- 1. Create master bill
    INSERT INTO bill (patient_id, bill_date, total_amount)
    VALUES (p_patient_id, SYSDATE, v_total)
    RETURNING bill_id INTO v_bill_id;

    -- 2. Savepoint before inserting line items
    SAVEPOINT sp_before_items;

    -- 3. Insert each item
    FOR i IN 1 .. p_items.COUNT LOOP
        INSERT INTO bill_item (bill_id, item_type, description, amount)
        VALUES (v_bill_id, 'TREATMENT', p_items(i), p_amounts(i));
    END LOOP;

    -- 4. Update patient balance due
    UPDATE patient
    SET balance_due = balance_due + v_total
    WHERE patient_id = p_patient_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Generated Bill #' || v_bill_id || ' for Patient #' || p_patient_id || ' | Total: Rs. ' || v_total);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END generate_bill;
/


PROMPT =========================================================================
PROMPT 4. FUNCTION: calculate_patient_bill (Sums Unpaid Bill Balances)
PROMPT =========================================================================

CREATE OR REPLACE FUNCTION calculate_patient_bill (
    p_patient_id IN NUMBER
) RETURN NUMBER AS
    v_unpaid_total NUMBER(10,2) := 0;
BEGIN
    SELECT NVL(SUM(b.total_amount) - NVL(SUM(p.amount_paid), 0), 0)
    INTO v_unpaid_total
    FROM bill b
    LEFT JOIN payment p ON b.bill_id = p.bill_id
    WHERE b.patient_id = p_patient_id;

    RETURN v_unpaid_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END calculate_patient_bill;
/


PROMPT =========================================================================
PROMPT 5. FUNCTION: get_doctor_appointment_count (Daily Appointment Statistics)
PROMPT =========================================================================

CREATE OR REPLACE FUNCTION get_doctor_appointment_count (
    p_doctor_id IN NUMBER,
    p_date      IN DATE
) RETURN NUMBER AS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM appointment
    WHERE doctor_id = p_doctor_id
      AND appointment_date = TRUNC(p_date)
      AND status != 'CANCELLED';

    RETURN v_count;
END get_doctor_appointment_count;
/


PROMPT =========================================================================
PROMPT 6. EXPLICIT CURSOR DEMO: patients_with_pending_bills
PROMPT =========================================================================

CREATE OR REPLACE PROCEDURE print_pending_bills_report AS
    CURSOR cur_pending_patients IS
        SELECT p.patient_id,
               p.full_name,
               p.phone,
               p.balance_due,
               COUNT(b.bill_id) AS total_bills
        FROM patient p
        LEFT JOIN bill b ON p.patient_id = b.patient_id
        WHERE p.balance_due > 0
        GROUP BY p.patient_id, p.full_name, p.phone, p.balance_due
        ORDER BY p.balance_due DESC;

    v_rec cur_pending_patients%ROWTYPE;
    v_row_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('PATIENT ID | PATIENT NAME          | PHONE        | BALANCE DUE | BILLS');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------');

    OPEN cur_pending_patients;
    LOOP
        FETCH cur_pending_patients INTO v_rec;
        EXIT WHEN cur_pending_patients%NOTFOUND;

        v_row_count := v_row_count + 1;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_rec.patient_id, 11) || '| ' ||
            RPAD(v_rec.full_name, 22) || '| ' ||
            RPAD(v_rec.phone, 13) || '| ' ||
            LPAD('Rs. ' || TO_CHAR(v_rec.balance_due, '99990.99'), 12) || ' | ' ||
            v_rec.total_bills
        );
    END LOOP;
    CLOSE cur_pending_patients;

    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Patients with Pending Balances: ' || v_row_count);
END print_pending_bills_report;
/


PROMPT =========================================================================
PROMPT 7. LIVE TEST SUITE: Executing PL/SQL Components
PROMPT =========================================================================

-- Test 7a: Run get_patient_details procedure
PROMPT === Test 7a: Calling get_patient_details(p_id => 1) ===
DECLARE
    cur SYS_REFCURSOR;
    v_id NUMBER;
    v_name VARCHAR2(100);
    v_dob VARCHAR2(20);
    v_gender VARCHAR2(10);
    v_phone VARCHAR2(20);
    v_blood VARCHAR2(5);
    v_bal NUMBER;
    v_reg VARCHAR2(30);
BEGIN
    get_patient_details(1, cur);
    FETCH cur INTO v_id, v_name, v_dob, v_gender, v_phone, v_blood, v_bal, v_reg;
    CLOSE cur;
    DBMS_OUTPUT.PUT_LINE('Fetched Patient: #' || v_id || ' ' || v_name || ' | Balance: Rs.' || v_bal || ' | DOB: ' || v_dob);
END;
/

-- Test 7b: Run calculate_patient_bill function
PROMPT === Test 7b: Calling calculate_patient_bill(p_patient_id => 2) ===
DECLARE
    v_unpaid NUMBER;
BEGIN
    v_unpaid := calculate_patient_bill(2);
    DBMS_OUTPUT.PUT_LINE('Calculated Unpaid Amount for Patient 2: Rs. ' || v_unpaid);
END;
/

-- Test 7c: Run get_doctor_appointment_count function
PROMPT === Test 7c: Calling get_doctor_appointment_count for Doctor 1 ===
DECLARE
    v_count NUMBER;
BEGIN
    v_count := get_doctor_appointment_count(1, TO_DATE('2026-09-01', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Doctor 1 Appointment Count on 2026-09-01: ' || v_count);
END;
/

-- Test 7d: Run Cursor Report Procedure
PROMPT === Test 7d: Executing print_pending_bills_report (Explicit Cursor) ===
BEGIN
    print_pending_bills_report;
END;
/

-- Test 7e: Exception Handling Demonstration (Invalid Patient ID)
PROMPT === Test 7e: Testing Custom Exception Handling (Pass nonexistent Patient 99999) ===
DECLARE
    cur SYS_REFCURSOR;
BEGIN
    get_patient_details(99999, cur);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Caught Expected Error: ' || SQLERRM);
END;
/

PROMPT =========================================================================
PROMPT PL/SQL Procedures Script 04 Complete!
PROMPT =========================================================================
