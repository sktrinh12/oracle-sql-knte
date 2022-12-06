create or replace procedure Refresh_failed_dtsources
as 

cursor cur is
select distinct table_name, order_by 
  from simple_snapshots
  where TABLE_OR_VIEW ='TABLE'
    and order_by >-1
minus    
select distinct ss.table_name, ss.order_by 
  from simple_snapshots ss
Where exists (select 1 from simple_snapshots_log ssl where instr(ssl.table_name,ss.Table_name,1,1)>0 and run_date >sysdate-2/24)
and ss.TABLE_OR_VIEW ='TABLE'
and order_by >-1
order by order_by;

begin 

for rec in  cur loop

 INSERT INTO DS3_APPDATA.EVENT_TRIGGER(EVENT,ID) VALUES ('DSUPDATER',rec.table_name);
 commit;

 dbms_session.sleep(30);

end loop;

end;
