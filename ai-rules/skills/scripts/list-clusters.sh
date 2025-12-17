#!/usr/bin/env bash
set -euo pipefail

# list-clusters.sh - List all Aurora DSQL clusters
#
# Usage: ./list-clusters.sh [--region REGION]
#
# Examples:
#   ./list-clusters.sh
#   ./list-clusters.sh --region us-west-2

REGION="${AWS_REGION:-us-east-1}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --region)
      REGION="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--region REGION]"
      echo ""
      echo "List all Aurora DSQL clusters in the specified region."
      echo ""
      echo "Options:"
      echo "  --region REGION    AWS region (default: \$AWS_REGION or us-east-1)"
      echo "  -h, --help         Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Listing Aurora DSQL clusters in $REGION..."
echo ""

# List clusters
aws dsql list-clusters --region "$REGION" --output table

echo ""
echo "To get details about a cluster:"
echo "./scripts/cluster-info.sh CLUSTER_IDENTIFIER"
