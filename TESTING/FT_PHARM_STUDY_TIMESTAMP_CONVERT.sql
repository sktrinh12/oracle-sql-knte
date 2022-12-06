alter table FT_PHARM_STUDY MODIFY (IN_LIFE_DATE TIMESTAMP);



select IN_LIFE_DATE , extract(TIME from 
                            TO_TIMESTAMP (
                                TO_CHAR (IN_LIFE_DATE,
                                     'DD-MON-YY HH:mi:SS AM') ) ) AS TIME from FT_PHARM_STUDY;

select TO_CHAR(IN_LIFE_DATE - TO_TIMESTAMP(TO_CHAR(CAST(IN_LIFE_DATE AS DATE), 'DD-MON-YY' ) ||' 10:00:00 AM', 'HH:MI:SS AM'),'hh:mi:ss AM') from FT_PHARM_STUDY;
                                     
                                     
                                     


select TO_TIMESTAMP('02:00:00 AM', 'HH:MI:SS AM') from DUAL;

--CREATE TABLE COPY_FT_PHARM_STUDY AS (
--    SELECT * FROM FT_PHARM_STUDY );
--
--DROP TABLE COPY_FT_PHARM_STUDY;    
    
select TO_CHAR(TO_DATE(TO_CHAR(CAST(IN_LIFE_DATE AS DATE), 'DD-MON-YY') ||' 10:00', 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS') FROM FT_PHARM_STUDY;

UPDATE FT_PHARM_STUDY SET IN_LIFE_DATE = TO_CHAR(TO_DATE(TO_CHAR(CAST(IN_LIFE_DATE AS DATE), 'DD-MON-YY') ||' 10:00', 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS');


SELECT IN_LIFE_DATE FROM COPY_FT_PHARM_STUDY;