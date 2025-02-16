#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T backup-sidecar sh <<'EOF'
    mkdir -p /dump/
    pg_dump \
        -h ${POSTGRES_HOST} \
        -U ${POSTGRES_USER} \
        -d ${POSTGRES_DB} \
        --compress=zstd:level=3 \
        -Fc \
        -f /dump/$(date '+%Y%m%d_%H%M%S')_dump.pgdump
EOF
