# Developing in DSQL

*A practical guide for effective Aurora DSQL development*

## Prerequisites

- AWS account with configured credentials
- Aurora DSQL cluster endpoint
- IAM permissions for DSQL access (`dsql:DbConnect` or `dsql:DbConnectAdmin`)
- For non-admin users: IAM role linked to database user with schema access

## Environment Variables

Set these for your development environment:

```bash
export CLUSTER_ENDPOINT="<cluster-id>.dsql.<region>.on.aws"
export CLUSTER_USER="admin"  # or custom user
export REGION="us-west-2"     # your AWS region
```

## Connection Configuration

### Authentication Token Generation

Aurora DSQL uses [IAM authentication with temporary tokens](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html):

- **Admin users**: Generate admin tokens (15-minute expiry by default)
- **Standard users**: Generate standard tokens
- **Token refresh**: Generate fresh token per connection or implement periodic refresh

**AWS CLI pattern:**
```bash
# Admin token
aws dsql generate-db-connect-admin-auth-token \
  --hostname $CLUSTER_ENDPOINT \
  --region $REGION

# Standard user token  
aws dsql generate-db-connect-auth-token \
  --hostname $CLUSTER_ENDPOINT \
  --region $REGION
```

### SSL/TLS Requirements

Aurora DSQL uses the [PostgreSQL wire protocol](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility.html) and enforces SSL:

```
sslmode: verify-full
sslnegotiation: direct      # PostgreSQL 17+ drivers (better performance)
port: 5432
database: postgres           # single database per cluster
```

**Key details:**
- SSL always enabled server-side
- Use `verify-full` to verify server certificate
- Use `direct` TLS negotiation for PostgreSQL 17+ compatible drivers
- System trust store must include Amazon Root CA

### Schema Selection

Set search path immediately after connection:

```sql
SET search_path = public      -- admin users
SET search_path = myschema    -- non-admin users
```

Non-admin users cannot create objects in `public` schema.

### Connection Pooling

For production applications:

- Implement connection pooling with token refresh hooks
- Configure pool size appropriately (e.g., max: 10, min: 2)
- Generate fresh token in `BeforeConnect` or equivalent hook
- Set connection lifetime to account for 1-hour connection timeout
- Configure idle timeout appropriately

## Language-Specific Notes

