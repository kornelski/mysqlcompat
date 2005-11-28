-- ADDDATE(), DATE_ADD()
CREATE OR REPLACE FUNCTION adddate(date, interval)
RETURNS date AS $$
  SELECT ($1 + $2)::date
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- XXX: change to timestamps?
CREATE OR REPLACE FUNCTION date_add(date, interval)
RETURNS date AS $$
  SELECT ($1 + $2)::date
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION adddate(date, integer)
RETURNS date AS $$
  SELECT ($1 + $2 * interval '1 day')::date
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- ADDTIME()
-- Broken??
CREATE OR REPLACE FUNCTION addtime(time, time)
RETURNS time AS $$
  SELECT ($1 + $2)::time
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION addtime(timestamp, time)
RETURNS timestamp AS $$
  SELECT ($1 + $2)::timestamp
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- CONVERT_TZ()
CREATE OR REPLACE FUNCTION convert_tz(timestamp without time zone, text, text)
RETURNS timestamp without time zone AS $$
  SELECT ($1 || ' ' || $2)::timestamp with time zone AT TIME ZONE $3
$$ IMMUTABLE LANGUAGE SQL;

-- CURDATE()
-- Haven't implemented integer-context variant
CREATE OR REPLACE FUNCTION curdate()
RETURNS date AS $$
  SELECT CURRENT_DATE
$$ VOLATILE LANGUAGE SQL;

-- CURTIME()
-- Haven't implemented integer-context variant
CREATE OR REPLACE FUNCTION curtime()
RETURNS time without time zone AS $$
  SELECT LOCALTIME(0)
$$ VOLATILE LANGUAGE SQL;

-- DATEDIFF()
CREATE OR REPLACE FUNCTION datediff(date, date)
RETURNS integer AS $$
  SELECT $1 - $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- DATE_FORMAT()
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
-- Haven't implemented integer-context variant, nor second formatting
-- parameter.
CREATE OR REPLACE FUNCTION from_unixtime(bigint)
RETURNS timestamp without time zone AS $$
  SELECT 'epoch'::timestamp + $1 * INTERVAL '1 second'
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
      (((EXTRACT(YEAR FROM $1) + 1) || '-01-01')::date - INTERVAL '1 day')::date
    ELSE
      ((EXTRACT(YEAR FROM $1) || '-' || (EXTRACT(MONTH FROM $1) + 1) || '-01')::date - INTERVAL '1 day')::date
    END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MAKEDATE()
CREATE OR REPLACE FUNCTION makedate(integer, integer)
RETURNS date AS $$
  SELECT CASE WHEN $2 > 0 THEN
    (($1 || '-01-01')::date + ($2 - 1) * INTERVAL '1 day')::date
  ELSE
    NULL
  END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MAKETIME()
-- ??? Should this return an interval? Does mysql accept hour > 23?
CREATE OR REPLACE FUNCTION maketime(integer, integer, integer)
RETURNS time AS $$
  SELECT ($1 || ':' || $2 || ':' || $3)::time
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MICROSECOND()
-- ??? Only done time version.  Hard to get timestamp one
-- going as well due to overloading rules.
CREATE OR REPLACE FUNCTION microsecond(time)
RETURNS integer AS $$
  SELECT EXTRACT(MICROSECONDS FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MINUTE()
CREATE OR REPLACE FUNCTION minute(time)
RETURNS integer AS $$
  SELECT EXTRACT(MINUTES FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

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
-- Does not support integer context.

-- PERIOD_ADD()

-- PERIOD_DIFF()

-- QUARTER()
CREATE OR REPLACE FUNCTION quarter(date)
RETURNS integer AS $$
  SELECT EXTRACT(QUARTER FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SECOND()
CREATE OR REPLACE FUNCTION second(time)
RETURNS integer AS $$
  SELECT EXTRACT(SECONDS FROM $1)::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SEC_TO_TIME()
-- Haven't implemented integer-context variant
CREATE OR REPLACE FUNCTION sec_to_time(integer)
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

-- SUBDATE

-- SUBTIME
-- Haven't done (interval, interval) version
CREATE OR REPLACE FUNCTION subtime(timestamp, interval)
RETURNS timestamp AS $$
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

-- TIMESTAMP()
-- Not possible to implement

-- TIMESTAMPADD()

-- TIMESTAMPDIFF()

-- TIME_FORMAT()

-- TIME_TO_SEC()
CREATE OR REPLACE FUNCTION time_to_sec(interval)
RETURNS integer AS $$
  SELECT (EXTRACT(HOURS FROM $1) * 3600
    + EXTRACT(MINUTES FROM $1) * 60
    + EXTRACT(SECONDS FROM $1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- TO_DAYS()
-- Haven't done integer variant
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
CREATE OR REPLACE FUNCTION unix_timestamp(timestamp)
RETURNS bigint AS $$
  SELECT EXTRACT(EPOCH FROM $1)::bigint
$$ VOLATILE LANGUAGE SQL;

-- UTC_DATE()
-- Haven't done integer variant
CREATE OR REPLACE FUNCTION utc_date()
RETURNS date AS $$
  SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
$$ VOLATILE LANGUAGE SQL;

-- UTC_TIME()
-- Haven't done integer variant
CREATE OR REPLACE FUNCTION utc_time()
RETURNS time(0) AS $$
  SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::time(0)
$$ VOLATILE LANGUAGE SQL;

-- UTC_TIMESTAMP()
-- Haven't done integer variant
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

-- YEAR()
CREATE OR REPLACE FUNCTION year(date)
RETURNS integer AS $$
  SELECT EXTRACT(YEAR FROM DATE($1))::integer
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- YEARWEEK()
