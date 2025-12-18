📋 Copy Page

# Configuring Multi-Region Clusters

## Overview

Learn how to work with clusters that span multiple AWS Regions. Configure and manage clusters across multiple AWS Regions using either the CLI or your preferred programming language including Python, C++, JavaScript, Java, Rust, Ruby, .NET, and Golang.

## Multi-Region Cluster Concepts

### Witness Region

A witness region is a third AWS Region that helps maintain consistency and availability for your multi-region cluster. The witness region doesn't host client endpoints but maintains transaction logs to support quorum decisions.

### Cluster Linking

Multi-region clusters are created by linking two clusters in different regions. This creates a synchronized, distributed database that spans multiple geographic locations.

### High Availability

Multi-region clusters provide enhanced availability and disaster recovery capabilities by maintaining synchronized data across multiple AWS Regions.

## Using AWS SDKs

The AWS SDKs provide programmatic access to Aurora DSQL in your preferred programming language. The following sections show how to perform common multi-region cluster operations.

### Create Multi-Region Cluster

The following examples show how to create a multi-Region cluster using different programming languages.

#### Python SDK

```
import boto3

def create_multi_region_clusters(region_1, region_2, witness_region):
    try:
        client_1 = boto3.client("dsql", region_name=region_1)
        client_2 = boto3.client("dsql", region_name=region_2)

        # We can only set the witness region for the first cluster
        cluster_1 = client_1.create_cluster(
            deletionProtectionEnabled=True,
            multiRegionProperties={"witnessRegion": witness_region},
            tags={"Name": "Python multi region cluster"}
        )
        print(f"Created {cluster_1['arn']}")

        # For the second cluster we can set witness region and designate cluster_1 as a peer
        cluster_2 = client_2.create_cluster(
            deletionProtectionEnabled=True,
            multiRegionProperties={"witnessRegion": witness_region, "clusters": [cluster_1["arn"]]},
            tags={"Name": "Python multi region cluster"}
        )
        print(f"Created {cluster_2['arn']}")

        # Now that we know the cluster_2 arn we can set it as a peer of cluster_1
        client_1.update_cluster(
            identifier=cluster_1["identifier"],
            multiRegionProperties={"witnessRegion": witness_region, "clusters": [cluster_2["arn"]]}
        )
        print(f"Added {cluster_2['arn']} as a peer of {cluster_1['arn']}")

        # Now that multiRegionProperties is fully defined for both clusters they'll begin the transition to ACTIVE
        print(f"Waiting for {cluster_1['arn']} to become ACTIVE")
        client_1.get_waiter("cluster_active").wait(
            identifier=cluster_1["identifier"],
            WaiterConfig={'Delay': 10, 'MaxAttempts': 30}
        )

        print(f"Waiting for {cluster_2['arn']} to become ACTIVE")
        client_2.get_waiter("cluster_active").wait(
            identifier=cluster_2["identifier"],
            WaiterConfig={'Delay': 10, 'MaxAttempts': 30}
        )

        return (cluster_1, cluster_2)
    except:
        print("Unable to create cluster")
        raise

def main():
    region_1 = "us-east-1"
    region_2 = "us-east-2"
    witness_region = "us-west-2"
    (cluster_1, cluster_2) = create_multi_region_clusters(region_1, region_2, witness_region)
    print("Created multi region clusters:")
    print("Cluster id: " + cluster_1['arn'])
    print("Cluster id: " + cluster_2['arn'])

if __name__ == "__main__":
    main()
```

#### JavaScript SDK

