create or replace function decode_url(url text)
  returns text as
$BODY$
DECLARE result text;
BEGIN
    if url isnull then
        return null;
    end if;

    BEGIN
        with str AS (
            select
                   case when url ~ '^%[0-9a-fA-F][0-9a-fA-F]'
                   then array['']
                   end
            || regexp_split_to_array(url, '(%[0-9a-fA-F][0-9a-fA-F])+', 'i') plain,

            array(select (regexp_matches(url, '((?:%[0-9a-fA-F][0-9a-fA-F])+)', 'gi'))[1]) encoded
            )

        select string_agg(plain[i] || coalesce(convert_from(decode(replace(encoded[i], '%',''), 'hex'), 'utf8'),''),'')
        from str, (select generate_series(1, array_upper(encoded, 1) + 2) i FROM str) serie
        into result;

    EXCEPTION WHEN OTHERS THEN
        raise notice 'failed: %', url;
        return url;
    END;

    return coalesce(result, url);

END;

$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT;
