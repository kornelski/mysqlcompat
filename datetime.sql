-- ADDDATE(), DATE_ADD()
CREATE OR REPLACE FUNCTION adddate(date, interval)
RETURNS date AS '
  SELECT ($1 + $2)::date
' IMMUTABLE STRICT LANGUAGE SQL;

-- XXX: change to timestamps?
CREATE OR REPLACE FUNCTION date_add(date, interval)
RETURNS date AS '
  SELECT ($1 + $2)::date
' IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION adddate(date, integer)
RETURNS date AS '
  SELECT ($1 + $2 * interval ''1 day'')::date
' IMMUTABLE STRICT LANGUAGE SQL;

-- ADDTIME()
CREATE OR REPLACE FUNCTION addtime(time, time)
RETURNS time AS '
  SELECT ($1 + $2)::time
' IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION addtime(timestamp, time)
RETURNS timestamp AS '
  SELECT ($1 + $2)::timestamp
' IMMUTABLE STRICT LANGUAGE SQL;

-- CONVERT_TZ()
CREATE OR REPLACE FUNCTION convert_tz(timestamp without time zone, text, text)
RETURNS timestamp without time zone AS '
  SELECT ($1 || '' '' || $2)::timestamp with time zone AT TIME ZONE $3
' IMMUTABLE LANGUAGE SQL;

-- CURDATE()
-- Haven't implemented integer-context variant
CREATE OR REPLACE FUNCTION curdate()
RETURNS date AS '
  SELECT CURRENT_DATE
' VOLATILE LANGUAGE SQL;

-- CURTIME()
-- Haven't implemented integer-context variant
CREATE OR REPLACE FUNCTION curtime()
RETURNS time without time zone AS '
  SELECT LOCALTIME(0)
' VOLATILE LANGUAGE SQL;

-- DATEDIFF()
CREATE OR REPLACE FUNCTION datediff(date, date)
RETURNS integer AS '
  SELECT $1 - $2
' IMMUTABLE STRICT LANGUAGE SQL;

-- DATE_FORMAT()

-- DAY()
CREATE OR REPLACE FUNCTION day(date)
RETURNS integer AS '
  SELECT EXTRACT(DAY FROM DATE($1))::integer
' IMMUTABLE STRICT LANGUAGE SQL;

-- DAYNAME()
CREATE OR REPLACE FUNCTION dayname(date)
RETURNS text AS '
  SELECT pg_catalog.to_char($1, ''FMDay'')
' IMMUTABLE STRICT LANGUAGE SQL;

-- DAYOFMONTH()
CREATE OR REPLACE FUNCTION dayofmonth(date)
RETURNS integer AS '
  SELECT EXTRACT(DAY FROM DATE($1))::integer
' IMMUTABLE STRICT LANGUAGE SQL;

-- DAYOFWEEK()
CREATE OR REPLACE FUNCTION dayofweek(date)
RETURNS integer AS '
  SELECT EXTRACT(DOW FROM DATE($1))::integer + 1
' IMMUTABLE STRICT LANGUAGE SQL;

-- DAYOFYEAR()
CREATE OR REPLACE FUNCTION dayofyear(date)
RETURNS integer AS '
  SELECT EXTRACT(DOY FROM DATE($1))::integer
' IMMUTABLE STRICT LANGUAGE SQL;

-- FROM_DAYS()
CREATE OR REPLACE FUNCTION from_days(integer)
RETURNS date AS '
  SELECT (''0000-01-01''::date + $1 * INTERVAL ''1 day'')::date
' IMMUTABLE STRICT LANGUAGE SQL;

-- FROM_UNIXTIME()
-- Haven't implemented integer-context variant, not second formatting
-- parameter.
CREATE OR REPLACE FUNCTION from_unixtime(integer)
RETURNS timestamp without time zone AS '
  SELECT ''epoch''::timestamp + $1 * INTERVAL ''1 second''
' IMMUTABLE STRICT LANGUAGE SQL;

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

-- MONTH()
-- ?? Needs to support timestamps?
CREATE OR REPLACE FUNCTION month(date)
RETURNS integer AS '
  SELECT EXTRACT(MONTH FROM DATE($1))::integer
' IMMUTABLE STRICT LANGUAGE SQL;

-- MONTHNAME()
-- ?? Needs to support timestamps?
CREATE OR REPLACE FUNCTION monthname(date)
RETURNS text AS '
  SELECT pg_catalog.to_char($1, ''FMMonth'')
' IMMUTABLE STRICT LANGUAGE SQL;

-- NOW()
-- Does not support integer context.

-- PERIOD_ADD()

-- PERIOD_DIFF()

-- QUARTER()
-- ?? Needs to support timestamps?
CREATE OR REPLACE FUNCTION quarter(date)
RETURNS integer AS '
  SELECT EXTRACT(QUARTER FROM DATE($1))::integer
' IMMUTABLE STRICT LANGUAGE SQL;
