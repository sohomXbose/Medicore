# MediCore — Database Normalization Proof

## 1. Unnormalized Form (UNF)

### Definition

Unnormalized Form (UNF) is a form in which data may contain repeating groups or multi-valued attributes. The initial conceptual design of the MediCore hospital database contains patient information along with repeated appointments, treatments, prescriptions, medicines, bills, admissions and laboratory test information.

A conceptual representation of the unnormalized patient record is:

```text
PATIENT_RECORD(
    Patient_ID,
    Full_Name,
    DOB,
    Gender,
    Phone,
    Blood_Group,
    Balance_Due,
    Created_At,

    Doctor(
        Doctor_ID,
        Staff_ID,
        Full_Name,
        Email,
        Password_Hash,
        Role,
        Created_At,
        Department_ID,
        Department_Name,
        Specialization
    ),

    Appointments(
        Appointment_ID,
        Patient_ID,
        Doctor_ID,
        Appointment_Date,
        Appointment_Time,
        Reason,
        Status,

        Treatment(
            Treatment_ID,
            Patient_ID,
            Doctor_ID,
            Appointment_ID,
            Diagnosis,
            Treatment_Notes,
            Treatment_Date,

            Prescription(
                Prescription_ID,
                Treatment_ID,
                Prescribed_Date,

                Prescription_Items(
                    Prescription_Item_ID,
                    Medicine_ID,
                    Medicine_Name,
                    Unit_Price,
                    Stock_Quantity,
                    Reorder_Level,
                    Dosage,
                    Frequency_Per_Day,
                    Duration_Days
                )
            )
        )
    ),

    Bills(
        Bill_ID,
        Patient_ID,
        Bill_Date,
        Total_Amount,

        Bill_Items(
            Bill_Item_ID,
            Item_Type,
            Description,
            Amount
        ),

        Payments(
            Payment_ID,
            Payment_Date,
            Amount_Paid,
            Payment_Mode
        )
    ),

    Rooms(
        Room_ID,
        Room_Number,
        Ward_Type,

        Beds(
            Bed_Number,
            Is_Occupied
        )
    ),

    Admissions(
        Admission_ID,
        Patient_ID,
        Room_ID,
        Bed_Number,
        Admission_Date,
        Discharge_Date
    ),

    Lab_Tests(
        Lab_Test_ID,
        Patient_ID,
        Doctor_ID,
        Test_Type,
        Requested_Date,
        Result,
        Result_Date,
        Status
    )
)
```

The above conceptual relation contains repeating groups such as `Appointments`, `Prescription_Items`, `Bill_Items`, `Payments`, `Beds` and `Lab_Tests`. Therefore, the relation is not in First Normal Form.

---

# 2. First Normal Form (1NF)

### Rule

A relation is in First Normal Form (1NF) when:

1. Every attribute contains a single atomic value.
2. There are no repeating groups.
3. Each row can be uniquely identified.

### Action

The repeating groups from the UNF design are separated into individual relations. Each attribute is made atomic and each entity is represented by its own relation.

The resulting 1NF relations are:

