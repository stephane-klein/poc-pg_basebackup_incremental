#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T postgres2 sh -c "cat << EOF | psql -U \$POSTGRES_USER \$POSTGRES_DB
select count(*) from dummy;
\q
EOF"
