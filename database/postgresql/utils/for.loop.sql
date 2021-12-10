CREATE OR REPLACE FUNCTION for_loop() RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    row RECORD;
BEGIN
    FOR row IN select name, last_name, id, age from person

    LOOP
        update person
        set age = row.age + 10
        where id = row.id;
    END LOOP;
END
$$;