#!/bin/bash
set -e

if [ $# -lt 3 ]; then
  echo "Usage: $0 <repo> <VERCEL_PROJECT_ID> <VERCEL_ORG_ID>"
  exit 1
fi

REPO=$1
PROJECT=$2
ORGID=$3

gh secret set VERCEL_PROJECT_ID -b "$PROJECT" -R "$REPO"
gh secret set VERCEL_ORG_ID -b "$ORGID" -R "$REPO"
gh secret set VERCEL_TOKEN -R "$REPO"

echo "Vercel secrets configured."