```text
DEPARTMENT(
    Department_ID,
    Department_Name
)

STAFF(
    Staff_ID,
    Full_Name,
    Email,
    Password_Hash,
    Role,
    Created_At
)

DOCTOR(
    Doctor_ID,
    Staff_ID,
    Department_ID,
    Specialization
)

PATIENT(
    Patient_ID,
    Full_Name,
    DOB,
    Gender,
    Phone,
    Blood_Group,
    Balance_Due,
    Created_At
)

APPOINTMENT(
    Appointment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_Date,
    Appointment_Time,
    Reason,
    Status
)

TREATMENT(
    Treatment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_ID,
    Diagnosis,
    Treatment_Notes,
    Treatment_Date
)

MEDICINE(
    Medicine_ID,
    Medicine_Name,
    Unit_Price,
    Stock_Quantity,
    Reorder_Level
)

PRESCRIPTION(
    Prescription_ID,
    Treatment_ID,
    Prescribed_Date
)

PRESCRIPTION_ITEM(
    Prescription_Item_ID,
    Prescription_ID,
    Medicine_ID,
    Dosage,
    Frequency_Per_Day,
    Duration_Days
)

ROOM(
    Room_ID,
    Room_Number,
    Ward_Type
)

BED(
    Room_ID,
    Bed_Number,
    Is_Occupied
)

ADMISSION(
    Admission_ID,
    Patient_ID,
    Room_ID,
    Bed_Number,
    Admission_Date,
    Discharge_Date
)

LAB_TEST(
    Lab_Test_ID,
    Patient_ID,
    Doctor_ID,
    Test_Type,
    Requested_Date,
    Result,
    Result_Date,
    Status
)

BILL(
    Bill_ID,
    Patient_ID,
    Bill_Date,
    Total_Amount
)

BILL_ITEM(
    Bill_Item_ID,
    Bill_ID,
    Item_Type,
    Description,
    Amount
)

PAYMENT(
    Payment_ID,
    Bill_ID,
    Payment_Date,
    Amount_Paid,
    Payment_Mode
)

AUDIT_LOG(
    Audit_ID,
    Table_Name,
    Record_ID,
    Operation,
    Old_Data,
    Changed_By,
    Changed_At
)

USER_SESSION(
    Session_ID,
    Staff_ID,
    Login_Time,
    Logout_Time
)

DOCTOR_SCHEDULE(
    Schedule_ID,
    Doctor_ID,
    Day_Of_Week,
    Start_Time,
    End_Time
)

NOTIFICATION(
    Notification_ID,
    Patient_ID,
    Staff_ID,
    Message,
    Notification_Type,
    Is_Read,
    Created_At
)
```

All attributes are atomic and the repeating groups have been removed. Therefore, the relations satisfy the requirements of 1NF.

---

# 3. Second Normal Form (2NF)

### Rule

A relation is in Second Normal Form (2NF) when:

1. It is already in 1NF.
2. Every non-key attribute depends on the entire primary key.
3. There are no partial dependencies.

### Dependency Analysis

Most MediCore relations have a single-attribute primary key. Therefore, partial dependency cannot occur in those relations.

The `BED` table has a composite primary key:

```text
(Room_ID, Bed_Number)
```

The attribute `Is_Occupied` depends on the complete combination `(Room_ID, Bed_Number)` because a bed is uniquely identified by its room and bed number.

The resulting 2NF relations are:

```text
DEPARTMENT(
    Department_ID,
    Department_Name
)

STAFF(
    Staff_ID,
    Full_Name,
    Email,
    Password_Hash,
    Role,
    Created_At
)

DOCTOR(
    Doctor_ID,
    Staff_ID,
    Department_ID,
    Specialization
)

PATIENT(
    Patient_ID,
    Full_Name,
    DOB,
    Gender,
    Phone,
    Blood_Group,
    Balance_Due,
    Created_At
)

APPOINTMENT(
    Appointment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_Date,
    Appointment_Time,
    Reason,
    Status
)

TREATMENT(
    Treatment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_ID,
    Diagnosis,
    Treatment_Notes,
    Treatment_Date
)

MEDICINE(
    Medicine_ID,
    Medicine_Name,
    Unit_Price,
    Stock_Quantity,
    Reorder_Level
)

PRESCRIPTION(
    Prescription_ID,
    Treatment_ID,
    Prescribed_Date
)

PRESCRIPTION_ITEM(
    Prescription_Item_ID,
    Prescription_ID,
    Medicine_ID,
    Dosage,
    Frequency_Per_Day,
    Duration_Days
)

ROOM(
    Room_ID,
    Room_Number,
    Ward_Type
)

BED(
    Room_ID,
    Bed_Number,
    Is_Occupied
)

ADMISSION(
    Admission_ID,
    Patient_ID,
    Room_ID,
    Bed_Number,
    Admission_Date,
    Discharge_Date
)

LAB_TEST(
    Lab_Test_ID,
    Patient_ID,
    Doctor_ID,
    Test_Type,
    Requested_Date,
    Result,
    Result_Date,
    Status
)

BILL(
    Bill_ID,
    Patient_ID,
    Bill_Date,
    Total_Amount
)

BILL_ITEM(
    Bill_Item_ID,
    Bill_ID,
    Item_Type,
    Description,
    Amount
)

PAYMENT(
    Payment_ID,
    Bill_ID,
    Payment_Date,
    Amount_Paid,
    Payment_Mode
)

AUDIT_LOG(
    Audit_ID,
    Table_Name,
    Record_ID,
    Operation,
    Old_Data,
    Changed_By,
    Changed_At
)

USER_SESSION(
    Session_ID,
    Staff_ID,
    Login_Time,
    Logout_Time
)

DOCTOR_SCHEDULE(
    Schedule_ID,
    Doctor_ID,
    Day_Of_Week,
    Start_Time,
    End_Time
)

NOTIFICATION(
    Notification_ID,
    Patient_ID,
    Staff_ID,
    Message,
    Notification_Type,
    Is_Read,
    Created_At
)
```

