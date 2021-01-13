create or replace function persian_date(input timestamp with time zone, with_time bool=true) returns character varying
    language plpgsql
as
$$
DECLARE
    day smallint;
    month smallint;
    year smallint;

    current_day smallint;
    current_month smallint;
    current_year smallint;
    current_month_end smallint;
    leap_year smallint;
    number_of_days int;
    constant_date timestamp without time zone;

    local_datetime timestamp with time zone;
    local_time time;

    result_year char(4);
    result_month char(2);
    result_day char(2);
    result_hour char(2);
    result_minute char(2);
    result_second char(2);

BEGIN
    if input isnull then
        return null;
    end if;

    constant_date = cast('1921-03-21' as timestamp without time zone);
    local_datetime = timezone('Asia/Tehran', input);
    number_of_days = DATE_PART('day', local_datetime - constant_date);
    day = 1;
    month = 1;
    year = 1300;
    leap_year = cast((number_of_days / 1461) as int);
    number_of_days = number_of_days - leap_year * 1461;
    current_year = cast((number_of_days / 365) as int);

    If current_year = 4 then
        current_year = current_year - 1;
    end if;

    number_of_days = number_of_days - current_year * 365;
    current_month = cast((number_of_days / 31) as int);

    If (current_month > 6) then
        current_month = 6;
    end if;

    number_of_days = number_of_days - current_month * 31;
    current_month_end = 0;

    If (number_of_days >= 30 And current_month = 6 ) then
        current_month_end = cast((number_of_days / 30) as int);

        If current_month_end >= 5 then
            current_month_end = 5;
        end if;

        number_of_days = number_of_days - current_month_end * 30;
    End if;

    current_month = (current_month_end + current_month);
    current_day = number_of_days;
    current_year = (current_year + leap_year * 4);
    year = (year + current_year);
    month = month + current_month;
    day = day + current_day;

    result_year = year;
    result_month = month;
    result_day = day;

    If length(result_month) = 1 then
        result_month = format('0%s', result_month);
    end if;

    If length(result_day) = 1 then
        result_day = format('0%s', result_day);
    end if;

    if with_time is true then
        local_time = local_datetime::time;
        result_hour = extract(hour from local_time);
        result_minute = extract(minute from local_time);
        result_second = extract(second from local_time)::int;

        If length(result_hour) = 1 then
            result_hour = format('0%s', result_hour);
        end if;

        If length(result_minute) = 1 then
            result_minute = format('0%s', result_minute);
        end if;

        If length(result_second) = 1 then
            result_second = format('0%s', result_second);
        end if;

        return format('%s-%s-%s %s:%s:%s',
            result_year, result_month, result_day,
            result_hour, result_minute, result_second);
    end if;

    return format('%s-%s-%s', result_year, result_month, result_day);
END;
$$;

alter function persian_date(timestamp with time zone, bool) owner to postgres;
