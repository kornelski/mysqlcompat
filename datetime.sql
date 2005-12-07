-- ADDDATE()
-- Note: passing in the interval is different
CREATE OR REPLACE FUNCTION adddate(timestamp without time zone, interval)
RETURNS timestamp without time zone AS $$
    SELECT $1 + $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION adddate(timestamp without time zone, integer)
RETURNS timestamp without time zone AS $$
  SELECT $1 + (INTERVAL '1 day' * $2)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- ADDTIME()
-- Note: requires casting if you install both versions
CREATE OR REPLACE FUNCTION addtime(timestamp without time zone, interval)
RETURNS timestamp without time zone AS $$
  SELECT $1 + $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION addtime(interval, interval)
RETURNS interval AS $$
  SELECT $1 + $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- CONVERT_TZ()
CREATE OR REPLACE FUNCTION convert_tz(timestamp without time zone, text, text)
RETURNS timestamp without time zone AS $$
  SELECT CASE
    WHEN POSITION(':' IN $3) = 0 THEN
      ($1 operator(pg_catalog.||) ' ' operator(pg_catalog.||) $2)::timestamp with time zone AT TIME ZONE $3
    ELSE
      ($1 operator(pg_catalog.||) ' ' operator(pg_catalog.||) $2)::timestamp with time zone AT TIME ZONE $3::interval
    END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- CURDATE()
CREATE OR REPLACE FUNCTION curdate()
RETURNS date AS $$
  SELECT CURRENT_DATE
$$ VOLATILE LANGUAGE SQL;

-- CURTIME()
CREATE OR REPLACE FUNCTION curtime()
RETURNS time without time zone AS $$
  SELECT LOCALTIME(0)
$$ VOLATILE LANGUAGE SQL;

-- DATEDIFF()
CREATE OR REPLACE FUNCTION datediff(date, date)
RETURNS integer AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DATE_ADD()
CREATE OR REPLACE FUNCTION date_add(timestamp without time zone, interval)
RETURNS timestamp without time zone AS $$
  SELECT $1 + $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DATE_FORMAT()
