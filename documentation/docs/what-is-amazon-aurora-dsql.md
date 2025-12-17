{% include 'copy-page-script.md' %}
{% include 'copy-page-button.md' %}

# What is Amazon Aurora DSQL?

## Overview

Amazon Aurora DSQL is a serverless, distributed relational database service optimized for transactional workloads. Amazon Aurora DSQL offers virtually unlimited scale and doesn't require you to manage infrastructure. The active-active highly available architecture provides 99.99% single-Region and 99.999% multi-Region availability.

## When to Use Amazon Aurora DSQL

Aurora DSQL is optimized for transactional workloads that benefit from ACID transactions and a relational data model. Because it's serverless, Aurora DSQL is ideal for application patterns of microservice, serverless, and event-driven architectures. Aurora DSQL is PostgreSQL-compatible, so you can use familiar drivers, object-relational mappings (ORMs), frameworks, and SQL features.

Aurora DSQL automatically manages system infrastructure and scales compute, I/O, and storage based on your workload. Because you have no servers to provision or manage, you don't have to worry about maintenance downtime related to provisioning, patching, or infrastructure upgrades.

Aurora DSQL helps you to build and maintain enterprise applications that are always available at any scale. The active-active serverless design automates failure recovery, so you don't need to worry about traditional database failover. Your applications benefit from Multi-AZ and multi-Region availability, and you don't have to be concerned about eventual consistency or missing data related to failovers.

## Key Features in Amazon Aurora DSQL

### Distributed Architecture

Amazon Aurora DSQL is composed of the following multi-tenant components:

1. **Relay and connectivity**
2. **Compute and databases**
3. **Transaction log, concurrency control, and isolation**
4. **Storage**

A control plane coordinates these components. Each component provides redundancy across three Availability Zones (AZs), with:
- Automatic cluster scaling
- Self-healing in case of component failures

### Single-Region and Multi-Region Clusters

Amazon Aurora DSQL clusters provide the following benefits:

- **Synchronous data replication**
- **Consistent read operations**
- **Automatic failure recovery**
- **Data consistency across multiple AZs or Regions**

#### Failure Recovery

If an infrastructure component fails, Amazon Aurora DSQL automatically routes requests to healthy infrastructure without manual intervention. Amazon Aurora DSQL provides **atomicity, consistency, isolation, and durability (ACID) transactions** with:
- Strong consistency
- Snapshot isolation
- Atomicity
- Cross-AZ and cross-Region durability

#### Multi-Region Capabilities

Multi-Region peered clusters provide the same resilience and connectivity as single-Region clusters. But they improve availability by offering:
- Two Regional endpoints (one in each peered cluster Region)
- Both endpoints present a single logical database
- Available for concurrent read and write operations
- Strong data consistency

You can build applications that run in multiple Regions at the same time for performance and resilience—and know that readers always see the same data.

### Compatibility with PostgreSQL Databases

The distributed database layer (compute) in Amazon Aurora DSQL is based on a current major version of PostgreSQL. You can connect to Amazon Aurora DSQL with familiar PostgreSQL drivers and tools, such as `psql`.

#### Version Compatibility

- Amazon Aurora DSQL is currently compatible with **PostgreSQL version 16**
- Supports a subset of PostgreSQL features, expressions, and data types

## Technical Specifications

### Availability Guarantees

- **Single-Region**: 99.99% availability
- **Multi-Region**: 99.999% availability

### Architecture Benefits

- **Serverless**: No infrastructure management required
- **Distributed**: Built for high availability and scalability
- **Active-Active**: Highly available architecture
- **ACID Compliant**: Full transactional consistency
- **PostgreSQL Compatible**: Use familiar tools and syntax

### Scaling Characteristics

- **Virtually unlimited scale**
- **Automatic scaling** of compute, I/O, and storage
- **Multi-AZ redundancy**
- **Multi-Region support**

## Region Availability for Amazon Aurora DSQL

With Amazon Aurora DSQL, you can deploy database instances across multiple AWS Regions to support global applications and meet data residency requirements. Region availability determines where you can create and manage Aurora DSQL database clusters. Database administrators and application architects who need to design highly available, globally distributed database systems often need to understand Region support for their workloads. Common use cases include setting up cross-Region disaster recovery, serving users from geographically closer database instances to reduce latency, and maintaining data copies in specific locations for compliance.

The following table shows the AWS Regions where Aurora DSQL is currently available and the endpoint for each AWS Region:

### Supported AWS Regions

| Region Name | Region Code | Endpoint | Protocol |
|-------------|-------------|----------|----------|
| US East (Ohio) | us-east-2 | dsql.us-east-2.api.aws<br/>dsql-fips.us-east-2.api.aws | HTTPS<br/>HTTPS |
| US East (N. Virginia) | us-east-1 | dsql.us-east-1.api.aws<br/>dsql-fips.us-east-1.api.aws | HTTPS<br/>HTTPS |
| US West (Oregon) | us-west-2 | dsql.us-west-2.api.aws<br/>dsql-fips.us-west-2.api.aws | HTTPS<br/>HTTPS |
| Asia Pacific (Osaka) | ap-northeast-3 | dsql.ap-northeast-3.api.aws | HTTPS |
| Asia Pacific (Seoul) | ap-northeast-2 | dsql.ap-northeast-2.api.aws | HTTPS |
| Asia Pacific (Tokyo) | ap-northeast-1 | dsql.ap-northeast-1.api.aws | HTTPS |
| Europe (Frankfurt) | eu-central-1 | dsql.eu-central-1.api.aws | HTTPS |
| Europe (Ireland) | eu-west-1 | dsql.eu-west-1.api.aws | HTTPS |
| Europe (London) | eu-west-2 | dsql.eu-west-2.api.aws | HTTPS |
| Europe (Paris) | eu-west-3 | dsql.eu-west-3.api.aws | HTTPS |

### Multi-Region Cluster Availability for Amazon Aurora DSQL

You can create Aurora DSQL multi-Region clusters within specific AWS Region sets. Each Region set groups geographically related Regions that can work together in a multi-Region cluster.

#### US Regions
- US East (N. Virginia)
- US East (Ohio)
- US West (Oregon)

#### Asia Pacific Regions
- Asia Pacific (Osaka)
- Asia Pacific (Seoul)
- Asia Pacific (Tokyo)

#### European Regions
- Europe (Frankfurt)
- Europe (Ireland)
- Europe (London)
- Europe (Paris)

#### Important Limitations
Multi-Region clusters must be created within a single Region set. For example, you can't create a cluster that includes both US East (N. Virginia) and Europe (Ireland) Regions.

**Important**: Aurora DSQL currently doesn't support cross-continent multi-Region clusters.

## Pricing

For cost information, see [Amazon Aurora DSQL pricing](https://aws.amazon.com/rds/aurora/dsql/pricing/).

## Next Steps

For information about the core components in Amazon Aurora DSQL and to get started with the service, see the following:

1. **Getting Started** - Complete guide to creating your first Aurora DSQL cluster
2. **PostgreSQL Compatibility** - Detailed information about supported SQL features
3. **Accessing Aurora DSQL** - Methods for connecting to your clusters with PostgreSQL-compatible clients
4. **Working with Aurora DSQL** - Advanced cluster management and operations

### Cross-References
- **High Availability Architecture**: Learn more about how the distributed architecture supports high availability
- **SQL Feature Compatibility**: Understand the subset of PostgreSQL features, expressions, and data types supported
