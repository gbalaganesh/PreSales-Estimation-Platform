## database

Contains all PostgreSQL 17 database artifacts for the PreSales Estimation Platform.

### Subfolders

- **migrations/** — Versioned, sequential schema migration scripts applied in order to create and evolve the database schema.
- **functions/** — PostgreSQL user-defined functions (UDFs) encapsulating reusable query logic and business calculations.
- **views/** — PostgreSQL views that expose curated, read-optimized projections of the underlying tables.
- **procedures/** — PostgreSQL stored procedures for transactional, multi-step operations that require procedural control flow.
- **seed/** — Reference and baseline data scripts used to populate lookup tables and initial configuration data.
