# 🏥 MediCore — Hospital Management System & DBMS Architecture

> A production-ready, headless Hospital Management System driven by a **Node.js/Express REST API** and an **Oracle Database PL/SQL Engine**. Designed and verified to fulfill both transactional healthcare requirements and advanced academic DBMS laboratory concepts.

---

## 📌 Project Overview

MediCore is built strictly around verifiable data integrity, role-based security, automated database triggers, ACID transactional safety, and live SQL aggregations. The system eliminates front-end UI overhead, demonstrating full operational compliance through:
1. **Postman API Suite**: 24 automated, sequential REST API tests verifying end-to-end patient care workflows.
2. **Oracle DBMS Lab Pack**: 10 standalone SQL/PLSQL scripts proving Relational Algebra, Normalization (3NF/BCNF), Explicit Cursors, Triggers, Two-Phase Locking Concurrency, B-Tree Indexing, and System Recovery.
3. **Formal Academic Report**: A 100% verified, monochrome academic PDF report with embedded visual proofs (`docs/MediCore_Project_Report.pdf`).

---

## 👥 4-Member Team Roles & Task Division

The project workload is split across 4 distinct engineering domains:

| Team Role | Lead Responsibilities & Owned Deliverables | Key Artifacts |
| :--- | :--- | :--- |
| **1. Database Architect [Srija Das]** | ER Diagram modeling, 3NF/BCNF normalization proofs, primary/foreign key constraint enforcement, DDL schema generation, and initial seed datasets. | `schema.sql`<br>`seed.sql` |
| **2. Backend REST Developer [Agnish Mondal]** | Node.js/Express REST API architecture, role-based JWT authentication middleware, business logic controllers, structured JSON error handling, and `/health` DB ping route. | `server.js`<br>`controllers/`<br>`routes/`<br>`middlewares/` |
| **3. Advanced DBMS Engineer [Deepayan Dey]** | Compiled PL/SQL stored procedures, functions, explicit cursors, inventory auto-decrement triggers, atomic financial transactions (`SAVEPOINT`/`ROLLBACK`), 2PL concurrency scripts, B-Tree indexing, and crash recovery. | `docs/dbms-lab/` *(Scripts 01–10)* |
| **4. Integration & Demo Lead [Sohom Bose]** | Postman collection runner configuration, sequential end-to-end API test automation, visual screenshot proof capture, project report compilation, and GitHub repo management. | `postman/`<br>`test results/`<br>`docs/MediCore_Project_Report.pdf` |

---

## 🛠️ Technology Stack

* **Database Engine**: Oracle Database (SQL, PL/SQL)
* **Backend Framework**: Node.js, Express.js (`oracledb` native driver)
* **Authentication & Security**: JSON Web Tokens (JWT), Bcrypt hashing, CORS, Role-Based Access Control (RBAC)
* **API Testing & Automation**: Postman Collection Runner
* **Documentation & Verification**: Custom HTML-to-PDF monochrome compiler, Markdown

---

## 📂 Repository Structure

```text
DBMS Medicore/
├── config/                  # Oracle Database Connection Pool config
├── controllers/             # Express Request Handlers & Business Logic
│   ├── appointmentController.js
│   ├── authController.js
│   ├── billController.js
│   ├── patientController.js
│   ├── prescriptionController.js
│   ├── reportController.js
│   └── treatmentController.js
├── docs/
│   ├── dbms-lab/            # 10 Academic DBMS Laboratory SQL/PLSQL Scripts
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
│   └── MediCore_Project_Report.pdf   # Formal PDF Academic Execution Report
├── middlewares/             # JWT & Role Authorization Middlewares
├── postman/                 # Complete Postman Test Runner Suite
├── routes/                  # Express RESTful API Endpoints
├── test results/            # Visual Verification Proof Screenshots (100% Passed)
│   ├── 00_overall_24_of_24_passed.png
│   ├── appointments/
│   ├── authentication/
│   ├── billing/
│   ├── dbms_lab_scripts/    # Screenshots for all 10 SQL Lab Scripts
│   ├── inventory/
│   ├── patients/
│   ├── prescriptions/
│   ├── reports/
│   └── treatments/
├── schema.sql               # Oracle Database DDL Schema Creation
├── seed.sql                 # Database Seed Data & Mock Master Records
├── server.js                # Express Application Entry Point
└── package.json             # Node.js Dependencies & Scripts
```

---

## 🚀 Step-by-Step API Execution Workflow

The system executes linearly to maintain database state consistency across operational modules:

