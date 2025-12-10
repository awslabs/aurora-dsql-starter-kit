# Aurora DSQL Development Steering Guide

**Version:** 1.0  
**Last Updated:** 2025-11-25  
**Purpose:** Comprehensive guide for developing applications with Amazon Aurora DSQL

---

## Prerequisites

### AWS Account Requirements

- Active AWS account with configured credentials
- IAM permissions for DSQL access (`dsql:DbConnect` or `dsql:DbConnectAdmin`)
- Aurora DSQL cluster provisioned in target region
- AWS CLI installed and configured

### Development Environment

- Chosen language runtime (Python 3.8+, Go 1.19+, Node.js 14+, Java 11+, Rust 1.70+, Elixir 1.14+)
- PostgreSQL client libraries for your language
- SSL/TLS support in your database driver
- AWS SDK for token generation

### Preliminaries

Review the official [aurora-dsql-samples repository](https://github.com/aws-samples/aurora-dsql-samples) for language-specific examples and patterns. The samples demonstrate:

- IAM authentication token generation
- SSL/TLS connection configuration
- Schema setup patterns
- CRUD operation examples
- Connection pooling strategies

### Non-Admin User Setup

For non-admin database users:

1. Create IAM role with DSQL access permissions
2. Link database user to IAM role
3. Grant schema access: `GRANT ALL ON SCHEMA myschema TO <username>`
4. Set ownership: `ALTER SCHEMA myschema OWNER TO <username>`

---

## Authentication & Connection Patterns

### IAM Authentication Token Generation

Aurora DSQL requires IAM authentication tokens instead of traditional passwords. Tokens are short-lived (15 minutes) and must be generated using AWS Signature Version 4.

**Admin Token:**
```bash
aws dsql generate-db-connect-admin-auth-token \
  --hostname <endpoint>.dsql.<region>.on.aws \
  --region <region>
```

**Standard User Token:**
```bash
aws dsql generate-db-connect-auth-token \
  --hostname <endpoint>.dsql.<region>.on.aws \
  --region <region>
```

### Environment Variables Pattern

Configure connection parameters via environment variables:

```bash
export CLUSTER_ENDPOINT="<endpoint>.dsql.<region>.on.aws"
export CLUSTER_USER="admin"  # or non-admin user
export REGION="us-east-1"    # your AWS region
```

### SSL/TLS Configuration

Aurora DSQL requires SSL/TLS with certificate verification:

```
SSL Mode: verify-full (required)
SSL Negotiation: direct (PostgreSQL 17+ drivers for improved performance)
Port: 5432 (PostgreSQL default)
Database: postgres (DSQL creates this automatically)
```

**Key Requirements:**
- Always use `verify-full` to verify server certificate
- Ensure system trust store includes Amazon Root CA
- Use `direct` TLS negotiation for compatible drivers
- Fallback to traditional preamble for older drivers

### Connection Lifecycle

**Single Connection Pattern:**
```
1. Generate IAM token
2. Configure SSL with verify-full
3. Establish connection with token as password
4. Set search_path (public for admin, custom schema for non-admin)
5. Execute operations
6. Close connection
```

**Connection Pooling Pattern (Recommended for Production):**
```
1. Initialize connection pool
2. Configure token refresh hook (before expiration)
3. Set pool parameters:
   - max_connections: 10
   - min_connections: 2
   - connection_lifetime: 50 minutes (before 60-min timeout)
   - idle_timeout: 10 minutes
4. Generate fresh token in BeforeConnect hook
5. Set search_path on each connection acquisition
```

### Schema Selection After Connection

```sql
-- Admin users
SET search_path = public;

-- Non-admin users
SET search_path = myschema;
```

---

## Operations

### Supported CRUD Operations

#### Create Table

```sql
CREATE TABLE IF NOT EXISTS teams (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  nba_id INTEGER NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  abbreviation VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);
```

**Key Points:**
- Use UUID primary keys with `gen_random_uuid()`
- Avoid SERIAL, BIGSERIAL, SMALLSERIAL (unsupported)
- Use `CREATE TABLE IF NOT EXISTS` for idempotency

#### Insert Data

```sql
-- Single row
INSERT INTO teams (nba_id, full_name, abbreviation)
VALUES (1610612737, 'Atlanta Hawks', 'ATL');

-- Multiple rows (up to 3,000 per transaction)
INSERT INTO teams (nba_id, full_name, abbreviation)
VALUES 
  (1610612738, 'Boston Celtics', 'BOS'),
  (1610612739, 'Cleveland Cavaliers', 'CLE'),
  (1610612740, 'New Orleans Pelicans', 'NOP');

-- With RETURNING clause
INSERT INTO teams (nba_id, full_name, abbreviation)
VALUES (1610612741, 'Chicago Bulls', 'CHI')
RETURNING *;
```

#### Query Data

```sql
-- Simple SELECT
SELECT * FROM teams WHERE nba_id = 1610612737;

-- Parameterized queries (recommended)
SELECT id, full_name FROM teams WHERE abbreviation = $1;

-- Joins work normally
SELECT g.game_date, t.full_name
FROM games g
JOIN teams t ON g.home_team_id = t.id
WHERE g.game_date > '2024-01-01';
```

#### Update Data

```sql
-- Update with RETURNING
UPDATE teams 
SET full_name = 'LA Clippers'
WHERE nba_id = 1610612746
RETURNING *;

-- Bulk updates (respect 3,000 row limit)
UPDATE games 
SET status = 'completed'
WHERE game_date < CURRENT_DATE;
```

#### Delete Data

```sql
-- Delete with RETURNING
DELETE FROM teams 
WHERE nba_id = 1610612737
RETURNING id, full_name;

-- Conditional delete
DELETE FROM games 
WHERE game_date < '2020-01-01';
```

### Transaction Patterns

**Transaction Constraints:**
- Cannot mix DDL and DML in same transaction
- Only 1 DDL statement per transaction
- Maximum 3,000 rows modified per transaction (includes all DML statements)
- Transaction isolation level fixed at PostgreSQL Repeatable Read
- Connection timeout after 1 hour

**DDL Transaction:**
```sql
BEGIN;
CREATE TABLE example (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
END;
```

**DML Transaction:**
```sql
BEGIN;
INSERT INTO teams VALUES (...);
UPDATE teams SET ... WHERE ...;
DELETE FROM games WHERE ...;
END;
```

### Unsupported PostgreSQL Features

#### NO: Foreign Key Constraints

```sql
-- ❌ NOT SUPPORTED
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_team_id UUID REFERENCES teams(id) ON DELETE CASCADE
);

-- ✅ USE INSTEAD: UUID without FK constraint
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_team_id UUID NOT NULL  -- No referential integrity
);
```

**Workaround:** Implement application-layer referential integrity validation:
- Validate foreign keys in application code before INSERT/UPDATE
- Handle cascade deletes manually
- Run periodic integrity checks to detect orphaned records

#### NO: Synchronous Indexes

```sql
-- ❌ NOT SUPPORTED
CREATE INDEX idx_teams_nba_id ON teams(nba_id);

-- ❌ NOT SUPPORTED: Index ordering
CREATE INDEX idx_games_date ON games(game_date DESC);

-- ⚠️ ASYNC REQUIRED (may have driver compatibility issues)
CREATE INDEX ASYNC idx_teams_nba_id ON teams(nba_id);
```

**Important:** Some drivers (including Elixir Postgrex) have protocol incompatibilities with `CREATE INDEX ASYNC`. Test thoroughly with your specific driver.

**Workaround Options:**
1. Create indexes manually via psql after schema deployment
2. Rely on DSQL's automatic query optimization
3. Accept full table scans for smaller datasets

#### NO: SERIAL or IDENTITY Columns

```sql
-- ❌ NOT SUPPORTED
CREATE TABLE teams (
  id BIGSERIAL PRIMARY KEY
);

-- ❌ NOT SUPPORTED
CREATE TABLE teams (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

-- ✅ USE INSTEAD
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);
```

**Implications:**
- 16-byte UUID vs 8-byte BIGINT primary keys
- No sequential numeric IDs
- Slightly slower joins (UUID comparison)

#### NO: Sequences

```sql
-- ❌ NOT SUPPORTED
CREATE SEQUENCE team_id_seq;
```

**Workaround:** Use UUID with `gen_random_uuid()` or generate IDs in application layer.

#### NO: Temporary Tables

```sql
-- ❌ NOT SUPPORTED
CREATE TEMPORARY TABLE temp_results AS 
SELECT * FROM games WHERE game_date = CURRENT_DATE;
```

**Workaround:** Use regular tables with cleanup logic or perform operations in application memory.

#### NO: Triggers

```sql
-- ❌ NOT SUPPORTED
CREATE TRIGGER update_timestamp 
BEFORE UPDATE ON teams
FOR EACH ROW EXECUTE FUNCTION update_modified_column();
```

**Workaround:** Implement trigger logic in application layer.

#### NO: Stored Procedures (Non-SQL)

```sql
-- ❌ NOT SUPPORTED: PL/pgSQL, PL/Python, etc.
CREATE FUNCTION calculate_stats() RETURNS void AS $$
BEGIN
  -- procedural logic
END;
$$ LANGUAGE plpgsql;

-- ✅ SQL Functions OK
CREATE FUNCTION get_team_name(team_uuid UUID) RETURNS VARCHAR AS $$
  SELECT full_name FROM teams WHERE id = team_uuid;
$$ LANGUAGE SQL;
```

#### NO: Partitioning

```sql
-- ❌ NOT SUPPORTED
CREATE TABLE games_2024 PARTITION OF games
FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');
```

#### NO: Extensions

Aurora DSQL does not support any PostgreSQL extensions:
- ❌ PL/pgSQL
- ❌ PostGIS
- ❌ PGVector
- ❌ PGAudit
- ❌ postgres_fdw
- ❌ pg_cron
- ❌ pg_stat_statements

#### NO: Multiple Databases

Aurora DSQL provides a single database named `postgres`. You cannot:
- Create additional databases
- Rename the postgres database
- Drop the postgres database
- Use `GRANT ... ON DATABASE` syntax

**Workaround:** Use schemas to organize objects within the postgres database.

#### NO: TRUNCATE

```sql
-- ❌ NOT SUPPORTED
TRUNCATE TABLE teams;

-- ✅ USE INSTEAD
DELETE FROM teams;
```

#### NO: VACUUM

```sql
-- ❌ NOT SUPPORTED (and not needed)
VACUUM ANALYZE teams;
```

**Note:** DSQL manages storage optimization automatically.

#### NO: DO Blocks

```sql
-- ❌ NOT SUPPORTED
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM teams WHERE nba_id = 12345) THEN
    INSERT INTO teams VALUES (...);
  END IF;
END $$;

-- ✅ USE INSTEAD: Multiple statements
SELECT COUNT(*) FROM teams WHERE nba_id = 12345;
-- Check result in application, then:
INSERT INTO teams VALUES (...);
```

### Additional Constraints

**Character Encoding:**
- UTF-8 only (cannot be changed)

**Collation:**
- C collation only

**Timezone:**
- System timezone is UTC
- Can set `TimeZone` parameter for display/client input

**Database Connections:**
- Timeout after 1 hour
- Contact AWS support for connection limit increases

**Schema Permissions:**
- Non-admin users cannot create objects in public schema
- Non-admin users must use custom schemas
- Admin can grant read/write to public schema objects but not CREATE permission

### Useful Reading

- [Unsupported PostgreSQL features](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-unsupported-features.html)
- [PostgreSQL compatibility considerations](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility.html)
- [Cluster quotas and limits](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/quotas-limits.html)

---

## Implementation Checklist

### Initial Setup

- [ ] Provision Aurora DSQL cluster in target region
- [ ] Configure IAM permissions for DSQL access
- [ ] Install and configure AWS CLI
- [ ] Set up environment variables (CLUSTER_ENDPOINT, CLUSTER_USER, REGION)
- [ ] Install language-specific AWS SDK
- [ ] Install PostgreSQL-compatible database driver

### Connection Configuration

- [ ] Initialize AWS SDK client for DSQL token generation
- [ ] Implement token generation function (admin or standard)
- [ ] Configure SSL/TLS with verify-full mode
- [ ] Enable direct TLS negotiation if driver supports PostgreSQL 17+
- [ ] Set database connection parameters (hostname, port, database name)
- [ ] Test basic connectivity with generated token

### Schema Management

- [ ] Design schema using supported data types (UUID primary keys)
- [ ] Avoid unsupported features (SERIAL, FOREIGN KEY, indexes)
- [ ] Create schema deployment scripts
- [ ] Test DDL operations (may require manual execution via psql)
- [ ] Document schema deployment procedure

### Application Integration

- [ ] Implement connection pooling with token refresh
- [ ] Set search_path after connection establishment
- [ ] Implement application-layer referential integrity checks
- [ ] Add validation for foreign key relationships
- [ ] Implement manual cascade delete logic where needed
- [ ] Add transaction wrapping for DML operations
- [ ] Respect 3,000 row modification limit per transaction

### Testing & Validation

- [ ] Test CRUD operations (INSERT, SELECT, UPDATE, DELETE)
- [ ] Test parameterized queries
- [ ] Test transaction handling
- [ ] Verify token refresh works before 15-minute expiration
- [ ] Test connection pool behavior
- [ ] Validate application-layer integrity checks
- [ ] Performance test with expected data volumes

### Production Readiness

- [ ] Configure monitoring and alerting
- [ ] Set up connection pool sizing appropriately
- [ ] Implement error handling for token expiration
- [ ] Document operational procedures
- [ ] Plan for schema changes and deployment
- [ ] Implement integrity verification jobs (if using FK workarounds)

---

## Language-Specific Implementation Guides

### Python (psycopg/psycopg2/SQLAlchemy)

- Use `boto3` for IAM token generation
- Check `pq.version()` for direct TLS support (PostgreSQL 17+)
- Use context managers for connection handling
- Configure `sslmode='verify-full'` in connection string
- Example: See `experiments/aurora-dsql-samples/python/psycopg/`

### Go (pgx)

- Use `aws-sdk-go-v2/feature/dsql/auth` for token generation
- Implement `BeforeConnect` hook for token refresh
- Use `pgxpool` for connection pooling
- Configure `sslmode=verify-full` in connection string
- Example: See `experiments/aurora-dsql-samples/go/pgx/`

### JavaScript/TypeScript (node-postgres, postgres-js)

- Use `@aws-sdk/dsql-signer` for token generation
- Configure SSL with `rejectUnauthorized: true`
- Handle async/await properly for token generation
- Set `ssl.mode: 'verify-full'` in connection config
- Example: See `experiments/aurora-dsql-samples/javascript/node-postgres/`

### Java (pgjdbc)

- Use Aurora DSQL JDBC Connector for automatic IAM auth
- JDBC URL format: `jdbc:aws-dsql:postgresql://<endpoint>:5432/postgres`
- Use `DefaultJavaSSLFactory` for SSL verification
- Connection pooling via HikariCP recommended
- Example: See `experiments/aurora-dsql-samples/java/pgjdbc/`

### Rust (sqlx)

- Use `aws-sdk-dsql` for token generation
- Implement periodic token refresh with `tokio::spawn`
- Use `after_connect` hook for schema setup (`SET search_path`)
- Configure `sslmode=verify-full` in connection string
- Example: See `experiments/aurora-dsql-samples/rust/sqlx/`

### Elixir (Postgrex)

- Use AWS CLI via `System.cmd/3` for token generation (or implement with AWS SDK)
- Configure SSL in Postgrex options with `:verify_peer` and `:public_key.cacerts_get()`
- Set search_path after connection via `Postgrex.query!/3`
- **Important:** Postgrex has protocol incompatibility with DDL operations (CREATE TABLE, CREATE INDEX)
- **Workaround:** Deploy schema manually via psql, use Postgrex only for DML (SELECT/INSERT/UPDATE/DELETE)
- Example: See `experiments/aurora-dsql-samples/elixir/postgrex/`

---

## Security Best Practices

### Credential Management

- **Never hardcode credentials** in source code or configuration files
- Use environment variables or AWS Secrets Manager for connection parameters
- Leverage IAM roles for applications running on AWS (EC2, ECS, Lambda)
- Rotate tokens before expiration (generate fresh token every 10-12 minutes)

### IAM Authentication

- **Always use IAM authentication** - never attempt password-based auth
- Grant least privilege IAM permissions (`dsql:DbConnect` for read/write, `dsql:DbConnectAdmin` for admin)
- Use separate IAM roles for different application tiers (read-only vs read-write)
- Link database roles to IAM roles for non-admin users
- Monitor IAM access logs for unauthorized connection attempts

### SSL/TLS

- **Always use SSL/TLS** with `verify-full` mode
- Ensure system trust store includes Amazon Root CA certificates
- Never disable certificate verification in production
- Use direct TLS negotiation when driver supports it (reduced handshake overhead)

### Connection Security

- Use connection pooling to minimize token generation overhead
- Set appropriate connection timeouts (DSQL enforces 1-hour max)
- Implement connection retry logic with exponential backoff
- Monitor connection pool metrics (active connections, wait time)

### Data Protection

- Implement application-layer encryption for sensitive data
- Use parameterized queries to prevent SQL injection
- Validate and sanitize all user input before queries
- Audit database access patterns regularly

### Schema Permissions

- Admin users: Grant minimum necessary permissions to non-admin users
- Non-admin users: Work exclusively in assigned schemas
- Never grant CREATE permission on public schema to non-admin users
- Use schema-level permissions to isolate data access

---

## Common Pitfalls

### Token Expiration

**Issue:** IAM tokens expire after 15 minutes. Cached tokens cause authentication failures.

**Solution:**
- Generate fresh token for each new connection
- Implement token refresh in connection pool `BeforeConnect` hook
- Monitor for `access denied` errors and regenerate token
- Set token refresh interval to 10-12 minutes (before expiration)

### Protocol Incompatibilities

**Issue:** Some drivers (e.g., Elixir Postgrex) have protocol message handling incompatibilities with DSQL, particularly for DDL operations.

**Solution:**
- Test DDL operations (CREATE TABLE, CREATE INDEX) with your specific driver
- If DDL fails, deploy schema manually via psql or AWS CloudShell
- Use driver only for DML operations (SELECT, INSERT, UPDATE, DELETE)
- Document driver limitations in deployment procedures

### Foreign Key Constraints Missing

**Issue:** DSQL does not enforce foreign key constraints. Orphaned records are possible.

**Solution:**
- Implement foreign key validation in application layer before INSERT/UPDATE
- Add checks in ORM changeset validations or application logic
- Create periodic integrity verification jobs to detect orphans
- Implement manual cascade delete functions
- Example validation:
  ```sql
  -- Before inserting game record
  SELECT COUNT(*) FROM teams WHERE id = $1;  -- Verify home_team_id exists
  SELECT COUNT(*) FROM teams WHERE id = $2;  -- Verify away_team_id exists
  -- Then insert if both exist
  ```

### Index Creation Failures

**Issue:** `CREATE INDEX` (synchronous) not supported. `CREATE INDEX ASYNC` may fail with some drivers.

**Solution:**
- Create indexes manually via psql after schema deployment
- Test `CREATE INDEX ASYNC` with your specific driver
- If indexes critical, create them outside migration system
- Monitor query performance and add indexes as needed
- Consider query restructuring if indexes unavailable

### SERIAL/IDENTITY Not Available

**Issue:** Auto-increment integer types unsupported.

**Solution:**
- Use UUID primary keys with `gen_random_uuid()`
- Accept larger key size (16 bytes vs 8 bytes)
- If sequential IDs needed, generate in application layer using atomic counters

### Transaction Row Limits

**Issue:** Maximum 3,000 rows can be modified per transaction (includes INSERT, UPDATE, DELETE).

**Solution:**
- Batch large operations into chunks of ≤3,000 rows
- Process batches in separate transactions
- Monitor row counts before transactions
- Example:
  ```python
  # Split 10,000 inserts into 4 transactions
  for batch in chunk_list(records, 3000):
      with transaction():
          db.execute_many("INSERT INTO ...", batch)
  ```

### Connection Timeout

**Issue:** Database connections timeout after 1 hour.

**Solution:**
- Set connection pool `max_lifetime` to 50-55 minutes
- Implement connection health checks
- Close idle connections after 10-15 minutes
- Let pool recreate connections automatically

### Mixed DDL and DML in Transactions

**Issue:** Cannot mix DDL (CREATE, ALTER, DROP) and DML (INSERT, UPDATE, DELETE) in same transaction.

**Solution:**
- Separate DDL and DML into distinct transactions
- Run schema changes in dedicated deployment step
- Execute data migrations after schema deployment

### Schema Access for Non-Admin Users

**Issue:** Non-admin users cannot create objects in public schema.

**Solution:**
- Create custom schema: `CREATE SCHEMA myschema;`
- Grant ownership: `ALTER SCHEMA myschema OWNER TO myuser;`
- Set search_path: `SET search_path = myschema;`
- Grant appropriate permissions to schema

### SSL Certificate Verification

**Issue:** System trust store missing Amazon Root CA certificates.

**Solution:**
- Ensure operating system CA bundle up to date
- For containers, use base images with updated CA certificates
- Manually install Amazon Root CAs if needed
- Never disable certificate verification

### Connection Pool Token Refresh

**Issue:** All pooled connections use expired token simultaneously.

**Solution:**
- Generate fresh token in connection pool's `BeforeConnect` hook
- Token generated per connection acquisition, not pool initialization
- Implement token caching with expiration tracking (optional optimization)
- Monitor connection acquisition errors for auth failures

### Query Performance Without Indexes

**Issue:** All queries perform full table scans without indexes.

**Solution:**
- Keep tables small (under 100k rows) or accept slower queries
- Denormalize data to reduce joins
- Use query result caching in application layer
- Consider alternative database if query performance critical
- Monitor query execution time and optimize SQL

### Integrity Verification Overhead

**Issue:** Application-layer foreign key checks add query overhead.

**Solution:**
- Cache frequently accessed reference data (teams, seasons)
- Batch validation queries where possible
- Run integrity checks asynchronously
- Accept eventual consistency for non-critical relationships
- Balance between performance and data quality

---

## Additional Resources

### Official Documentation

- [Aurora DSQL User Guide](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/what-is-aurora-dsql.html)
- [Getting Started Guide](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/getting-started.html)
- [IAM Authentication](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html)
- [PostgreSQL Compatibility](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility.html)
- [Unsupported Features](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-unsupported-features.html)
- [API Reference](https://docs.aws.amazon.com/aurora-dsql/latest/APIReference/Welcome.html)
- [CLI Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/dsql/index.html)

### Code Samples

- [aurora-dsql-samples Repository](https://github.com/aws-samples/aurora-dsql-samples)
- Language-specific examples: Python, Go, JavaScript, Java, Rust, Elixir, Ruby, C++, .NET

### Tools

- [AWS CloudShell](https://console.aws.amazon.com/cloudshell) - Browser-based shell with psql pre-installed
- [DBeaver](https://dbeaver.io/) - Universal database tool with PostgreSQL support
- [DataGrip](https://www.jetbrains.com/datagrip/) - JetBrains database IDE
- [psql](https://www.postgresql.org/docs/current/app-psql.html) - PostgreSQL command-line client

### Support

- AWS Support Console for technical issues
- GitHub Issues on aurora-dsql-samples repository for sample-related questions
- AWS re:Post for community questions

---

## Document History

- **v1.0** (2025-11-25): Initial comprehensive steering guide based on official samples, common recipe patterns, and real-world Elixir implementation experience

---

**Note:** This is a living document. As Aurora DSQL evolves and new patterns emerge, this guide will be updated. Check the official AWS documentation for the latest service updates and capabilities.