-- XXX: TODO
-- Will make errors with strings like '%%y'
-- Not implemented week of year
CREATE OR REPLACE FUNCTION date_format(timestamp, text)
RETURNS text AS $$
  SELECT pg_catalog.to_char($1,
    pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(
    pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(
    pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(
    pg_catalog.replace(pg_catalog.replace($2, 
      '%a', 'Dy'), 
      '%b', 'Mon'), 
      '%c', 'FMMM'), 
      '%D', 'FMDDth'), 
      '%d', 'DD'), 
      '%e', 'FMDD'), 
      '%f', 'US'), 
      '%H', 'HH24'), 
      '%h', 'HH12'), 
      '%I', 'HH12'),      
      '%i', 'MI'), 
      '%j', 'DDD'), 
      '%k', 'FMHH24'), 
      '%l', 'FMHH12'), 
      '%M', 'FMMonth'), 
      '%m', 'MM'), 
      '%p', 'AM'), 
      '%r', 'HH12:MI:SS AM'), 
      '%S', 'SS'),
      '%s', 'SS'),
      '%T', 'HH24:MI:SS'), 
      '%U', '?'),
      '%u', '?'), 
      '%V', '?'), 
      '%v', '?'), 
      '%W', 'FMDay'), 
      '%w', EXTRACT(DOW FROM $1)), 
      '%X', '?'), 
      '%x', '?'), 
      '%Y', 'YYYY'), 
      '%y', 'YY'),
      '%%', '%')
  )
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DATE_SUB()
CREATE OR REPLACE FUNCTION date_sub(timestamp without time zone, interval)
RETURNS timestamp without time zone AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DAY()
CREATE OR REPLACE FUNCTION day(date)
RETURNS integer AS $$
  SELECT EXTRACT(DAY FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DAYNAME()
CREATE OR REPLACE FUNCTION dayname(date)
RETURNS text AS $$
  SELECT pg_catalog.to_char($1, 'FMDay')
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DAYOFMONTH()
CREATE OR REPLACE FUNCTION dayofmonth(date)
RETURNS integer AS $$
  SELECT EXTRACT(DAY FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DAYOFWEEK()
CREATE OR REPLACE FUNCTION dayofweek(date)
RETURNS integer AS $$
  SELECT EXTRACT(DOW FROM DATE($1))::integer + 1
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DAYOFYEAR()
CREATE OR REPLACE FUNCTION dayofyear(date)
RETURNS integer AS $$
  SELECT EXTRACT(DOY FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- FROM_DAYS()
CREATE OR REPLACE FUNCTION from_days(integer)
RETURNS date AS $$
  SELECT ('0000-01-01'::date + $1 * INTERVAL '1 day')::date
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- FROM_UNIXTIME()
-- Returns local time?  Is this actually the same as MySQL?
-- Depends on: DATE_FORMAT()
CREATE OR REPLACE FUNCTION from_unixtime(bigint)
RETURNS timestamp without time zone AS $$
  SELECT pg_catalog.to_timestamp($1)::timestamp without time zone
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION from_unixtime(bigint, text)
RETURNS text AS $$
  SELECT date_format(from_unixtime($1), $2)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- GET_FORMAT()
-- Note that first parameter needs to be quoted in this version
CREATE OR REPLACE FUNCTION get_format(text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 ILIKE 'DATE' THEN
      CASE WHEN $2 ILIKE 'USA' THEN '%m.%d.%Y'
      WHEN $2 ILIKE 'JIS' OR $2 ILIKE 'ISO' THEN '%Y-%m-%d'
      WHEN $2 ILIKE 'EUR' THEN '%d.%m.%Y'
      WHEN $2 ILIKE 'INTERNAL' THEN '%Y%m%d'
      ELSE NULL
      END
    WHEN $1 ILIKE 'DATETIME' THEN
      CASE WHEN $2 ILIKE 'USA' OR $2 ILIKE 'EUR' THEN '%Y-%m-%d-%H.%i.%s'
      WHEN $2 ILIKE 'JIS' OR $2 ILIKE 'ISO' THEN '%Y-%m-%d %H:%i:%s'
      WHEN $2 ILIKE 'INTERNAL' THEN '%Y%m%d%H%i%s'
      ELSE NULL
      END
    WHEN $1 ILIKE 'TIME' THEN
      CASE WHEN $2 ILIKE 'USA' THEN '%h:%i:%s %p'
      WHEN $2 ILIKE 'JIS' OR $2 ILIKE 'ISO' THEN '%H:%i:%s'
      WHEN $2 ILIKE 'EUR' THEN 'H.%i.%S'
      WHEN $2 ILIKE 'INTERNAL' THEN '%H%i%s'
      ELSE NULL
      END
    ELSE
      NULL
    END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- HOUR()
-- Note: takes an interval instead of a time since MySQL's HOUR()
-- function deals with times like: '272:59:59'
CREATE OR REPLACE FUNCTION hour(interval)
RETURNS integer AS $$ 
  SELECT EXTRACT (HOUR FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- LAST_DAY()
-- Note that for illegal timestamps this function raises an error,
-- whereas under MySQL it returns NULL
CREATE OR REPLACE FUNCTION last_day(timestamp)
RETURNS date AS $$ 
  SELECT CASE
    WHEN EXTRACT(MONTH FROM $1) = 12 THEN
      (((EXTRACT(YEAR FROM $1) + 1) operator(pg_catalog.||) '-01-01')::date - INTERVAL '1 day')::date
    ELSE
      ((EXTRACT(YEAR FROM $1) operator(pg_catalog.||) '-' operator(pg_catalog.||) (EXTRACT(MONTH FROM $1) + 1) operator(pg_catalog.||) '-01')::date - INTERVAL '1 day')::date
    END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MAKEDATE()
CREATE OR REPLACE FUNCTION makedate(integer, integer)
RETURNS date AS $$
  SELECT CASE WHEN $2 > 0 THEN
    (($1 operator(pg_catalog.||) '-01-01')::date + ($2 - 1) * INTERVAL '1 day')::date
  ELSE
    NULL
  END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MAKETIME()
CREATE OR REPLACE FUNCTION maketime(integer, integer, integer)
RETURNS interval AS $$
  SELECT ($1 operator(pg_catalog.||) ':' operator(pg_catalog.||) $2 operator(pg_catalog.||) ':' operator(pg_catalog.||) $3)::interval
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MICROSECOND()
-- Timestamp version not implemented
CREATE OR REPLACE FUNCTION microsecond(time)
RETURNS integer AS $$
  SELECT (EXTRACT(MICROSECONDS FROM $1))::integer % 1000000
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MINUTE()
CREATE OR REPLACE FUNCTION minute(time)
RETURNS integer AS $$
  SELECT EXTRACT(MINUTES FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- XXXX UP TO HERE XXXX --

-- MONTH()
CREATE OR REPLACE FUNCTION month(date)
RETURNS integer AS $$
  SELECT EXTRACT(MONTH FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MONTHNAME()
CREATE OR REPLACE FUNCTION monthname(date)
RETURNS text AS $$
  SELECT pg_catalog.to_char($1, 'FMMonth')
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- NOW()
-- Part of base PostgreSQL

-- PERIOD_ADD()
CREATE OR REPLACE FUNCTION period_add(integer, integer)
RETURNS text AS $$
  DECLARE
    period text;
    base date;
    baseyear integer;
  BEGIN
      IF pg_catalog.length($1) < 4 THEN
        period := pg_catalog.lpad($1, 4, 0);
      ELSIF pg_catalog.length($1) = 5 THEN
        period := pg_catalog.lpad($1, 6, 0);
      ELSE
        period := $1;
      END IF;

      IF pg_catalog.length(period) = 4 THEN
        baseyear := SUBSTRING(period FROM 1 FOR 2);
        IF baseyear BETWEEN 70 AND 99 THEN
          baseyear := baseyear + 1900;
        ELSE
          baseyear := baseyear + 2000;
        END IF;
        base := (baseyear operator(pg_catalog.||) '-' operator(pg_catalog.||) SUBSTRING(period FROM 3) operator(pg_catalog.||) '-01')::date;
      ELSIF pg_catalog.length(period) = 6 THEN
        base := (SUBSTRING(period FROM 1 FOR 4) operator(pg_catalog.||) '-' operator(pg_catalog.||) SUBSTRING(period FROM 5) operator(pg_catalog.||) '-01')::date;
      ELSE
        RETURN NULL;
      END IF;

      base := base + (INTERVAL '1 month' * $2);
      RETURN pg_catalog.lpad(EXTRACT(YEAR FROM base), 4, '0') operator(pg_catalog.||) pg_catalog.lpad(EXTRACT(MONTH FROM base), 2, '0');
  END
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- PERIOD_DIFF()
CREATE OR REPLACE FUNCTION period_diff(integer, integer)
RETURNS integer AS $$
  DECLARE
    baseyear integer;
    period1 text;
    period2 text;
    months1 integer;
    months2 integer;
  BEGIN
      IF pg_catalog.length($1) < 4 THEN
        period1 := pg_catalog.lpad($1, 4, 0);
      ELSIF pg_catalog.length($1) = 5 THEN
        period1 := pg_catalog.lpad($1, 6, 0);
      ELSE
        period1 := $1;
      END IF;

      IF pg_catalog.length(period1) = 4 THEN
        baseyear := SUBSTRING(period1 FROM 1 FOR 2);
        IF baseyear BETWEEN 70 AND 99 THEN
          baseyear := baseyear + 1900;
        ELSE
          baseyear := baseyear + 2000;
        END IF;
        months1 := baseyear * 12 + SUBSTRING(period1 FROM 3)::integer;
      ELSIF pg_catalog.length(period1) = 6 THEN
        months1 := SUBSTRING(period1 FROM 1 FOR 4)::integer * 12 + SUBSTRING(period1 FROM 5)::integer;
      ELSE
        RETURN NULL;
      END IF;

      IF pg_catalog.length($2) < 4 THEN
        period2 := pg_catalog.lpad($2, 4, 0);
      ELSIF pg_catalog.length($2) = 5 THEN
        period2 := pg_catalog.lpad($2, 6, 0);
      ELSE
        period2 := $2;
      END IF;

      IF pg_catalog.length(period2) = 4 THEN
        baseyear := SUBSTRING(period2 FROM 1 FOR 2);
        IF baseyear BETWEEN 70 AND 99 THEN
          baseyear := baseyear + 1900;
        ELSE
          baseyear := baseyear + 2000;
        END IF;
        months2 := baseyear * 12 + SUBSTRING(period2 FROM 3)::integer;
      ELSIF pg_catalog.length(period2) = 6 THEN
        months2 := SUBSTRING(period2 FROM 1 FOR 4)::integer * 12 + SUBSTRING(period2 FROM 5)::integer;
      ELSE
        RETURN NULL;
      END IF;

      RETURN months1 - months2;
  END
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- QUARTER()
CREATE OR REPLACE FUNCTION quarter(date)
RETURNS integer AS $$
  SELECT EXTRACT(QUARTER FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SECOND()
CREATE OR REPLACE FUNCTION second(interval)
RETURNS integer AS $$
  SELECT EXTRACT(SECONDS FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SEC_TO_TIME()
CREATE OR REPLACE FUNCTION sec_to_time(bigint)
RETURNS interval AS $$
  SELECT $1 * INTERVAL '1 second'
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- STR_TO_DATE()
-- XXX: DOESN'T WORK YET
CREATE OR REPLACE FUNCTION str_to_date(text, text)
RETURNS timestamp without time zone AS $$
  SELECT pg_catalog.to_timestamp($1,
    pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(
    pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(
    pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(pg_catalog.replace(
    pg_catalog.replace(pg_catalog.replace($2, 
      '%a', 'Dy'), 
      '%b', 'Mon'), 
      '%c', 'FMMM'), 
      '%D', 'FMDDth'), 
      '%d', 'DD'), 
      '%e', 'FMDD'), 
      '%f', 'US'), 
      '%H', 'HH24'), 
      '%h', 'HH12'), 
      '%I', 'HH12'),      
      '%i', 'MI'), 
      '%j', 'DDD'), 
      '%k', 'FMHH24'), 
      '%l', 'FMHH12'), 
      '%M', 'FMMonth'), 
      '%m', 'MM'), 
      '%p', 'AM'), 
      '%r', 'HH12:MI:SS AM'), 
      '%S', 'SS'),
      '%s', 'SS'),
      '%T', 'HH24:MI:SS'), 
      '%U', '?'),
      '%u', '?'), 
      '%V', '?'), 
      '%v', '?'), 
      '%W', 'FMDay'), 
      '%w', '?'), 
      '%X', '?'), 
      '%x', '?'), 
      '%Y', 'YYYY'), 
      '%y', 'YY'),
      '%%', '%')
  )::timestamp without time zone
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SUBDATE()
-- Note: passing in the interval is different
CREATE OR REPLACE FUNCTION subdate(timestamp without time zone, interval)
RETURNS timestamp without time zone AS $$
    SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION subdate(timestamp without time zone, integer)
