#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T backup-sidecar sh <<'EOF'
    mkdir -p /working_directory/wals/
    pg_receivewal \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        --slot=receivewal \
        --create-slot \
        --if-not-exists;
    pg_receivewal \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        --slot=receivewal \
        -v \
        -D /working_directory/wals/ \
        --compress=lz4
    # nohup pg_receivewal \
    #     -U ${POSTGRES_USER} \
    #     -h ${POSTGRES_HOST} \
    #     --slot=receivewal \
    #     -v \
    #     -D /working_directory/wals/ \
    #     --compress=lz4 & echo $! > /working_directory/pg_receivewal.pid
EOF