Thus, there are no partial dependencies in the final relations, and the database satisfies 2NF.

---

# 4. Third Normal Form (3NF)

### Rule

A relation is in Third Normal Form (3NF) when:

1. It is already in 2NF.
2. There are no transitive dependencies.
3. Non-key attributes depend directly on the key and not on another non-key attribute.

### Dependency Analysis

The MediCore database separates descriptive information into independent relations.

For example:

```text
Department_ID → Department_Name
```

Therefore, department information is stored in the `DEPARTMENT` table.

Similarly:

```text
Staff_ID → Full_Name, Email, Password_Hash, Role, Created_At
```

Therefore, staff information is stored in the `STAFF` table.

Doctor information contains references to staff and department:

```text
Doctor_ID → Staff_ID, Department_ID, Specialization
```

The staff and department descriptive attributes are not repeated inside the `DOCTOR` table.

Similarly:

```text
Medicine_ID → Medicine_Name, Unit_Price, Stock_Quantity, Reorder_Level
```

Therefore, medicine information is stored separately in `MEDICINE`.

Room information depends on `Room_ID`:

```text
Room_ID → Room_Number, Ward_Type
```

and is therefore stored in `ROOM`.

Billing information is separated into:

```text
Bill_ID → Patient_ID, Bill_Date, Total_Amount
```

and individual bill items are stored in `BILL_ITEM`.

Payment information is stored separately using:

```text
Payment_ID → Bill_ID, Payment_Date, Amount_Paid, Payment_Mode
```

Therefore, there are no unnecessary transitive dependencies.

The resulting 3NF relations are:

```text
DEPARTMENT(
    Department_ID,
    Department_Name
)

STAFF(
    Staff_ID,
    Full_Name,
    Email,
    Password_Hash,
    Role,
    Created_At
)

DOCTOR(
    Doctor_ID,
    Staff_ID,
    Department_ID,
    Specialization
)

PATIENT(
    Patient_ID,
    Full_Name,
    DOB,
    Gender,
    Phone,
    Blood_Group,
    Balance_Due,
    Created_At
)

APPOINTMENT(
    Appointment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_Date,
    Appointment_Time,
    Reason,
    Status
)

TREATMENT(
    Treatment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_ID,
    Diagnosis,
    Treatment_Notes,
    Treatment_Date
)

MEDICINE(
    Medicine_ID,
    Medicine_Name,
    Unit_Price,
    Stock_Quantity,
    Reorder_Level
)

PRESCRIPTION(
    Prescription_ID,
    Treatment_ID,
    Prescribed_Date
)

PRESCRIPTION_ITEM(
    Prescription_Item_ID,
    Prescription_ID,
    Medicine_ID,
    Dosage,
    Frequency_Per_Day,
    Duration_Days
)

ROOM(
    Room_ID,
    Room_Number,
    Ward_Type
)

BED(
    Room_ID,
    Bed_Number,
    Is_Occupied
)

ADMISSION(
    Admission_ID,
    Patient_ID,
    Room_ID,
    Bed_Number,
    Admission_Date,
    Discharge_Date
)

LAB_TEST(
    Lab_Test_ID,
    Patient_ID,
    Doctor_ID,
    Test_Type,
    Requested_Date,
    Result,
    Result_Date,
    Status
)

BILL(
    Bill_ID,
    Patient_ID,
    Bill_Date,
    Total_Amount
)

BILL_ITEM(
    Bill_Item_ID,
    Bill_ID,
    Item_Type,
    Description,
    Amount
)

PAYMENT(
    Payment_ID,
    Bill_ID,
    Payment_Date,
    Amount_Paid,
    Payment_Mode
)

AUDIT_LOG(
    Audit_ID,
    Table_Name,
    Record_ID,
    Operation,
    Old_Data,
    Changed_By,
    Changed_At
)

USER_SESSION(
    Session_ID,
    Staff_ID,
    Login_Time,
    Logout_Time
)

DOCTOR_SCHEDULE(
    Schedule_ID,
    Doctor_ID,
    Day_Of_Week,
    Start_Time,
    End_Time
)

NOTIFICATION(
    Notification_ID,
    Patient_ID,
    Staff_ID,
    Message,
    Notification_Type,
    Is_Read,
    Created_At
)
```

