📋 Copy Page

# Getting Started with Aurora DSQL

Learn how to create an Aurora DSQL cluster, connect to it, and run your first queries. This guide walks you through creating single-Region and multi-Region Aurora DSQL clusters, connecting to them, and running sample SQL commands using the AWS Console and PostgreSQL-compatible tools.

## Prerequisites

Before you begin using Aurora DSQL, ensure you meet the following prerequisites:

- Your IAM identity must have permission to [sign in to the console](https://docs.aws.amazon.com/signin/latest/userguide/console-sign-in-tutorials.html)
- Your IAM identity must meet the following criteria:
- Access to perform any action on any resource in your AWS account
- `AmazonAuroraDSQLConsoleFullAccess` AWS managed policy is [attached](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonAuroraDSQLConsoleFullAccess.html)

## Step 1: Create a Single-Region Cluster

The basic unit of Aurora DSQL is the cluster, which is where you store your data. In this step, you create a cluster in a single AWS Region.

### Create a single-Region cluster

1. Sign in to the AWS Console and open the Aurora DSQL console at <https://console.aws.amazon.com/dsql>
1. Choose **Create cluster** and then **Single-Region**
1. (Optional) Change the value of the default **Name** tag
1. (Optional) Add additional **Tags** for this cluster
1. (Optional) In **Cluster settings**, select any of the following options:
1. Select **Customize encryption settings (advanced)** to choose or create an AWS KMS key
1. Select **Enable deletion protection** to prevent a delete operation from removing your cluster. By default, deletion protection is selected
1. Select **Resource-based policy (advanced)** to specify access control policies for this cluster
1. Choose **Create cluster**
1. The console returns you to the **Clusters** page. A notification banner appears indicating that the cluster is being created. Select the **Cluster ID** to open the cluster details view

## Step 2: Connect to Your Cluster

Aurora DSQL supports multiple ways to connect to your cluster, including the DSQL Query Editor, AWS CloudShell, the local psql client, and other PostgreSQL-compatible tools. In this step, you connect using the [Aurora DSQL Query Editor](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/getting-started-query-editor.html), which provides a quick way to begin interacting with your new cluster.

### Connect using the Query Editor

1. In the Aurora DSQL Console (<https://console.aws.amazon.com/dsql>), open the **Clusters** page and confirm that your cluster creation has completed and its status is Active
1. Select your cluster from the list, or choose the **Cluster ID** to open the Cluster details page
1. Choose **Connect with Query editor**
1. Choose Connect as **admin** for the cluster that was just created
1. Optionally you can connect with a custom role see [Using database roles and IAM authentication](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html)

## Step 3: Run Sample SQL Commands

Test your Aurora DSQL cluster by running SQL statements. After opening the cluster in the Query Editor, select and run each sample query step by step.

### Create a schema

Create a schema named `test`:

```
CREATE SCHEMA IF NOT EXISTS test;
```

### Create a table

Create a hello_world table that uses an automatically generated UUID as the primary key:

```
CREATE TABLE IF NOT EXISTS test.hello_world (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Insert sample data

Insert a sample row:

```
INSERT INTO test.hello_world (message)
VALUES ('Hello, World!');
```

### Query the data

Read the inserted values:

```
SELECT * FROM test.hello_world;
```

### Clean up (Optional)

Optionally clean up the test resources:

```
DROP TABLE test.hello_world;
DROP SCHEMA test;
```

## Step 4 (Optional): Create a Multi-Region Cluster

When you create a multi-Region cluster, you specify the following Regions:

### Remote Region

This is the Region in which you create a second cluster. You create a second cluster in this Region and peer it to your initial cluster. Aurora DSQL replicates all writes on the initial cluster to the remote cluster. You can read and write on any cluster.

### Witness Region

This Region receives all data that is written to the multi-Region cluster. However, witness Regions don't host client endpoints and don't provide user data access. A limited window of the encrypted transaction log is maintained in witness Regions. This log facilitates recovery and supports transactional quorum if a Region becomes unavailable.

### Create a multi-Region cluster

Use the following procedure to create an initial cluster, create a second cluster in a different Region, and then peer the two clusters to create a multi-Region cluster. It also demonstrates cross-Region write replication and consistent reads from both Regional endpoints.

1. Sign in to the [Aurora DSQL console](https://console.aws.amazon.com/dsql)

1. In the navigation pane, choose **Clusters**

1. Choose **Create cluster** and then **Multi-Region**

1. (Optional) Change the value of the default **Name** tag

1. (Optional) Add additional **Tags** for this cluster

1. In **Multi-Region settings**, choose the following options for your initial cluster:

1. In **Witness Region**, choose a Region. Currently, only US-based Regions are supported for witness Regions in multi-Region clusters

1. (Optional) In **Remote Region cluster ARN**, enter an ARN for an existing cluster in another Region. If no cluster exists to serve as the second cluster in your multi-Region cluster, complete setup after you create the initial cluster

1. (Optional) In **Cluster settings**, select any of the following options for your initial cluster:

1. Select **Customize encryption settings (advanced)** to choose or create an AWS KMS key

1. Select **Enable deletion protection** to prevent a delete operation from removing your cluster. By default, deletion protection is selected

1. Select **Resource-based policy (advanced)** to specify access control policies for this cluster

1. Choose **Create cluster** to create your initial cluster. If you didn't enter an ARN in the previous step, the console shows the **Cluster setup pending** notification

1. In the **Cluster setup pending** notification, choose **Complete multi-Region cluster setup**. This action initiates creation of a second cluster in another Region

1. Choose one of the following options for your second cluster:

   - **Add remote Region cluster ARN** – Choose this option if a cluster exists, and you want it to be the second cluster in your multi-Region cluster
   - **Create cluster in another Region** – Choose this option to create a second cluster. In **Remote Region**, choose the Region for this second cluster

1. Choose **Create cluster in your-second-region**, where `your-second-region` is the location of your second cluster. The console opens in your second Region

1. (Optional) Choose cluster settings for your second cluster. For example, you can choose an AWS KMS key

1. Choose **Create cluster** to create your second cluster

1. Choose **Peer in initial-cluster-region**, where `initial-cluster-region` is the Region that hosts the first cluster that you created

1. When prompted, choose **Confirm**. This step completes the creation of your multi-Region cluster

### Connect to your second cluster

1. Open the Aurora DSQL console and choose the Region for your second cluster
1. Choose **Clusters**
1. Select the row for the second cluster in your multi-Region cluster
1. Choose **Connect with Query editor**
1. Choose **Connect as admin**
1. Create a sample schema and table, and insert data by following the steps in [Step 3: Run Sample SQL Commands](#step-3-run-sample-sql-commands)

### Query data across Regions

To query data in the second cluster from the Region hosting your initial cluster:

1. In the Aurora DSQL console, choose the Region for your initial cluster
1. Choose **Clusters**
1. Select the row for the second cluster in your multi-Region cluster
1. Choose **Connect with Query editor**
1. Choose **Connect as admin**
1. Query the data that you inserted into the second cluster:

```
SELECT * FROM test.hello_world;
```

## Troubleshooting

See the [Troubleshooting](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/troubleshooting.html) section of the Aurora DSQL documentation.

## Next Steps

- Learn about [authentication and authorization](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/authentication.html)
- Explore [programming with Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/programming-with.html)
- Understand [multi-Region clusters](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/multi-region-clusters.html)
- Review [security best practices](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/security-best-practices.html)
