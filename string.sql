-- BIN()
CREATE OR REPLACE FUNCTION bin(bigint)
RETURNS bit(64) AS $$ 
  SELECT $1::bit(64)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- BIT_LENGTH()
CREATE OR REPLACE FUNCTION bit_length(text)
RETURNS integer AS $$
  SELECT pg_catalog.octet_length($1) * 8
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- CHAR(N, ...)
-- Not implemented

-- COMPRESS
-- Not implemented

-- CONCAT
CREATE OR REPLACE FUNCTION concat(text)
RETURNS text AS $$
  SELECT $1
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION concat(text, text)
RETURNS text AS $$
  SELECT $1 operator(pg_catalog.||) $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION concat(text, text, text)
RETURNS text AS $$
  SELECT $1 operator(pg_catalog.||) $2 operator(pg_catalog.||) $3
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- CONCAT_WS
-- Note: fails in this case: select concat_ws(',', 'First name', null);
CREATE OR REPLACE FUNCTION concat_ws(text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 IS NULL THEN NULL
    ELSE $2
  END
$$ IMMUTABLE LANGUAGE SQL;

CREATE OR REPLACE FUNCTION concat_ws(text, text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 IS NULL THEN NULL
    ELSE
      coalesce($2 operator(pg_catalog.||) $1, '') operator(pg_catalog.||) coalesce($3, '')
  END
$$ IMMUTABLE LANGUAGE SQL;

CREATE OR REPLACE FUNCTION concat_ws(text, text, text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 IS NULL THEN NULL
    ELSE 
      coalesce($2 operator(pg_catalog.||) $1, '') operator(pg_catalog.||) coalesce($3 operator(pg_catalog.||) $1, '') operator(pg_catalog.||) coalesce($4, '')
  END
$$ IMMUTABLE LANGUAGE SQL;

-- HEX()
-- XXX: String variant not implemented
CREATE OR REPLACE FUNCTION hex(integer)
RETURNS text AS $$
  SELECT pg_catalog.upper(pg_catalog.to_hex($1))
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION hex(bigint)
RETURNS text AS $$
  SELECT pg_catalog.upper(pg_catalog.to_hex($1))
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- INSERT()
CREATE OR REPLACE FUNCTION insert(text, integer, integer, text)
RETURNS text AS $$
  SELECT CASE
    WHEN NOT $2 BETWEEN 1 AND pg_catalog.length($1) THEN $1
    ELSE overlay($1 placing $4 from $2 for $3)
  END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- STRCMP()
-- Note: comparison is case-sensitive
CREATE OR REPLACE FUNCTION strcmp(text, text)
RETURNS integer AS $$
  SELECT CASE
    WHEN $1 = $2 THEN 0
    WHEN $1 < $2 THEN -1
    ELSE 1
  END
$$ IMMUTABLE STRICT LANGUAGE SQL;