Therefore, the database satisfies the requirements of Third Normal Form.

---

# 5. Boyce-Codd Normal Form (BCNF)

### Rule

A relation is in Boyce-Codd Normal Form (BCNF) if, for every non-trivial functional dependency:

```text
X → Y
```

the determinant `X` is a candidate key.

### Candidate Keys and Functional Dependencies

The primary keys and declared unique constraints in the MediCore schema provide the following determinants.

### DEPARTMENT

```text
Department_ID → Department_Name
Department_Name → Department_ID
```

`Department_ID` is the primary key and `Department_Name` is declared unique.

### STAFF

```text
Staff_ID → Full_Name, Email, Password_Hash, Role, Created_At
Email → Staff_ID
```

`Staff_ID` is the primary key and `Email` is unique.

### DOCTOR

```text
Doctor_ID → Staff_ID, Department_ID, Specialization
Staff_ID → Doctor_ID, Department_ID, Specialization
```

`Doctor_ID` is the primary key and `Staff_ID` is declared unique.

### PATIENT

```text
Patient_ID → Full_Name, DOB, Gender, Phone, Blood_Group, Balance_Due, Created_At
```

`Patient_ID` is the primary key.

### APPOINTMENT

```text
Appointment_ID → Patient_ID, Doctor_ID, Appointment_Date,
                  Appointment_Time, Reason, Status

(Doctor_ID, Appointment_Date, Appointment_Time)
    → Appointment_ID, Patient_ID, Reason, Status
```

The composite combination `(Doctor_ID, Appointment_Date, Appointment_Time)` is declared unique.

### TREATMENT

```text
Treatment_ID → Patient_ID, Doctor_ID, Appointment_ID,
               Diagnosis, Treatment_Notes, Treatment_Date
```

`Treatment_ID` is the primary key. `Appointment_ID` is also declared unique when it is not null.

### MEDICINE

```text
Medicine_ID → Medicine_Name, Unit_Price, Stock_Quantity, Reorder_Level
```

`Medicine_ID` is the primary key.

### PRESCRIPTION

```text
Prescription_ID → Treatment_ID, Prescribed_Date
```

`Prescription_ID` is the primary key.

### PRESCRIPTION_ITEM

```text
Prescription_Item_ID → Prescription_ID, Medicine_ID,
                       Dosage, Frequency_Per_Day, Duration_Days
```

`Prescription_Item_ID` is the primary key.

### ROOM

```text
Room_ID → Room_Number, Ward_Type
Room_Number → Room_ID, Ward_Type
```

`Room_ID` is the primary key and `Room_Number` is unique.

### BED

```text
(Room_ID, Bed_Number) → Is_Occupied
```

`(Room_ID, Bed_Number)` is the composite primary key.

### ADMISSION

```text
Admission_ID → Patient_ID, Room_ID, Bed_Number,
                Admission_Date, Discharge_Date
```

`Admission_ID` is the primary key.

### LAB_TEST

```text
Lab_Test_ID → Patient_ID, Doctor_ID, Test_Type,
              Requested_Date, Result, Result_Date, Status
```

`Lab_Test_ID` is the primary key.

### BILL

```text
Bill_ID → Patient_ID, Bill_Date, Total_Amount
```

`Bill_ID` is the primary key.

### BILL_ITEM

```text
Bill_Item_ID → Bill_ID, Item_Type, Description, Amount
```

`Bill_Item_ID` is the primary key.

### PAYMENT

```text
Payment_ID → Bill_ID, Payment_Date, Amount_Paid, Payment_Mode
```

