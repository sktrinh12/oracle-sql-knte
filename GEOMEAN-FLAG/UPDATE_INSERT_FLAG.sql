CREATE OR REPLACE PROCEDURE update_ic50_flag(
    p_pid VARCHAR2, 
    p_flag NUMBER,
    p_uname VARCHAR2, 
    p_comment VARCHAR2, 
    p_dsrc VARCHAR2, 
    p_result OUT NUMBER)
IS
  v_ds VARCHAR2(50) := 'cellular';
  v_sqltemplate_check VARCHAR2(200) := q'[select count(*) from ds3_userdata.{ds}_ic50_flags where pid = '{pid}']';
  v_sqltemplate_insert VARCHAR2(500) := q'[INSERT INTO ds3_userdata.{ds}_ic50_flags(pid, flag, change_date, user_name, comment_text) VALUES ('{pid}', {flag}, SYSTIMESTAMP, '{uname}', '{comment}')]';
  v_sqltemplate_update VARCHAR2(300) := q'[UPDATE {ds}_ic50_flags SET flag = {flag}, comment_text = '{comment}' WHERE pid = '{pid}']';
  v_sqlquery VARCHAR2(500);
BEGIN
    IF regexp_count(p_dsrc, 'bio', 1, 'i') > 0 THEN
    v_ds := 'biochem';
    END IF;
    v_sqlquery := format(v_sqltemplate_check, dict_pkg.t_dict_table (
            'pid' => p_pid,
            'ds' => v_ds
            )
    );
      DBMS_OUTPUT.PUT('query: ' || v_sqlquery|| CHR(10));

  execute immediate v_sqlquery INTO p_result;
  DBMS_OUTPUT.PUT('count: ' || to_char(p_result)|| CHR(10));
  IF p_result = 0 THEN
   v_sqlquery := format(v_sqltemplate_insert, 
        dict_pkg.t_dict_table ('ds' => v_ds,
                                'pid' => p_pid,
                                'flag' => p_flag,
                                'uname' => p_uname,
                                'comment' => p_comment));
   DBMS_OUTPUT.PUT(v_sqlquery|| CHR(10));
   execute immediate v_sqlquery;
   commit;
  ELSE
    v_sqlquery := format(v_sqltemplate_update, dict_pkg.t_dict_table ('ds' => v_ds, 
    'flag' => p_flag, 
    'pid' => p_pid, 
    'comment' => p_comment)
    );
    execute immediate v_sqlquery;
    commit;
  END IF;
  DBMS_OUTPUT.PUT('query: ' || v_sqlquery || CHR(10));
EXCEPTION
  WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    p_result := -1;
END;
/




DECLARE
  v_result NUMBER := 100;
BEGIN
  update_ic50_flag(p_pid => 'BIO-21206-1', 
  p_flag => 0, 
  p_uname => 'SPENCER', 
  p_comment => 'comment1234', 
  p_dsrc => 'bio', 
  p_result => v_result);
DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);

END;
/


select to_char(systimestamp, 'yyyy-dd-MM HH:mm:ss') from dual;


delete from biochem_ic50_flags;
delete from cellular_ic50_flags;

delete from biochem_ic50_flags;


select * from biochem_ic50_flags;

select * from cellular_ic50_flags;

select count(*) from biochem_ic50_flags where pid = 'BIO-21206-1';