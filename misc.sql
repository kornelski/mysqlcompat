-- INET_ATON()
-- Note: doesn't support short addresses, eg '127.1'
CREATE OR REPLACE FUNCTION inet_aton(inet)
RETURNS bigint AS $$
  DECLARE
      a text[];
  BEGIN
      IF pg_catalog.family($1) <> 4 THEN
          RETURN NULL;
      END IF;
  
      a := pg_catalog.string_to_array(host($1), '.');
  
      RETURN (a[1]::bigint << 24) |
             (a[2]::bigint << 16) |
             (a[3]::bigint << 8) |
             a[4]::bigint;
  END
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- INET_NTOA()
CREATE OR REPLACE FUNCTION inet_ntoa(bigint)
RETURNS text AS $$
  DECLARE 
    oct1 int;
    oct2 int;
    oct3 int;
    oct4 int;
  BEGIN
    IF $1 > 4294967295 THEN
      RETURN NULL;
    END IF;

    oct1 := ((($1 >> 24) % 256) + 256) % 256;
    oct2 := ((($1 >> 16) % 256) + 256) % 256;
    oct3 := ((($1 >>  8) % 256) + 256) % 256;
    oct4 := ((($1      ) % 256) + 256) % 256;
    RETURN oct1 || '.' || oct2 || '.' || oct3 || '.' || oct4;
  END
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- SLEEP()
CREATE OR REPLACE FUNCTION sleep(float)
RETURNS integer AS $$
  BEGIN
    WHILE pg_catalog.timeofday()::timestamp < (current_timestamp + interval '1 second' * $1) LOOP
      -- Do nothing
    END LOOP;
    RETURN 0;
  END
$$ STRICT VOLATILE LANGUAGE PLPGSQL;