`Payment_ID` is the primary key.

### AUDIT_LOG

```text
Audit_ID → Table_Name, Record_ID, Operation,
           Old_Data, Changed_By, Changed_At
```

`Audit_ID` is the primary key.

### USER_SESSION

```text
Session_ID → Staff_ID, Login_Time, Logout_Time
```

`Session_ID` is the primary key.

### DOCTOR_SCHEDULE

```text
Schedule_ID → Doctor_ID, Day_Of_Week, Start_Time, End_Time
```

`Schedule_ID` is the primary key.

### NOTIFICATION

```text
Notification_ID → Patient_ID, Staff_ID, Message,
                   Notification_Type, Is_Read, Created_At
```

`Notification_ID` is the primary key.

Since the determinants identified above are candidate keys or primary keys of their respective relations, the final logical design satisfies BCNF.

---

# 6. Final BCNF Relations

The final normalized database consists of the following relations:

```text
DEPARTMENT(
    Department_ID,
    Department_Name
)

STAFF(
    Staff_ID,
    Full_Name,
    Email,
    Password_Hash,
    Role,
    Created_At
)

DOCTOR(
    Doctor_ID,
    Staff_ID,
    Department_ID,
    Specialization
)

PATIENT(
    Patient_ID,
    Full_Name,
    DOB,
    Gender,
    Phone,
    Blood_Group,
    Balance_Due,
    Created_At
)

APPOINTMENT(
    Appointment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_Date,
    Appointment_Time,
    Reason,
    Status
)

TREATMENT(
    Treatment_ID,
    Patient_ID,
    Doctor_ID,
    Appointment_ID,
    Diagnosis,
    Treatment_Notes,
    Treatment_Date
)

MEDICINE(
    Medicine_ID,
    Medicine_Name,
    Unit_Price,
    Stock_Quantity,
    Reorder_Level
)

PRESCRIPTION(
    Prescription_ID,
    Treatment_ID,
    Prescribed_Date
)

PRESCRIPTION_ITEM(
    Prescription_Item_ID,
    Prescription_ID,
    Medicine_ID,
    Dosage,
    Frequency_Per_Day,
    Duration_Days
)

ROOM(
    Room_ID,
    Room_Number,
    Ward_Type
)

BED(
    Room_ID,
    Bed_Number,
    Is_Occupied
)

ADMISSION(
    Admission_ID,
    Patient_ID,
    Room_ID,
    Bed_Number,
    Admission_Date,
    Discharge_Date
)

LAB_TEST(
    Lab_Test_ID,
    Patient_ID,
    Doctor_ID,
    Test_Type,
    Requested_Date,
    Result,
    Result_Date,
    Status
)

BILL(
    Bill_ID,
    Patient_ID,
    Bill_Date,
    Total_Amount
)

BILL_ITEM(
    Bill_Item_ID,
    Bill_ID,
    Item_Type,
    Description,
    Amount
)

PAYMENT(
    Payment_ID,
    Bill_ID,
    Payment_Date,
    Amount_Paid,
    Payment_Mode
)

AUDIT_LOG(
    Audit_ID,
    Table_Name,
    Record_ID,
    Operation,
    Old_Data,
    Changed_By,
    Changed_At
)

USER_SESSION(
    Session_ID,
    Staff_ID,
    Login_Time,
    Logout_Time
)

DOCTOR_SCHEDULE(
    Schedule_ID,
    Doctor_ID,
    Day_Of_Week,
    Start_Time,
    End_Time
)

NOTIFICATION(
    Notification_ID,
    Patient_ID,
    Staff_ID,
    Message,
    Notification_Type,
    Is_Read,
    Created_At
)
```

---

# Conclusion

The MediCore database is normalized through the stages of UNF, 1NF, 2NF, 3NF and BCNF.

The normalization process:

* Removes repeating groups.
* Ensures atomic attributes.
* Removes partial dependencies.
* Removes transitive dependencies.
* Separates independent entities into appropriate relations.
* Uses primary keys and declared unique constraints to identify records.
* Reduces data redundancy.
* Helps prevent update, insertion and deletion anomalies.

The final normalized relations correspond directly to the physical database schema implemented in `schema(4).sql`.
