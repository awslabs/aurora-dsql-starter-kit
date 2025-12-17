#!/usr/bin/env bash
set -euo pipefail

# cluster-info.sh - Get detailed information about a DSQL cluster
#
# Usage: ./cluster-info.sh CLUSTER_IDENTIFIER [--region REGION]
#
# Examples:
#   ./cluster-info.sh abc123def456
#   ./cluster-info.sh abc123def456 --region us-west-2

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 CLUSTER_IDENTIFIER [--region REGION]"
  echo ""
  echo "Get detailed information about an Aurora DSQL cluster."
  echo ""
  echo "Arguments:"
  echo "  CLUSTER_IDENTIFIER  The cluster identifier"
  echo ""
  echo "Options:"
  echo "  --region REGION     AWS region (default: \$AWS_REGION or us-east-1)"
  exit 1
fi

CLUSTER_ID="$1"
shift

REGION="${AWS_REGION:-us-east-1}"

# Parse remaining arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --region)
      REGION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Fetching cluster information for: $CLUSTER_ID"
echo ""

# Get cluster details
aws dsql get-cluster \
  --identifier "$CLUSTER_ID" \
  --region "$REGION" \
  --output json | jq '{
    identifier: .identifier,
    endpoint: .endpoint,
    arn: .arn,
    status: .status,
    creationTime: .creationTime
  }'

echo ""
ENDPOINT="${CLUSTER_ID}.dsql.${REGION}.on.aws"
echo "To connect with psql:"
echo "export CLUSTER=$CLUSTER_ID"
echo "export REGION=$REGION"
echo "./scripts/psql-connect.sh"
