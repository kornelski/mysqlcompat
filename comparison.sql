-- <=> NULL SAFE COMPARISON
-- Note: needs casts in some circumstances
CREATE OR REPLACE FUNCTION null_safe_cmp(anyelement, anyelement)
RETURNS integer AS '
  SELECT CASE
    WHEN $1 IS NULL AND $2 IS NULL THEN 1
    WHEN $1 IS NOT NULL != $2 IS NOT NULL THEN 0
    ELSE CASE 
      WHEN $1 = $2 THEN 1 
      ELSE 0
    END
  END
' IMMUTABLE LANGUAGE SQL;

CREATE OPERATOR <=> (
  PROCEDURE = null_safe_cmp,
  LEFTARG = anyelement,
  RIGHTARG = anyelement
);