```
import { DSQLClient, CreateClusterCommand, UpdateClusterCommand, waitUntilClusterActive } from "@aws-sdk/client-dsql";

async function createMultiRegionCluster(region1, region2, witnessRegion) {
    const client1 = new DSQLClient({ region: region1 });
    const client2 = new DSQLClient({ region: region2 });

    try {
        // We can only set the witness region for the first cluster
        console.log(`Creating cluster in ${region1}`);
        const createClusterCommand1 = new CreateClusterCommand({
            deletionProtectionEnabled: true,
            tags: { Name: "javascript multi region cluster 1" },
            multiRegionProperties: { witnessRegion: witnessRegion }
        });
        const response1 = await client1.send(createClusterCommand1);
        console.log(`Created ${response1.arn}`);

        // For the second cluster we can set witness region and designate the first cluster as a peer
        console.log(`Creating cluster in ${region2}`);
        const createClusterCommand2 = new CreateClusterCommand({
            deletionProtectionEnabled: true,
            tags: { Name: "javascript multi region cluster 2" },
            multiRegionProperties: {
                witnessRegion: witnessRegion,
                clusters: [response1.arn]
            }
        });
        const response2 = await client2.send(createClusterCommand2);
        console.log(`Created ${response2.arn}`);

        // Now that we know the second cluster arn we can set it as a peer of the first cluster
        const updateClusterCommand = new UpdateClusterCommand({
            identifier: response1.identifier,
            multiRegionProperties: {
                witnessRegion: witnessRegion,
                clusters: [response2.arn]
            }
        });
        await client1.send(updateClusterCommand);
        console.log(`Added ${response2.arn} as a peer of ${response1.arn}`);

        // Now that multiRegionProperties is fully defined for both clusters they'll begin the transition to ACTIVE
        console.log(`Waiting for cluster ${response1.identifier} to become ACTIVE`);
        await waitUntilClusterActive(
            { client: client1, maxWaitTime: 300 },
            { identifier: response1.identifier }
        );
        console.log(`Cluster 1 is now active`);

        console.log(`Waiting for cluster ${response2.identifier} to become ACTIVE`);
        await waitUntilClusterActive(
            { client: client2, maxWaitTime: 300 },
            { identifier: response2.identifier }
        );
        console.log(`Cluster 2 is now active`);
        console.log("The multi region clusters are now active");
        return;
    } catch (error) {
        console.error("Failed to create cluster: ", error.message);
        throw error;
    }
}

async function main() {
    const region1 = "us-east-1";
    const region2 = "us-east-2";
    const witnessRegion = "us-west-2";

    await createMultiRegionCluster(region1, region2, witnessRegion);
}

main();
```

#### Java SDK

```
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dsql.DsqlClient;
import software.amazon.awssdk.services.dsql.DsqlClientBuilder;
import software.amazon.awssdk.services.dsql.model.CreateClusterRequest;
import software.amazon.awssdk.services.dsql.model.CreateClusterResponse;
import software.amazon.awssdk.services.dsql.model.GetClusterResponse;
import software.amazon.awssdk.services.dsql.model.UpdateClusterRequest;

import java.time.Duration;
import java.util.Map;

public class CreateMultiRegionCluster {
    public static void main(String[] args) {
        Region region1 = Region.US_EAST_1;
        Region region2 = Region.US_EAST_2;
        Region witnessRegion = Region.US_WEST_2;

        DsqlClientBuilder clientBuilder = DsqlClient.builder()
                .credentialsProvider(DefaultCredentialsProvider.create());

        try (DsqlClient client1 = clientBuilder.region(region1).build();
             DsqlClient client2 = clientBuilder.region(region2).build()) {

            // We can only set the witness region for the first cluster
            System.out.println("Creating cluster in " + region1);
            CreateClusterRequest request1 = CreateClusterRequest.builder()
                    .deletionProtectionEnabled(true)
                    .multiRegionProperties(mrp -> mrp.witnessRegion(witnessRegion.toString()))
                    .tags(Map.of("Name", "java multi region cluster"))
                    .build();
            CreateClusterResponse cluster1 = client1.createCluster(request1);
            System.out.println("Created " + cluster1.arn());

            // For the second cluster we can set the witness region and designate cluster1 as a peer
            System.out.println("Creating cluster in " + region2);
            CreateClusterRequest request2 = CreateClusterRequest.builder()
                    .deletionProtectionEnabled(true)
                    .multiRegionProperties(mrp ->
                            mrp.witnessRegion(witnessRegion.toString()).clusters(cluster1.arn())
                    )
                    .tags(Map.of("Name", "java multi region cluster"))
                    .build();
            CreateClusterResponse cluster2 = client2.createCluster(request2);
            System.out.println("Created " + cluster2.arn());

            // Now that we know the cluster2 ARN we can set it as a peer of cluster1
            UpdateClusterRequest updateReq = UpdateClusterRequest.builder()
                    .identifier(cluster1.identifier())
                    .multiRegionProperties(mrp ->
                            mrp.witnessRegion(witnessRegion.toString()).clusters(cluster2.arn())
                    )
                    .build();
            client1.updateCluster(updateReq);
            System.out.printf("Added %s as a peer of %s%n", cluster2.arn(), cluster1.arn());

            // Wait for both clusters to become ACTIVE
            System.out.printf("Waiting for cluster %s to become ACTIVE%n", cluster1.arn());
            GetClusterResponse activeCluster1 = client1.waiter().waitUntilClusterActive(
                    getCluster -> getCluster.identifier(cluster1.identifier()),
                    config -> config.waitTimeout(Duration.ofMinutes(5))
            ).matched().response().orElseThrow();

            System.out.printf("Waiting for cluster %s to become ACTIVE%n", cluster2.arn());
            GetClusterResponse activeCluster2 = client2.waiter().waitUntilClusterActive(
                    getCluster -> getCluster.identifier(cluster2.identifier()),
                    config -> config.waitTimeout(Duration.ofMinutes(5))
            ).matched().response().orElseThrow();

            System.out.println("Created multi region clusters:");
            System.out.println(activeCluster1);
            System.out.println(activeCluster2);
        }
    }
}
```

