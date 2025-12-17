#!/usr/bin/env bash
set -euo pipefail

# delete-cluster.sh - Delete an Aurora DSQL cluster
#
# Usage: ./delete-cluster.sh CLUSTER_IDENTIFIER [--region REGION] [--force]
#
# Examples:
#   ./delete-cluster.sh abc123def456
#   ./delete-cluster.sh abc123def456 --region us-west-2
#   ./delete-cluster.sh abc123def456 --force

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 CLUSTER_IDENTIFIER [--region REGION] [--force]"
  echo ""
  echo "Deletes an Aurora DSQL cluster."
  echo ""
  echo "Arguments:"
  echo "  CLUSTER_IDENTIFIER  The cluster identifier to delete"
  echo ""
  echo "Options:"
  echo "  --region REGION     AWS region (default: \$AWS_REGION or us-east-1)"
  echo "  --force             Skip confirmation prompt"
  exit 1
fi

CLUSTER_ID="$1"
shift

REGION="${AWS_REGION:-us-east-1}"
FORCE=false

# Parse remaining arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --region)
      REGION="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Confirmation prompt unless --force is used
if [[ "$FORCE" != "true" ]]; then
  echo "⚠️  WARNING: This will permanently delete cluster: $CLUSTER_ID"
  echo ""
  read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM

  if [[ "$CONFIRM" != "yes" ]]; then
    echo "Deletion cancelled."
    exit 0
  fi
fi

echo "Deleting Aurora DSQL cluster: $CLUSTER_ID in $REGION..."

# Delete the cluster
aws dsql delete-cluster \
  --identifier "$CLUSTER_ID" \
  --region "$REGION"

echo ""
echo "✓ Cluster deletion initiated!"
echo ""
echo "Note: The cluster may take a few minutes to fully delete."
echo "Check status with: aws dsql get-cluster --identifier $CLUSTER_ID --region $REGION"
