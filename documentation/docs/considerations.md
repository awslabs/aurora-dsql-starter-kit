{% include 'copy-page-script.md' %}
{% include 'copy-page-button.md' %}

# Considerations for Working with Amazon Aurora DSQL

## Overview

Consider the following behaviors when you work with Amazon Aurora DSQL. For more information about PostgreSQL compatibility and support, see the compatibility documentation. For quotas and limits, see the quotas and limits guide.

## Key Considerations

### COUNT(*) Operations on Large Tables

**Behavior**: Aurora DSQL doesn't complete `COUNT(*)` operations before transaction timeout for large tables.

**Recommendation**: To retrieve table row count from the system catalog, use the systems tables and commands available in Aurora DSQL.

**Related Documentation**: [Using systems tables and commands in Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-systems-tables.html)

### Prepared Statements Behavior

**Behavior**: Drivers calling `PG_PREPARED_STATEMENTS` might provide an inconsistent view of cached prepared statements for the cluster.

**Technical Details**: 
- You might see more than the expected number of prepared statements per connection for the same cluster and IAM role
- Aurora DSQL doesn't preserve statement names that you prepare

**Impact**: This affects statement caching behavior but doesn't impact functionality

### Multi-Region Cluster Recovery

**Behavior**: In rare multi-Region linked-cluster impairment scenarios, it might take longer than expected for transaction commit availability to resume.

**Technical Details**:
- Automated cluster recovery operations can result in transient concurrency control or connection errors
- In most cases, you will only see the effects for a percentage of your workload

**Recommendation**: When you see these transient errors, retry your transaction or reconnect with your client.

### SQL Client Schema Display

**Behavior**: Some SQL clients, such as DataGrip, make expansive calls to system metadata to populate schema information.

**Technical Details**:
- Aurora DSQL doesn't support all of this metadata information and returns errors
- This issue doesn't affect SQL query functionality
- It might affect schema display in certain clients

**Impact**: Query functionality remains unaffected, only visual schema display may be impacted

### Admin Role Permissions

**Behavior**: The admin role has a set of permissions related to database management tasks.

**Technical Details**:
- By default, these permissions don't extend to objects that other users create
- The admin role can't grant or revoke permissions on user-created objects to other users
- The admin user can grant itself any other role to get the necessary permissions on these objects

**Recommendation**: Use role-based access control for managing permissions on user-created objects

## General Behavioral Considerations

### Transaction Behavior
- **Timeout Limits**: Large operations may timeout before completion
- **Retry Logic**: Implement retry mechanisms for transient errors
- **Connection Management**: Plan for connection lifecycle and recovery scenarios

### Client Compatibility
- **Version Requirements**: Use supported PostgreSQL client versions
- **Feature Support**: Not all PostgreSQL features are available
- **Error Handling**: Implement proper error handling for unsupported operations

### Performance Considerations
- **Large Table Operations**: Consider alternative approaches for operations on large datasets
- **Index Usage**: Optimize queries to use available indexes effectively
- **Connection Pooling**: Implement appropriate connection pooling strategies

### Security Considerations
- **Role Management**: Understand admin role limitations with user-created objects
- **Permission Inheritance**: Plan role hierarchy for proper access control
- **IAM Integration**: Leverage IAM roles for secure database access

## Best Practices

### Application Design
1. **Implement retry logic** for transient errors during cluster recovery
2. **Use appropriate timeouts** for large table operations
3. **Plan for client compatibility** requirements
4. **Design role hierarchy** to handle admin role limitations

### Operational Practices
1. **Monitor cluster health** and recovery operations
2. **Test client compatibility** before production deployment
3. **Implement proper error handling** for unsupported features
4. **Plan capacity** based on quotas and limits

### Development Practices
1. **Use supported PostgreSQL features** only
2. **Test with realistic data volumes** to understand timeout behavior
3. **Implement proper connection management** in applications
4. **Design for eventual consistency** during recovery scenarios
