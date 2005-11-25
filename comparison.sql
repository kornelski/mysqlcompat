-- <=> NULL SAFE COMPARISON
-- Note: needs casts in some circumstances
CREATE OR REPLACE FUNCTION null_safe_cmp(anyelement, anyelement)
RETURNS integer AS '
  SELECT CASE
    WHEN ($1 IS DISTINCT FROM $2) THEN 0
    ELSE 1
  END 
' IMMUTABLE LANGUAGE SQL;

CREATE OPERATOR <=> (
  PROCEDURE = null_safe_cmp,
  LEFTARG = anyelement,
  RIGHTARG = anyelement
);

