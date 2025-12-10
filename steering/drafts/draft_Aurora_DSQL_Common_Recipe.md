# Aurora DSQL Common Recipe

This document outlines the common patterns used across all Aurora DSQL client samples.

## Prerequisites

- AWS account with configured credentials
- Aurora DSQL cluster endpoint
- IAM permissions for DSQL access
- For non-admin users: IAM role linked to database user with schema access

## Environment Variables

All samples require these environment variables:

```bash
export CLUSTER_ENDPOINT="<endpoint>.dsql.<region>.on.aws"
export CLUSTER_USER="admin" # or non-admin user
export REGION="us-east-1" # your AWS region
```

## Connection Pattern

### 1. Authentication Token Generation

Generate IAM authentication tokens using AWS SDK:

- **Admin user**: Use admin token generation method
- **Non-admin user**: Use standard token generation method
- **Token expiry**: Tokens are short-lived (typically 15 minutes)
- **Refresh strategy**: Generate fresh token for each connection or periodically refresh

### 2. SSL/TLS Configuration

```
sslmode: verify-full
sslnegotiation: direct # PostgreSQL 17+ drivers
port: 5432
database: postgres
```

- Use `verify-full` SSL mode to verify server certificate
- Use `direct` TLS negotiation for PostgreSQL 17+ compatible drivers (improved performance)
- Fall back to traditional preamble for older drivers

### 3. Schema Selection

Set search path after connection:

- **Admin user**: `SET search_path = public`
- **Non-admin user**: `SET search_path = myschema`

### 4. Connection Pooling (Recommended)

For production applications:

- Implement connection pooling
- Configure token refresh before expiration
- Set appropriate pool size (e.g., max: 10, min: 2)
- Configure connection lifetime and idle timeout
- Generate fresh token in `BeforeConnect` or equivalent hook

## Standard Operations

### Create Table

```sql
CREATE TABLE IF NOT EXISTS owner (
id UUID NOT NULL DEFAULT gen_random_uuid(),
name VARCHAR(30) NOT NULL,
city VARCHAR(80) NOT NULL,
telephone VARCHAR(20) DEFAULT NULL,
PRIMARY KEY (id)
)
```

### Insert Data

```sql
INSERT INTO owner (name, city, telephone)
VALUES ('John Doe', 'Anytown', '555-555-1999')
```

### Query Data

```sql
SELECT * FROM owner WHERE name = 'John Doe'
```

### Delete Data

```sql
DELETE FROM owner WHERE name = 'John Doe'
```

## Implementation Checklist

- [ ] Load environment variables (CLUSTER_ENDPOINT, CLUSTER_USER, REGION)
- [ ] Initialize AWS SDK client for DSQL
- [ ] Generate authentication token (admin or standard)
- [ ] Configure SSL/TLS with verify-full mode
- [ ] Enable direct TLS negotiation if driver supports it
- [ ] Establish database connection
- [ ] Set search_path based on user type
- [ ] Implement connection pooling with token refresh
- [ ] Execute database operations
- [ ] Clean up resources on exit

## Language-Specific Notes

### Python (psycopg/psycopg2)

- Use `boto3` for token generation
- Check `pq.version()` for direct TLS support
- Use context managers for connection handling

### Go (pgx)

- Use `aws-sdk-go-v2/feature/dsql/auth` for tokens
- Implement `BeforeConnect` hook for token refresh
- Use `pgxpool` for connection pooling

### JavaScript/TypeScript (node-postgres)

- Use `@aws-sdk/dsql-signer` for token generation
- Configure SSL with `rejectUnauthorized: true`
- Handle async/await properly

### Java (pgJDBC)

- Use Aurora DSQL JDBC Connector for automatic IAM auth
- JDBC URL format: `jdbc:aws-dsql:postgresql://<endpoint>`
- Use `DefaultJavaSSLFactory` for SSL verification

### Rust (sqlx)

- Use `aws-sdk-dsql` for token generation
- Implement periodic token refresh with `tokio::spawn`
- Use `after_connect` hook for schema setup

## Security Best Practices

- Never hardcode credentials
- Use IAM authentication exclusively
- Always use SSL/TLS with certificate verification
- Grant least privilege IAM permissions
- Rotate tokens before expiration
- Use connection pooling to minimize token generation overhead

## Common Pitfalls

- **Expired tokens**: Generate fresh token for each connection or refresh periodically
- **SSL verification**: Ensure system trust store includes Amazon Root CA
- **Schema access**: Non-admin users must have explicit schema grants
- **Connection limits**: Configure appropriate pool sizes
- **Direct TLS**: Verify driver version supports direct negotiation

## Additional Resources

- [Aurora DSQL Documentation](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/)
- [IAM Authentication](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html)
- [Getting Started Guide](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/getting-started.html)
