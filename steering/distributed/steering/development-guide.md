# DSQL Development 

DSQL is the **PREFERRED** relational database. This decision was made for fast serverless distributed SQL, 
effortless scaling, multi-region viability, among other advantages.

---


## Best Practices

- **SHOULD read guidelines first** - Check [development_guide.md](steering/development-guide.md) before making schema changes
- **SHOULD Execute queries directly** - PREFER MCP tools for ad-hoc queries 
- **REQUIRED: Follow DDL Guidelines** - Refer to [DDL Rules](#ddl-rules)
- **SHALL repeatedly generate fresh tokens** - Refer to [Connection Limits](#connection-limits)
- **ALWAYS use ASYNC indexes** - `CREATE INDEX ASYNC` is mandatory
- **ALWAYS validate references in code** - implement referential integrity at the application layer 
- **MUST Serialize arrays/JSON as TEXT** - Store arrays/JSON as TEXT (comma separated, JSON.stringify)
- **ALWAYS Include tenant_id everywhere** - First parameter in all queries for isolation
- **ALWAYS Batch under 3,000 rows** - maintain transaction limits
- **REQUIRED: Use parameterized queries** - Prevent SQL injection with $1, $2 placeholders
- **ALWAYS Check dependents before delete** - Implement cascade logic in application
- **REQUIRED use DELETE for truncation** - DELETE is the only supported operation for truncation
- **SHOULD test any migrations** - Verify DDL on dev clusters before production
- **SHOULD use partial indexes** - For sparse data with WHERE clauses
- **Plan for Scale** - DSQL is designed to optimize for massive scales without latency drops

---


## Basic Development Guidelines

### Connection and Authentication

#### IAM Authentication

**Principle of least privilege:**
- Grant only `dsql:DbConnect` for standard users
- Reserve `dsql:DbConnectAdmin` for administrative operations
- Link database roles to IAM roles for proper access control
- Use IAM policies to restrict cluster access by resource tags

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dsql:DbConnect",
      "Resource": "arn:aws:dsql:us-east-1:123456789012:cluster/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "production"
        }
      }
    }
  ]
}
```

#### Token Management
**Rotation strategies:**
- Generate fresh token per connection (simplest, most secure)
- Implement periodic refresh before 15-minute expiration
- Use connection pool hooks for automated refresh
- Handle token expiration gracefully with retry logic

**Best practices:**
- Never log or persist authentication tokens
- Regenerate token on connection errors
- Monitor token generation failures
- Set connection timeouts appropriately

#### Secrets Management
**Never hardcode credentials:**
- Use environment variables for configuration
- Store cluster endpoints in AWS Systems Manager Parameter Store
- Use AWS Secrets Manager for any sensitive configuration
- Rotate credentials regularly even though tokens are short-lived

```bash
# Good - Use Parameter Store
export CLUSTER_ENDPOINT=$(aws ssm get-parameter \
  --name /myapp/dsql/endpoint \
  --query 'Parameter.Value' \
  --output text)

# Bad - Hardcoded in code
const endpoint = "abc123.dsql.us-east-1.on.aws" // ❌ Never do this
```

#### Limits
- 15-minute token expiry
- 60-minute connection maximum
- 10,000 connections per cluster
- SSL required

### DDL Rules
- One DDL statement per operation
- No DDL in transactions
- All indexes must use ASYNC
- To add a column with DEFAULT or NOT NULL:
  - MUST issue ADD COLUMN specifying only the column name and data type
  - MUST then issue UPDATE to populate existing rows
  - MAY then issue ALTER COLUMN to apply the constraint
- MUST issue a separate ALTER TABLE statement for each column modification.

### Transaction 
- Should modify **up to 3000 rows** per transaction
- Should maintain **10 MiB data size** per write transaction
- Should expect **5-minute** transaction duration 
- Should always expect repeatable read isolation

### Audit Logging

**CloudTrail integration:**
- Enable CloudTrail logging for DSQL API calls
- Monitor token generation patterns
- Track cluster configuration changes
- Set up alerts for suspicious activity

**Query logging:**
- Enable query logging if available
- Monitor slow queries and connection patterns
- Track failed authentication attempts
- Review logs regularly for anomalies

### Access Control

**Database-level security:**
- Create schema-specific users for applications
- Grant minimal required privileges (SELECT, INSERT, UPDATE, DELETE)
- Admin users should only perform administrative tasks
- Regularly audit user permissions and access patterns

**Example IAM policy for non-admin users:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dsql:DbConnect",
      "Resource": "arn:aws:dsql:*:*:cluster/*"
    }
  ]
}
```

---

## Operational Rules

### Query Execution

---

## Critical Constraints

### Transaction Limits
- **3,000 row modifications** per transaction maximum
- **10 MiB data size** per write transaction
- **5-minute duration** maximum per transaction
- **Repeatable Read isolation** only (fixed, cannot change)

### DDL Restrictions
- **One DDL per transaction** - Never mix DDL statements
- **No DDL/DML mixing** - Separate schema changes from data changes
- **No rollback** - DDL changes are permanent
- **Async execution** - All DDL runs asynchronously
- **No transactions** - Execute each DDL individually

