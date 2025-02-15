#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose down -v
docker compose up -d postgres1 backup-sidecar --wait

#export NUMBER_OF_LINES_TO_GENERATE=1000 # 8k * 1000 = 8MB
export NUMBER_OF_LINES_TO_GENERATE=10000 # 8k * 10000 = 80MB

./scripts/seed.sh
./scripts/generate_dummy_rows_in_postgres1.sh $NUMBER_OF_LINES_TO_GENERATE

echo "Execute first full backup"
docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /backup/;
    export BACKUP_ID="$(date "+%Y%m%d_%H%M%S")_full";
    pg_basebackup \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        -D /backup/${BACKUP_ID}/ \
        -l backup \
        -P \
        -v \
        --format=tar \
        --compress=client-zstd:level=3 \
        --checkpoint=fast
    cd /backup/${BACKUP_ID}/
    zstd pg_wal.tar
    rm pg_wal.tar
EOF

echo "Execute pg_dump backup to check the archive size"
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

echo "Restore full backup to postgres2"
docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /var/lib/postgres2/data/*
    rm -rf /var/lib/postgres2/data/.* 2>/dev/null
    cp -r /backup/$(ls /backup/ -1 | head -n1)/* /var/lib/postgres2/data/
    cd /var/lib/postgres2/data/
    tar -I zstd -xf base.tar.zst
    tar -I zstd -xf pg_wal.tar.zst -C pg_wal/
    rm base.tar.zst pg_wal.tar.zst
    chown -R 999:999 /var/lib/postgres2/data/
    ls -lha /var/lib/postgres2/data/
    echo "fin"
EOF

echo "Size /backup/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /backup/"

echo "Size /dump/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /dump/"

./scripts/postgres1-display-tables-size.sh

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

# echo "Restore latest dump to postgres2"
# docker compose exec -T backup-sidecar sh <<'EOF'
#     LATEST_DUMP=$(ls -1t /dump/*.pgdump | head -n1);
#
#     PGPASSWORD=${POSTGRES_PASSWORD} pg_restore \
#         -h postgres2 \
#         -U ${POSTGRES_USER} \
#         -d ${POSTGRES_DB} \
#         --clean \
#         --if-exists \
#         "${LATEST_DUMP}"
# EOF

docker compose down postgres2

sleep 2

./scripts/generate_dummy_rows_in_postgres1.sh $NUMBER_OF_LINES_TO_GENERATE

echo "Execute incremental backup"
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
        --checkpoint=fast;
    cd /backup/${BACKUP_ID}/;
    zstd pg_wal.tar;
    rm pg_wal.tar
EOF

echo "Execute pg_dump backup to check the archive size"
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

echo "Restore backup to postgres2 with pg_combinebackup"
docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /uncompress
    mkdir -p /uncompress

    for backup_dir in /backup/*/; do
        dirname=$(basename "$backup_dir")
        
        mkdir -p "/uncompress/$dirname"
        
        cp -r "$backup_dir"/* "/uncompress/$dirname/"
        cd "/uncompress/$dirname"
        
        tar -I zstd -xf base.tar.zst && rm base.tar.zst
        mkdir -p pg_wal
        tar -I zstd -xf pg_wal.tar.zst -C pg_wal/
        rm base.tar.zst pg_wal.tar.zst
    done

    echo "Size of /backup/*"
    du -h -d1 /backup/

    echo "Size of /uncompress/*"
    du -h -d1 /uncompress/

    rm -rf /var/lib/postgres2/data/*
    rm -rf /var/lib/postgres2/data/.* 2>/dev/null
    pg_combinebackup $(cd /uncompress/ && ls -1 | sort | sed 's#^#/uncompress/#' | tr '\n' ' ') -o /var/lib/postgres2/data/

    chown -R 999:999 /var/lib/postgres2/data/
    ls -lha /var/lib/postgres2/data/
EOF

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

docker compose down postgres2
#
for i in {1..5}; do
    echo "=== Executing iteration $i/5 ==="

    ./scripts/generate_dummy_rows_in_postgres1.sh $NUMBER_OF_LINES_TO_GENERATE
docker compose exec -T backup-sidecar sh <<'EOF'
    export BACKUP_ID="$(date "+%Y%m%d_%H%M%S")_incr"
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
        --checkpoint=fast
    cd /backup/${BACKUP_ID}/
    zstd pg_wal.tar
    rm pg_wal.tar
EOF

echo "Execute pg_dump backup to check the archive size"
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

done

echo "Restore backup to postgres2 with pg_combinebackup"
docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /uncompress
    mkdir -p /uncompress

    for backup_dir in /backup/*/; do
        dirname=$(basename "$backup_dir")
        
        mkdir -p "/uncompress/$dirname"
        
        cp -r "$backup_dir"/* "/uncompress/$dirname/"
        cd "/uncompress/$dirname"
        
        tar -I zstd -xf base.tar.zst && rm base.tar.zst
        mkdir -p pg_wal
        tar -I zstd -xf pg_wal.tar.zst -C pg_wal/
        rm base.tar.zst pg_wal.tar.zst
    done

    echo "Size of /backup/*"
    du -h -d1 /backup/

    echo "Size of /uncompress/*"
    du -h -d1 /uncompress/

    rm -rf /var/lib/postgres2/data/*
    rm -rf /var/lib/postgres2/data/.* 2>/dev/null
    pg_combinebackup $(cd /uncompress/ && ls -1 | sort | sed 's#^#/uncompress/#' | tr '\n' ' ') -o /var/lib/postgres2/data/

    chown -R 999:999 /var/lib/postgres2/data/
    ls -lha /var/lib/postgres2/data/
EOF

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

echo "Size /backup/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /backup/"

echo "Size /uncompress/*/"
docker compose exec backup-sidecar sh -c "du -h -d1 /uncompress/"

echo "PGDATA size"
docker compose exec backup-sidecar sh -c "du -h -d0 /var/lib/postgres2/data/"

echo "Size /dump/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /dump/*"

./scripts/postgres1-display-tables-size.sh
