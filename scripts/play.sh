#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose down -v
docker compose up -d postgres1 backup-sidecar --wait

# export NUMBER_OF_LINES_TO_GENERATE=10
# export NUMBER_OF_LINES_TO_GENERATE=1000 # 8k * 1000 = 8MB
export NUMBER_OF_LINES_TO_GENERATE=10000 # 8k * 10000 = 80MB

#./scripts/start-pg_receivewal.sh

./scripts/seed.sh
./scripts/generate_dummy_rows_in_postgres1.sh $NUMBER_OF_LINES_TO_GENERATE

# docker compose exec -T postgres1 sh -c "cat << EOF | psql -U \$POSTGRES_USER \$POSTGRES_DB
# VACUUM FULL;
# SELECT pg_switch_wal();
# CHECKPOINT;
# \q
# EOF"

echo "Execute first full backup"
./scripts/postgres1-full-backup.sh

echo "Execute pg_dump backup to check the archive size"
./scripts/postgres1-dump-backup.sh

echo "Restore full backup to postgres2"
./scripts/restore-backup-to-postgres2.sh

echo "Size /working_directory/backup/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /working_directory/backup/"

echo "Size /working_directory/dump/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /working_directory/dump/"

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
# docker compose exec -T postgres1 sh -c "cat << EOF | psql -U \$POSTGRES_USER \$POSTGRES_DB
# VACUUM FULL;
# SELECT pg_switch_wal();
# CHECKPOINT;
# \q
# EOF"
# sleep 10

echo "Execute incremental backup"
./scripts/postgres1-incremental-backup.sh

echo "Execute pg_dump backup to check the archive size"
./scripts/postgres1-dump-backup.sh

echo "Restore backup to postgres2 with pg_combinebackup"
./scripts/restore-backup-to-postgres2.sh

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh


docker compose down postgres2

for i in {1..5}; do
    echo "=== Executing iteration $i/5 ==="

    ./scripts/generate_dummy_rows_in_postgres1.sh $NUMBER_OF_LINES_TO_GENERATE
    # docker compose exec -T postgres1 sh -c "cat << EOF | psql -U \$POSTGRES_USER \$POSTGRES_DB
    # VACUUM FULL;
    # SELECT pg_switch_wal();
    # CHECKPOINT;
    # \q
    # EOF"
    ./scripts/postgres1-incremental-backup.sh

    echo "Execute pg_dump backup to check the archive size"
    ./scripts/postgres1-dump-backup.sh
done

echo "Restore backup to postgres2 with pg_combinebackup"
./scripts/restore-backup-to-postgres2.sh

docker compose up -d postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

echo "Size /working_directory/backup/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /working_directory/backup/"

echo "Size /working_directory/uncompress/*/"
docker compose exec backup-sidecar sh -c "du -h -d1 /working_directory/uncompress/"

echo "PGDATA size"
docker compose exec backup-sidecar sh -c "du -h -d0 /var/lib/postgres2/data/"

echo "Size /working_directory/dump/*/ (compressed)"
docker compose exec backup-sidecar sh -c "du -h -d1 /working_directory/dump/*"

./scripts/postgres1-display-tables-size.sh