### Unsupported PostgreSQL Features

#### Critical Missing Features
- **NO Foreign Key enforcement** (can define but not enforced)
- **NO Arrays as column types** (use TEXT with serialization)
- **NO JSON/JSONB columns** (store as TEXT)
- **NO Triggers**
- **NO Stored Procedures** (PL/pgSQL not supported)
- **NO Sequences** (use UUIDs)
- **NO TRUNCATE**
- **NO Temporary tables**
- **NO Materialized views**
- **NO Extensions** (PostGIS, PGVector, etc.)

#### ALTER TABLE Limitations
- **One column at a time** - No multi-column ALTER
- **No DEFAULT in ADD COLUMN** - Add column, then UPDATE
- **No NOT NULL in ADD COLUMN** - Add nullable, handle in app
- **No DROP CONSTRAINT** - Constraints are permanent

#### Index Requirements
- **MUST use CREATE INDEX ASYNC** - No synchronous creation
- **24 indexes per table** maximum
- **8 columns per index** maximum

### Connection Management
- **15-minute token expiry** - Generate fresh tokens
- **SSL required** - All connections must use SSL
- **60-minute connection limit** - Maximum connection duration

---

## Operational Rules

### Query Execution

**For Ad-Hoc Queries and Data Exploration:**
- MUST ALWAYS Execute DIRECTLY using MCP server or psql one-liners
- SHOULD Return results immediately

**Writing Scripts REQUIRES at least 1 of:**
- Permanent migrations in database
- Reusable utilities
- EXPLICIT user request


### Schema Design Rules

- Use simple PostgreSQL types: VARCHAR, TEXT, INTEGER, BOOLEAN, TIMESTAMP
- Store arrays as TEXT (comma-separated or JSON.stringify)
- Store JSON objects as TEXT
- Always include tenant_id in tables for multi-tenant isolation
- Create async indexes for tenant_id and common query patterns
- Use partial indexes for sparse data (WHERE column IS NOT NULL)

### Application-Layer Patterns

**MANDATORY for Referential Integrity:**
- Validate parent references before INSERT
- Check for dependents before DELETE
- Implement cascade logic in application code
- Handle orphaned records in application layer

**MANDATORY for Multi-Tenant Isolation:**
- tenantId is ALWAYS first parameter in repository methods
- ALL queries include WHERE tenant_id = ?
- NEVER allow cross-tenant data access
- Validate tenant ownership before operations

### Migration Patterns

- One DDL statement per migration step
- Use IF NOT EXISTS for idempotency
- Add column first, then UPDATE with defaults
- Cannot use DEFAULT or NOT NULL in ADD COLUMN
- Each DDL executes separately (no BEGIN/COMMIT)

---

## DSQL Best Practices

### General Tips

1. **Execute directly** - Use MCP tools for queries, not temporary scripts
2. **Read constraints first** - Check dsql.md steering file before schema changes
3. **Validate in application** - Implement foreign key logic in your code
4. **Serialize complex types** - Store arrays/JSON as TEXT
5. **Batch carefully** - Keep well under 3,000 row limit
6. **Index strategically** - Use ASYNC, focus on tenant_id and common filters
7. **Test migrations** - Verify DDL on dev cluster before production
8. **Monitor token expiry** - Reconnect if seeing auth errors
9. **Use partial indexes** - For sparse data with WHERE clause
10. **Plan for scale** - DSQL is built for massive scale, design accordingly

### DDL Requirements
- One DDL statement per operation
- No DDL in transactions
- All indexes must use ASYNC
- To add a column with DEFAULT or NOT NULL:
  - MUST issue ADD COLUMN specifying only the column name and data type
  - MUST then issue UPDATE to populate existing rows
  - MAY then issue ALTER COLUMN to apply the constraint
- MUST issue a separate ALTER TABLE statement for each column modification.

### Connection Limits
- 15-minute token expiry
- 60-minute connection maximum
- 10,000 connections per cluster
- SSL required

---

## Quick Reference

### Schema Operations
```sql
CREATE INDEX ASYNC idx_name ON table(column);          ← ALWAYS ASYNC
ALTER TABLE t ADD COLUMN c VARCHAR(50);                ← ONE AT A TIME
ALTER TABLE t ADD COLUMN c2 INTEGER;                   ← SEPARATE STATEMENT
UPDATE table SET c = 'default' WHERE c IS NULL;        ← AFTER ADD COLUMN
```

### Supported Data Types
```
VARCHAR, TEXT, INTEGER, DECIMAL, BOOLEAN, TIMESTAMP, UUID
```

### Supported Key
```
PRIMARY KEY, UNIQUE, NOT NULL, CHECK, DEFAULT (in CREATE TABLE)
```

Join on any keys; must enforce referential integrity at application layer. 

### Transaction Requirements
```
Rows: 3,000 max
Size: 10 MiB max
Duration: 5 minutes max
Isolation: Repeatable Read (fixed)
```
