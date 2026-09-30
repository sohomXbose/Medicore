# MediCore — Revised Blueprint (No Frontend, 4 Members)

**Change from v1:** Frontend (React) is dropped entirely. The system is demonstrated through two tools instead of a UI:
1. **Postman** — hits the REST API live, showing request → database write → response, for every workflow.
2. **SQL Developer / DBeaver** — runs SQL, PL/SQL, and shows table state directly, for every DBMS Lab concept.

This is not a downgrade for a DBMS course — showing raw queries and API calls in front of faculty is *more* convincing than a UI, because there's nowhere to hide fake data. Nothing else about the schema, PL/SQL, triggers, or transactions changes from the original blueprint (§3–§9 there are all still valid — reuse them as-is).

---

## 1. Revised Team Roles (4-person split)

| Role | Owns |
|---|---|
| **Database Architect** | ER model, schema, normalization proof, keys, constraints, seed data |
| **Backend Developer** | Node.js/Express REST API, auth, DB connectivity, business logic |
| **Advanced DBMS Engineer** | PL/SQL procedures/functions/triggers, transactions, indexing, concurrency, recovery |
| **Integration & Demo Lead** | Postman collection (organizes every endpoint into a runnable folder-per-workflow), SQL Lab script pack, final report, rehearsed demo script |

The 4th role replaces "Frontend Developer" — this person's job is making the *demonstration itself* airtight: a Postman collection anyone can run top-to-bottom, and a folder of `.sql` files that run the DBMS Lab concepts on command. This is real, necessary work — not a filler role.

---

## 2. Phase Roadmap (revised)

### **Phase 0 — Environment & Repo Setup** — unchanged from v1.

### **Phase 1 — Database Design** — unchanged from v1 (schema, ER diagram, normalization, seed data).

### **Phase 2 — Backend (REST API)**
Same as v1 §Phase 2, with one addition: **every endpoint must be demo-ready without a UI**, meaning:
- Consistent, readable JSON responses (this is what you'll be showing on-screen in Postman)
- A `/health` endpoint that confirms DB connectivity
- Meaningful error messages in the response body (e.g. `{"error": "Doctor already booked at this time"}`) — since there's no UI to show a friendly error, the raw JSON *is* the error UI

**Gate 2 (revised):**
- [ ] Postman collection covers every endpoint, organized into folders by workflow (Auth, Patients, Appointments, Treatments, Prescriptions, Billing, Admissions, Lab Tests, Reports)
- [ ] Postman collection has a **Runner-ready order** — i.e., can be run top-to-bottom via Postman's Collection Runner and complete without manual intervention (uses saved variables like `{{patient_id}}` from one response in the next request)
- [ ] Login → role-scoped JWT confirmed; unauthorized role on a protected route returns 403
- [ ] Double-booking rejection confirmed live in Postman

### **Phase 3 — DBMS Lab Script Pack** *(replaces the old Frontend phase)*
Instead of building UI pages for ER model / relational algebra / normalization / SQL console / PL-SQL / transactions / concurrency / indexing / optimization / recovery, build a **folder of ready-to-run `.sql` files**, one per concept, each demonstrating the *exact* thing on a live connection to your seeded database:

```
/docs/dbms-lab/
  01_relational_algebra.sql      -- selection, projection, join, division, set ops
  02_normalization_proof.sql     -- shows the UNF table + decomposed 3NF/BCNF tables side by side
  03_sql_queries.sql             -- the JOIN/GROUP BY/HAVING/nested query library
  04_plsql_procedures.sql        -- CREATE OR REPLACE for every procedure/function/cursor
  05_triggers_demo.sql           -- insert a prescription, then SELECT to show stock dropped
  06_transaction_demo.sql        -- BEGIN/COMMIT/ROLLBACK/SAVEPOINT on bill generation
  07_concurrency_demo.sql        -- two-session conflicting UPDATE script (run in two SQL Developer tabs)
  08_indexing_demo.sql           -- EXPLAIN PLAN before/after index creation
  09_query_optimization.sql      -- original query vs. rewritten query, EXPLAIN PLAN comparison
  10_recovery_demo.sql           -- forced mid-transaction failure + recovery check
```

Each file should have SQL comments explaining what it proves, so it reads like a lab manual — this is literally what you hand faculty to page through if they want to inspect anything themselves.

**Gate 3 (replaces old Gate 3):**
- [ ] All 10 script files exist, each runs cleanly against the seeded database with **no errors**
- [ ] Each file's output is captured as a screenshot in `/docs/phase3/screenshots/` (faculty may not let you run live everywhere — screenshots are your backup)
- [ ] `07_concurrency_demo.sql` has been actually run in two simultaneous sessions and the lock-wait/serialization behavior captured, not just written

### **Phase 4 — Advanced DBMS Layer** — same content as v1 §Phase 4a–4h, just executed via the script pack from Phase 3 instead of a UI page. Gate 4 same checklist as v1, minus anything UI-specific.

### **Phase 5 — Documentation & Demo Rehearsal**
Same as v1, with the demo script rewritten (see §4 below) to run entirely through Postman + SQL Developer.

---

## 3. Revised Timeline (6 weeks, 4 members)

| Week | Focus |
|---|---|
| 1 | Phase 0 + Phase 1 |
| 2–3 | Phase 2 (backend) — Integration Lead starts building the Postman collection alongside, not after |
| 3–4 | Phase 3 (DBMS Lab script pack) — Advanced DBMS Engineer + Integration Lead work together here |
| 5 | Phase 4 (deep PL/SQL, transactions, concurrency, indexing, optimization, recovery) |
| 6 | Phase 5 (report, rehearsal, buffer) |

Frontend's removal actually frees up roughly a third of your original build time — reinvest it into making Phase 3/4 airtight rather than rushing.

---

## 4. Revised Final Demo Script (10 steps, no UI)

1. Open Postman → run `POST /login` → show JWT + role in response
2. `POST /patients` → register a new patient → show the row appear via a quick `SELECT` in SQL Developer
3. `POST /appointments` → book a slot → then try booking the **same slot again** → show the rejection in the response body
4. `POST /treatments` → doctor records diagnosis → confirm row in `TREATMENT` table
5. `POST /prescriptions` → run `06_triggers_demo.sql`'s `SELECT` right after → show `MEDICINE.stock_quantity` visibly dropped from the trigger
6. `POST /bills/generate` → open `06_transaction_demo.sql` alongside → show the `BILL`, `BILL_ITEM`, `PAYMENT` rows all appear together (or force a failure and show the rollback)
7. `GET /reports/revenue` → show live JSON aggregation (`GROUP BY`/`SUM`) straight from the database
8. Open `01_relational_algebra.sql` and `02_normalization_proof.sql` in SQL Developer → run and narrate
9. Open `04_plsql_procedures.sql` → execute a procedure/function/cursor live, show output
10. Run `07_concurrency_demo.sql` (two tabs), `08_indexing_demo.sql`, `09_query_optimization.sql`, `10_recovery_demo.sql` in sequence — each with a one-line explanation of what just happened

This sequence hits every module from the original idea doc and every syllabus unit from the coverage table — just through Postman + SQL Developer instead of screens.
