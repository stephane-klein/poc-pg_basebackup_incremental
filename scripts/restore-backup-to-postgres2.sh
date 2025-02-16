#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"
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
