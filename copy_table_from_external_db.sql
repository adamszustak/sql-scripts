CREATE OR REPLACE PROCEDURE COPY_TABLE_FROM_EXTERNAL_DB (IN DBNAME character varying, IN req_table_name character varying)
LANGUAGE PLPGSQL
AS $$
DECLARE
    raw_schema_with_cols record;
    full_data_query text;
    create_table_query text;
    dbname_arg text := CONCAT('dbname=', dbname);
    full_schema_query text := CONCAT('select column_name, data_type FROM information_schema.columns WHERE table_name = ''', req_table_name, ''';');
BEGIN
    CREATE EXTENSION IF NOT EXISTS dblink;
    WITH db_schema AS (
        SELECT
            *
        FROM
            dblink(dbname_arg, full_schema_query) AS db_schema (column_name text,
                datatype text)
),
combined_schema_columns AS (
    SELECT
        CONCAT_WS(' ', column_name, datatype) AS column_name_with_type,
        column_name,
        1 AS id
    FROM
        db_schema
),
combined_schema_columns_as_string AS (
    SELECT
        string_agg(column_name_with_type, ', ') AS combined_columns_with_types,
        string_agg(column_name, ', ') AS combined_columns
    FROM
        combined_schema_columns
    GROUP BY
        id
)
SELECT
    * INTO raw_schema_with_cols
FROM
    combined_schema_columns_as_string;
        full_data_query := CONCAT('SELECT * FROM dblink(''', dbname_arg, ''', ''SELECT ', raw_schema_with_cols.combined_columns, ' FROM ', req_table_name, ''') AS data_table(', raw_schema_with_cols.combined_columns_with_types, ')');
        RAISE NOTICE '%', full_data_query;
        IF (
            SELECT
                EXISTS (
                SELECT
                    1
                FROM
                    information_schema.tables
                WHERE
                    table_name = req_table_name)) THEN
            EXECUTE 'DROP TABLE ' || req_table_name;
        END IF;
        create_table_query := CONCAT('CREATE TABLE ', req_table_name, ' AS (', full_data_query, ');');
        RAISE NOTICE '%', create_table_query;
        EXECUTE create_table_query;
        -- Procedure responsible for generating MD5 hash
        CALL ADD_HASH_TO_TABLES (req_table_name);
END;
$$
