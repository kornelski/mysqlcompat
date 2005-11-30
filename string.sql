-- BIN()
CREATE OR REPLACE FUNCTION bin(bigint)
RETURNS text AS $$ 
  SELECT pg_catalog.ltrim(pg_catalog.textin(pg_catalog.bit_out($1::bit(64))), '0');
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- BIT_LENGTH()
CREATE OR REPLACE FUNCTION bit_length(text)
RETURNS integer AS $$
  SELECT pg_catalog.octet_length($1) * 8
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- CHAR()
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

-- CONV()

-- ELT()
CREATE OR REPLACE FUNCTION elt(integer, text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 < 1 OR $1 > 2 THEN NULL
    WHEN $1 = 1 THEN $2
    ELSE $3
  END 
$$ IMMUTABLE LANGUAGE SQL;

CREATE OR REPLACE FUNCTION elt(integer, text, text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 < 1 OR $1 > 3 THEN NULL
    WHEN $1 = 1 THEN $2
    WHEN $1 = 2 THEN $3
    ELSE $4
  END 
$$ IMMUTABLE LANGUAGE SQL;

CREATE OR REPLACE FUNCTION elt(integer, text, text, text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 < 1 OR $1 > 4 THEN NULL
    WHEN $1 = 1 THEN $2
    WHEN $1 = 2 THEN $3
    WHEN $1 = 3 THEN $4
    ELSE $5
  END 
$$ IMMUTABLE LANGUAGE SQL;

-- REVERSE()
CREATE OR REPLACE FUNCTION reverse(text)
RETURNS text AS $$
  DECLARE
    temp TEXT;
    count INTEGER;
  BEGIN
    temp := '';
    count := pg_catalog.length($1);
    FOR i IN REVERSE count..1 LOOP
      temp := temp  operator(pg_catalog.||)  substring($1 from i for 1);
    END LOOP;
    RETURN temp;
  END;
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- EXPORT_SET()
-- Depends on: BIN() and REVERSE()
-- XXX: WILL fail if $2 is '0'
CREATE OR REPLACE FUNCTION export_set(bigint, text, text, text, integer)
RETURNS text AS $$
  SELECT pg_catalog.rtrim(pg_catalog.replace(pg_catalog.replace(reverse(pg_catalog.lpad(bin($1), $5, '0')), 1, $2 operator(pg_catalog.||) $4), 0, $3 operator(pg_catalog.||) $4), $4)
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION export_set(bigint, text, text, text)
RETURNS text AS $$
  SELECT export_set($1, $2, $3, $4, 64)
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION export_set(bigint, text, text)
RETURNS text AS $$
  SELECT export_set($1, $2, $3, ',', 64)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- FIELD()
CREATE OR REPLACE FUNCTION field(text, text, text)
RETURNS integer AS $$
  SELECT CASE
    WHEN $1 = $2 THEN 1
    WHEN $1 = $3 THEN 2
    ELSE 0
  END 
$$ IMMUTABLE LANGUAGE SQL;

CREATE OR REPLACE FUNCTION field(text, text, text, text)
RETURNS integer AS $$
  SELECT CASE
    WHEN $1 = $2 THEN 1
    WHEN $1 = $3 THEN 2
    WHEN $1 = $4 THEN 3
    ELSE 0
  END 
$$ IMMUTABLE LANGUAGE SQL;

CREATE OR REPLACE FUNCTION field(text, text, text, text, text)
RETURNS integer AS $$
  SELECT CASE
    WHEN $1 = $2 THEN 1
    WHEN $1 = $3 THEN 2
    WHEN $1 = $4 THEN 3
    WHEN $1 = $5 THEN 4
    ELSE 0
  END 
$$ IMMUTABLE LANGUAGE SQL;

-- FIND_IN_SET()
CREATE OR REPLACE FUNCTION find_in_set(text, text)
RETURNS integer AS $$
  DECLARE
    list text[];
    len integer;
  BEGIN
    IF $2 = '' THEN
      RETURN 0;
    END IF;
    list := pg_catalog.string_to_array($2, ',');
    len := pg_catalog.array_upper(list, 1);
    FOR i IN 1..len LOOP
      IF list[i] = $1 THEN
        RETURN i;
      END IF;
    END LOOP;
    RETURN 0;
  END;
$$ STRICT IMMUTABLE LANGUAGE PLPGSQL;

-- HEX()
CREATE OR REPLACE FUNCTION hex(integer)
RETURNS text AS $$
  SELECT pg_catalog.upper(pg_catalog.to_hex($1))
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION hex(bigint)
RETURNS text AS $$
  SELECT pg_catalog.upper(pg_catalog.to_hex($1))
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION hex(text)
RETURNS text AS $$
  DECLARE
    len integer;
    temp text;
  BEGIN
    len := pg_catalog.length($1);
    temp := '';
    FOR i IN 1..len LOOP
      temp := temp operator(pg_catalog.||) pg_catalog.to_hex(pg_catalog.ascii(SUBSTRING($1 FROM i FOR 1)));
    END LOOP;
    RETURN pg_catalog.upper(temp);
  END;
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- FORMAT()
-- See: mathematical.sql

-- INSERT()
CREATE OR REPLACE FUNCTION insert(text, integer, integer, text)
RETURNS text AS $$
  SELECT CASE
    WHEN NOT $2 BETWEEN 1 AND pg_catalog.length($1) THEN $1
    ELSE overlay($1 placing $4 from $2 for $3)
  END
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- INSTR()
CREATE OR REPLACE FUNCTION instr(text, text)
RETURNS integer AS $$
  SELECT POSITION($2 IN $1)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- LCASE()
CREATE OR REPLACE FUNCTION lcase(text)
RETURNS text AS $$
  SELECT pg_catalog.lower($1)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- LEFT()
CREATE OR REPLACE FUNCTION left(text, integer)
RETURNS text AS $$
  SELECT substring($1 FOR $2);
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- LOAD_FILE()
-- Not implemented

-- LOCATE()
CREATE OR REPLACE FUNCTION locate(text, text, integer)
RETURNS integer AS $$
  SELECT POSITION($1 IN SUBSTRING ($2 FROM $3)) + $3 - 1
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION locate(text, text)
RETURNS integer AS $$
  SELECT locate($1, $2, 1)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- MAKE_SET()
-- Note implemented

-- MID()
CREATE OR REPLACE FUNCTION mid(text, integer, integer)
RETURNS text AS $$
  SELECT pg_catalog.substring($1, $2, $3)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- OCT()

-- ORD()
-- Note: Does not support multibyte
CREATE OR REPLACE FUNCTION ord(text)
RETURNS integer AS $$
  SELECT pg_catalog.ascii($1)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- QUOTE()
CREATE OR REPLACE FUNCTION quote(text)
RETURNS text AS $$
  SELECT CASE
    WHEN $1 IS NULL THEN 'NULL'
    ELSE pg_catalog.quote_literal($1)
  END
$$ IMMUTABLE LANGUAGE SQL;

-- REVERSE()
-- See above.  Needed by EXPORT_SET().

-- RIGHT()
CREATE OR REPLACE FUNCTION right(text, integer)
RETURNS text AS $$
  SELECT substring($1 FROM pg_catalog.length($1) + 1 - $2);
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SOUNDEX()
-- Thanks to Fredrik Olsson for the original soundex() function.
CREATE OR REPLACE FUNCTION _soundexcode(char(1))
RETURNS char(1) AS $$
  SELECT COALESCE(
    (ARRAY['0', '1', '2', '3', '0', 
           '1', '2', '0', '0', '2', 
           '2', '4', '5', '5', '0', 
           '1', '2', '6', '2', '3', 
           '0', '1', '0', '2', '0', '2'])[pg_catalog.ascii($1) - 64],
     '0');
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OR REPLACE FUNCTION soundex(text) RETURNS text AS $$
DECLARE
        a_text alias for $1;
	l_text text;
	l_lchr char(1);
	l_chr char(1);
	l_ret text;
BEGIN
	l_text := pg_catalog.upper(trim(both from a_text));
	IF l_text = '' THEN
		RETURN '0000';
	END IF;
	l_chr := substring(l_text FOR 1);
	l_ret := l_chr;
	l_text := substring(l_text FROM 2);
	WHILE (l_text <> '') LOOP
		l_lchr := l_chr; 
		l_chr := substring(l_text FOR 1);
		l_text := substring(l_text FROM 2);
		IF (pg_catalog.ascii(l_chr) BETWEEN 65 AND 90) AND
				(_soundexcode(l_chr) <> _soundexcode(l_lchr)) THEN
			IF _soundexcode(l_chr) <> '0' THEN
				l_ret := l_ret operator(pg_catalog.||) _soundexcode(l_chr);
			END IF;
		END IF;
	END LOOP;
	IF pg_catalog.length(l_ret) < 4 THEN
	 	l_ret := rpad(l_ret, 4, '0');
	END IF;
	RETURN l_ret;
END;
$$ IMMUTABLE STRICT LANGUAGE plpgsql;

-- SPACE()
CREATE OR REPLACE FUNCTION space(integer)
RETURNS text AS $$
  SELECT pg_catalog.repeat(' ', $1)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- SUBSTRING_INDEX()

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

-- UCASE()
CREATE OR REPLACE FUNCTION ucase(text)
RETURNS text AS $$
  SELECT pg_catalog.upper($1)
$$ IMMUTABLE STRICT LANGUAGE SQL;

-- UNCOMPRESS()
-- Not implemented.

-- UNHEX()
