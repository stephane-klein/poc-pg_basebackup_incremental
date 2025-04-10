# POC pg_basebackup with incremental option (PG17)

```sh
$ mise install
$ docker compose build
$ ./scripts/play.sh
[+] Running 3/3
 ✔ Volume poc_pg_basebackup_7e4e50c7e7f7_postgres1  Removed                                                                                                                                                                                                                                                                                             0.0s
 ✔ Volume poc_pg_basebackup_7e4e50c7e7f7_postgres2  Removed                                                                                                                                                                                                                                                                                             0.0s
 ✔ Volume poc_pg_basebackup_7e4e50c7e7f7_backup     Removed                                                                                                                                                                                                                                                                                             0.0s
[+] Running 5/6
 ✔ Network poc_pg_basebackup_7e4e50c7e7f7_default             Created                                                                                                                                                                                                                                                                                   0.2s
 ✔ Volume "poc_pg_basebackup_7e4e50c7e7f7_postgres2"          Created                                                                                                                                                                                                                                                                                   0.0s
 ✔ Volume "poc_pg_basebackup_7e4e50c7e7f7_backup"             Created                                                                                                                                                                                                                                                                                   0.0s
 ✔ Volume "poc_pg_basebackup_7e4e50c7e7f7_postgres1"          Created                                                                                                                                                                                                                                                                                   0.0s[+] Running 6/6
 ✔ Network poc_pg_basebackup_7e4e50c7e7f7_default             Created                                                                                                    0.2s  ✔ Volume "poc_pg_basebackup_7e4e50c7e7f7_postgres2"          Created                                                                                                    0.0s  ✔ Volume "poc_pg_basebackup_7e4e50c7e7f7_backup"             Created                                                                                                    0.0s
 ✔ Volume "poc_pg_basebackup_7e4e50c7e7f7_postgres1"          Created                                                                                                    0.0s  ✔ Container poc_pg_basebackup_7e4e50c7e7f7-postgres1-1       Healthy                                                                                                    6.5s  ✔ Container poc_pg_basebackup_7e4e50c7e7f7-backup-sidecar-1  Healthy                                                                                                    6.3s
NOTICE:  table "dummy" does not exist, skipping
DROP TABLE
CREATE TABLE
DROP FUNCTION
NOTICE:  function public.insert_dummy_records() does not exist, skipping
CREATE FUNCTION
 insert_dummy_records
----------------------

(1 row)

 count
-------
 10000
(1 row)

Execute first full backup
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/7000028 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_96"
107892/107892 kB (100%), 0/1 tablespace (...0250410_195421_full/base.tar.zst)
107892/107892 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/7000120
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.01%   (  16.0 MiB =>    888 B, pg_wal.tar.zst)
Backup size: 45M        /working_directory/backup/20250410_195421_full/
Execute pg_dump backup to check the archive size
Restore full backup to postgres2
Size of /working_directory/backup/*
45M     /working_directory/backup/20250410_195421_full
45M     /working_directory/backup/
Size of /working_directory/uncompress/*
122M    /working_directory/uncompress/20250410_195421_full
122M    /working_directory/uncompress/
total 220K
drwxr-xr-x 1  999  999  536 Apr 10 19:54 .
drwxr-xr-x 1 root root    8 Apr 10 19:54 ..
-rw-r----- 1  999  999    3 Apr 10 19:54 PG_VERSION
-rw-r----- 1  999  999  206 Apr 10 19:54 backup_label
-rw-r----- 1  999  999 136K Apr 10 19:54 backup_manifest
drwxr-x--- 1  999  999    6 Apr 10 19:54 base
drwxr-x--- 1  999  999  600 Apr 10 19:54 global
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_commit_ts
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_dynshmem
-rw-r----- 1  999  999 5.7K Apr 10 19:54 pg_hba.conf
-rw-r----- 1  999  999 2.6K Apr 10 19:54 pg_ident.conf
drwxr-x--- 1  999  999   76 Apr 10 19:54 pg_logical
drwxr-x--- 1  999  999   28 Apr 10 19:54 pg_multixact
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_notify
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_replslot
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_serial
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_snapshots
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_stat
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_stat_tmp
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_subtrans
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_tblspc
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_twophase
drwxr-x--- 1  999  999   94 Apr 10 19:54 pg_wal
drwxr-x--- 1  999  999    8 Apr 10 19:54 pg_xact
-rw-r----- 1  999  999   88 Apr 10 19:54 postgresql.auto.conf
-rw-r----- 1  999  999  31K Apr 10 19:54 postgresql.conf
-rw-r----- 1  999  999    0 Apr 10 19:54 tablespace_map
Size /working_directory/backup/*/ (compressed)
45M     /working_directory/backup/20250410_195421_full
45M     /working_directory/backup/
Size /working_directory/dump/*/ (compressed)
42M     /working_directory/dump/
Database size:;
 pg_size_pretty
----------------
 90 MB
(1 row)

Table sizes:;
 schema | table | total_size | data_size | index_size | rows  | total_row_size | row_size
--------+-------+------------+-----------+------------+-------+----------------+----------
 public | dummy | 83 MB      | 832 kB    | 240 kB     | 10000 | 8678 bytes     | 85 bytes
(1 row)

[+] Running 1/1
 ✔ Container poc_pg_basebackup_7e4e50c7e7f7-postgres2-1  Healthy                                                                                                                                                                                                                                                                                        6.1s
 count
-------
 10000
(1 row)

[+] Running 2/2
 ✔ Container poc_pg_basebackup_7e4e50c7e7f7-postgres2-1  Removed                                                                                                                                                                                                                                                                                        0.3s
 ! Network poc_pg_basebackup_7e4e50c7e7f7_default        Resource is still in use                                                                                                                                                                                                                                                                       0.0s
 insert_dummy_records
----------------------

(1 row)

 count
-------
 20000
(1 row)

Execute incremental backup
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/E0000D8 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_135"
 77853/192561 kB (40%), 0/1 tablespace (...0250410_195438_incr/base.tar.zst)
 88577/192561 kB (45%), 0/1 tablespace (...0250410_195438_incr/base.tar.zst)
 88577/192561 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/E0001D0
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.00%   (  16.0 MiB =>    832 B, pg_wal.tar.zst)
Backup size: 43M        /working_directory/backup/20250410_195438_incr/
Execute pg_dump backup to check the archive size
Restore backup to postgres2 with pg_combinebackup
Size of /working_directory/backup/*
45M     /working_directory/backup/20250410_195421_full
43M     /working_directory/backup/20250410_195438_incr
88M     /working_directory/backup/
Size of /working_directory/uncompress/*
122M    /working_directory/uncompress/20250410_195421_full
105M    /working_directory/uncompress/20250410_195438_incr
226M    /working_directory/uncompress/
total 220K
drwx------ 1  999  999  536 Apr 10 19:54 .
drwxr-xr-x 1 root root    8 Apr 10 19:54 ..
-rw-r----- 1  999  999    3 Apr 10 19:54 PG_VERSION
-rw-r----- 1  999  999  206 Apr 10 19:54 backup_label
-rw-r----- 1  999  999 136K Apr 10 19:54 backup_manifest
drwxr-x--- 1  999  999    6 Apr 10 19:54 base
drwxr-x--- 1  999  999  600 Apr 10 19:54 global
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_commit_ts
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_dynshmem
-rw-r----- 1  999  999 5.7K Apr 10 19:54 pg_hba.conf
-rw-r----- 1  999  999 2.6K Apr 10 19:54 pg_ident.conf
drwxr-x--- 1  999  999   76 Apr 10 19:54 pg_logical
drwxr-x--- 1  999  999   28 Apr 10 19:54 pg_multixact
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_notify
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_replslot
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_serial
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_snapshots
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_stat
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_stat_tmp
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_subtrans
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_tblspc
drwxr-x--- 1  999  999    0 Apr 10 19:54 pg_twophase
drwxr-x--- 1  999  999   94 Apr 10 19:54 pg_wal
drwxr-x--- 1  999  999    8 Apr 10 19:54 pg_xact
-rw-r----- 1  999  999   88 Apr 10 19:54 postgresql.auto.conf
-rw-r----- 1  999  999  31K Apr 10 19:54 postgresql.conf
-rw-r----- 1  999  999    0 Apr 10 19:54 tablespace_map
[+] Running 1/1
 ✔ Container poc_pg_basebackup_7e4e50c7e7f7-postgres2-1  Healthy                                                                                                                                                                                                                                                                                        6.2s
 count
-------
 20000
(1 row)

[+] Running 2/2
 ✔ Container poc_pg_basebackup_7e4e50c7e7f7-postgres2-1  Removed                                                                                                                                                                                                                                                                                        0.3s
 ! Network poc_pg_basebackup_7e4e50c7e7f7_default        Resource is still in use                                                                                                                                                                                                                                                                       0.0s
=== Executing iteration 1/5 ===
 insert_dummy_records
----------------------

(1 row)

 count
-------
 30000
(1 row)

pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/150000D8 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_157"
110803/277226 kB (39%), 0/1 tablespace (...0250410_195454_incr/base.tar.zst)
223379/277226 kB (80%), 0/1 tablespace (...0250410_195454_incr/base.tar.zst)
255248/277226 kB (92%), 0/1 tablespace (...0250410_195454_incr/base.tar.zst)
255248/277226 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/150001D0
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.01%   (  16.0 MiB =>    929 B, pg_wal.tar.zst)
Backup size: 127M       /working_directory/backup/20250410_195454_incr/
Execute pg_dump backup to check the archive size
=== Executing iteration 2/5 ===
 insert_dummy_records
----------------------

(1 row)

 count
-------
 40000
(1 row)

pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/1C0000D8 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_178"
 88643/361914 kB (24%), 0/1 tablespace (...0250410_195502_incr/base.tar.zst)
 88643/361914 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/1C0001D0
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.00%   (  16.0 MiB =>    832 B, pg_wal.tar.zst)
Backup size: 43M        /working_directory/backup/20250410_195502_incr/
Execute pg_dump backup to check the archive size
=== Executing iteration 3/5 ===
 insert_dummy_records
----------------------

(1 row)

 count
-------
 50000
(1 row)

pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/230000D8 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_199"
 88619/446570 kB (19%), 0/1 tablespace (...0250410_195510_incr/base.tar.zst)
 88619/446570 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/230001D0
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.00%   (  16.0 MiB =>    825 B, pg_wal.tar.zst)
Backup size: 43M        /working_directory/backup/20250410_195510_incr/
Execute pg_dump backup to check the archive size
=== Executing iteration 4/5 ===
 insert_dummy_records
----------------------

(1 row)

 count
-------
 60000
(1 row)

pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/2A0000D8 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_221"
 88952/531330 kB (16%), 0/1 tablespace (...0250410_195519_incr/base.tar.zst)
 88952/531330 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/2A0001D0
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.01%   (  16.0 MiB =>    926 B, pg_wal.tar.zst)
Backup size: 43M        /working_directory/backup/20250410_195519_incr/
Execute pg_dump backup to check the archive size
=== Executing iteration 5/5 ===
 insert_dummy_records
----------------------

(1 row)

 count
-------
 70000
(1 row)

pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/310000D8 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_242"
 88691/616002 kB (14%), 0/1 tablespace (...0250410_195529_incr/base.tar.zst)
 88691/616002 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/310001D0
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
pg_wal.tar           :  0.01%   (  16.0 MiB =>    922 B, pg_wal.tar.zst)
Backup size: 43M        /working_directory/backup/20250410_195529_incr/
Execute pg_dump backup to check the archive size
Restore backup to postgres2 with pg_combinebackup
Size of /working_directory/backup/*
45M     /working_directory/backup/20250410_195421_full
43M     /working_directory/backup/20250410_195438_incr
127M    /working_directory/backup/20250410_195454_incr
43M     /working_directory/backup/20250410_195502_incr
43M     /working_directory/backup/20250410_195510_incr
43M     /working_directory/backup/20250410_195519_incr
43M     /working_directory/backup/20250410_195529_incr
385M    /working_directory/backup/
Size of /working_directory/uncompress/*
122M    /working_directory/uncompress/20250410_195421_full
105M    /working_directory/uncompress/20250410_195438_incr
268M    /working_directory/uncompress/20250410_195454_incr
105M    /working_directory/uncompress/20250410_195502_incr
105M    /working_directory/uncompress/20250410_195510_incr
105M    /working_directory/uncompress/20250410_195519_incr
105M    /working_directory/uncompress/20250410_195529_incr
912M    /working_directory/uncompress/
total 220K
drwx------ 1  999  999  536 Apr 10 19:55 .
drwxr-xr-x 1 root root    8 Apr 10 19:54 ..
-rw-r----- 1  999  999    3 Apr 10 19:55 PG_VERSION
-rw-r----- 1  999  999  208 Apr 10 19:55 backup_label
-rw-r----- 1  999  999 136K Apr 10 19:55 backup_manifest
drwxr-x--- 1  999  999    6 Apr 10 19:55 base
drwxr-x--- 1  999  999  600 Apr 10 19:55 global
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_commit_ts
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_dynshmem
-rw-r----- 1  999  999 5.7K Apr 10 19:55 pg_hba.conf
-rw-r----- 1  999  999 2.6K Apr 10 19:55 pg_ident.conf
drwxr-x--- 1  999  999   76 Apr 10 19:55 pg_logical
drwxr-x--- 1  999  999   28 Apr 10 19:55 pg_multixact
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_notify
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_replslot
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_serial
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_snapshots
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_stat
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_stat_tmp
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_subtrans
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_tblspc
drwxr-x--- 1  999  999    0 Apr 10 19:55 pg_twophase
drwxr-x--- 1  999  999   94 Apr 10 19:55 pg_wal
drwxr-x--- 1  999  999    8 Apr 10 19:55 pg_xact
-rw-r----- 1  999  999   88 Apr 10 19:55 postgresql.auto.conf
-rw-r----- 1  999  999  31K Apr 10 19:55 postgresql.conf
-rw-r----- 1  999  999    0 Apr 10 19:55 tablespace_map
[+] Running 1/1
 ✔ Container poc_pg_basebackup_7e4e50c7e7f7-postgres2-1  Healthy                                                                                                                                                                                                                                                                                        6.5s
 count
-------
 70000
(1 row)

Size /working_directory/backup/*/ (compressed)
45M     /working_directory/backup/20250410_195421_full
43M     /working_directory/backup/20250410_195438_incr
127M    /working_directory/backup/20250410_195454_incr
43M     /working_directory/backup/20250410_195502_incr
43M     /working_directory/backup/20250410_195510_incr
43M     /working_directory/backup/20250410_195519_incr
43M     /working_directory/backup/20250410_195529_incr
385M    /working_directory/backup/
Size /working_directory/uncompress/*/
122M    /working_directory/uncompress/20250410_195421_full
105M    /working_directory/uncompress/20250410_195438_incr
268M    /working_directory/uncompress/20250410_195454_incr
105M    /working_directory/uncompress/20250410_195502_incr
105M    /working_directory/uncompress/20250410_195510_incr
105M    /working_directory/uncompress/20250410_195519_incr
105M    /working_directory/uncompress/20250410_195529_incr
912M    /working_directory/uncompress/
PGDATA size
634M    /var/lib/postgres2/data/
Size /working_directory/dump/*/ (compressed)
42M     /working_directory/dump/20250410_195422_dump.pgdump
83M     /working_directory/dump/20250410_195439_dump.pgdump
124M    /working_directory/dump/20250410_195456_dump.pgdump
165M    /working_directory/dump/20250410_195503_dump.pgdump
206M    /working_directory/dump/20250410_195511_dump.pgdump
248M    /working_directory/dump/20250410_195521_dump.pgdump
289M    /working_directory/dump/20250410_195530_dump.pgdump
Database size:;
 pg_size_pretty
----------------
 586 MB
(1 row)

Table sizes:;
 schema | table | total_size | data_size | index_size | rows  | total_row_size | row_size
--------+-------+------------+-----------+------------+-------+----------------+----------
 public | dummy | 579 MB     | 5776 kB   | 1552 kB    | 70000 | 8671 bytes     | 84 bytes
(1 row)
```

## Teardown

```
$ docker compose down -v
```
