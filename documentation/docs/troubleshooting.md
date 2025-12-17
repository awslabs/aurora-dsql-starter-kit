{% include 'copy-page-script.md' %}
{% include 'copy-page-button.md' %}

# Troubleshooting Amazon Aurora DSQL

## Overview

This guide provides troubleshooting advice for common errors and issues when using Amazon Aurora DSQL. If you encounter an issue not listed here, contact AWS support.

## Connection Errors

### SSL Error Code 6

**Error Message**: `error: unrecognized SSL error code: 6` or `unable to accept connection, sni was not received`

**Root Cause**: PostgreSQL client version earlier than 14 lacks Server Name Indication (SNI) support, which is required for Aurora DSQL connections.

**Resolution**:
1. Check your client version: `psql --version`
2. Upgrade PostgreSQL client to version 14 or later
3. Retry the connection

### Network Unreachable Error

**Error Message**: `error: NetworkUnreachable`

**Root Cause**: Client doesn't support IPv6 connections on dual-stack server configuration.

**Technical Details**: When a server supports dual-stack mode, clients first resolve hostnames to both IPv4 and IPv6 addresses. They attempt IPv4 connection first, then IPv6 if initial connection fails. IPv4-only systems show generic NetworkUnreachable error instead of clear "IPv6 not supported" message.

**Resolution**: Ensure IPv6 support is available or use IPv4-only endpoint if provided.

## Authentication Errors

### IAM Authentication Failed

**Error Message**: `IAM authentication failed for user "..."`

**Root Cause**: Authentication token or IAM role has expired.

**Common Scenarios**:
- Authentication token exceeded maximum duration (1 week)
- Temporary IAM role expired before connection attempt
- IAM role credentials no longer valid

**Resolution**:
1. Generate new authentication token
2. Verify IAM role is still valid and accessible
3. Check IAM role expiration time
4. Retry connection with fresh credentials

**Related Documentation**: [Authentication and authorization guide](authentication-and-authorization.md)

### Invalid Access Key ID

**Error Message**: `An error occurred (InvalidAccessKeyId) when calling the GetObject operation: The AWS Access Key ID you provided does not exist in our records`

**Root Cause**: IAM credential validation failure.

**Resolution**:
1. Verify AWS Access Key ID is correct
2. Check if credentials have been rotated or deleted
3. Ensure credentials are properly configured in your environment

