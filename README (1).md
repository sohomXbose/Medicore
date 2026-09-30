# 🏥 MediCore — Hospital Management System & DBMS Architecture

> A production-ready, headless Hospital Management System driven by a **Node.js/Express REST API** and an **Oracle Database PL/SQL Engine**. Designed and verified to fulfill both transactional healthcare requirements and advanced academic DBMS laboratory concepts.

---

## 📌 Project Overview

MediCore is built around **data integrity, role-based security, automated database triggers, ACID transactional safety, and live SQL aggregations**.

The system eliminates front-end UI overhead and demonstrates complete operational functionality through:

1. **Postman API Suite** — 24 automated, sequential REST API tests verifying end-to-end patient care workflows.
2. **Oracle DBMS Lab Pack** — 10 standalone SQL/PLSQL scripts demonstrating Relational Algebra, Normalization (3NF/BCNF), Explicit Cursors, Triggers, Two-Phase Locking (2PL), B-Tree Indexing, and System Recovery.
3. **Formal Academic Report** — A 100% verified academic PDF report containing execution results and visual verification proofs.

---

## 👥 4-Member Team Roles & Task Division

| Team Role | Member | Lead Responsibilities | Key Artifacts |
|---|---|---|---|
| **Database Architect** | **Srija Das** | ER diagram modeling, 3NF/BCNF normalization proofs, primary/foreign key constraint enforcement, DDL schema generation, and initial seed datasets. | `schema.sql`<br>`seed.sql` |
| **Backend REST Developer** | **Agnish Mondal** | Node.js/Express REST API architecture, role-based JWT authentication middleware, business logic controllers, structured JSON error handling, and `/health` DB ping route. | `server.js`<br>`controllers/`<br>`routes/`<br>`middlewares/` |
| **Advanced DBMS Engineer** | **Deepayan Dey** | Compiled PL/SQL stored procedures, functions, explicit cursors, inventory auto-decrement triggers, atomic financial transactions, 2PL concurrency scripts, B-Tree indexing, and crash recovery. | `docs/dbms-lab/`<br>Scripts 01–10 |
| **Integration & Demo Lead** | **Sohom Bose** | Postman collection runner configuration, sequential end-to-end API test automation, visual screenshot proof capture, project report compilation, and GitHub repository management. | `postman/`<br>`test results/`<br>`docs/MediCore_Project_Report.pdf` |

---

## 🛠️ Technology Stack

| Category | Technologies |
|---|---|
| **Database** | Oracle Database, SQL, PL/SQL |
| **Backend** | Node.js, Express.js |
| **Database Driver** | `oracledb` |
| **Authentication** | JSON Web Tokens (JWT), Bcrypt |
| **Authorization** | Role-Based Access Control (RBAC) |
| **Security** | CORS, JWT Authentication |
| **API Testing** | Postman Collection Runner |
| **Documentation** | Markdown, HTML-to-PDF compilation |

---

## 🏗️ System Architecture

```text
                         ┌─────────────────────┐
                         │      Postman        │
                         │   API Test Suite    │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │   Node.js /         │
                         │   Express REST API  │
                         └──────────┬──────────┘
                                    │
                           oracledb Driver
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │   Oracle Database   │
                         │                     │
                         │  SQL + PL/SQL       │
                         │  Triggers           │
                         │  Transactions       │
                         │  Procedures         │
                         │  Functions          │
                         └─────────────────────┘
```

---

## 📂 Repository Structure

