# Connectors for Amazon Aurora DSQL

## Overview

Aurora DSQL provides specialized connectors that extend existing database drivers to enable seamless IAM authentication and integration with AWS services. These connectors are designed to work with popular programming languages and frameworks while maintaining compatibility with existing PostgreSQL workflows.

## Available Connectors

### Java JDBC Connector

**Purpose**: Extends PostgreSQL JDBC driver functionality for Aurora DSQL

**Key Features**:
- Seamless IAM authentication integration
- Automatic token generation and refresh
- Compatible with existing JDBC workflows
- Built on top of PostgreSQL JDBC driver

**Use Cases**:
- Java applications using JDBC
- Enterprise Java applications
- Spring Boot applications
- Hibernate ORM integration

**Repository**: [Aurora DSQL JDBC Connector](https://github.com/awslabs/aurora-dsql-jdbc-connector)

### Python Connector

**Purpose**: Extends Python PostgreSQL drivers for Aurora DSQL

**Key Features**:
- Works with Psycopg, Psycopg2, and asyncpg
- Automatic IAM token handling
- Seamless integration with existing Python workflows
- Support for both synchronous and asynchronous operations

**Use Cases**:
- Python applications using PostgreSQL drivers
- Django web applications
- SQLAlchemy ORM integration
- Data science and analytics applications

**Supported Libraries**:
- Psycopg (latest version)
- Psycopg2 (legacy support)
- asyncpg (asynchronous operations)

**Repository**: [Aurora DSQL Python Connector](https://github.com/awslabs/aurora-dsql-python-connector)

### Node.js Connectors

**Purpose**: Extends Node.js PostgreSQL drivers for Aurora DSQL

**Key Features**:
- Support for node-postgres and Postgres.js
- Automatic IAM authentication handling
- Compatible with existing Node.js PostgreSQL workflows
- TypeScript support available

**Use Cases**:
- Node.js web applications
- Express.js applications
- TypeScript applications
- Serverless functions (Lambda)

**Supported Libraries**:
- node-postgres (pg)
- Postgres.js

**Repository**: [Aurora DSQL Node.js Connectors](https://github.com/awslabs/aurora-dsql-nodejs-connectors)

## Connector Benefits

### Simplified Authentication
- **Automatic token generation**: Connectors handle IAM token creation and refresh
- **Seamless integration**: No changes required to existing application code
- **Security best practices**: Built-in support for AWS security standards

### Framework Compatibility
- **Existing workflows**: Maintain compatibility with current PostgreSQL applications
- **ORM support**: Works with popular ORMs like Hibernate, SQLAlchemy, Django
- **Migration friendly**: Easy transition from standard PostgreSQL to Aurora DSQL

### AWS Integration
- **IAM authentication**: Native support for AWS IAM roles and policies
- **AWS SDK integration**: Leverages existing AWS SDK configurations
- **Service integration**: Designed for AWS service ecosystem

## Getting Started with Connectors

### Installation Process
1. **Install connector package** for your programming language
2. **Configure AWS credentials** (IAM roles, access keys, or profiles)
3. **Update connection strings** to use Aurora DSQL endpoints
4. **Test connectivity** with your Aurora DSQL cluster

### Configuration Requirements
- **AWS credentials**: Valid IAM credentials with Aurora DSQL permissions
- **Cluster endpoint**: Aurora DSQL cluster endpoint URL
- **Database role**: Admin role or custom database role
- **SSL configuration**: SSL/TLS encryption enabled

### Best Practices
- **Use IAM roles** when possible for enhanced security
- **Configure connection pooling** appropriately for your workload
- **Handle token expiration** gracefully in your applications
- **Monitor connection health** and implement retry logic

## Future Connector Releases

Additional connectors are planned for future releases. For the latest information on connector availability, see the [Aurora DSQL samples repository](https://github.com/aws-samples/aurora-dsql-samples).

### Planned Languages and Frameworks
- Additional ORM integrations
- More programming language support
- Enhanced framework-specific features
- Improved performance optimizations

## Related Documentation

- **Database Drivers**: [Programming with DSQL Overview](programming-with-dsql.md#database-drivers)
- **Authentication**: [Generate Authentication Token](generate-authentication-token.md)
- **Database Roles**: [Database Roles and IAM Authentication](database-roles-iam-authentication.md)
- **Sample Code**: [Aurora DSQL Samples Repository](https://github.com/aws-samples/aurora-dsql-samples)
- **Getting Started**: [Getting Started](guides/getting-started/quickstart.md)