**Related Documentation**: [Why requests are signed](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html#why-requests-are-signed)

### IAM Role Not Found

**Error Message**: `IAM role <role> does not exist`

**Root Cause**: Aurora DSQL cannot locate the specified IAM role.

**Resolution**:
1. Verify IAM role name and ARN are correct
2. Check if role exists in the correct AWS account
3. Confirm role hasn't been deleted or renamed

**Related Documentation**: [IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)

### Invalid IAM ARN Format

**Error Message**: `IAM role must look like an IAM ARN`

**Root Cause**: IAM role ARN format is incorrect.

**Resolution**:
1. Verify ARN follows correct format: `arn:aws:iam::account-id:role/role-name`
2. Check for typos in ARN string
3. Ensure proper ARN structure and syntax

**Related Documentation**: [IAM ARN format](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#identifiers-arns)

## Authorization Errors

### Role Not Supported

**Error Message**: `Role <role> not supported`

**Root Cause**: Aurora DSQL doesn't support certain PostgreSQL GRANT operations.

**Resolution**: Review supported PostgreSQL commands and use alternative approaches.

**Related Documentation**: [Supported PostgreSQL commands](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-supported-sql-subsets.html)

### Cannot Establish Trust with Role

**Error Message**: `Cannot establish trust with role <role>`

**Root Cause**: Aurora DSQL doesn't support certain PostgreSQL GRANT operations.

**Resolution**: Use Aurora DSQL-specific role management commands instead of standard PostgreSQL GRANT operations.

**Related Documentation**: [Supported PostgreSQL commands](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-supported-sql-subsets.html)

### Database Role Does Not Exist

**Error Message**: `Role <role> does not exist`

**Root Cause**: Aurora DSQL cannot find the specified database user role.

**Resolution**:
1. Verify the database role was created properly
2. Check role name spelling and case sensitivity
3. Ensure role was created with proper permissions

**Related Documentation**: [Custom database roles](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html#using-database-and-iam-roles-custom-database-roles)

### Permission Denied for IAM Trust

**Error Message**: `ERROR: permission denied to grant IAM trust with role <role>`

**Root Cause**: Must be connected with admin role to grant access to database roles.

**Resolution**:
1. Connect to cluster using admin role
2. Verify you have `dsql:DbConnectAdmin` permission
3. Retry the grant operation

**Related Documentation**: [Database role authorization](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html#using-database-and-iam-roles-custom-database-roles-sql)

### Role Missing LOGIN Attribute

**Error Message**: `ERROR: role <role> must have the LOGIN attribute`

**Root Cause**: Database roles must have LOGIN permission to be used for connections.

**Resolution**:
1. Create role with LOGIN permission: `CREATE ROLE example WITH LOGIN;`
2. Or modify existing role: `ALTER ROLE example WITH LOGIN;`

**Related Documentation**: 
- [CREATE ROLE](https://www.postgresql.org/docs/current/sql-createrole.html)
- [ALTER ROLE](https://www.postgresql.org/docs/current/sql-alterrole.html)

### Cannot Drop Role with Dependencies

**Error Message**: `ERROR: role <role> cannot be dropped because some objects depend on it`

**Root Cause**: Database role has active IAM relationship that must be revoked first.

**Resolution**:
1. Revoke IAM relationship: `AWS IAM REVOKE example FROM 'arn:aws:iam::account:role/role-name';`
2. Then drop the database role
3. Verify no other dependencies exist

**Related Documentation**: [Revoking authorization](authentication-and-authorization.md#revoking-authorization-using-iam-and-postgresql)

## SQL Errors

### Feature Not Supported

**Error Message**: `Error: Not supported`

**Root Cause**: Attempted to use PostgreSQL feature not supported in Aurora DSQL.

**Resolution**:
1. Check Aurora DSQL feature compatibility documentation
2. Use supported alternative commands or approaches
3. Review PostgreSQL compatibility guide

**Related Documentation**: [Supported PostgreSQL features](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-supported-sql-features.html)

### Index Creation Error

**Error Message**: `Error: use CREATE INDEX ASYNC instead`

**Root Cause**: Creating indexes on tables with existing data requires asynchronous operation.

**Resolution**:
1. Use `CREATE INDEX ASYNC` command instead of `CREATE INDEX`
2. Monitor index creation progress
3. Wait for completion before using index

**Related Documentation**: [Asynchronous index creation](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-create-index-async.html)

## Concurrency Control Errors

### Mutation Conflicts

**Error Message**: `OC000 "ERROR: mutation conflicts with another transaction, retry as needed"`

**Root Cause**: Transaction attempted to modify same data as concurrent transaction.

**Technical Details**: Indicates contention on modified tuples between concurrent transactions.

**Resolution**:
1. Implement retry logic in application
2. Add exponential backoff for retries
3. Consider reducing transaction scope to minimize conflicts

**Related Documentation**: [Concurrency control](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-concurrency-control.html)

### Schema Update Conflicts

**Error Message**: `OC001 "ERROR: schema has been updated by another transaction, retry as needed"`

**Root Cause**: Session catalog cache became outdated due to concurrent schema changes.

**Technical Process**:
1. Session loaded catalog version V1 at time T1
2. Another transaction updated catalog to V2 at time T2
3. Original session attempted storage read with outdated V1 catalog
4. Storage layer rejected request due to version mismatch

**Resolution**:
1. Retry the transaction (Aurora DSQL will refresh catalog cache)
2. New transaction will use updated catalog version
3. Ensure no additional schema changes occur during retry

## SSL/TLS Connection Errors

### Certificate Verification Failed

**Error Message**: `SSL error: certificate verify failed`

**Root Cause**: Client cannot verify server certificate.

**Resolution**:
1. Install Amazon Root CA 1 certificate properly
2. Set `PGSSLROOTCERT` environment variable to correct certificate file
3. Verify certificate file has correct permissions
4. Retry connection

### Unrecognized SSL Error Code

**Error Message**: `Unrecognized SSL error code: 6`

**Root Cause**: PostgreSQL client version below 14 lacks proper SSL support.

**Resolution**: Upgrade PostgreSQL client to version 17 or later.

### SSL Unregistered Scheme (Windows)

**Error Message**: `SSL error: unregistered scheme (Windows)`

**Root Cause**: Known issue with Windows psql client using system certificates.

**Resolution**: Use downloaded certificate file method for Windows connections instead of system certificates.
