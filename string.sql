-- BIN
-- Not implemented

-- CHAR(N, ...)
-- Not implemented

-- COMPRESS
-- Not implemented

-- CONCAT

-- CONCAT_WS

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

