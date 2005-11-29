-- &&
-- XXX: MySQL version has wacky null behaviour 
CREATE FUNCTION _and(boolean, boolean)
RETURNS boolean AS $$
  SELECT $1 AND $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OPERATOR && (
  leftarg = boolean,
  rightarg = boolean,
  procedure = _and,
  commutator = &&
);

-- ||
-- XXX: MySQL version has wacky null behaviour 
-- This replaces the SQL standard || concatenation operator
CREATE FUNCTION _or(boolean, boolean)
RETURNS boolean AS $$
  SELECT $1 OR $2
$$ IMMUTABLE STRICT LANGUAGE SQL;

CREATE OPERATOR || (
  leftarg = boolean,
  rightarg = boolean,
  procedure = _or,
  commutator = || 
);
