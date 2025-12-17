# Backup and restore for Amazon Aurora DSQL

Amazon Aurora DSQL helps you meet your regulatory compliance and business continuity requirements through integration with AWS Backup, a fully managed data protection service that makes it easy to centralize and automate backups across AWS services, in the cloud, and on premises. The service streamlines backup creation, management, and restoration for both single-Region and multi-Region Aurora DSQL clusters.

Key features include the following:

- Centralized backup management through the AWS Management Console, SDK, or AWS CLI
- Full cluster backups
- Automated backup schedules and retention policies
- Cross-Region and cross-account capabilities
- WORM (write-once, read-many) configuration for all the backups you store

For more information on the features of AWS Backup Vault Lock and an extensive list of available AWS Backup features for Aurora DSQL, see [Vault lock benefits](https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html#backup-vault-lock-benefits) and [AWS Backup feature availability](https://docs.aws.amazon.com/aws-backup/latest/devguide/backup-feature-availability.html) in the _AWS Backup Developer Guide_.

## Getting started with AWS Backup

AWS Backup creates complete copies of your Aurora DSQL clusters. You can get started using AWS Backup for Aurora DSQL by following the steps in [Getting started with AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/getting-started.html):

1. Create on-demand backups for immediate protection.
2. Establish backup plans for automated, scheduled backups.
3. Configure retention periods and cross-Region copying.
4. Set up monitoring and notifications for backup activities.

## Restoring your backups

When you restore Aurora DSQL clusters, AWS Backup always creates new clusters to preserve your source data.

### Restoring single-Region clusters

To restore an Aurora DSQL single-Region cluster, use the [AWS Backup console](https://console.aws.amazon.com/backup) or CLI to select the recovery point (backup) you wish to restore. Configure the settings for the new cluster that will be created from your backup. For detailed instructions, see [Restore a single-Region Aurora DSQL cluster](https://docs.aws.amazon.com/aws-backup/latest/devguide/restore-auroradsql.html#restore-auroradsql-singleregion).

### Restoring multi-Region clusters

Restoring an Aurora DSQL multi-Region cluster is supported through both the [AWS Backup console](https://console.aws.amazon.com/backup) and the AWS CLI. For detailed instructions, see [Restore a multi-Region Aurora DSQL cluster](https://docs.aws.amazon.com/aws-backup/latest/devguide/restore-auroradsql.html#restore-auroradsql-multiregion).

To restore to a multi-Region Aurora DSQL cluster, you can use a backup taken in a single AWS Region. However, before you initiate the restore process, you must ensure there is an identical copy of your backup in all AWS Regions for your multi-Region clusters. If you don't yet have those copies, you must first copy the backup to another AWS Region that supports multi-Region clusters.

We recommend creating backup copies in key AWS Regions to enable robust disaster recovery options and meet compliance requirements. To view available AWS Regions for Aurora DSQL, see [Region Availability for Amazon Aurora DSQL](what-is-amazon-aurora-dsql.md#region-availability-for-amazon-aurora-dsql).

For detailed instructions on these steps, see [Amazon Aurora DSQL restore](https://docs.aws.amazon.com/aws-backup/latest/devguide/restore-auroradsql.html) documentation.

## Monitoring and compliance

AWS Backup provides comprehensive visibility into backup and restore operations with the following resources.

- A centralized dashboard for tracking backup and restore jobs
- Integration with CloudWatch and CloudTrail.
- [AWS Backup Audit Manager](https://docs.aws.amazon.com/aws-backup/latest/devguide/aws-backup-audit-manager.html) for compliance reporting and auditing.

See [Logging Aurora DSQL operations using AWS CloudTrail](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/logging-using-cloudtrail.html) to learn more about logging records of actions taken by a user, role, or an AWS service while using Aurora DSQL.

## Additional resources

To learn more about AWS Backup features and and using it in tandem with Aurora DSQL, see the following resources:

- [Managed policies for AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/security-iam-awsmanpol.html#AWSBackupOperatorAccess)
- [Amazon Aurora DSQL restore](https://docs.aws.amazon.com/aws-backup/latest/devguide/restore-auroradsql.html)
- [Supported services by AWS Region](https://docs.aws.amazon.com/aws-backup/latest/devguide/backup-feature-availability.html#supported-services-by-region)
- [Encryption for backups in AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/encryption.html)

By using AWS Backup for Aurora DSQL, you implement a robust, compliant, and automated backup strategy that protects your critical database resources while minimizing administrative overhead. Whether you manage a single cluster or a complex multi-Region deployment, AWS Backup provides the tools you need to ensure your data remains secure and recoverable.
