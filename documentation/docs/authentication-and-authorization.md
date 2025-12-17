# Authentication and Authorization for Amazon Aurora DSQL

## Overview

Aurora DSQL uses IAM roles and policies for cluster authorization. You associate IAM roles with [PostgreSQL database roles](https://www.postgresql.org/docs/current/user-manag.html) for database authorization. This approach combines [benefits from IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-iam-features.html) with [PostgreSQL privileges](https://www.postgresql.org/docs/current/user-manag.html). Aurora DSQL uses these features to provide a comprehensive authorization and access policy for your cluster, database, and data.

## Managing Your Cluster Using IAM

To manage your cluster, use IAM for authentication and authorization:

### IAM Authentication

To authenticate your IAM identity when you manage Aurora DSQL clusters, you must use IAM. You can provide authentication using:
- [AWS Management Console](https://docs.aws.amazon.com/signin/latest/userguide/how-to-sign-in.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [AWS SDK](https://docs.aws.amazon.com/sdkref/latest/guide/access.html)

### IAM Authorization

To manage Aurora DSQL clusters, grant authorization using IAM actions for Aurora DSQL. For example, to describe a cluster, make sure that your IAM identity has permissions for the IAM action `dsql:GetCluster`, as in the following sample policy action:

```json
{
  "Effect": "Allow",
  "Action": "dsql:GetCluster",
  "Resource": "arn:aws:dsql:us-east-1:123456789012:cluster/my-cluster"
}
```

## Connecting to Your Cluster Using IAM

To connect to your cluster, use IAM for authentication and authorization:

### IAM Authentication

Generate a temporary authentication token using an IAM identity with authorization to connect to your cluster. To learn more, see [Generating an authentication token in Amazon Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/SECTION_authentication-token.html).

### IAM Authorization

Grant the following IAM policy actions to the IAM identity you're using to establish the connection to your cluster's endpoint:

#### Admin Role Connection

Use `dsql:DbConnectAdmin` if you're using the `admin` role. Aurora DSQL creates and manages this role for you. The following sample IAM policy action permits `admin` to connect to `my-cluster`:

```json
{
  "Effect": "Allow",
  "Action": "dsql:DbConnectAdmin",
  "Resource": "arn:aws:dsql:us-east-1:123456789012:cluster/my-cluster"
}
```

#### Custom Database Role Connection

Use `dsql:DbConnect` if you're using a custom database role. You create and manage this role by using SQL commands in your database. The following sample IAM policy action permits a custom database role to connect to `my-cluster` for up to one hour:

```json
{
  "Effect": "Allow",
  "Action": "dsql:DbConnect",
  "Resource": "arn:aws:dsql:us-east-1:123456789012:cluster/my-cluster"
}
```

**Important**: After you establish a connection, your role is authorized for up to one hour for the connection.

## PostgreSQL Database Roles and IAM Roles

### Database Role Management

PostgreSQL manages database access permissions using the concept of roles. A role can be thought of as either a database user, or a group of database users, depending on how the role is set up. You create PostgreSQL roles using SQL commands. To manage database-level authorization, grant PostgreSQL permissions to your PostgreSQL database roles.

Aurora DSQL supports two types of database roles:
- **Admin role**: Aurora DSQL automatically creates a predefined `admin` role for you in your Aurora DSQL cluster. You can't modify the `admin` role.
- **Custom roles**: When you connect to your database as `admin`, you can issue SQL to create new database-level roles to associate with your IAM roles.

To let IAM roles connect to your database, associate your custom database roles with your IAM roles.

### Authentication Process

Use the `admin` role to connect to your cluster. After you connect your database, use the command `AWS IAM GRANT` to associate a custom database role with the IAM identity authorized to connect to the cluster:

```sql
AWS IAM GRANT custom-db-role TO 'arn:aws:iam::account-id:role/iam-role-name';
```

To learn more, see [Authorizing database roles to connect to your cluster](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html#using-database-and-iam-roles-custom-database-roles).

### Authorization Process

Use the `admin` role to connect to your cluster. Run SQL commands to set up custom database roles and grant permissions. To learn more, see:
- [PostgreSQL database roles](https://www.postgresql.org/docs/current/user-manag.html)
- [PostgreSQL privileges](https://www.postgresql.org/docs/current/ddl-priv.html)

## Using IAM Policy Actions with Aurora DSQL

The IAM policy action you use depends on the role you use to connect to your cluster: either `admin` or a custom database role. The policy also depends on the IAM actions required for this role.

### Using IAM Policy Actions to Connect to Clusters

#### Admin Role Connection
When you connect to your cluster with the default database role of `admin`, use an IAM identity with authorization to perform the following IAM policy action:

```
"dsql:DbConnectAdmin"
```

#### Custom Database Role Connection
When you connect to your cluster with a custom database role, first associate the IAM role with the database role. The IAM identity you use to connect to your cluster must have authorization to perform the following IAM policy action:

```
"dsql:DbConnect"
```

To learn more about custom database roles, see [Using database roles and IAM authentication](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html).

### Using IAM Policy Actions to Manage Clusters

When managing your Aurora DSQL clusters, specify policy actions only for the actions that your role needs to perform. For example, if your role only needs to get cluster information, you might limit role permissions to only the `GetCluster` and `ListClusters` permissions, as in the following sample policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dsql:GetCluster",
        "dsql:ListClusters"
      ],
      "Resource": "arn:aws:dsql:us-east-1:123456789012:cluster/my-cluster"
    }
  ]
}
```

#### All Available IAM Policy Actions for Managing Clusters

The following example policy shows all available IAM policy actions for managing clusters:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dsql:CreateCluster",
        "dsql:GetCluster",
        "dsql:UpdateCluster",
        "dsql:DeleteCluster",
        "dsql:ListClusters",
        "dsql:TagResource",
        "dsql:ListTagsForResource",
        "dsql:UntagResource"
      ],
      "Resource": "*"
    }
  ]
}
```

## Revoking Authorization Using IAM and PostgreSQL

You can revoke permissions for your IAM roles to access your database-level roles:

### Revoking Admin Authorization to Connect to Clusters

To revoke authorization to connect to your cluster with the `admin` role:
1. Revoke the IAM identity's access to `dsql:DbConnectAdmin`
2. Either edit the IAM policy or detach the policy from the identity

After revoking connection authorization from the IAM identity, Aurora DSQL rejects all new connection attempts from that IAM identity. Any active connections that use the IAM identity might stay authorized for the duration of the connection. For more information on connection durations, see [Quotas and limits](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/CHAP_quotas.html).

### Revoking Custom Role Authorization to Connect to Clusters

To revoke access to database roles other than `admin`:
1. Revoke the IAM identity's access to `dsql:DbConnect`
2. Either edit the IAM policy or detach the policy from the identity

You can also remove the association between the database role and IAM by using the command `AWS IAM REVOKE` in your database. To learn more about revoking access from database roles, see [Revoking database authorization from an IAM role](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html#using-database-and-iam-roles-revoke).

### Important Notes on Permission Management

- You can't manage permissions of the predefined `admin` database role
- To learn how to manage permissions for custom database roles, see [PostgreSQL privileges](https://www.postgresql.org/docs/current/ddl-priv.html)
- Modifications to privileges take effect on the next transaction after Aurora DSQL successfully commits the modification transaction
