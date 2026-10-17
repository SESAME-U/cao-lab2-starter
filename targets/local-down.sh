#!/usr/bin/env bash
# Remove the two local containers created by local-up.sh.
set -euo pipefail
docker rm -f web1 web2 >/dev/null 2>&1 || true
echo "Local targets removed."
