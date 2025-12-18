📋 Copy Page

# Get started with the Aurora DSQL Query Editor

With the Aurora DSQL Query Editor, you can securely connect to your Aurora DSQL clusters and run SQL queries directly from the AWS Management Console without installing or configuring external clients. It provides an intuitive workspace with built-in syntax highlighting, auto-completion, and intelligent code assistance. You can quickly explore schema objects, develop and execute SQL queries, and view results, all within a single interface.

This topic walks you through the steps to connect to a cluster, run queries, view results, and explore advanced capabilities such as execution plans.

Note

The Query Editor is available in all Regions where Aurora DSQL is supported. For more information, see [AWS Regional Services](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/).

## Prerequisites

Before you begin, ensure that you meet the following requirements:

- You have at least one Aurora DSQL cluster available. For more information, see [Step 1: Create a Single-Region Cluster](https://jubilant-adventure-yv9p22g.pages.github.io/guides/getting-started/quickstart.html#step-1-create-a-single-region-cluster).
- Your cluster endpoint is publicly accessible. The Query Editor does not currently support clusters that have public access blocked by resource-based policies or clusters managed through VPC endpoints. For more information, see [Blocking public access with resource-based policies in Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/rbp-block-public-access.html) and [Managing and connecting to Amazon Aurora DSQL clusters using AWS PrivateLink](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/privatelink-managing-clusters.html).
- Your IAM user or role has the required permissions to access and connect to the cluster. For more information, see [Using database roles and IAM authentication](https://jubilant-adventure-yv9p22g.pages.github.io/database-roles-iam-authentication.html).

## Working with the Query Editor

### Open the Query Editor

**To open the Query Editor:**

1. Open the [Aurora DSQL console](https://console.aws.amazon.com/dsql).
1. In the navigation pane, choose **Query Editor**.

Alternatively, from the **Clusters** page, select the cluster you want to query and choose **Connect with Query editor** to launch the editor directly.

Note

Work and connection state are not saved. If you navigate away from the Aurora DSQL console, close the browser tab, or sign out, your connections, query text, and results are lost.

### Connect to a cluster

**To connect to a cluster:**

1. If no cluster connection exists, the editor displays **No cluster has been connected**. Choose **Connect** or select **+** (Add) in the **Cluster Explorer** pane to connect to an existing cluster.
1. (Optional) Connect to multiple clusters or to the same cluster using different roles.

### Explore cluster objects

The Cluster Explorer displays all available cluster connections and lets you browse objects such as databases, schemas, tables, and views. It also provides common actions like **Refresh**, **Create table**, and other context-specific options.

### Run queries

**To run a query:**

1. In the query editor tab pane, enter your SQL statement. For example:

   ```
   SELECT * FROM public.orders LIMIT 10;
   ```

1. Verify the **Active Cluster Context** displayed on the upper right of the query tab. This indicates the cluster connection associated with the current query tab.

1. (Optional) Use the **connection** dropdown to review all available connections or switch to a different cluster. Changing the connection updates where your queries in that tab are executed.

1. Choose **Run** to execute the query.

Note

Each query can return up to 10,000 rows in the results pane. For larger datasets, refine your query with filters or limits.

### Review results and execution plans

After the query runs, review the output in the **Results panel** at the bottom of the editor. By default, each query execution displays the **Results (Table)** tab, showing tabular query output.

To get the query execution plan, run `EXPLAIN ANALYZE` or `EXPLAIN ANALYZE VERBOSE` to get additional insights into query performance. For more information, see [Reading Aurora DSQL EXPLAIN plans](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/reading-dsql-explain-plans.html).

Tip

The `EXPLAIN ANALYZE VERBOSE` command surfaces DPU usage estimates, including Compute, Read, Write, and Total DPU values, providing immediate visibility into the resources consumed by individual SQL statements.
