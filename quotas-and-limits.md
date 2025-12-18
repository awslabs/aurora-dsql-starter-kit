📋 Copy Page

# Cluster Quotas and Database Limits in Amazon Aurora DSQL

## Overview

This guide describes the cluster quotas and database limits for Amazon Aurora DSQL. Understanding these limits is essential for planning your Aurora DSQL deployment and application design.

## Cluster Quotas

Your AWS account has the following cluster quotas in Aurora DSQL. To request an increase to the service quotas for single-Region and multi-Region clusters within a specific AWS Region, use the [Service Quotas](https://console.aws.amazon.com/servicequotas) console page. For other quota increases, contact AWS Support.

### Single-Region Clusters

| Quota                                              | Default Limit | Configurable | Error Code                            | Error Message                         |
| -------------------------------------------------- | ------------- | ------------ | ------------------------------------- | ------------------------------------- |
| **Maximum single-Region clusters per AWS account** | 20 clusters   | Yes          | `ServiceQuotaExceededException : 402` | `You have reached the cluster limit.` |

### Multi-Region Clusters

| Quota                                             | Default Limit | Configurable | Error Code                            | Error Message                         |
| ------------------------------------------------- | ------------- | ------------ | ------------------------------------- | ------------------------------------- |
| **Maximum multi-Region clusters per AWS account** | 5 clusters    | Yes          | `ServiceQuotaExceededException : 402` | `You have reached the cluster limit.` |

### Storage Quotas

| Quota                           | Default Limit                                 | Configurable | Error Code         | Error Message                                      |
| ------------------------------- | --------------------------------------------- | ------------ | ------------------ | -------------------------------------------------- |
| **Maximum storage per cluster** | 10 TiB (up to 256 TiB with approved increase) | Yes          | `DISK_FULL(53100)` | `Current cluster size exceeds cluster size limit.` |

### Connection Quotas

| Quota                                             | Default Limit              | Configurable | Error Code                         | Error Message                                             |
| ------------------------------------------------- | -------------------------- | ------------ | ---------------------------------- | --------------------------------------------------------- |
| **Maximum connections per cluster**               | 10,000 connections         | Yes          | `TOO_MANY_CONNECTIONS(53300)`      | `Unable to accept connection, too many open connections.` |
| **Maximum connection rate per cluster**           | 100 connections per second | No           | `CONFIGURED_LIMIT_EXCEEDED(53400)` | `Unable to accept connection, rate exceeded.`             |
| **Maximum connection burst capacity per cluster** | 1,000 connections          | No           | No error code                      | No error message                                          |
| **Connection refill rate**                        | 100 connections per second | No           | No error code                      | No error message                                          |
| **Maximum connection duration**                   | 60 minutes                 | No           | No error code                      | No error message                                          |

### Operational Quotas

| Quota                               | Default Limit | Configurable | Error Code    | Error Message    |
| ----------------------------------- | ------------- | ------------ | ------------- | ---------------- |
| **Maximum concurrent restore jobs** | 4             | No           | No error code | No error message |

## Database Limits

The following table describes the database limits in Aurora DSQL.

### Table and Column Limits

| Limit                                                           | Default Value | Configurable | Error Code | Error Message                                                  |
| --------------------------------------------------------------- | ------------- | ------------ | ---------- | -------------------------------------------------------------- |
| **Maximum combined size of columns in primary key**             | 1 KiB         | No           | `54000`    | `ERROR: key size too large`                                    |
| **Maximum combined size of columns in secondary index**         | 1 KiB         | No           | `54000`    | `ERROR: key size too large`                                    |
| **Maximum size of a row in a table**                            | 2 MiB         | No           | `54000`    | `ERROR: maximum row size exceeded`                             |
| **Maximum size of a column (not part of index)**                | 1 MiB         | No           | `54000`    | `ERROR: maximum column size exceeded`                          |
| **Maximum number of columns in primary key or secondary index** | 8             | No           | `54011`    | `ERROR: more than 8 column keys in an index are not supported` |
| **Maximum number of columns in a table**                        | 255           | No           | `54011`    | `ERROR: tables can have at most 255 columns`                   |
| **Maximum number of indexes in a table**                        | 24            | No           | `54000`    | `ERROR: more than 24 indexes per table are not allowed`        |

### Database Structure Limits

| Limit                                        | Default Value | Configurable | Error Code    | Error Message                                       |
| -------------------------------------------- | ------------- | ------------ | ------------- | --------------------------------------------------- |
| **Maximum number of schemas in a database**  | 10            | No           | `54000`       | `ERROR: more than 10 schemas not allowed`           |
| **Maximum number of tables in a database**   | 1,000 tables  | No           | `54000`       | `ERROR: creating more than 1000 tables not allowed` |
| **Maximum number of databases in a cluster** | 1             | No           | No error code | `ERROR: unsupported statement`                      |
| **Maximum number of views in a database**    | 5,000         | No           | `54000`       | `ERROR: creating more than 5000 views not allowed`  |
| **Maximum view definition size**             | 2 MiB         | No           | `54000`       | `ERROR: view definition too large`                  |

### Transaction Limits

| Limit                                                      | Default Value | Configurable | Error Code | Error Message                                                                                |
| ---------------------------------------------------------- | ------------- | ------------ | ---------- | -------------------------------------------------------------------------------------------- |
| **Maximum size of all data modified in write transaction** | 10 MiB        | No           | `54000`    | `ERROR: transaction size limit 10mb exceeded DETAIL: Current transaction size {sizemb} 10mb` |
| **Maximum number of rows mutated per transaction**         | 3,000 rows    | No           | `54000`    | `ERROR: transaction row limit exceeded`                                                      |
| **Maximum transaction time**                               | 5 minutes     | No           | `54000`    | `ERROR: transaction age limit of 300s exceeded`                                              |

### Memory Limits

| Limit                                       | Default Value           | Configurable | Error Code | Error Message                                               |
| ------------------------------------------- | ----------------------- | ------------ | ---------- | ----------------------------------------------------------- |
| **Maximum base memory per query operation** | 128 MiB per transaction | No           | `53200`    | `ERROR: query requires too much temp space, out of memory.` |

## Quota Management

### Requesting Quota Increases

**Service Quotas Console**: Use the [Service Quotas](https://console.aws.amazon.com/servicequotas) console to request increases for:

- Single-Region cluster limits
- Multi-Region cluster limits
- Storage limits per cluster
- Connection limits per cluster

**AWS Support**: Contact AWS Support for other quota increases not available through Service Quotas console.

### Monitoring Quota Usage

**Best Practices**:

1. **Monitor cluster count** against account limits
1. **Track storage usage** per cluster
1. **Monitor connection patterns** to avoid rate limits
1. **Plan capacity** based on application requirements

## Planning Considerations

### Application Design

- **Transaction Size**: Keep transactions under 10 MiB data modification limit
- **Row Mutations**: Limit to 3,000 rows per transaction
- **Connection Management**: Plan for 10,000 connection limit per cluster
- **Schema Design**: Consider 10 schema limit per database

### Performance Planning

- **Query Memory**: Design queries to stay within 128 MiB memory limit
- **Transaction Duration**: Keep transactions under 5-minute limit
- **Index Strategy**: Plan for maximum 24 indexes per table
- **Table Structure**: Consider 255 column limit per table

### Scalability Planning

- **Multi-Region Strategy**: Plan for 5 multi-Region cluster limit
- **Storage Growth**: Plan for 10 TiB default storage limit
- **Connection Scaling**: Consider connection rate limits (100/second)
- **View Management**: Plan for 5,000 view limit per database

## Error Code Reference

### Connection Error Codes

- **53300**: `TOO_MANY_CONNECTIONS` - Exceeded connection limit
- **53400**: `CONFIGURED_LIMIT_EXCEEDED` - Exceeded connection rate
- **53100**: `DISK_FULL` - Exceeded storage limit

### Database Error Codes

- **54000**: General database limit exceeded
- **54011**: Column or key limit exceeded
- **53200**: Memory limit exceeded

### API Error Codes

- **402**: `ServiceQuotaExceededException` - Service quota exceeded

## Related Documentation

- **PostgreSQL Compatibility**: [Supported PostgreSQL features](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-supported-sql-features.html)
- **Data Types**: [Supported data types](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-postgresql-compatibility-supported-data-types.html)
- **Systems Tables**: [Using systems tables and commands](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/working-with-systems-tables.html)
