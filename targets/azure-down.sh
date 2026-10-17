#!/usr/bin/env bash
# Delete everything created by azure-up.sh (the whole resource group).
set -euo pipefail
OWNER="${GITHUB_USER:-$(whoami)}"
RG="${RG:-rg-cao-lab2-$OWNER}"
echo "Deleting resource group $RG (runs in the background, about 5 minutes)..."
az group delete -n "$RG" --yes --no-wait
echo "Check later with: az group exists -n $RG   (should print false)"
