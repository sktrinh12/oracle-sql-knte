create or replace FUNCTION                "SCHEDULE_THROTTLE" (QUERYID IN NUMBER,SQLQUERY in VARCHAR2,ISID IN VARCHAR2, PRIMARYID IN VARCHAR2) RETURN NUMBER IS

	scheduleDate  		   DATE := SYSDATE + (1/24/60); -- immediately
	command				   VARCHAR2(4000) := 'DS3_USERDATA.THROTTLE('||QUERYID||','''||SQLQUERY||''','''||ISID||''','''||PRIMARYID||''');';



	
	v_job NUMBER;
	i NUMBER;

	cursor existingJobs is
		select job from user_jobs WHERE what = command; 

BEGIN
	

 	 DBMS_JOB.SUBMIT(v_job, command);
	 
  
	 RETURN v_job;
	 
END SCHEDULE_THROTTLE;
