#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /working_directory/backup/;
    export BACKUP_ID="$(date "+%Y%m%d_%H%M%S")_full";
    pg_basebackup \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        -D /working_directory/backup/${BACKUP_ID}/ \
        -l backup \
        -P \
        -v \
        --format=tar \
        --compress=client-zstd:level=3 \
        --checkpoint=fast;
        #--wal-method=none;
    cd /working_directory/backup/${BACKUP_ID}/
    zstd pg_wal.tar
    rm pg_wal.tar
    echo "Backup size: $(du -h -d0 /working_directory/backup/${BACKUP_ID}/)"
EOF
