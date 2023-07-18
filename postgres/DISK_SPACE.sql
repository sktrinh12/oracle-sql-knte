SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';
CREATE TABLE DISK_SPACE (
  record_extracted TEXT NOT NULL,
  record_date TIMESTAMP NOT NULL
);

--drop table my_table;
select * from "DISK_SPACE";


COPY disk_space
FROM '/Users/spencer.trinhkinnate.com/Desktop/disk_space.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE DISK_SPACE (
  record_extracted TEXT NOT NULL,
  record_date TIMESTAMP NOT NULL
);


-- drop table disk_usage_time_series;


SELECT unnest(string_to_array(record_extracted, E'\n')) as disk_info, record_date
FROM disk_space;

select 
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[1] AS "Filesystem",
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[1] AS "Filesystem"
from disk_space;

select * from disk_usage_time_series order by "Date" ASC;

SELECT "Filesystem", "Type", "Size", "Date", COUNT(*) 
FROM disk_usage_time_series 
GROUP BY "Filesystem", "Type", "Size", "Date" 
HAVING COUNT(*) > 1;

DELETE FROM disk_usage_time_series
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM disk_usage_time_series
    GROUP BY "Filesystem", "Type", "Size", "Date"
);


CREATE TABLE IF NOT EXISTS disk_usage_time_series AS
SELECT 
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[1] AS "Filesystem",
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[2] AS "Type",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[3], '\D', '', 'g')AS numeric) AS "Size",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[4], '\D', '', 'g')AS numeric) AS "Used",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[5], '\D', '', 'g')AS numeric) AS "Avail",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[1], E'\\s+'))[6], '\D', '', 'g')AS numeric) AS "Use%",
    DATE_TRUNC('day', record_date) AS "Date"
FROM (
    SELECT record_extracted, record_date
    FROM disk_space
	) t
UNION ALL
SELECT 
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[1] AS "Filesystem",
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[2] AS "Type",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[3], '\D', '', 'g')AS numeric) AS "Size",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[4], '\D', '', 'g')AS numeric) AS "Used",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[5], '\D', '', 'g')AS numeric) AS "Avail",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[2], E'\\s+'))[6], '\D', '', 'g')AS numeric) AS "Use%",
    DATE_TRUNC('day', record_date) AS "Date"
FROM (
    SELECT record_extracted, record_date
    FROM disk_space
	) t
UNION ALL
SELECT 
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[3], E'\\s+'))[1] AS "Filesystem",
    (regexp_split_to_array((string_to_array(record_extracted, E'\n'))[3], E'\\s+'))[2] AS "Type",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[3], E'\\s+'))[3], '\D', '', 'g') AS numeric) AS "Size",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[3], E'\\s+'))[4], '\D', '', 'g') AS numeric) AS "Used",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[3], E'\\s+'))[5], '\D', '', 'g') AS numeric) AS "Avail",
    CAST(regexp_replace((regexp_split_to_array((string_to_array(record_extracted, E'\n'))[3], E'\\s+'))[6], '\D', '', 'g') AS numeric) AS "Use%",
    DATE_TRUNC('day', record_date) AS "Date"
FROM (
    SELECT record_extracted, record_date
    FROM disk_space
	) t
;


ALTER TABLE disk_usage_time_series
ADD CONSTRAINT disk_usage_time_series_constraint UNIQUE ("Filesystem", "Type", "Size", "Date");

select count(*) from disk_usage_time_series;

CREATE OR REPLACE FUNCTION update_disk_usage_time_series()
RETURNS TRIGGER AS $$
DECLARE
    parsed_rows record;
BEGIN
    RAISE NOTICE 'Trigger fired for disk_space insert';
    FOR parsed_rows IN (SELECT * FROM parse_disk_space(NEW."RECORD_EXTRACTED", NEW."RECORD_DATE")) LOOP
        INSERT INTO disk_usage_time_series ("Filesystem", "Type", "Size", "Used", "Avail", "Use%", "Date")
        VALUES (parsed_rows."Filesystem", parsed_rows."Type", parsed_rows."Size", parsed_rows."Used", parsed_rows."Avail", parsed_rows."Use%", parsed_rows."Date")
        ON CONFLICT ("Filesystem", "Type", "Size", "Date") DO UPDATE
        SET "Used" = EXCLUDED."Used",
            "Avail" = EXCLUDED."Avail",
            "Use%" = EXCLUDED."Use%";
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_disk_usage_time_series_trigger
AFTER INSERT ON "DISK_SPACE"
FOR EACH ROW
EXECUTE FUNCTION update_disk_usage_time_series();

SELECT tgname, tgenabled
FROM pg_trigger;


-- drop function parse_disk_space;

