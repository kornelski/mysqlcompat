CREATE FUNCTION rand() RETURNS float AS '
  SELECT random()
' LANGUAGE SQL;

CREATE FUNCTION concat(text, text) RETURNS text AS '
  SELECT $1 || $2
' LANGUAGE SQL;

CREATE FUNCTION if(boolean, anyelement, anyelement) RETURNS anyelement AS '
  SELECT CASE WHEN $1 THEN $2 ELSE $3 END
' LANGUAGE SQL;

CREATE FUNCTION greatest(integer, integer) RETURNS integer AS '
  SELECT 
    CASE WHEN $2 IS NULL THEN $1
         WHEN $1 > $2 THEN $1
         ELSE $2
    END
' LANGUAGE SQL;

CREATE FUNCTION greatest(integer, integer, integer) RETURNS integer AS '
  SELECT greatest($1, greatest($2, $3))
' LANGUAGE SQL;


