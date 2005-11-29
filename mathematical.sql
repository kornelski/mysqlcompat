-- Two parameter alias of atan2
CREATE OR REPLACE FUNCTION atan(double precision, double precision) 
RETURNS double precision AS '
  SELECT pg_catalog.atan2($1, $2)
' IMMUTABLE STRICT LANGUAGE SQL;

-- CRC32
-- Not implemented

-- FORMAT
CREATE OR REPLACE FUNCTION format(double precision, integer)
RETURNS text AS '
  SELECT pg_catalog.to_char($1, ''FM999,999,999,999,999,999,999.'' 
    operator(pg_catalog.||) pg_catalog.repeat(''0'', $2))
' IMMUTABLE STRICT LANGUAGE SQL;

-- LN, LOG
-- Not reimplemented but note that PostgreSQL has an error on -ve values,
-- but MySQL just returns NULL.

-- LOG2
CREATE OR REPLACE FUNCTION log2(numeric)
RETURNS numeric AS '
  SELECT CASE WHEN $1 > 0 THEN pg_catalog.log(2, $1) ELSE NULL END
' IMMUTABLE STRICT LANGUAGE SQL;

-- LOG10
CREATE OR REPLACE FUNCTION log10(numeric)
RETURNS numeric AS '
  SELECT CASE WHEN $1 > 0 THEN pg_catalog.log(10, $1) ELSE NULL END
' IMMUTABLE STRICT LANGUAGE SQL;

-- MOD
-- PostgreSQL has all MOD usage the same as MySQL EXCEPT this will not work:
--
-- SELECT 29 MOD 9;

-- RAND
CREATE OR REPLACE FUNCTION rand() RETURNS double precision AS '
  SELECT pg_catalog.random()
' VOLATILE LANGUAGE SQL;

-- RAND(N)
CREATE OR REPLACE FUNCTION rand(integer) RETURNS double precision AS '
  SELECT pg_catalog.setseed($1); 
  SELECT pg_catalog.random()
' VOLATILE LANGUAGE SQL;

-- SQRT
-- Not reimplemented but note that PostgreSQL has an error on -ve values,
-- but MySQL just returns NULL.

-- TRUNCATE
CREATE OR REPLACE FUNCTION truncate(numeric, integer)
RETURNS numeric AS '
  SELECT pg_catalog.trunc($1, $2)
' IMMUTABLE STRICT LANGUAGE SQL;