#### Ruby SDK

```
require "aws-sdk-dsql"
require "pp"

def create_multi_region_clusters(region_1, region_2, witness_region)
  client_1 = Aws::DSQL::Client.new(region: region_1)
  client_2 = Aws::DSQL::Client.new(region: region_2)

  # We can only set the witness region for the first cluster
  puts "Creating cluster in #{region_1}"
  cluster_1 = client_1.create_cluster(
    deletion_protection_enabled: true,
    multi_region_properties: { witness_region: witness_region },
    tags: { Name: "ruby multi region cluster" }
  )
  puts "Created #{cluster_1.arn}"

  # For the second cluster we can set witness region and designate cluster_1 as a peer
  puts "Creating cluster in #{region_2}"
  cluster_2 = client_2.create_cluster(
    deletion_protection_enabled: true,
    multi_region_properties: {
      witness_region: witness_region,
      clusters: [ cluster_1.arn ]
    },
    tags: { Name: "ruby multi region cluster" }
  )
  puts "Created #{cluster_2.arn}"

  # Now that we know the cluster_2 arn we can set it as a peer of cluster_1
  client_1.update_cluster(
    identifier: cluster_1.identifier,
    multi_region_properties: {
      witness_region: witness_region,
      clusters: [ cluster_2.arn ]
    }
  )
  puts "Added #{cluster_2.arn} as a peer of #{cluster_1.arn}"

  # Now that multi_region_properties is fully defined for both clusters they'll begin the transition to ACTIVE
  puts "Waiting for #{cluster_1.arn} to become ACTIVE"
  cluster_1 = client_1.wait_until(:cluster_active, identifier: cluster_1.identifier) do |w|
    w.max_attempts = 30
    w.delay = 10
  end

  puts "Waiting for #{cluster_2.arn} to become ACTIVE"
  cluster_2 = client_2.wait_until(:cluster_active, identifier: cluster_2.identifier) do |w|
    w.max_attempts = 30
    w.delay = 10
  end

  [ cluster_1, cluster_2 ]
rescue Aws::Errors::ServiceError => e
  abort "Failed to create multi-region clusters: #{e.message}"
end

def main
  region_1 = "us-east-1"
  region_2 = "us-east-2"
  witness_region = "us-west-2"

  cluster_1, cluster_2 = create_multi_region_clusters(region_1, region_2, witness_region)

  puts "Created multi region clusters:"
  pp cluster_1
  pp cluster_2
end

main if $PROGRAM_NAME == __FILE__
```

