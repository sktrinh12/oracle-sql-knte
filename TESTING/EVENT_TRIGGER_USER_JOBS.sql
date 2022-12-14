select job from user_jobs;



select distinct table_name, order_by 
  from simple_snapshots
--  where TABLE_OR_VIEW ='TABLE'
--    and order_by >-1;    
;



INSERT INTO DS3_APPDATA.EVENT_TRIGGER(EVENT,ID) VALUES ('DSUPDATER','SU_CELLULAR_DRC_STATS');