```text
DBMS Medicore/
│
├── config/
│   └── # Oracle Database connection pool configuration
│
├── controllers/
│   ├── appointmentController.js
│   ├── authController.js
│   ├── billController.js
│   ├── patientController.js
│   ├── prescriptionController.js
│   ├── reportController.js
│   └── treatmentController.js
│
├── docs/
│   ├── dbms-lab/
│   │   ├── 01_relational_algebra.sql
│   │   ├── 02_normalization_proof.sql
│   │   ├── 03_sql_queries.sql
│   │   ├── 04_plsql_procedures.sql
│   │   ├── 05_triggers_demo.sql
│   │   ├── 06_transaction_demo.sql
│   │   ├── 07_concurrency_demo.sql
│   │   ├── 08_indexing_demo.sql
│   │   ├── 09_query_optimization.sql
│   │   └── 10_recovery_demo.sql
│   │
│   └── MediCore_Project_Report.pdf
│
├── middlewares/
│   └── # JWT & role authorization middleware
│
├── postman/
│   └── # Complete Postman test runner suite
│
├── routes/
│   └── # Express REST API endpoints
│
├── test results/
│   ├── 00_overall_24_of_24_passed.png
│   ├── authentication/
│   ├── patients/
│   ├── appointments/
│   ├── billing/
│   ├── dbms_lab_scripts/
│   ├── inventory/
│   ├── prescriptions/
│   ├── reports/
│   └── treatments/
│
├── schema.sql
├── seed.sql
├── server.js
└── package.json
```

---

# 🚀 Step-by-Step API Execution Workflow

The API suite executes sequentially so that database state remains consistent across the complete hospital workflow.

### 1. Authentication & RBAC

```http
POST /api/auth/login
```

Authenticates users and generates role-scoped JWT bearer tokens.

Supported roles:

- Admin
- Doctor
- Receptionist
- Pharmacist

---

### 2. Patient Management

```http
POST /api/patients
```

Registers a new patient while enforcing unique email and phone constraints.

---

### 3. Appointment Scheduling

```http
POST /api/appointments
```

Schedules doctor appointments and enforces unique appointment slots based on:

```text
doctor_id
date
time_slot
```

Duplicate bookings return:

```text
409 Conflict
```

---

### 4. Clinical Treatment

```http
POST /api/treatments
```

Allows physicians to record:

- Clinical diagnosis
- Symptoms
- Treatment information
- Prescribed procedures

The treatment record is linked to the corresponding appointment.

---

### 5. Prescription & Inventory Trigger

```http
POST /api/prescriptions
```

Creates prescriptions while Oracle database triggers automatically decrement the corresponding medicine stock.

```text
Prescription Created
        ↓
Database Trigger Fires
        ↓
Medicine Stock Decremented
```

---

### 6. ACID Financial Billing

```http
POST /api/bills/generate
```

Performs atomic multi-table billing operations involving:

- `BILL`
- `BILL_ITEM`

Transaction safety is demonstrated using:

```text
SAVEPOINT
COMMIT
ROLLBACK
```

If an operation fails, the transaction can be rolled back to prevent partial data.

---

### 7. Live Revenue Reporting

```http
GET /api/reports/revenue
```

Uses SQL aggregation operations such as:

```sql
GROUP BY
SUM()
```

to generate department-wise revenue information.

---

# 🧪 Advanced DBMS Laboratory Script Pack

The project contains **10 standalone SQL/PLSQL scripts** designed for execution using Oracle SQL Developer or DBeaver.

| Script | File | DBMS Concept |
|---|---|---|
| **01** | `01_relational_algebra.sql` | Selection, Projection, Joins, Set Operations, Division |
| **02** | `02_normalization_proof.sql` | UNF → 1NF → 2NF → 3NF → BCNF |
| **03** | `03_sql_queries.sql` | Complex JOINs, Aggregate Queries, HAVING, Window Functions |
| **04** | `04_plsql_procedures.sql` | Procedures, Functions, Explicit Parameterized Cursors |
| **05** | `05_triggers_demo.sql` | Inventory Triggers, Audit Logging |
| **06** | `06_transaction_demo.sql` | BEGIN, SAVEPOINT, COMMIT, ROLLBACK, ACID |
| **07** | `07_concurrency_demo.sql` | Dual-Session Concurrency, 2PL Lock-Wait Behavior |
| **08** | `08_indexing_demo.sql` | B-Tree Indexing, EXPLAIN PLAN |
| **09** | `09_query_optimization.sql` | Query Optimization & Execution Plan Comparison |
| **10** | `10_recovery_demo.sql` | REDO/UNDO Crash Recovery & Consistency Checks |

