-- ============================================================
-- Project:      PreSales Estimation Platform
-- Migration:    V001__Create_Extensions.sql
-- Description:  Create Extensions and Base Infrastructure
-- Author:       Platform Database Architect
-- Created Date: 2026-07-15
-- ============================================================

BEGIN;

-- ============================================================
-- Extensions
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Schema
-- ============================================================

CREATE SCHEMA IF NOT EXISTS app;

-- ============================================================
-- Table: app.schema_versions
-- ============================================================

CREATE TABLE app.schema_versions (
    id                UUID         NOT NULL DEFAULT gen_random_uuid(),
    version           VARCHAR(20)  NOT NULL,
    description       VARCHAR(500) NOT NULL,
    installed_on      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    installed_by      VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    execution_time_ms INTEGER,
    success           BOOLEAN      NOT NULL DEFAULT TRUE,
    checksum          VARCHAR(128),
    CONSTRAINT pk_schema_versions          PRIMARY KEY (id),
    CONSTRAINT uq_schema_versions_version  UNIQUE      (version)
);

COMMENT ON TABLE  app.schema_versions                    IS 'Tracks every applied database migration, its execution outcome, and audit metadata to support operational governance and rollback planning.';
COMMENT ON COLUMN app.schema_versions.id                 IS 'Surrogate primary key generated as a Version 4 UUID.';
COMMENT ON COLUMN app.schema_versions.version            IS 'Migration version label matching the filename prefix (e.g. V001). Must be unique across all applied migrations.';
COMMENT ON COLUMN app.schema_versions.description        IS 'Human-readable summary of the migration scope and intent.';
COMMENT ON COLUMN app.schema_versions.installed_on       IS 'Timestamp with time zone at which the migration was committed to the database.';
COMMENT ON COLUMN app.schema_versions.installed_by       IS 'Database role that executed the migration script.';
COMMENT ON COLUMN app.schema_versions.execution_time_ms  IS 'Total wall-clock execution time of the migration in milliseconds. Nullable when the migration runner does not capture timing.';
COMMENT ON COLUMN app.schema_versions.success            IS 'TRUE when the migration committed without error; FALSE when it was recorded after a known partial failure.';
COMMENT ON COLUMN app.schema_versions.checksum           IS 'SHA-256 or equivalent hash of the migration script content used to detect post-deployment tampering. Nullable when not computed by the migration runner.';

-- ============================================================
-- Table: app.application_locks
-- ============================================================

CREATE TABLE app.application_locks (
    lock_id    UUID         NOT NULL DEFAULT gen_random_uuid(),
    lock_name  VARCHAR(200) NOT NULL,
    locked_by  VARCHAR(100),
    locked_on  TIMESTAMPTZ,
    expires_on TIMESTAMPTZ,
    purpose    VARCHAR(500),
    CONSTRAINT pk_application_locks           PRIMARY KEY (lock_id),
    CONSTRAINT uq_application_locks_lock_name UNIQUE      (lock_name)
);

COMMENT ON TABLE  app.application_locks            IS 'Provides application-level named locking to coordinate exclusive access to shared resources across concurrent processes and service instances.';
COMMENT ON COLUMN app.application_locks.lock_id    IS 'Surrogate primary key generated as a Version 4 UUID.';
COMMENT ON COLUMN app.application_locks.lock_name  IS 'Unique logical name identifying the resource or critical section being protected by this lock entry.';
COMMENT ON COLUMN app.application_locks.locked_by  IS 'Identifier of the process, service instance, or user currently holding the lock. Null when the lock is not currently acquired.';
COMMENT ON COLUMN app.application_locks.locked_on  IS 'Timestamp with time zone at which the lock was most recently acquired. Null when the lock is not currently held.';
COMMENT ON COLUMN app.application_locks.expires_on IS 'Timestamp with time zone at which the lock automatically expires and may be reclaimed. Null for locks with no enforced expiry.';
COMMENT ON COLUMN app.application_locks.purpose    IS 'Description of the operation or resource being protected when the lock was acquired. Null when not supplied by the acquiring process.';

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX ix_schema_versions_installed_on
    ON app.schema_versions (installed_on DESC);

COMMENT ON INDEX app.ix_schema_versions_installed_on
    IS 'Supports chronological queries retrieving the most recently applied migrations.';

CREATE INDEX ix_application_locks_expires_on
    ON app.application_locks (expires_on)
    WHERE expires_on IS NOT NULL;

COMMENT ON INDEX app.ix_application_locks_expires_on
    IS 'Supports efficient identification of expired lock entries eligible for reclamation. Partial index excludes locks with no expiry.';

-- ============================================================
-- Seed: baseline migration record
-- ============================================================

INSERT INTO app.schema_versions (version, description)
VALUES ('V001', 'Create Extensions and Base Infrastructure');

COMMIT;