1. **Authentication & RBAC (`POST /api/auth/login`)**: Authenticates users (Admin, Doctor, Receptionist, Pharmacist) and issues role-scoped JWT bearer tokens.
2. **Patient Management (`POST /api/patients`)**: Registers new patients with unique email and phone constraints into persistent database storage.
3. **Appointment Scheduling (`POST /api/appointments`)**: Schedules doctor visits and enforces unique slot constraints `(doctor_id, date, time)`, returning `409 Conflict` on double-booking attempts.
4. **Clinical Diagnoses (`POST /api/treatments`)**: Physicians record clinical diagnoses, symptoms, and prescribed procedures linked to appointments.
5. **Prescriptions & Inventory Triggers (`POST /api/prescriptions`)**: Inserts prescriptions while database triggers automatically decrement `MEDICINE.stock_quantity`.
6. **ACID Financial Billing (`POST /api/bills/generate`)**: Executes atomic multi-table writes (`BILL`, `BILL_ITEM`) with `SAVEPOINT` and `ROLLBACK` safety.
7. **Live Aggregation Reporting (`GET /api/reports/revenue`)**: Executes real-time `GROUP BY` and `SUM` queries returning department revenue metrics.

---

## 🧪 Advanced DBMS Laboratory Script Pack

The `/docs/dbms-lab/` directory contains 10 standalone SQL scripts designed for live execution in **SQL Developer** or **DBeaver**:

* `01_relational_algebra.sql`: Formal Selection (&sigma;), Projection (&pi;), Joins (&bowtie;), Set Operations, and Division (&divide;).
* `02_normalization_proof.sql`: Decomposition from UNF to 1NF, 2NF, 3NF, and Boyce-Codd Normal Form (BCNF).
* `03_sql_queries.sql`: Complex multi-table JOINs, aggregate subqueries (`HAVING`), and ranking window functions.
* `04_plsql_procedures.sql`: Compiled PL/SQL stored procedures, stored functions, and explicit parameterized cursors.
* `05_triggers_demo.sql`: `AFTER INSERT` inventory triggers and `BEFORE UPDATE` audit trail logging.
* `06_transaction_demo.sql`: Multi-statement `BEGIN`, `SAVEPOINT`, `COMMIT`, and `ROLLBACK` ACID verification.
* `07_concurrency_demo.sql`: Dual-session execution demonstrating Oracle Two-Phase Locking (2PL) lock-wait behavior.
* `08_indexing_demo.sql`: `EXPLAIN PLAN` execution cost reduction analysis via B-Tree indexes.
* `09_query_optimization.sql`: Optimizer execution plan comparison between naive nested queries and rewritten joins.
* `10_recovery_demo.sql`: Redo/Undo crash recovery safeguards and database consistency checks.

---

## ⚡ How to Run Locally

### 1. Prerequisits
* Node.js (v18+)
* Oracle Database Instance (Local or Cloud Autonomous DB)
* Postman Client or SQL Developer / DBeaver

### 2. Database Initialization
Run the DDL and DML scripts in Oracle SQL Developer:
```sql
@schema.sql
@seed.sql
```

### 3. Environment Setup
Create a `.env` file in the project root:
```env
PORT=5000
JWT_SECRET=your_jwt_secret_key
NODE_ORACLEDB_USER=your_db_username
NODE_ORACLEDB_PASSWORD=your_db_password
NODE_ORACLEDB_CONNECTIONSTRING=localhost:1521/XEPDB1
```

### 4. Server Launch
Install dependencies and start the backend:
```bash
npm install
npm run dev   # Starts server at http://localhost:5000
```

### 5. Health Check Verification
Confirm DB connectivity by visiting `http://localhost:5000/health`:
```json
{
  "status": "UP",
  "database": "CONNECTED",
  "message": "MediCore Backend API and Oracle DB are connected and running perfectly."
}
```

---

## 📊 Verification & Test Results

* **API Pass Rate**: 24 / 24 Endpoints Verified (100% Pass Rate).
* **DBMS Scripts Pass Rate**: 10 / 10 SQL Scripts Executed & Verified.
* **Full Verification Proofs**: Available in the [`/test results`](./test%20results) directory and detailed in [`docs/MediCore_Project_Report.pdf`](./docs/MediCore_Project_Report.pdf).

---

## 📄 License & Academic Integrity

This project is built for DBMS course evaluation and academic demonstration purposes. All queries, REST API handlers, and documentation are original deliverables created by the MediCore project team.
