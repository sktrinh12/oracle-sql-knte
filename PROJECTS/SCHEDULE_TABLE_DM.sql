create or replace FUNCTION                "SCHEDULE_TABLE" (V_TABLE_NAME IN VARCHAR2) RETURN NUMBER IS

	scheduleDate  		   DATE := SYSDATE + (1/24/60); -- minute from now
	command				   VARCHAR2(100) := 'SIMPLE_REFRESH_SINGLE(''' || V_TABLE_NAME || ''');';
	
	v_job NUMBER;
	i NUMBER;

	cursor existingJobs is
		select job from user_jobs WHERE what = command; 

BEGIN
	 -- drop existing jobs:	  
	 OPEN existingJobs;
	 LOOP
	 	 FETCH existingJobs INTO v_job;
		 EXIT WHEN existingJobs%NOTFOUND;
		 DBMS_JOB.REMOVE(v_job);
	 END LOOP;
	 CLOSE existingJobs;

 	 DBMS_JOB.SUBMIT(v_job, command, scheduleDate, null);
	 
	
	 

	 RETURN v_job;
	 
END SCHEDULE_TABLE;
