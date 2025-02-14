#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose down -v
docker compose up -d postgres1 backup-sidecar --wait

./scripts/seed.sh
./scripts/generate_dummy_rows_in_postgres1.sh 1000

echo "Execute first full backup"
docker compose exec -T backup-sidecar sh -c "pg_basebackup -U \${POSTGRES_USER} -h \${POSTGRES_HOST} -D /backup/\$(date \"+%Y%m%d_%H%M%S\")_full/ -l backup -P -v --format=tar --compress=client-zstd:level=3"

echo "Restore full backup to postgres2"
docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /var/lib/postgres2/data/*
    rm -rf /var/lib/postgres2/data/.* 2>/dev/null
    cp -r /backup/$(ls /backup/ -1 | head -n1)/* /var/lib/postgres2/data/
    cd /var/lib/postgres2/data/
    tar -I zstd -xf base.tar.zst
    tar -xf pg_wal.tar -C pg_wal/
    rm base.tar.zst pg_wal.tar
    chown -R 999:999 /var/lib/postgres2/data/
    ls -lha /var/lib/postgres2/data/
    echo "fin"
EOF

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

docker compose down postgres2

sleep 2

./scripts/generate_dummy_rows_in_postgres1.sh 1000

echo "Execute incremental backup"
docker compose exec -T backup-sidecar sh <<'EOF'
    pg_basebackup \
        -U ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        -D /backup/$(date "+%Y%m%d_%H%M%S")_incr/ \
        -l backup \
        -P \
        -v \
        --incremental=/backup/$(ls -1r /backup/ | head -n1)/backup_manifest \
        --format=tar \
        --compress=client-zstd:level=3
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
        tar -xf pg_wal.tar -C pg_wal/ && rm pg_wal.tar
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

    ./scripts/generate_dummy_rows_in_postgres1.sh 1000
    docker compose exec backup-sidecar sh -c "pg_basebackup -U \${POSTGRES_USER} -h \${POSTGRES_HOST} -D /backup/\$(date \"+%Y%m%d_%H%M%S\")_incr/ -l backup -P -v --incremental=/backup/\$(ls -1r /backup/ | head -n1)/backup_manifest --format=tar --compress=client-zstd:level=3"
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
        tar -xf pg_wal.tar -C pg_wal/ && rm pg_wal.tar
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
