#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T backup-sidecar sh <<'EOF'
    export BACKUP_ID="$(date "+%Y%m%d_%H%M%S")_incr";
    pg_basebackup \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        -D /backup/${BACKUP_ID}/ \
        -l backup \
        -P \
        -v \
        --incremental=/backup/$(ls -1r /backup/ | head -n1)/backup_manifest \
        --format=tar \
        --compress=client-zstd:level=3 \
        --checkpoint=fast \
        --wal-method=none;
    cd /backup/${BACKUP_ID}/;
    # zstd pg_wal.tar;
    # rm pg_wal.tar
    echo "Backup size: $(du -h -d0 /backup/${BACKUP_ID}/)"
EOF