### Get Multi-Region Cluster Information

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

### Update Multi-Region Cluster

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

### Delete Multi-Region Clusters

#### Python SDK

```
import boto3

def delete_multi_region_clusters(region_1, cluster_id_1, region_2, cluster_id_2):
    try:
        client_1 = boto3.client("dsql", region_name=region_1)
        client_2 = boto3.client("dsql", region_name=region_2)

        client_1.delete_cluster(identifier=cluster_id_1)
        print(f"Deleting cluster {cluster_id_1} in {region_1}")

        # cluster_1 will stay in PENDING_DELETE state until cluster_2 is deleted
        client_2.delete_cluster(identifier=cluster_id_2)
        print(f"Deleting cluster {cluster_id_2} in {region_2}")

        # Now that both clusters have been marked for deletion they will transition to DELETING state and finalize deletion
        print(f"Waiting for {cluster_id_1} to finish deletion")
        client_1.get_waiter("cluster_not_exists").wait(
            identifier=cluster_id_1,
            WaiterConfig={'Delay': 10, 'MaxAttempts': 30}
        )

        print(f"Waiting for {cluster_id_2} to finish deletion")
        client_2.get_waiter("cluster_not_exists").wait(
            identifier=cluster_id_2,
            WaiterConfig={'Delay': 10, 'MaxAttempts': 30}
        )
    except:
        print("Unable to delete cluster")
        raise

def main():
    region_1 = "us-east-1"
    cluster_id_1 = "<cluster 1 id>"
    region_2 = "us-east-2"
    cluster_id_2 = "<cluster 2 id>"

    delete_multi_region_clusters(region_1, cluster_id_1, region_2, cluster_id_2)
    print(f"Deleted {cluster_id_1} in {region_1} and {cluster_id_2} in {region_2}")

if __name__ == "__main__":
    main()
```

## Additional SDK Examples

For complete SDK examples in all supported languages (C++, Rust, .NET, Golang), visit the [Aurora DSQL Samples GitHub repository](https://github.com/aws-samples/aurora-dsql-samples).

## Multi-Region Cluster Management

### Key Concepts

**Witness Region**: Third region that maintains transaction logs for quorum decisions **Cluster Linking**: Process of connecting clusters across regions **Synchronization**: Automatic data replication between linked clusters **Failover**: Automatic switching between regions during outages

### Best Practices

**Region Selection**:

- Choose regions close to your user base
- Consider data residency requirements
- Plan for disaster recovery scenarios
- Ensure witness region is geographically separate

**Performance Considerations**:

- Account for cross-region latency
- Plan for eventual consistency during network partitions
- Monitor replication lag between regions
- Design applications for multi-region architecture

**Security Considerations**:

- Configure IAM policies for cross-region access
- Ensure encryption in transit between regions
- Plan for compliance requirements across regions
- Monitor access patterns across regions

## Operational Considerations

### Cluster States

- **CREATING**: Cluster is being provisioned
- **ACTIVE**: Cluster is ready for connections
- **UPDATING**: Cluster configuration is being modified
- **DELETING**: Cluster is being removed
- **PENDING_DELETE**: Multi-region cluster waiting for peer deletion

### Deletion Process

For multi-region clusters, both clusters must be deleted. The first cluster will remain in PENDING_DELETE state until the second cluster is also deleted.

### Monitoring

- Monitor cluster status in both regions
- Track replication metrics
- Set up alerts for failover events
- Monitor cross-region network connectivity

## Related Documentation

- **Single-Region Clusters**: [Single-Region Clusters](https://jubilant-adventure-yv9p22g.pages.github.io/single-region-clusters.html)
- **Getting Started**: [Getting Started](https://jubilant-adventure-yv9p22g.pages.github.io/guides/getting-started/quickstart.html)
- **Authentication**: [Auth & Access Overview](https://jubilant-adventure-yv9p22g.pages.github.io/authentication-and-authorization.html)
- **Troubleshooting**: [Troubleshooting Overview](https://jubilant-adventure-yv9p22g.pages.github.io/troubleshooting.html)
