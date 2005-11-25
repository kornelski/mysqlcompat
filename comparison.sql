-- <=> NULL SAFE COMPARISON
-- Note: needs casts in some circumstances
CREATE OR REPLACE FUNCTION null_safe_cmp(anyelement, anyelement)
RETURNS integer AS '
  SELECT (NOT ($1 IS DISTINCT FROM $2))::integer 
' IMMUTABLE LANGUAGE SQL;

CREATE OPERATOR <=> (
  PROCEDURE = null_safe_cmp,
  LEFTARG = anyelement,
  RIGHTARG = anyelement
);

