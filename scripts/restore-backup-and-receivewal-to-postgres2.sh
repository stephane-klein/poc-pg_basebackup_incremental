#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"
docker compose exec -T backup-sidecar sh <<'EOF'
    rm -rf /working_directory/uncompress/
    mkdir -p /working_directory/uncompress/

    for backup_dir in /working_directory/backup/*/; do
        dirname=$(basename "$backup_dir")
        
        mkdir -p "/working_directory/uncompress/$dirname"
        
        cp -r "$backup_dir"/* "/working_directory/uncompress/$dirname/"
        cd "/working_directory/uncompress/$dirname"
        
        tar -I zstd -xf base.tar.zst && rm base.tar.zst
        mkdir -p pg_wal
        tar -I zstd -xf pg_wal.tar.zst -C pg_wal/ && rm pg_wal.tar.zst
    done

    echo "Size of /working_directory/backup/*"
    du -h -d1 /working_directory/backup/

    echo "Size of /working_directory/uncompress/*"
    du -h -d1 /working_directory/uncompress/

    rm -rf /var/lib/postgres2/data/*
    rm -rf /var/lib/postgres2/data/.* 2>/dev/null
    pg_combinebackup $(cd /working_directory/uncompress/ && ls -1 | sort | sed 's#^#/working_directory/uncompress/#' | tr '\n' ' ') -o /var/lib/postgres2/data/
    
    rm -rf /var/lib/postgres2/data/pg_wal/
    mkdir -p /var/lib/postgres2/data/pg_wal/
    cd /working_directory/wals/
    for wal_file in *; do
        lz4 $wal_file "/var/lib/postgres2/data/pg_wal/$(echo ${wal_file} | sed 's/\.lz4//g')"
    done

    chown -R 999:999 /var/lib/postgres2/data/
EOF
