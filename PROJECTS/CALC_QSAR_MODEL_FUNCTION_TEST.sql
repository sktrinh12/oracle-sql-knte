select distinct goodrange from FOUNT.calculated_ft_vk_qsar_models;


select goodrange from FOUNT.calculated_ft_vk_qsar_models;


set serveroutput on size 5000;

DROP FUNCTION map_goodrange;

CREATE OR REPLACE FUNCTION map_goodrange(good_range_string IN VARCHAR2, predicted_value IN NUMBER) 
   RETURN VARCHAR2 
   as 
   map_integer NUMBER;
   eval_value NUMBER;
   counter NUMBER := 1;
   BEGIN 
    CASE 
    WHEN good_range_string IS NULL THEN
        return NULL;
    WHEN regexp_like( good_range_string, ',') THEN
        FOR i IN (
        SELECT
            TRIM(regexp_substr(good_range_string, '[^,]+', 1, level)) split_value
        FROM
            dual
        CONNECT BY
            level <= regexp_count(good_range_string, ',') + 1
    ) LOOP
        dbms_output.put_line(i.split_value);        
        eval_value := eval_string(predicted_value, i.split_value);        
        IF eval_value = 1 THEN
            CASE 
                WHEN counter = 1 THEN
                    map_integer := 0;
                WHEN counter = 2 THEN
                    map_integer := 1;
                ELSE
                    map_integer := 2;
            END CASE;            
            EXIT;
        ELSE 
            map_integer := 3;
        END IF;
        counter := counter + 1;
    END LOOP;   
    ELSE 
       eval_value := eval_string(predicted_value, good_range_string);
       IF eval_value = 1 THEN
            map_integer := 0;
        ELSE
            map_integer := 3;
        END IF;
    END CASE;
      RETURN map_integer; 
    END map_goodrange;
/

CREATE OR REPLACE FUNCTION eval_string(predicted_value IN NUMBER, string2 IN VARCHAR2) 
   RETURN number 
   AS 
   return_integer NUMBER;
   select_stmt VARCHAR2(200);
   base_select_stmt VARCHAR2(200) := 'select count(*) from dual where ';
begin
  if regexp_like(string2, 'between') THEN
    select_stmt := base_select_stmt || regexp_replace(
            regexp_replace(string2, 'between ', TO_CHAR(predicted_value) || ' > '),
            'and', 
            'AND ' || TO_CHAR(predicted_value) || ' < ');
  else
    select_stmt := base_select_stmt || TO_CHAR(predicted_value) || ' ' || string2;
  end if;
  execute immediate select_stmt
    into return_integer;
--  if return_integer = 1 then
--    dbms_output.put_line('True');
--  else
--    dbms_output.put_line('False');
--  end if;
    return return_integer;
end;
/




select map_goodrange('<50,<100,<1000', 50) from dual;

select eval_string(55, '=100') from dual;


select map_goodrange(NULL, 500) from dual;

select map_goodrange('< 35', 25) from dual; 
select map_goodrange('>40', 500) from dual; 
select map_goodrange('<=5', 500) from dual; 
select map_goodrange('> 0', 500) from dual; 

select map_goodrange('>30', 500) from dual; 
select map_goodrange('>=4', 500) from dual; 

select map_goodrange('between  -20 and  20', 10) from dual; 
