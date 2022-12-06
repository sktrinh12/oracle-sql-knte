select * from DS3_userdata.TEST_BIOCHEM_IC50_FLAGS where experiment_id = 138645;


delete from DS3_userdata.TEST_BIOCHEM_IC50_FLAGS where experiment_ID = 138645;


select * from user_scheduler_jobs; select * from user_jobs;

SELECT job_name, job_class, operation, status FROM USER_SCHEDULER_JOB_LOG;

SELECT to_char(log_date, 'DD-MON-YY HH24:MM:SS') TIMESTAMP, job_name, status,
   SUBSTR(additional_info, 1, 40) ADDITIONAL_INFO
   FROM user_scheduler_job_run_details ORDER BY log_date;