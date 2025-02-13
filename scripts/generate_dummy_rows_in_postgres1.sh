#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T postgres1 sh -c "cat << EOF | psql -U \$POSTGRES_USER \$POSTGRES_DB
select insert_dummy_records(10000);
select count(*) from dummy;
\q
EOF"
