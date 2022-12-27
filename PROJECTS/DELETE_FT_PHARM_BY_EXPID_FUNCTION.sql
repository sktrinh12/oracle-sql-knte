--DELETE FROM FT_PHARM_ANIMAL t WHERE t.experiment_id = '197466' ;
--
--DELETE FROM FT_PHARM_DOSE t WHERE t.experiment_id = '197466' ;
--
--DELETE FROM FT_PHARM_DOSING t WHERE t.experiment_id = '197466' ;
--
--DELETE FROM FT_PHARM_EFFICACY_RAW t WHERE t.experiment_id = '197466' ;
--
--DELETE FROM FT_PHARM_GROUP t WHERE t.experiment_id = '197466' ;
--
--DELETE FROM FT_PHARM_RAW t WHERE t.experiment_id = '197466' ;
--
--DELETE FROM FT_PHARM_STUDY t WHERE t.experiment_id = '197466' ;

SELECT * FROM FT_PHARM_ANIMAL t WHERE t.experiment_id = '211304' ;

SELECT * FROM FT_PHARM_DOSE t WHERE t.experiment_id = '211304' ;

SELECT * FROM FT_PHARM_DOSING t WHERE t.experiment_id = '211304' ;

SELECT * FROM FT_PHARM_EFFICACY_RAW t WHERE t.experiment_id = '211304' ;

SELECT * FROM FT_PHARM_GROUP t WHERE t.experiment_id = '211304' ;

SELECT * FROM FT_PHARM_RAW t WHERE t.experiment_id = '211304' ;

SELECT * FROM FT_PHARM_STUDY t WHERE t.experiment_id = '211304' ;

select * FROM FT_PHARM_STUDY t WHERE t.experiment_id = '197466' ;

--SELECT RTRIM(LTRIM(STUDY_ID, chr(34)), chr(34)) FROM FT_PHARM_STUDY t WHERE t.experiment_id = '197466' ;
--
--SELECT REGEXP_REPLACE(STUDY_ID, '"', '') FROM FT_PHARM_STUDY t WHERE t.experiment_id = '197466' ;


SELECT COUNT(*) FROM FT_PHARM_ANIMAL t WHERE t.experiment_id = '197466';

--SELECT * FROM FT_PHARM_EFFICACY_RAW FETCH NEXT 10 ROWS ONLY;

create or replace FUNCTION "REMOVE_PHARM_EXPID" (EXPID IN VARCHAR) RETURN VARCHAR IS
   
    pragma autonomous_transaction;

	return_string VARCHAR(1000) := '';
    result_string VARCHAR(50);
	return_integer NUMBER;
    select_stmt VARCHAR2(200);
    TYPE str_list_type IS
        TABLE OF VARCHAR2(50);
    FT_TABLES str_list_type;
BEGIN
     FT_TABLES := str_list_type('ANIMAL','DOSE','DOSING','EFFICACY_RAW','GROUP','RAW','STUDY');
     FOR indx IN FT_TABLES.first..FT_TABLES.last LOOP
	 	 select_stmt := 'DELETE FROM FT_PHARM_' || FT_TABLES(indx) || ' WHERE EXPERIMENT_ID = ' || EXPID;
         dbms_output.put_line('stmt: ' || select_stmt);
         execute immediate select_stmt;
         commit;
         select_stmt := 'SELECT COUNT(*) FROM FT_PHARM_' || FT_TABLES(indx) || ' WHERE EXPERIMENT_ID = ' || EXPID;
         execute immediate select_stmt into return_integer;
         dbms_output.put_line('return: ' || TO_CHAR(return_integer));
         IF return_integer != 0 THEN
            result_string := 'ERROR';
         ELSE
            result_string := 'OK';
         END IF;
         IF return_string != '' THEN
            return_string := return_string || ',';
         END IF;
         return_string := return_string || 'FT_PHARM_' || FT_TABLES(indx) || '=>' || result_string || '<br />' ;
	 END LOOP;

	 RETURN return_string;
	 
END;
/

grant execute on REMOVE_PHARM_EXPID to DS3_APPDATA;
set serveroutput on size 30000;
select REMOVE_PHARM_EXPID('211304') from dual;
select REMOVE_PHARM_EXPID('197466') from dual;