---

# 🔬 DBMS Concepts Demonstrated

### Relational Algebra

```text
Selection
Projection
Joins
Set Operations
Division
```

### Normalization

```text
UNF
 ↓
1NF
 ↓
2NF
 ↓
3NF
 ↓
BCNF
```

### PL/SQL

```text
Stored Procedures
Stored Functions
Explicit Cursors
```

### Database Triggers

```text
INSERT
  ↓
Trigger
  ↓
Automatic Database Action
```

### Transactions

```text
BEGIN
 ↓
SAVEPOINT
 ↓
Operations
 ↓
COMMIT / ROLLBACK
```

### Concurrency

```text
Session 1
    ↓
Row Lock
    ↓
Session 2
    ↓
Wait
```

### Indexing

```text
Query
 ↓
B-Tree Index
 ↓
Reduced Search Cost
```

### Recovery

```text
Database Failure
       ↓
REDO / UNDO
       ↓
Database Consistency
```

---

# ⚙️ How to Run Locally

## 1. Prerequisites

Install:

- Node.js v18+
- Oracle Database
- Postman
- SQL Developer or DBeaver

---

## 2. Database Initialization

Run the schema and seed scripts in Oracle SQL Developer:

```sql
@schema.sql
@seed.sql
```

---

## 3. Environment Configuration

Create a `.env` file in the project root:

```env
PORT=5000
JWT_SECRET=your_jwt_secret_key
NODE_ORACLEDB_USER=your_db_username
NODE_ORACLEDB_PASSWORD=your_db_password
NODE_ORACLEDB_CONNECTIONSTRING=localhost:1521/XEPDB1
```

---

## 4. Install Dependencies

```bash
npm install
```

---

## 5. Start the Backend

```bash
npm run dev
```

The backend starts at:

```text
http://localhost:5000
```

---

## 6. Health Check

Open:

```text
http://localhost:5000/health
```

Expected response:

```json
{
  "status": "UP",
  "database": "CONNECTED",
  "message": "MediCore Backend API and Oracle DB are connected and running perfectly."
}
```

---

# 📊 Verification & Test Results

## API Verification

```text
24 / 24 Tests Passed
100% Pass Rate
```

The API suite verifies:

- Authentication
- Patient registration
- Patient verification
- Appointment booking
- Double-booking prevention
- Treatment recording
- Inventory checking
- Prescription creation
- Database trigger execution
- Stock decrement verification
- Atomic billing
- Transaction rollback
- Revenue aggregation

---

## DBMS Verification

```text
10 / 10 SQL/PLSQL Scripts Passed
100% Verification
```

The scripts demonstrate:

- Relational Algebra
- Normalization
- Advanced SQL
- PL/SQL
- Triggers
- Transactions
- Concurrency
- Indexing
- Query Optimization
- Crash Recovery

---

# 📸 Verification Evidence

All execution screenshots are organized inside:

```text
/test results/
```

The complete academic verification report is available at:

```text
/docs/MediCore_Project_Report.pdf
```

---

# 🏆 Project Verification Summary

| Component | Verification |
|---|---|
| Relational Schema | ✅ 3NF/BCNF implemented |
| REST API | ✅ 24/24 tests passed |
| DBMS Lab Scripts | ✅ 10/10 scripts passed |
| Database Triggers | ✅ Verified |
| ACID Transactions | ✅ Verified |
| Concurrency | ✅ Dual-session verification |
| Indexing | ✅ B-Tree execution plan verification |
| Query Optimization | ✅ Verified |
| Crash Recovery | ✅ REDO/UNDO verification |
| Documentation | ✅ Completed |

---

# 📄 Academic Integrity

This project is developed for **DBMS course evaluation and academic demonstration purposes**.

All database schemas, SQL/PLSQL scripts, REST API handlers, test workflows, and documentation are original deliverables created by the MediCore project team.
