# SELECT :sunglasses: FROM PL/pgSQL     :sparkles:

Some scripts (sometimes quite useless) written using PL/pgSQL

## Table of Contents

* copy_table_from_external_db.sql - procedure responsible for copying the table schema (without constraints) and data from an external database using the `dblink` extension.

    usage:
    ```
    CALL COPY_TABLE_FROM_EXTERNAL_DB ('your_db_string', 'your_table_string_from_your_db_string'); 
    ```

* count_hash.sql - procedure `COPY_TABLE_FROM_EXTERNAL_DB` responsible for counting MD5 hash for each record and trigger `HASH_GENERATOR` which counts md5 hash for inserted records

## Useful sql commands

* Check the size of the table `<TABLE_NAME>`
```
SELECT
    relname,
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
FROM
    pg_class C
WHERE
    relname = '<TABLE_NAME>';
```

* Check the size of the 20 largest tables
```
SELECT
    nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
FROM
    pg_class C
    LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE
    nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
ORDER BY
    pg_total_relation_size(C.oid) DESC
LIMIT 20;
```

* When was the last vacuum, autovacuum .. operation performed
```
SELECT
    relname,
    last_vacuum,
    last_autovacuum,
    last_autoanalyze,
    last_analyze
FROM
    pg_stat_all_tables
WHERE
    schemaname = 'public';
```

* Check the unfinished transactions
```
select current_timestamp-xact_start czas_trwania,datname,
application_name,client_addr,query from pg_stat_activity where xact_start is not null;
```

* seq_scan -> number of sequential reads, seq_tup_read -> number of records read
```
select relname,seq_scan,seq_tup_read,idx_scan, idx_tup_fetch
 from pg_stat_all_tables where relname='<TABLE_NAME>';
```

