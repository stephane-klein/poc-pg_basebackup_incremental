#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T backup-sidecar sh <<'EOF'
    pg_receivewal \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        --slot=receivewal \
        --create-slot \
        --if-not-exists;
    nohup pg_receivewal \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        --slot=receivewal \
        -v \
        -D /working_directory/wals/ \
        --compress=lz4 & echo $! > /working_directory/pg_receivewal.pid
EOF