RETURNS timestamp without time zone AS $$
  SELECT $1 - (INTERVAL '1 day' * $2)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SUBTIME
-- Note: requires casting if you install both versions
CREATE OR REPLACE FUNCTION subtime(timestamp without time zone, interval)
RETURNS timestamp without time zone AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION subtime(interval, interval)
RETURNS interval AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SYSDATE()
CREATE OR REPLACE FUNCTION sysdate()
RETURNS timestamp without time zone AS $$
  SELECT pg_catalog.timeofday()::timestamp(0) without time zone
$$ VOLATILE LANGUAGE SQL;

-- TIME()
-- Not possible to implement

-- TIMEDIFF()
-- Note: requires casting if you install both versions
CREATE OR REPLACE FUNCTION timediff(timestamp without time zone, timestamp without time zone)
RETURNS interval AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION timediff(time without time zone, time without time zone)
RETURNS interval AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- TIMESTAMP()
-- Not possible to implement

-- TIMESTAMPADD()
-- Note that first parameter needs to be quoted in this version
CREATE OR REPLACE FUNCTION timestampadd(text, integer, timestamp without time zone)
RETURNS timestamp without time zone AS $$
  SELECT $3 + ($2 operator(pg_catalog.||) ' ' operator(pg_catalog.||) $1)::interval
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- TIMESTAMPDIFF()
-- Note that first parameter needs to be quoted in this version

