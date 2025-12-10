# Database Roles and IAM Authentication

## Overview

Amazon Aurora DSQL supports authentication using both IAM roles and IAM users. You can use either method to authenticate and access Aurora DSQL databases.

## IAM Identity Types

### IAM Roles

An IAM role is an identity within your AWS account that has specific permissions but is not associated with a specific person. Using IAM roles provide temporary security credentials. You can temporarily assume an IAM role in several ways:

- By switching roles in the AWS Console
- By calling a CLI or AWS API operation
- By using a custom URL

After assuming a role, you can access Aurora DSQL using the role's temporary credentials. For more information about methods for using roles, see [IAM Identities](https://docs.aws.amazon.com/IAM/latest/UserGuide/id.html) in the IAM user guide.

### IAM Users

An IAM user is an identity within your AWS account that has specific permissions and is associated with a single person or application. IAM users have long-term credentials such as passwords and access keys that can be used to access Aurora DSQL.

**Note**: To run SQL commands with IAM authentication, you can use either IAM role ARNs or IAM user ARNs in the examples below.

## Database Role Types

Aurora DSQL supports two types of database roles:

### Admin Role
- Aurora DSQL automatically creates a predefined `admin` role for you in your Aurora DSQL cluster
- You can't modify the `admin` role
- When you connect to your database as `admin`, you can issue SQL to create new database-level roles

### Custom Roles
- You create and manage custom roles using SQL commands in your database
- Custom roles must be associated with your IAM roles to allow IAM identities to connect to your database

## Working with Custom Database Roles

### Authorizing Database Roles to Connect to Your Cluster

1. **Create an IAM role** and grant connection authorization with the IAM policy action: `dsql:DbConnect`

2. **Grant cluster access permissions** - The IAM policy must also grant permission to access the cluster resources. Use a wildcard (`*`) or follow the instructions for using IAM condition keys with Aurora DSQL.

### Authorizing Database Roles to Use SQL in Your Database

You must use an IAM role with authorization to connect to your cluster.

**Step-by-step process:**

1. **Connect to your Aurora DSQL cluster** using a SQL utility with the `admin` database role and an IAM identity that is authorized for IAM action `dsql:DbConnectAdmin`

2. **Create a new database role** with the `WITH LOGIN` option:
   ```sql
   CREATE ROLE example WITH LOGIN;
   ```

3. **Associate the database role** with the IAM role ARN:
   ```sql
   AWS IAM GRANT example TO 'arn:aws:iam::012345678912:role/example';
   ```

4. **Grant database-level permissions** to the database role:
   ```sql
   GRANT USAGE ON SCHEMA myschema TO example;
   GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA myschema TO example;
   ```

For more information, see [PostgreSQL GRANT](https://www.postgresql.org/docs/current/sql-grant.html) and [PostgreSQL Privileges](https://www.postgresql.org/docs/current/ddl-priv.html) in the PostgreSQL documentation.

## Viewing IAM to Database Role Mappings

To view the mappings between IAM roles and database roles, query the `sys.iam_pg_role_mappings` system table:

```sql
SELECT * FROM sys.iam_pg_role_mappings;
```

**Example output:**
```
 iam_oid |                  arn                   | pg_role_oid | pg_role_name | grantor_pg_role_oid | grantor_pg_role_name
---------+----------------------------------------+-------------+--------------+---------------------+----------------------
   26398 | arn:aws:iam::012345678912:role/example |       26396 | example      |               15579 | admin
(1 row)
```

This table shows all the mappings between IAM roles (identified by their ARN) and PostgreSQL database roles.

## Revoking Database Authorization from an IAM Role

To revoke database authorization, use the `AWS IAM REVOKE` operation:

```sql
AWS IAM REVOKE example FROM 'arn:aws:iam::012345678912:role/example';
```

## Authentication Process Flow

### For Admin Role
1. **IAM Authentication**: Generate temporary authentication token using IAM identity with `dsql:DbConnectAdmin` permission
2. **Database Connection**: Use token as password to connect with `admin` role
3. **Database Operations**: Perform administrative tasks, create custom roles

### For Custom Role
1. **Role Creation**: Admin creates custom database role with `CREATE ROLE example WITH LOGIN`
2. **IAM Association**: Admin associates role with IAM identity using `AWS IAM GRANT`
3. **Permission Granting**: Admin grants specific database permissions to custom role
4. **IAM Authentication**: User generates token using IAM identity with `dsql:DbConnect` permission
5. **Database Connection**: User connects using custom role and token

## Authorization Process Flow

### Database-Level Authorization
1. **Connect as admin**: Use admin role to connect to cluster
2. **Create custom roles**: Issue SQL commands to create new database-level roles
3. **Grant permissions**: Use PostgreSQL GRANT commands to assign specific permissions
4. **Associate with IAM**: Use `AWS IAM GRANT` to link database roles with IAM identities

### Cluster-Level Authorization
- Managed through IAM policies
- Use `dsql:DbConnectAdmin` for admin role access
- Use `dsql:DbConnect` for custom role access

## Best Practices

### Security Recommendations
- Use custom database roles for production applications instead of admin role
- Grant minimal necessary permissions to custom roles
- Regularly review and audit role mappings using `sys.iam_pg_role_mappings`
- Use temporary IAM roles when possible for enhanced security

### Permission Management
- You can't manage permissions of the predefined `admin` database role
- Modifications to privileges take effect on the next transaction after Aurora DSQL successfully commits the modification transaction
- Use PostgreSQL standard commands for managing custom role permissions
