📋 Copy Page

# Configuring Single-Region Clusters

## Overview

Learn how to manage your clusters using the AWS SDKs and CLI. Configure and manage clusters for an AWS Region using either the CLI or your preferred programming language including Python, C++, JavaScript, Java, Rust, Ruby, .NET, and Golang.

The CLI provides quick access through shell commands, while AWS Software Development Kits (SDKs) enable programmatic control through native language support.

## Using AWS SDKs

The AWS SDKs provide programmatic access to Aurora DSQL in your preferred programming language. The following sections show how to perform common cluster operations using different programming languages.

### Create Cluster

The following examples show how to create a single-Region cluster using different programming languages.

#### Python SDK

```
import boto3

def create_cluster(region):
    try:
        client = boto3.client("dsql", region_name=region)
        tags = {"Name": "Python single region cluster"}
        cluster = client.create_cluster(tags=tags, deletionProtectionEnabled=True)
        print(f"Initiated creation of cluster: {cluster['identifier']}")

        print(f"Waiting for {cluster['arn']} to become ACTIVE")
        client.get_waiter("cluster_active").wait(
            identifier=cluster["identifier"],
            WaiterConfig={
                'Delay': 10,
                'MaxAttempts': 30
            }
        )

        return cluster
    except:
        print("Unable to create cluster")
        raise

def main():
    region = "us-east-1"
    response = create_cluster(region)
    print(f"Created cluster: {response['arn']}")

if __name__ == "__main__":
    main()
```

#### JavaScript SDK

```
import { DSQLClient, CreateClusterCommand, waitUntilClusterActive } from "@aws-sdk/client-dsql";

async function createCluster(region) {
    const client = new DSQLClient({ region });

    try {
        const createClusterCommand = new CreateClusterCommand({
            deletionProtectionEnabled: true,
            tags: {
                Name: "javascript single region cluster"
            },
        });
        const response = await client.send(createClusterCommand);

        console.log(`Waiting for cluster ${response.identifier} to become ACTIVE`);
        await waitUntilClusterActive(
            {
                client: client,
                maxWaitTime: 300 // Wait for 5 minutes
            },
            {
                identifier: response.identifier
            }
        );
        console.log(`Cluster Id ${response.identifier} is now active`);
        return;
    } catch (error) {
        console.error(`Unable to create cluster in ${region}: `, error.message);
        throw error;
    }
}

async function main() {
    const region = "us-east-1";
    await createCluster(region);
}

main();
```

#### Java SDK

```
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.core.waiters.WaiterResponse;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dsql.DsqlClient;
import software.amazon.awssdk.services.dsql.model.CreateClusterRequest;
import software.amazon.awssdk.services.dsql.model.CreateClusterResponse;
import software.amazon.awssdk.services.dsql.model.GetClusterResponse;

import java.time.Duration;
import java.util.Map;

public class CreateCluster {
    public static void main(String[] args) {
        Region region = Region.US_EAST_1;

        try (DsqlClient client = DsqlClient.builder()
                .region(region)
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build()) {

            CreateClusterRequest request = CreateClusterRequest.builder()
                    .deletionProtectionEnabled(true)
                    .tags(Map.of("Name", "java single region cluster"))
                    .build();
            CreateClusterResponse cluster = client.createCluster(request);
            System.out.println("Created " + cluster.arn());

            System.out.println("Waiting for cluster to become ACTIVE");
            WaiterResponse<GetClusterResponse> waiterResponse = client.waiter().waitUntilClusterActive(
                    getCluster -> getCluster.identifier(cluster.identifier()),
                    config -> config.waitTimeout(Duration.ofMinutes(5))
            );
            waiterResponse.matched().response().ifPresent(System.out::println);
        }
    }
}
```

### Get Cluster Information

The following examples show how to get information about a single-Region cluster.

#### Python SDK

```
import boto3
from datetime import datetime
import json

def get_cluster(region, identifier):
    try:
        client = boto3.client("dsql", region_name=region)
        return client.get_cluster(identifier=identifier)
    except:
        print(f"Unable to get cluster {identifier} in region {region}")
        raise

def main():
    region = "us-east-1"
    cluster_id = "<your cluster id>"
    response = get_cluster(region, cluster_id)
    print(json.dumps(response, indent=2, default=lambda obj: obj.isoformat() if isinstance(obj, datetime) else None))

if __name__ == "__main__":
    main()
```

#### JavaScript SDK

```
import { DSQLClient, GetClusterCommand } from "@aws-sdk/client-dsql";

async function getCluster(region, clusterId) {
    const client = new DSQLClient({ region });

    const getClusterCommand = new GetClusterCommand({
        identifier: clusterId,
    });

    try {
        return await client.send(getClusterCommand);
    } catch (error) {
        if (error.name === "ResourceNotFoundException") {
            console.log("Cluster ID not found or deleted");
        }
        throw error;
    }
}

async function main() {
    const region = "us-east-1";
    const clusterId = "<CLUSTER_ID>";

    const response = await getCluster(region, clusterId);
    console.log("Cluster: ", response);
}

main();
```

### Update Cluster

The following examples show how to update a single-Region cluster.

#### Python SDK

```
import boto3

def update_cluster(region, cluster_id, deletion_protection_enabled):
    try:
        client = boto3.client("dsql", region_name=region)
        return client.update_cluster(identifier=cluster_id, deletionProtectionEnabled=deletion_protection_enabled)
    except:
        print("Unable to update cluster")
        raise

def main():
    region = "us-east-1"
    cluster_id = "<your cluster id>"
    deletion_protection_enabled = False
    response = update_cluster(region, cluster_id, deletion_protection_enabled)
    print(f"Updated {response['arn']} with deletion_protection_enabled: {deletion_protection_enabled}")

if __name__ == "__main__":
    main()
```