-- TIME_FORMAT()

-- TIME_TO_SEC()
CREATE OR REPLACE FUNCTION time_to_sec(interval)
RETURNS bigint AS $$
  SELECT (EXTRACT(HOURS FROM $1) * 3600
    + EXTRACT(MINUTES FROM $1) * 60
    + EXTRACT(SECONDS FROM $1))::bigint
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- TO_DAYS()
-- XXX: Haven't done integer variant
CREATE OR REPLACE FUNCTION to_days(date)
RETURNS integer AS $$
  SELECT $1 - '0000-01-01'::date
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- UNIX_TIMESTAMP()
CREATE OR REPLACE FUNCTION unix_timestamp()
RETURNS bigint AS $$
  SELECT EXTRACT(EPOCH FROM LOCALTIMESTAMP)::bigint
$$ VOLATILE LANGUAGE SQL;

-- XXX: This gives wrong answers? Time zones?
CREATE OR REPLACE FUNCTION unix_timestamp(timestamp without time zone)
RETURNS bigint AS $$
  SELECT EXTRACT(EPOCH FROM $1)::bigint
$$ VOLATILE LANGUAGE SQL;

-- UTC_DATE()
CREATE OR REPLACE FUNCTION utc_date()
RETURNS date AS $$
  SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
$$ VOLATILE LANGUAGE SQL;

