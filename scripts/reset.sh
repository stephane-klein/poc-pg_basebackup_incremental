#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose down -v
docker compose up -d postgres1 backup-sidecar --wait

./scripts/seed.sh
./scripts/generate_dummy_rows_in_postgres1.sh

docker compose exec backup-sidecar sh -c "pg_basebackup -U \${POSTGRES_USER} -h \${POSTGRES_HOST} -D /backup/ -l backup -P -v"

docker compose exec backup-sidecar sh -c "rm -rf /var/lib/postgres2/data/*; rm -rf /var/lib/postgres2/data/.* 2>/dev/null; cp -r /backup/* /var/lib/postgres2/data/ ; chown -R 999:999 /var/lib/postgres2/data/ ; ls -lha /var/lib/postgres2/data/"

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

docker compose down postgres2

sleep 2

./scripts/generate_dummy_rows_in_postgres1.sh