### Delete Cluster

The following examples show how to delete a single-Region cluster.

#### Python SDK

```
import boto3

def delete_cluster(region, identifier):
    try:
        client = boto3.client("dsql", region_name=region)
        cluster = client.delete_cluster(identifier=identifier)
        print(f"Initiated delete of {cluster['arn']}")

        print("Waiting for cluster to finish deletion")
        client.get_waiter("cluster_not_exists").wait(
            identifier=cluster["identifier"],
            WaiterConfig={
                'Delay': 10,
                'MaxAttempts': 30
            }
        )
    except:
        print("Unable to delete cluster " + identifier)
        raise

def main():
    region = "us-east-1"
    cluster_id = "<cluster id>"
    delete_cluster(region, cluster_id)
    print(f"Deleted {cluster_id}")

if __name__ == "__main__":
    main()
```

## Using AWS CLI

The AWS CLI provides a command-line interface for managing your Aurora DSQL clusters. The following examples demonstrate common cluster management operations.

### Create Cluster

Create a cluster using the `create-cluster` command.

**Note**: Cluster creation is an asynchronous operation. Call the `GetCluster` API until the status changes to `ACTIVE`. You can connect to your cluster after it becomes active.

**Command**:

```
aws dsql create-cluster --region us-east-1
```

**Note**: To disable deletion protection during creation, include the `--no-deletion-protection-enabled` flag.

**Response**:

```
{
    "identifier": "abc0def1baz2quux3quuux4",
    "arn": "arn:aws:dsql:us-east-1:111122223333:cluster/abc0def1baz2quux3quuux4",
    "status": "CREATING",
    "creationTime": "2024-05-25T16:56:49.784000-07:00",
    "deletionProtectionEnabled": true,
    "tag": {},
    "encryptionDetails": {
        "encryptionType": "AWS_OWNED_KMS_KEY",
        "encryptionStatus": "ENABLED"
    }
}
```

### Get Cluster Information

Get information about a cluster using the `get-cluster` command.

**Command**:

```
aws dsql get-cluster \
  --region us-east-1 \
  --identifier your_cluster_id
```

**Response**:

```
{
    "identifier": "abc0def1baz2quux3quuux4",
    "arn": "arn:aws:dsql:us-east-1:111122223333:cluster/abc0def1baz2quux3quuux4",
    "status": "ACTIVE",
    "creationTime": "2024-11-27T00:32:14.434000-08:00",
    "deletionProtectionEnabled": false,
    "encryptionDetails": {
        "encryptionType": "CUSTOMER_MANAGED_KMS_KEY",
        "kmsKeyArn": "arn:aws:kms:us-east-1:111122223333:key/123a456b-c789-01de-2f34-g5hi6j7k8lm9",
        "encryptionStatus": "ENABLED"
    }
}
```

### Update Cluster

Update an existing cluster using the `update-cluster` command.

**Note**: Updates are asynchronous operations. Call the `GetCluster` API until the status changes to `ACTIVE` to see your changes.

**Command**:

```
aws dsql update-cluster \
  --region us-east-1 \
  --no-deletion-protection-enabled \
  --identifier your_cluster_id
```

**Response**:

```
{
    "identifier": "abc0def1baz2quux3quuux4",
    "arn": "arn:aws:dsql:us-east-1:111122223333:cluster/abc0def1baz2quux3quuux4",
    "status": "UPDATING",
    "creationTime": "2024-05-24T09:15:32.708000-07:00"
}
```

### Delete Cluster

Delete an existing cluster using the `delete-cluster` command.

**Note**: You can only delete clusters that have deletion protection disabled. By default, deletion protection is enabled when you create new clusters.

**Command**:

```
aws dsql delete-cluster \
  --region us-east-1 \
  --identifier your_cluster_id
```

**Response**:

```
{
    "identifier": "abc0def1baz2quux3quuux4",
    "arn": "arn:aws:dsql:us-east-1:111122223333:cluster/abc0def1baz2quux3quuux4",
    "status": "DELETING",
    "creationTime": "2024-05-24T09:16:43.778000-07:00"
}
```

### List Clusters

List your clusters using the `list-clusters` command.

**Command**:

```
aws dsql list-clusters --region us-east-1
```

**Response**:

```
{
    "clusters": [
        {
            "identifier": "abc0def1baz2quux3quux4quuux",
            "arn": "arn:aws:dsql:us-east-1:111122223333:cluster/abc0def1baz2quux3quux4quuux"
        },
        {
            "identifier": "abc0def1baz2quux3quux5quuuux",
            "arn": "arn:aws:dsql:us-east-1:111122223333:cluster/abc0def1baz2quux3quux5quuuux"
        }
    ]
}
```

## Additional Resources

For more code samples and examples, visit the [Aurora DSQL Samples GitHub repository](https://github.com/aws-samples/aurora-dsql-samples).

## Related Documentation

- **Getting Started**: [Getting Started](https://jubilant-adventure-yv9p22g.pages.github.io/guides/getting-started/quickstart.html)
- **Multi-Region Clusters**: [Multi-Region cluster management](https://jubilant-adventure-yv9p22g.pages.github.io/multi-region-clusters.html)
- **Authentication**: [Auth & Access Overview](https://jubilant-adventure-yv9p22g.pages.github.io/authentication-and-authorization.html)
- **Troubleshooting**: [Troubleshooting Overview](https://jubilant-adventure-yv9p22g.pages.github.io/troubleshooting.html)
