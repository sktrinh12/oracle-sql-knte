delete from ds3_userdata.cellular_ic50_flags;
drop table ds3_userdata.cellular_ic50_flags;

CREATE TABLE "DS3_USERDATA"."CELLULAR_IC50_FLAGS" 
   (	"PID" VARCHAR2(127 BYTE), 
	"FLAG" NUMBER, 
	"CHANGE_DATE" TIMESTAMP,
    "USER_NAME" VARCHAR2(200 BYTE),
	"COMMENT_TEXT" VARCHAR2(600 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DOTMATICS" ;


INSERT INTO ds3_userdata.cellular_ic50_flags (PID, FLAG, CHANGE_DATE, USER_NAME, COMMENT_TEXT)
SELECT
            pid,
            0 AS flag,
            TO_TIMESTAMP( '01-JAN-2000 23:00:00', 'DD-MON-YYYY HH24:MI:SS') CHANGE_DATE,
            'TESTADMIN' USER_NAME,
            'ENTER COMMENT' COMMENT_TEXT
        FROM
            ds3_userdata.su_cellular_growth_drc
;
        
select TO_TIMESTAMP('01-JAN-2000 23:00:00', 'DD-MON-YYYY HH24:MI:SS') CHANGE_DATE from dual;


select * from cellular_ic50_flags;


BEGIN
  dbms_scheduler.drop_job(job_name => 'UPDATE_CELLULAR_IC50_FLAGS');
END;
/
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
       job_name             => 'UPDATE_CELLULAR_IC50_FLAGS',
       job_type             => 'PLSQL_BLOCK',
             job_action           =>  'begin
                                 INSERT INTO Ds3_userdata.CELLULAR_IC50_FLAGS 
                                (
                                 PID, FLAG
                                )
                                SELECT       
                                    t1.pid PID,   
                                    0 FLAG,
                                    TO_TIMESTAMP( ''01-JAN-2000 01:00:00'', ''DD-MON-YYYY HH24:MI:SS'') CREATED_DATE,
                                    ''TESTADMIN'' USER_NAME,
                                    ''ENTER COMMENT'' COMMENT_TEXT                                                                                                   
                                FROM
                                    ds3_userdata.SU_CELLULAR_GROWTH_DRC T1
                                    LEFT JOIN DS3_USERDATA.CELLULAR_IC50_FLAGS T2 ON T1.pid = T2.pid
                                    WHERE T2.pid IS NULL;
                                 END;',
       repeat_interval      => 'FREQ=DAILY;BYHOUR=1,4,6,8,10,12,14,16,18,20,22;BYMINUTE=0;BYSECOND=0',       
       enabled              =>  TRUE,
       comments             => 'Update cellular_ic50_flags Table for the flag and comment field');
    END;
/


select owner as schema_name,
       job_name,
       job_style,
       case when job_type is null 
                 then 'PROGRAM'
            else job_type end as job_type,  
       case when job_type is null
                 then program_name
                 else job_action end as job_action,
       start_date,
       case when repeat_interval is null
            then schedule_name
            else repeat_interval end as schedule,
       last_start_date,
       next_run_date,
       state
from sys.all_scheduler_jobs
order by owner,
         job_name;


                                   
                                    
SELECT DBMS_METADATA.get_ddl('PROCOBJ','CELLULAR_IC50_FLAG_JOB', 'DS3_USERDATA') AS job_def FROM dual;

SELECT DBMS_METADATA.get_ddl('PROCOBJ','UPDATE_CELLULAR_IC50_FLAGS', 'DS3_USERDATA') AS job_def FROM dual;


--EXEC DBMS_SCHEDULER.drop_job('UPDATE_CELLULAR_IC50_FLAGS');


UPDATE DS3_USERDATA.CELLULAR_IC50_FLAGS SET FLAG = 1,
                             USER_NAME = 'SPENCER',
                             CHANGE_DATE = TO_TIMESTAMP('17-NOV-2022 15:40:33','DD-MON-YYYY HH24:MI:SS'),
                             COMMENT_TEXT = 'TESTING COMMENT'
                         WHERE PID = 'CELL-2022-169-8'

;

select * from cellular_ic50_flags where PID = 'SU-11740-2'
;

UPDATE DS3_USERDATA.CELLULAR_IC50_FLAGS SET FLAG = 1,
                             USER_NAME = 'SPENCER',
                             CHANGE_DATE = '16-Nov-2022',
                             COMMENT_TEXT = 'TESTING COMMENT 123'
                         WHERE PID = 'CELL-2022-169-8';
                         
                         
                         
select * from su_cellular_growth_drc where experiment_id in (202504, 198464)
and compound_id = 'FT002787' and cell_line = 'WM3928';