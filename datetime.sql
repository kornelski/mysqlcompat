-- ADDDATE(), DATE_ADD()
CREATE OR REPLACE FUNCTION adddate(date, interval)
RETURNS date AS '
  SELECT ($1 + $2)::date
' IMMUTABLE STRICT LANGUAGE SQL;

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

