# SELECT :sunglasses: FROM PL/pgSQL     :sparkles:

Some scripts (sometimes quite useless) written using PL/pgSQL

## Table of Contents

* copy_table_from_external_db.sql - procedure responsible for copying the table schema (without constraints) and data from an external database using the `dblink` extension.

    usage:
    ```
    CALL COPY_TABLE_FROM_EXTERNAL_DB ('your_db_string', 'your_table_string_from_your_db_string'); 
    ```

* count_hash.sql - procedure responsible for counting MD5 hash for each record.

    usage:
    ```
    SELECT COUNT_HASH('your_string'); 
    ```
