CREATE OR REPLACE PROCEDURE ADD_HASH_TO_TABLES (IN req_table_name character varying)
LANGUAGE PLPGSQL
AS $$
DECLARE
    single_row record;
BEGIN
    EXECUTE format('ALTER TABLE %I ADD COLUMN hash CHAR(64)', req_table_name);
    EXECUTE format('UPDATE %I SET hash=md5(CAST((%I.*) AS text))', req_table_name, req_table_name);
    FOR single_row IN EXECUTE format('SELECT *, ROW_NUMBER() OVER() AS row_nr FROM %I', req_table_name)
    LOOP
        RAISE NOTICE 'For record row_nr % generated hash %', single_row.row_nr, single_row.hash;
    END LOOP;
END;
$$
