CREATE OR REPLACE PROCEDURE ADD_HASH_TO_TABLES (IN req_table_name character varying)
LANGUAGE PLPGSQL
AS $$
DECLARE
    single_row record;
    function_count_hashes text := 'count_hash';
BEGIN
    EXECUTE format('ALTER TABLE %I ADD COLUMN hash CHAR(64)', req_table_name);
    EXECUTE format('UPDATE %I SET hash=md5(CAST((%I.*) AS text))', req_table_name, req_table_name);
    FOR single_row IN EXECUTE format('SELECT *, ROW_NUMBER() OVER() AS row_nr FROM %I', req_table_name)
    LOOP
        RAISE NOTICE 'For record row_nr % generated hash %', single_row.row_nr, single_row.hash;
    END LOOP;
    EXECUTE format('CREATE OR REPLACE TRIGGER HASH_GENERATOR BEFORE INSERT ON %I FOR EACH ROW EXECUTE PROCEDURE %I()', req_table_name, function_count_hashes);
END;
$$ 


CREATE OR REPLACE FUNCTION count_hash ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.hash IS NOT NULL THEN
        RAISE EXCEPTION 'Wrong hash %', NEW.hash;
    END IF;
    NEW.hash := md5(CAST((NEW.*) AS text));
    RETURN NEW;
END;
$$
