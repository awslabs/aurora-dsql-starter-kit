# Aurora DSQL Common Recipe (one doc)

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

# Aurora DSQL Onboarding / Build Checklist (another doc)

## ✅ Preliminaries  
- Choose your target language/runtime (Rust, Java/Kotlin, Python, TS, etc.)  
- Review the official [aws-samples/aurora-dsql-samples](https://github.com/aws-samples/aurora-dsql-samples) repository for starter code and patterns  

# Aurora DSQL Usage Requirements 

## 1. Authentication
**Rule:** MUST use AWS IAM authentication with Aurora DSQL  
**Details:** Use `@aws-sdk/dsql-signer` and `awsCredentialsProvider` for all connections.

## 2. Unsupported Postgres Features
**Rule:** MUST NOT use unsupported Postgres features  
**Prohibited:** Temporary Tables, Triggers, Tablespaces, Sequences, Partitions, ON UPDATE, or similar macros/extensions.

## 3. Macro Types
**Rule:** MUST NOT use SERIAL-like macro types  
**Prohibited:** SERIAL, BIGSERIAL, SMALLSERIAL, or similar auto-increment macros.

## 4. Index Creation
**Rule:** MUST use ASYNC when creating indexes

## 5. Index Ordering
**Rule:** MUST NOT specify index order  
**Prohibited:** ASC, DESC.

## 6. Transaction Wrapping
**Rule:** MUST wrap each DDL and DML statement in BEGIN/END  
**Pattern:**
BEGIN;
<statement>;
END;

# Some extra notes

## More on unsupported features:
- [Unsupported PostgreSQL features in Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-unsupported-features.html)

Unsupported objects

Objects unsupported by Aurora DSQL include the following:

    Multiple databases on a single Aurora DSQL cluster

    Temporary Tables

    Triggers

    Types (partial support)

    Tablespaces

    Functions written in languages other than SQL

    Sequences

    Partitions

Unsupported constraints

    Foreign keys

    Exclusion constraints

Unsupported commands

    ALTER SYSTEM

    TRUNCATE

    SAVEPOINT

    VACUUM

NOTE: Aurora DSQL doesn't require vacuuming. The system maintains statistics and manages storage optimization automatically without manual vacuum commands.



Aurora DSQL doesn't support PostgreSQL extensions. The following table shows extensions that are unsupported:

    PL/pgSQL

    PostGIS

    PGVector

    PGAudit

    Postgres_FDW

    PGCron

    pg_stat_statements


Unsupported SQL expressions

The following table describes clauses that aren't supported in Aurora DSQL.
Category 	Primary Clause 	Unsupported Clause

CREATE
	

INDEX ASYNC
	

ASC | DESC

CREATE
	

INDEX 1
	

TRUNCATE
	

	

ALTER
	

SYSTEM
	

All ALTER SYSTEM commands are blocked.

CREATE
	

TABLE
	

COLLATE, AS SELECT, INHERITS, PARTITION

CREATE
	

FUNCTION
	

LANGUAGE non-sql-lang, where non-sql-lang is any language other than SQL

CREATE
	

TEMPORARY
	

TABLES

CREATE
	

EXTENSION
	

CREATE
	

SEQUENCE
	

CREATE
	

MATERIALIZED
	

VIEW

CREATE
	

TABLESPACE
	

CREATE
	

TRIGGER
	

CREATE
	

TYPE
	

CREATE
	

DATABASE
	

You can't create additional databases.

1 See Asynchronous indexes in Aurora DSQL to create an index on a column of a specified table.
Aurora DSQL considerations for PostgreSQL compatibility

Consider the following compatibility limitations when using Aurora DSQL. For general considerations, see Considerations for working with Amazon Aurora DSQL. For quotas and limits, see Cluster quotas and database limits in Amazon Aurora DSQL.

    Aurora DSQL uses a single built-in database named postgres. You can't create additional databases or rename or drop the postgres database.

    The postgres database uses UTF-8 character encoding. You can't change the server encoding.

    The database uses the C collation only.

    Aurora DSQL uses UTC as the system timezone. Postgres stores all timezone-aware dates and times internally in UTC. You can set the TimeZone configuration parameter to convert how it is displayed to the client and serve as the default for client input that the server will use to convert to UTC internally.

    The transaction isolation level is fixed at PostgreSQL Repeatable Read.

    Transactions have the following constraints:

        A transaction can't mix DDL and DML operations

        A transaction can include only 1 DDL statement

        A transaction can modify up to 3,000 rows, regardless of the number of secondary indexes

        The 3,000-row limit applies to all DML statements (INSERT, UPDATE, DELETE)

    Database connections time out after 1 hour.

    Aurora DSQL doesn't currently let you run GRANT [permission] ON DATABASE. If you attempt to run that statement, Aurora DSQL returns the error message ERROR: unsupported object type in GRANT.

    Aurora DSQL doesn't let non-admin user roles to run the CREATE SCHEMA command. You can't run the GRANT [permission] on DATABASE command and grant CREATE permissions on the database. If a non-admin user role tries to create a schema, Aurora DSQL returns with the error message ERROR: permission denied for database postgres.

    Non-admin users can't create objects in the public schema. Only admin users can create objects in the public schema. The admin user role has permissions to grant read, write, and modify access to these objects to non-admin users, but it cannot grant CREATE permissions to the public schema itself. Non-admin users must use different, user-created schemas for object creation.

    Aurora DSQL doesn't support the command ALTER ROLE [] CONNECTION LIMIT. Contact AWS support if you need a connection limit increase.

    Aurora DSQL doesn't support asyncpg, the asynchronous PostgreSQL database driver for Python.


## Notes on Programming w/ DSQL
Aurora DSQL provides you with the following tools to manage your Aurora DSQL resources programmatically.

AWS Command Line Interface (AWS CLI)

    You can create and manage your resources by using the AWS CLI in a command-line shell. The AWS CLI provides direct access to the APIs for AWS services, such as Aurora DSQL. For syntax and examples for the commands for Aurora DSQL, see dsql in the AWS CLI Command Reference.
AWS software development kits (SDKs)

    AWS provides SDKs for many popular technologies and programming languages. They make it easier for you to call AWS services from within your applications in that language or technology. For more information about these SDKs, see Tools for developing and managing applications on AWS

    .
Aurora DSQL API

    This API is another programming interface for Aurora DSQL. When using this API, you must format every HTTPS request correctly and add a valid digital signature to every request. For more information, see Aurora DSQL API reference.
CloudFormation

    The AWS::DSQL::Cluster is an CloudFormation resource that enables you to create and manage Aurora DSQL clusters as part of your infrastructure as code. CloudFormation helps you define your entire AWS environment in code, making it easier to provision, update, and replicate your infrastructure in a consistent and reliable way.

    When you use the AWS::DSQL::Cluster resource in your CloudFormation templates, you can declaratively provision Aurora DSQL clusters alongside your other cloud resources. This helps ensure that your data infrastructure deploys and manages alongside the rest of your application stack.

## Protocol notes:
Aurora DSQL uses the PostgreSQL wire protocol

. You can connect to PostgreSQL using a variety of tools and clients, such as AWS CloudShell, psql, DBeaver, and DataGrip. The following table summarizes how Aurora DSQL maps common PostgreSQL connection parameters:
PostgreSQL 	Aurora DSQL 	Notes
Role (also known as User or Group) 	Database Role 	Aurora DSQL creates a role for you named admin. When you create custom database roles, you must use the admin role to associate them with IAM roles for authenticating when connecting to your cluster. For more information, see Configure custom database roles.
Host (also known as hostname or hostspec) 	Cluster Endpoint 	Aurora DSQL single-Region clusters provide a single managed endpoint and automatically redirect traffic if there is unavailability within the Region.
Port 	N/A – use default 5432 	This is the PostgreSQL default.
Database (dbname) 	use postgres 	Aurora DSQL creates this database for you when you create the cluster.
SSL Mode 	SSL is always enabled server-side 	In Aurora DSQL, Aurora DSQL supports the require SSL Mode. Connections without SSL are rejected by Aurora DSQL.
Password 	Authentication Token 	Aurora DSQL requires temporary authentication tokens instead of long-lived passwords. To learn more, see Generating an authentication token in Amazon Aurora DSQL.

When connecting, Aurora DSQL requires a signed IAM authentication token in place of a traditional password. These temporary tokens are generated using AWS Signature Version 4 and are used only during connection establishment. Once connected, the session remains active until it ends or the client disconnects.

If you attempt to open a new session with an expired token, the connection request fails and a new token must be generated. For more information, see Generating an authentication token in Amazon Aurora DSQL.