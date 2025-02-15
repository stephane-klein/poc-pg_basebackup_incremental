# POC pg_basebackup with incremental option (PG17)

```sh
$ mise install
$ docker compose build
$ ./scripts/reset.sh
```

## Teardown

```
$ docker compose down -v
```


-rw------- 1  999  999    3 Feb 13 17:06 PG_VERSION
-rw------- 1  999  999  208 Feb 13 17:06 backup_label
-rw------- 1  999  999 136K Feb 13 17:06 backup_manifest
drwx------ 1  999  999    6 Feb 13 17:06 base
drwx------ 1  999  999  600 Feb 13 17:06 global
drwx------ 1  999  999    0 Feb 13 17:06 pg_commit_ts
drwx------ 1  999  999    0 Feb 13 17:06 pg_dynshmem
-rw------- 1  999  999 5.7K Feb 13 17:06 pg_hba.conf
-rw------- 1  999  999 2.6K Feb 13 17:06 pg_ident.conf
drwx------ 1  999  999   76 Feb 13 17:06 pg_logical
drwx------ 1  999  999   28 Feb 13 17:06 pg_multixact
drwx------ 1  999  999    0 Feb 13 17:06 pg_notify
drwx------ 1  999  999    0 Feb 13 17:06 pg_replslot
drwx------ 1  999  999    0 Feb 13 17:06 pg_serial
drwx------ 1  999  999    0 Feb 13 17:06 pg_snapshots
drwx------ 1  999  999    0 Feb 13 17:06 pg_stat
drwx------ 1  999  999    0 Feb 13 17:06 pg_stat_tmp
drwx------ 1  999  999    0 Feb 13 17:06 pg_subtrans
drwx------ 1  999  999    0 Feb 13 17:06 pg_tblspc
drwx------ 1  999  999    0 Feb 13 17:06 pg_twophase
drwx------ 1  999  999   94 Feb 13 17:06 pg_wal
drwx------ 1  999  999    8 Feb 13 17:06 pg_xact
-rw------- 1  999  999   88 Feb 13 17:06 postgresql.auto.conf
-rw------- 1  999  999  31K Feb 13 17:06 postgresql.conf


---

compression par défaut :


Size /backup/*/ (compressed)
19M     /backup/20250214_132056_full
17M     /backup/20250214_132200_incr
17M     /backup/20250214_132334_incr
17M     /backup/20250214_132429_incr
17M     /backup/20250214_132523_incr
17M     /backup/20250214_132617_incr
17M     /backup/20250214_132711_incr
117M    /backup/
Size /uncompress/*/
47M     /uncompress/20250214_132056_full
39M     /uncompress/20250214_132200_incr
31M     /uncompress/20250214_132334_incr
39M     /uncompress/20250214_132429_incr
39M     /uncompress/20250214_132523_incr
31M     /uncompress/20250214_132617_incr
47M     /uncompress/20250214_132711_incr
269M    /uncompress/
PGDATA size
113M    /var/lib/postgres2/data/
