#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T postgres1 sh -c "cat << EOF | psql -U \$POSTGRES_USER \$POSTGRES_DB
\echo 'Database size:';
select pg_size_pretty(pg_database_size('postgres'));
\echo 'Table sizes:';
SELECT
  nspname                                               AS \"schema\",
  pg_class.relname                                      AS \"table\",
  pg_size_pretty(pg_total_relation_size(pg_class.oid))  AS \"total_size\",
  pg_size_pretty(pg_relation_size(pg_class.oid))        AS \"data_size\",
  pg_size_pretty(pg_indexes_size(pg_class.oid))         AS \"index_size\",
  pg_stat_user_tables.n_live_tup                        AS \"rows\",
  pg_size_pretty(
    pg_total_relation_size(pg_class.oid) /
    (pg_stat_user_tables.n_live_tup + 1)
  )                                                     AS \"total_row_size\",
  pg_size_pretty(
    pg_relation_size(pg_class.oid) /
    (pg_stat_user_tables.n_live_tup + 1)
  )                                                     AS \"row_size\"
FROM
  pg_stat_user_tables
JOIN
  pg_class
ON
  pg_stat_user_tables.relid = pg_class.oid
JOIN
  pg_catalog.pg_namespace AS ns
ON
  pg_class.relnamespace = ns.oid
ORDER BY
  pg_total_relation_size(pg_class.oid) DESC;
\q
EOF"