-- UTC_TIME()
CREATE OR REPLACE FUNCTION utc_time()
RETURNS time(0) AS $$
  SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::time(0)
$$ VOLATILE LANGUAGE SQL;

-- UTC_TIMESTAMP()
CREATE OR REPLACE FUNCTION utc_timestamp()
RETURNS timestamp(0) AS $$
  SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::timestamp(0)
$$ VOLATILE LANGUAGE SQL;

-- WEEK()

-- WEEKDAY()
CREATE OR REPLACE FUNCTION weekday(date)
RETURNS integer AS $$
  SELECT CASE
    WHEN EXTRACT(DOW FROM $1)::integer = 0 THEN
      6
    ELSE
      EXTRACT(DOW FROM $1)::integer - 1
    END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- WEEKOFYEAR()
CREATE OR REPLACE FUNCTION weekofyear(date)
RETURNS integer AS $$
  SELECT EXTRACT(WEEK FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- YEAR()
CREATE OR REPLACE FUNCTION year(date)
RETURNS integer AS $$
  SELECT EXTRACT(YEAR FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- YEARWEEK()
-- XXX: THIS IS BROKEN
CREATE OR REPLACE FUNCTION yearweek(date)
RETURNS text AS $$
  SELECT CASE
    WHEN EXTRACT(WEEK FROM $1)::integer = 53 THEN
      pg_catalog.lpad(EXTRACT(YEAR FROM $1) - 1, 4, '0') || '53'
    ELSE
      pg_catalog.lpad(EXTRACT(YEAR FROM $1) - 1, 4, '0')
        || pg_catalog.lpad(EXTRACT(WEEK FROM $1), 2, '0')
    END
$$ IMMUTABLE STRICT LANGUAGE SQL;

/*

set check_function_bodies = false;

-- dff(format) - return the to_char format for a %-spec
create function dff(text) returns text language sql
 as $f$ select case when $1 = '%' then '%'
                    when $1 = 'Y' then 'YYYY'
                    when $1 = 'm' then 'MM'
                    when $1 = 'd' then 'DD'
                    else '' end $f$;
 
-- df2(time,prefix,format,suffix)
create function df2(timestamptz,text,text,text) returns text language sql
 as $f$ select case when $1 is null then null
                    when $2 is null then null
                    when $3 is null then $2
                    when $4 is null then $2
                    else $2 operator(pg_catalog.||) to_char($1,dff($3)) operator(pg_catalog.||) date_format($1,$4) end $f$;
 
create or replace function date_format(timestamptz,text) returns text language sql
 as $f$ select df2($1,
                   substring($2 from '^(.*?)(?:%[%A-Za-z].*)?$'),
                   substring($2 from '^(?:.*?)(?:%([%A-Za-z]).*)$'),
                   substring($2 from '^(?:.*?)(?:%[%A-Za-z](.*))$')) $f$;
*/