CREATE OR REPLACE FUNCTION parse_disk_space_OLD(input_record_extracted text, input_record_date timestamp)
RETURNS TABLE (
    "Filesystem" text,
    "Type" text,
    "Size" numeric,
    "Used" numeric,
    "Avail" numeric,
    "Use%" numeric,
    "Date" timestamp
) AS $$
BEGIN
    RETURN QUERY -- data type result set
    SELECT 
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[1] AS "Filesystem",
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[2] AS "Type",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[3], '\D', '', 'g')AS numeric) AS "Size",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[4], '\D', '', 'g')AS numeric) AS "Used",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[5], '\D', '', 'g')AS numeric) AS "Avail",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[6], '\D', '', 'g')AS numeric) AS "Use%",
        DATE_TRUNC('day', input_record_date) AS "Date"
    UNION ALL
    SELECT 
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[1] AS "Filesystem",
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[2] AS "Type",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[3], '\D', '', 'g')AS numeric) AS "Size",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[4], '\D', '', 'g')AS numeric) AS "Used",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[5], '\D', '', 'g')AS numeric) AS "Avail",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[6], '\D', '', 'g')AS numeric) AS "Use%",
        DATE_TRUNC('day', input_record_date) AS "Date"
	UNION ALL
	SELECT 
		(regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[1] AS "Filesystem",
		(regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[2] AS "Type",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[3], '\D', '', 'g') AS numeric) AS "Size",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[4], '\D', '', 'g') AS numeric) AS "Used",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[5], '\D', '', 'g') AS numeric) AS "Avail",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[6], '\D', '', 'g') AS numeric) AS "Use%",
		DATE_TRUNC('day', input_record_date) AS "Date";
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION parse_disk_space(input_record_extracted text, input_record_date bigint)
RETURNS TABLE (
    "Filesystem" text,
    "Type" text,
    "Size" numeric,
    "Used" numeric,
    "Avail" numeric,
    "Use%" numeric,
    "Date" timestamp
) AS $$
BEGIN
    RETURN QUERY -- data type result set
    SELECT 
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[1] AS "Filesystem",
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[2] AS "Type",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[3], '\D', '', 'g')AS numeric) AS "Size",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[4], '\D', '', 'g')AS numeric) AS "Used",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[5], '\D', '', 'g')AS numeric) AS "Avail",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[1], E'\\s+'))[6], '\D', '', 'g')AS numeric) AS "Use%",
        TO_TIMESTAMP(input_record_date / 1000)::timestamptz at time zone 'UTC' AS "Date"
    UNION ALL
    SELECT 
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[1] AS "Filesystem",
        (regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[2] AS "Type",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[3], '\D', '', 'g')AS numeric) AS "Size",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[4], '\D', '', 'g')AS numeric) AS "Used",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[5], '\D', '', 'g')AS numeric) AS "Avail",
        CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[2], E'\\s+'))[6], '\D', '', 'g')AS numeric) AS "Use%",
        TO_TIMESTAMP(input_record_date / 1000)::timestamptz at time zone 'UTC' AS "Date"
	UNION ALL
	SELECT 
		(regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[1] AS "Filesystem",
		(regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[2] AS "Type",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[3], '\D', '', 'g') AS numeric) AS "Size",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[4], '\D', '', 'g') AS numeric) AS "Used",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[5], '\D', '', 'g') AS numeric) AS "Avail",
		CAST(regexp_replace((regexp_split_to_array((string_to_array(input_record_extracted, E'\n'))[3], E'\\s+'))[6], '\D', '', 'g') AS numeric) AS "Use%",
		TO_TIMESTAMP(input_record_date / 1000)::timestamptz at time zone 'UTC' AS "Date";
END;
$$ LANGUAGE plpgsql;

SELECT record_extracted, record_date
FROM disk_space
LIMIT 1;

SELECT parse_disk_space(record_extracted, record_date)
FROM disk_space
LIMIT 6;


SELECT * FROM disk_usage_time_series ORDER BY "Date" DESC;


select * from disk_usage_time_series where "Date" = TO_TIMESTAMP('2023-03-09 15:52:00', 'YYYY-MM-DD HH24:MI:SS') ;
select * from disk_space where record_date = TO_TIMESTAMP('2023-03-09 15:52:00', 'YYYY-MM-DD HH24:MI:SS') ;



INSERT INTO disk_usage_time_series ("Filesystem", "Type", "Size", "Used", "Avail", "Use%", "Date")        
SELECT * FROM parse_disk_space('/dev/xvda1     xfs           50G   47G  3.3G  94% /
/dev/xvdb      ext4          99G   85G  9.0G  91% /oradata
/dev/xvdc      ext4         296G  238G   45G  85% /orabkp', 1679382001000)


select * from "DISK_SPACE";

delete from "DISK_SPACE" WHERE "ID" = 1;

insert into "DISK_SPACE" ("ID", "RECORD_EXTRACTED", "RECORD_DATE") VALUES (1, '/dev/xvda1     xfs           50G   47G  3.5G  94% /
/dev/xvdb      ext4          99G   84G   10G  90% /oradata
/dev/xvdc      ext4         296G   73G  210G  26% /orabkp', 1679382001000)

