{% include 'copy-page-script.md' %}
{% include 'copy-page-button.md' %}

# Programming with Amazon Aurora DSQL

## Overview

Aurora DSQL provides you with the following tools to manage your Aurora DSQL resources programmatically and connect to your databases.

## Programmatic Access Tools

### AWS Command Line Interface (CLI)
You can create and manage your resources by using the CLI in a command-line shell. The CLI provides direct access to the APIs for AWS services, such as Aurora DSQL.

**Documentation**: [AWS CLI Command Reference for DSQL](https://docs.aws.amazon.com/cli/latest/reference/dsql)

### AWS Software Development Kits (SDKs)
AWS provides SDKs for many popular technologies and programming languages. They make it easier for you to call AWS services from within your applications in that language or technology.

**Documentation**: [Tools for developing and managing applications on AWS](https://aws.amazon.com/developer/tools/)

### Aurora DSQL API
This API is another programming interface for Aurora DSQL. When using this API, you must format every HTTPS request correctly and add a valid digital signature to every request.

**Documentation**: [Aurora DSQL API Reference](api-reference.md)

### AWS CloudFormation
The [AWS::DSQL::Cluster](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dsql-cluster.html) is a CloudFormation resource that enables you to create and manage Aurora DSQL clusters as part of your infrastructure as code.

CloudFormation helps you define your entire AWS environment in code, making it easier to provision, update, and replicate your infrastructure in a consistent and reliable way. When you use the AWS::DSQL::Cluster resource in your CloudFormation templates, you can declaratively provision Aurora DSQL clusters alongside your other cloud resources.

## Accessing Aurora DSQL with PostgreSQL-Compatible Clients

Aurora DSQL uses the [PostgreSQL wire protocol](https://www.postgresql.org/docs/current/protocol.html). You can connect to Aurora DSQL using a variety of tools and clients, such as CloudShell, psql, DBeaver, and DataGrip.

### Connection Parameter Mapping

| PostgreSQL | Aurora DSQL | Notes |
|------------|-------------|-------|
| **Role** (User or Group) | Database Role | Aurora DSQL creates a role named `admin`. Custom database roles must be associated with IAM roles for authentication. |
| **Host** (hostname) | Cluster Endpoint | Single-Region clusters provide a single managed endpoint with automatic traffic redirection. |
| **Port** | Default `5432` | Uses the PostgreSQL default port. |
| **Database** (dbname) | `postgres` | Aurora DSQL creates this database when you create the cluster. |
| **SSL Mode** | SSL always enabled | Aurora DSQL supports `require` SSL Mode. Connections without SSL are rejected. |
| **Password** | Authentication Token | Aurora DSQL requires temporary authentication tokens instead of long-lived passwords. |

### Authentication Requirements

When connecting, Aurora DSQL requires a signed IAM [authentication token](generate-authentication-token.md) in place of a traditional password. These temporary tokens are generated using AWS Signature Version 4 and are used only during connection establishment. Once connected, the session remains active until it ends or the client disconnects.

If you attempt to open a new session with an expired token, the connection request fails and a new token must be generated.

## SQL Client Access

Aurora DSQL supports multiple PostgreSQL-compatible clients for connecting to your cluster. Each client requires a valid authentication token.

### Using CloudShell with psql

Use the following procedure to access Aurora DSQL with the PostgreSQL interactive terminal from CloudShell.

**Steps**:
1. Sign in to the [Aurora DSQL console](https://console.aws.amazon.com/dsql)
2. Choose the cluster you want to connect to
3. Choose **Connect with Query Editor** and then **Connect with CloudShell**
4. Choose whether to connect as admin or with a custom database role
5. Choose **Launch in CloudShell** and **Run** in the CloudShell dialog

### Using Local CLI with psql

Use `psql`, a terminal-based front-end to PostgreSQL utility, to interactively enter queries and view results.

**Note**: To improve query response times, use PostgreSQL version 17 client. Ensure you have Python version 3.8+ and psql version 14+.

**Connection Example**:
```bash
# Aurora DSQL requires a valid IAM token as the password when connecting
# Generate authentication token using AWS CLI
export PGPASSWORD=$(aws dsql generate-db-connect-admin-auth-token \
  --region us-east-1 \
  --expires-in 3600 \
  --hostname your_cluster_endpoint)

# Aurora DSQL requires SSL and will reject connections without it
export PGSSLMODE=require

# Connect with psql using the environment variables
psql --quiet \
  --username admin \
  --dbname postgres \
  --host your_cluster_endpoint
```

### Using DBeaver

DBeaver is an open-source, GUI-based database tool for connecting to and managing your database.

**Setup Steps**:
1. Choose **New Database Connection**
2. Select **PostgreSQL**
3. In **Connection settings/Main** tab:
   - **Host**: Your cluster endpoint
   - **Database**: `postgres`
   - **Authentication**: `Database Native`
   - **Username**: `admin`
   - **Password**: [Generate authentication token](generate-authentication-token.md)
4. Configure SSL mode (`PGSSLMODE=require` or `PGSSLMODE=verify-full`)
5. Test connection and begin running SQL statements

**Important**: Administrative features like Session Manager and Lock Manager don't apply to Aurora DSQL due to its unique architecture.

### Using JetBrains DataGrip

DataGrip is a cross-platform IDE for working with SQL and databases, including PostgreSQL.

**Setup Steps**:
1. Choose **New Data Source** and select **PostgreSQL**
2. In **Data Sources/General** tab:
   - **Host**: Your cluster endpoint
   - **Port**: `5432`
   - **Database**: `postgres`
   - **Authentication**: `User & Password`
   - **Username**: `admin`
   - **Password**: [Generate authentication token](generate-authentication-token.md)
3. Configure SSL mode in connection settings
4. Test connection and start running SQL statements

**Important**: Some views like Sessions don't apply to Aurora DSQL due to its unique architecture.

## Database Connectivity Tools

AWS provides various tools for connecting to and working with Aurora DSQL databases, including database drivers, ORM libraries, and specialized adapters.

### Database Drivers

Low-level libraries that directly connect to the database:

| Programming Language | Driver | Sample Repository |
|---------------------|--------|-------------------|
| **C++** | libpq | [C++ libpq samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/cpp/libpq) |
| **C# (.NET)** | Npgsql | [.NET Npgsql samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/dotnet/npgsql) |
| **Go** | pgx | [Go pgx samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/go/pgx) |
| **Java** | pgJDBC | [Java pgJDBC samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/java/pgjdbc) |
| **Java** | Aurora DSQL Connector for JDBC | [JDBC Connector](https://github.com/awslabs/aurora-dsql-connectors/tree/main/java/jdbc) |
| **JavaScript** | node-postgres | [Node.js postgres samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/javascript/node-postgres) |
| **JavaScript** | Postgres.js | [Postgres.js samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/javascript/postgres-js) |
| **Python** | Psycopg | [Python Psycopg samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/python/psycopg) |
| **Python** | Psycopg2 | [Python Psycopg2 samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/python/psycopg2) |
| **Ruby** | pg | [Ruby pg samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/ruby/ruby-pg) |
| **Rust** | SQLx | [Rust SQLx samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/rust/sqlx) |

### Object-Relational Mapping (ORM) Libraries

Standalone libraries that provide object-relational mapping functionality:

| Programming Language | ORM Library | Sample Repository |
|---------------------|-------------|-------------------|
| **Java** | Hibernate | [Hibernate Pet Clinic App](https://github.com/awslabs/aurora-dsql-orms/tree/main/java/hibernate/examples/pet-clinic-app) |
| **Python** | SQLAlchemy | [SQLAlchemy Pet Clinic App](https://github.com/awslabs/aurora-dsql-orms/tree/main/python/sqlalchemy/examples/pet-clinic-app) |
| **TypeScript** | Sequelize | [TypeScript Sequelize samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/typescript/sequelize) |
| **TypeScript** | TypeORM | [TypeScript TypeORM samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/typescript/type-orm) |

### Aurora DSQL Adapters and Dialects

Specific extensions that make existing ORMs work with Aurora DSQL:

| Programming Language | ORM/Framework | Repository |
|---------------------|---------------|------------|
| **Java** | Hibernate | [Aurora DSQL Hibernate Adapter](https://github.com/awslabs/aurora-dsql-orms/tree/main/java/hibernate) |
| **Python** | Django | [Aurora DSQL Django Adapter](https://github.com/awslabs/aurora-dsql-orms/tree/main/python/django) |
| **Python** | SQLAlchemy | [Aurora DSQL SQLAlchemy Adapter](https://github.com/awslabs/aurora-dsql-orms/tree/main/python/sqlalchemy) |

## Connection Troubleshooting

### Authentication Token Expiration

**Behavior**: Established sessions remain authenticated for a maximum of 1 hour or until an explicit disconnect or client-side timeout occurs.

**Important Considerations**:
- If new connections need to be established, a new authentication token must be generated
- Opening a new session (listing tables, new SQL console) forces a new authentication attempt
- If the authentication token is no longer valid, new sessions will fail and all previously opened sessions become invalid
- Plan token duration carefully using the `expires-in` option (15 minutes default, maximum 7 days)

### SSL Requirements

**SSL Mode Support**:
- `PGSSLMODE=require`: Basic SSL encryption
- `PGSSLMODE=verify-full`: SSL with certificate verification

**Important**: Aurora DSQL enforces SSL communication on the server side and rejects non-SSL connections. For `verify-full` option, you need to install SSL certificates locally.

## Related Documentation

- **Authentication Tokens**: [Generate Authentication Token](generate-authentication-token.md)
- **Database Roles**: [Database Roles and IAM Authentication](database-roles-iam-authentication.md)
- **Getting Started**: [Getting Started](guides/getting-started/quickstart.md)
- **Troubleshooting**: [Troubleshooting Overview](troubleshooting.md)
- **SSL Certificates**: [SSL/TLS certificates configuration](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/configure-root-certificates.html)