### Python
ALWAYS use the DSQL Python Connector for automatic IAM Auth:
- See [https://github.com/awslabs/aurora-dsql-python-connector](https://github.com/awslabs/aurora-dsql-python-connector)
- See sample: [aurora-dsql-samples/python/jupyter](https://github.com/aws-samples/aurora-dsql-samples/blob/main/python/jupyter/) 
- Compatible support in both: psycopg and psycopg2, install only the needed library 
  - **psycopg2**
    - synchronous
    - `import aurora_dsql_psycopg2 as dsql` 
    - See [aurora-dsql-samples/python/psycopg2](https://github.com/aws-samples/aurora-dsql-samples/tree/main/python/psycopg2)
  - **psycopg**
    - modern async/sync
    - `import aurora_dsql_psycopg as dsql`
    - See [aurora-dsql-samples/python/psycopg](https://github.com/aws-samples/aurora-dsql-samples/tree/main/python/psycopg)

**SQLAlchemy**
- ALWAYS use psycopg2 with SQLAlchemy
- See [aurora-dsql-samples/python/sqlalchemy](https://github.com/aws-samples/aurora-dsql-samples/tree/main/python/sqlalchemy)

### Go

**pgx** (recommended)
- Use `aws-sdk-go-v2/feature/dsql/auth` for token generation
- Implement `BeforeConnect` hook: `config.BeforeConnect = func() { cfg.Password = token }`
- Use `pgxpool` for connection pooling with max lifetime < 1 hour
- Set `sslmode=verify-full` in connection string
- See [aurora-dsql-samples/go/pgx](https://github.com/aws-samples/aurora-dsql-samples/tree/main/go/pgx)

### JavaScript/TypeScript
PREFER using node-postgres or postgres-js with the DSQL Node.js Connector

**node-postgres (pg)** (recommended)
- Use `@aws/aurora-dsql-node-postgres-connector` for automatic IAM auth
- See [aurora-dsql-samples/javascript/node-postgres](https://github.com/awslabs/aurora-dsql-nodejs-connector/tree/main/packages/node-postgres)

**postgres.js** (recommended)
- Lightweight alternative with `@aws/aurora-dsql-node-postgres-connector`
- Good for serverless environments
- See [aurora-dsql-samples/javascript/postgres-js](https://github.com/awslabs/aurora-dsql-nodejs-connector/tree/main/packages/postgres-js)

**Prisma**
- Custom `directUrl` with token refresh middleware
- See [aurora-dsql-samples/typescript/prisma](https://github.com/aws-samples/aurora-dsql-samples/tree/main/typescript/prisma)

**Sequelize**
- Configure `dialectOptions` for SSL
- Token refresh in `beforeConnect` hook
- See [aurora-dsql-samples/typescript/sequelize](https://github.com/aws-samples/aurora-dsql-samples/tree/main/typescript/sequelize)

**TypeORM**
- Custom DataSource with token refresh
- Create migrations table manually via psql
- See [aurora-dsql-samples/typescript/type-orm](https://github.com/aws-samples/aurora-dsql-samples/tree/main/typescript/type-orm)

### Java

**JDBC** (PostgreSQL JDBC Driver)
- Use Aurora DSQL JDBC Connector for automatic IAM auth
  - URL format: `jdbc:aws-dsql:postgresql://<endpoint>/postgres`
  - See [aurora-dsql-samples/java/pgjdbc](https://github.com/aws-samples/aurora-dsql-samples/tree/main/java/pgjdbc)
- Properties: `wrapperPlugins=iam`, `ssl=true`, `sslmode=verify-full`

**HikariCP** (Connection Pooling)
- Wrap JDBC connection, configure max lifetime < 1 hour
- See [aurora-dsql-samples/java/pgjdbc_hikaricp](https://github.com/aws-samples/aurora-dsql-samples/tree/main/java/pgjdbc_hikaricp)

### Rust

**SQLx** (async)
- Use `aws-sdk-dsql` for token generation
- Connection format: `postgres://admin:{token}@{endpoint}:5432/postgres?sslmode=verify-full`
- Use `after_connect` hook: `.after_connect(|conn, _| conn.execute("SET search_path = public"))`
- Implement periodic token refresh with `tokio::spawn`
- See [aurora-dsql-samples/rust/sqlx](https://github.com/aws-samples/aurora-dsql-samples/tree/main/rust/sqlx)

**Tokio-Postgres** (lower-level async)
- Direct control over connection lifecycle
- Use `Arc<Mutex<String>>` for shared token state
- Handle connection errors with retry logic

### Elixir

**Postgrex**
- MUST use Erlang/OTP 26+
- Driver: [Postgrex](https://hexdocs.pm/postgrex/) ~> 0.19
  - Use Postgrex.query! for all queries
  - See [aurora-dsql-samples/elixir/postgrex](https://github.com/aws-samples/aurora-dsql-samples/tree/main/elixir/postgrex)
- Connection: Implement `Repo.init/2` callback for dynamic token injection
  - MUST set `ssl: true` with `ssl_opts: [verify: :verify_peer, cacerts: :public_key.cacerts_get()]`
  - MAY prefer AWS CLI via `System.cmd` to call `generate-db-connect-auth-token`

## Schema Management

### Transaction Constraints

**Each DDL statement must be in its own transaction:**

```sql
BEGIN;
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);
END;
```

**Transaction rules:**
- Cannot mix DDL and DML in same transaction
- Only 1 DDL statement per transaction
- DML transactions can modify up to 3,000 rows
- Transaction isolation level fixed at Repeatable Read

### Primary Keys

Use UUID with `gen_random_uuid()` instead of SERIAL types:

```sql
-- Use this pattern
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- NOT this
id SERIAL PRIMARY KEY  -- unsupported macro type
```

### Index Creation

Indexes must be created asynchronously without ordering:

```sql
-- Correct
CREATE INDEX ASYNC idx_name ON table_name (column_name);

-- Incorrect
CREATE INDEX idx_name ON table_name (column_name ASC);  -- ASC/DESC unsupported
```

DSQL automatically manages statistics and storage optimization without manual `VACUUM` commands.

### Deployment Strategy

**CloudShell method (recommended):**

```bash
# Generate token
TOKEN=$(aws dsql generate-db-connect-admin-auth-token \
  --region $REGION \
  --hostname $CLUSTER_ENDPOINT)

# Connect and execute DDL
PGPASSWORD="$TOKEN" psql \
  -h $CLUSTER_ENDPOINT \
  -p 5432 \
  -U admin \
  -d postgres \
  -f your_schema.sql
```

Requires psql 10+ for SNI support.

## Security Best Practices

### IAM Authentication

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

### Token Management

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

### Secrets Management

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

### Network Security

**SSL/TLS requirements:**
- Always use `sslmode=verify-full` for certificate verification
- Ensure system trust store includes Amazon Root CA certificates
- Use `direct` TLS negotiation for PostgreSQL 17+ drivers
- Never disable SSL certificate verification

**Private connectivity:**
- Consider AWS PrivateLink for private network access
- Restrict security group rules to minimum required ports
- Use VPC endpoints where applicable
- Monitor network traffic with VPC Flow Logs

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

## Additional Resources

- [Aurora DSQL Documentation](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/)
- [IAM Authentication Guide](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html)
- [Getting Started Guide](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/getting-started.html)
- [PostgreSQL Compatibility](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility.html)
- [Unsupported Features List](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-unsupported-features.html)
- [Code Samples Repository](https://github.com/aws-samples/aurora-dsql-samples)
- [CloudFormation Resource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dsql-cluster.html)

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-02  
**Status**: Living document - update as patterns evolve
