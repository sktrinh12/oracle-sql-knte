CREATE OR REPLACE TYPE t_compound_id_type AS OBJECT
  (
  pid VARCHAR2(285),
  compound_id VARCHAR2(32),
  created_date DATE
);
/

CREATE OR REPLACE TYPE t_su_data_type AS OBJECT
  (
  EXPERIMENT_ID VARCHAR2(25),
  compound_id VARCHAR2(32),
  PROJECT_NAME VARCHAR2(25),
  CRO VARCHAR2(25),
  ASSAY_TYPE VARCHAR2(30),
  created_date DATE,
  IC50 NUMBER,
  IC50_NM NUMBER,
  VARIANT VARCHAR2(250),
  PARAM1 VARCHAR2(250), -- cell_line or target
  PARAM2 VARCHAR2(250), -- atp_conc_um or cell_incubation_hr
  PARAM3 VARCHAR2(250) -- cofactors or pct_serum
);
/

CREATE OR REPLACE TYPE t_msr_data_type_0 AS OBJECT
(
    compound_id VARCHAR2(100),
    created_date DATE,
    row_count number,
    DIFF_IC50 NUMBER,
    AVG_IC50 NUMBER
)
;
/

CREATE OR REPLACE TYPE t_msr_data_type AS OBJECT
(
    compound_id VARCHAR2(100),
    created_date DATE,
    row_count number,
    IC50_NM_1 number,
    IC50_NM_2 number,
    DIFF_IC50 NUMBER,
    AVG_IC50 NUMBER
)
;
/


CREATE OR REPLACE TYPE t_gmean_tbl_type AS OBJECT
  (
BATCH_ID VARCHAR2(100),
GRAPH BLOB,
IC50_NM NUMBER,
GEO_NM VARCHAR2(500),
AGG_STATS VARCHAR2(2000),
PROPERTIES VARCHAR2(800)
);
/


CREATE OR REPLACE PACKAGE DICT_PKG AUTHID CURRENT_USER IS
  TYPE t_dict_table IS TABLE OF VARCHAR2(25000) INDEX BY VARCHAR2(1200);
  FUNCTION CREATE_DICT RETURN t_dict_table;
END DICT_PKG;
/

drop type t_gmean_tbl_type_table;
drop type t_msr_data_type_table;
drop type t_su_data_type_table;
--drop type t_compound_id_type;
--drop type t_compound_id_type_table;
--drop function most_recent_ft_nbrs2;
--drop function calc_msr2;


SET DEFINE OFF;

CREATE OR REPLACE TYPE t_compound_id_type_table AS TABLE OF t_compound_id_type;
/

CREATE OR REPLACE TYPE t_gmean_tbl_type_table AS TABLE OF t_gmean_tbl_type;
/

CREATE OR REPLACE TYPE t_msr_data_type_table AS TABLE OF t_msr_data_type;
/

CREATE OR REPLACE TYPE t_msr_data_type_table_0 AS TABLE OF t_msr_data_type_0;
/

CREATE OR REPLACE TYPE t_su_data_type_table AS TABLE OF t_su_data_type;
/


CREATE OR REPLACE FUNCTION handle_null_param(i_param VARCHAR2, i_param_name VARCHAR2, i_type  NUMBER)
RETURN VARCHAR2
AS
v_param_clause VARCHAR2(300);
BEGIN
IF  i_type = 1 THEN -- if it is a integer type
  IF i_param = '-' THEN
        v_param_clause := i_param_name || ' IS NULL';
    ELSE 
        v_param_clause := i_param_name || ' = ' || i_param;
    END IF;
ELSE 
    IF i_param = '-' THEN
        v_param_clause := i_param_name || ' IS NULL';
    ELSE 
        v_param_clause := i_param_name || ' = ''' || i_param || '''';
    END IF;
END IF;
RETURN v_param_clause;
END;
/



CREATE OR REPLACE FUNCTION most_recent_ft_nbrs2(i_cro VARCHAR2, 
                                        i_assay_type varchar2, 
                                        i_param1 varchar2,                                         
                                        i_param2 varchar2, 
                                        i_param3 varchar2,
                                        i_variant varchar2,
                                        i_dsname varchar2) 
                                        RETURN t_su_data_type_table
AS
 v_data_tbl t_su_data_type_table;
  v_param1_clause VARCHAR2(230);
  v_param2_clause VARCHAR2(230);
  v_param3_clause VARCHAR2(230);
  v_variant VARCHAR2(200);
  v_sqlquery VARCHAR2(4000);
  v_sqltemplate VARCHAR2(4000);
  v_sqltemplate_cell VARCHAR2(4000) := q'!SELECT t_su_data_type(
    experiment_id, compound_id, project_name, cro, 
    assay_type, created_date, ic50, ic50_nm, variant, cell_line, cell_incubation_hr, pct_serum)
    FROM ( SELECT 
    to_char(T1.EXPERIMENT_ID) EXPERIMENT_ID,
    substr(T1.ID, 1, 8) COMPOUND_ID,
    T4.PROJECT PROJECT_NAME,
    T4.CRO CRO,
    T4.ASSAY_TYPE ASSAY_TYPE,
    t3.created_date created_date,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) IC50,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 IC50_NM,
    t5.variant,
    t5.cell_line,
    t5.cell_incubation_hr,
    nvl(t5.pct_serum, 10) PCT_SERUM
  FROM 
      DS3_USERDATA.TM_EXPERIMENTS T3 
      INNER JOIN DS3_USERDATA.TM_CONCLUSIONS T1 ON T3.EXPERIMENT_ID = T1.EXPERIMENT_ID
      INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
      INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
        AND t1.id = t5.batch_id
        AND t1.prop1 = t5.prop1
  WHERE 
      t3.completed_date IS NOT NULL
      AND t1.protocol_id = 201
      AND nvl( t3.deleted, 'N') = 'N'
      AND t1.validated = 'VALIDATED'
      UNION ALL
  SELECT        
      TO_CHAR(T4.EXPERIMENT_ID) experiment_id,
      SUBSTR(T3.DISPLAY_NAME, 1, 8)  COMPOUND_ID,
      T8.PROJECT PROJECT_NAME,
      T8.CRO,      
      T8.ASSAY_TYPE,     
      T4.CREATED_DATE,
      TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))              IC50,
      TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)) * 1000000000 IC50_NM,
      T9.VARIANT_1 variant,
      T9.cell_line,      
      t9.cell_incubation_hr,
      nvl(T9.pct_serum, 10) PCT_SERUM
      FROM
          DS3_USERDATA.SU_ANALYSIS_RESULTS T1
          INNER JOIN DS3_USERDATA.SU_GROUPINGS            T2 ON T1.GROUP_ID = T2.ID
          INNER JOIN DS3_USERDATA.SU_SAMPLES              T3 ON T2.SAMPLE_ID = T3.ID
          INNER JOIN DS3_USERDATA.TM_EXPERIMENTS          T4 ON T2.EXPERIMENT_ID = T4.EXPERIMENT_ID and t4.protocol_id = 441
          INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T8 ON T8.EXPERIMENT_ID = T2.EXPERIMENT_ID 
          RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT     T9 ON T9.EXPERIMENT_ID = T2.EXPERIMENT_ID
                                                                    AND T9.PLATE_SET = T2.PLATE_SET
      WHERE
          T4.COMPLETED_DATE IS NOT NULL
          AND T1.STATUS = 1
          AND nvl(T4.DELETED,'N')='N'
      )
      WHERE
      compound_id != 'BLANK'
      AND cro = '{cro}'
      AND assay_type = '{assay_type}'
      AND {variant}
      AND {param1} 
      AND {param2} 
      AND {param3}
 ORDER BY
      created_date DESC!';

 v_sqltemplate_bio VARCHAR2(4000) := q'!SELECT t_su_data_type(
    experiment_id, compound_id, project_name, cro, 
    assay_type, created_date, ic50, ic50_nm, variant, target, atp_conc_um, cofactors)
    FROM ( SELECT 
    to_char(T1.EXPERIMENT_ID) EXPERIMENT_ID,
    substr(T1.ID, 1, 8) COMPOUND_ID,
    T4.PROJECT PROJECT_NAME,
    T4.CRO CRO,
    T4.ASSAY_TYPE ASSAY_TYPE,
    t3.created_date created_date,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) IC50,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 IC50_NM,
    t5.variant,
    t5.target,
    t5.atp_conc_um,
    nvl2(t5.cofactor_1, t5.cofactor_1, NULL) || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL) COFACTORS
  FROM 
      DS3_USERDATA.TM_EXPERIMENTS T3 
      INNER JOIN DS3_USERDATA.TM_CONCLUSIONS T1 ON T3.EXPERIMENT_ID = T1.EXPERIMENT_ID
      INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
      INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
        AND t1.id = t5.batch_id
        AND t1.prop1 = t5.prop1
  WHERE 
      t3.completed_date IS NOT NULL
      AND t1.protocol_id = 181
      AND nvl( t3.deleted, 'N') = 'N'
      AND t1.validated = 'VALIDATED'
      UNION ALL
  SELECT        
      TO_CHAR(T4.EXPERIMENT_ID) experiment_id,
      SUBSTR(T3.DISPLAY_NAME, 1, 8)  COMPOUND_ID,
      T8.PROJECT PROJECT_NAME,
      T8.CRO,      
      T8.ASSAY_TYPE,     
      T4.CREATED_DATE,
      TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))              IC50,
      TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)) * 1000000000 IC50_NM,
      T9.VARIANT_1 variant,
      T9.target,    
      t9.atp_conc_um,
      nvl2(t9.cofactor_1, t9.cofactor_1, NULL) || nvl2(t9.cofactor_2, ', ' || t9.cofactor_2, NULL) COFACTORS
      FROM
          DS3_USERDATA.SU_ANALYSIS_RESULTS T1
          INNER JOIN DS3_USERDATA.SU_GROUPINGS            T2 ON T1.GROUP_ID = T2.ID
          INNER JOIN DS3_USERDATA.SU_SAMPLES              T3 ON T2.SAMPLE_ID = T3.ID
          INNER JOIN DS3_USERDATA.TM_EXPERIMENTS          T4 ON T2.EXPERIMENT_ID = T4.EXPERIMENT_ID and t4.protocol_id = 501
          INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T8 ON T8.EXPERIMENT_ID = T2.EXPERIMENT_ID 
          RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT     T9 ON T9.EXPERIMENT_ID = T2.EXPERIMENT_ID
                                                                    AND T9.PLATE_SET = T2.PLATE_SET
      WHERE
          T4.COMPLETED_DATE IS NOT NULL
          AND T1.STATUS = 1
          AND nvl(T4.DELETED,'N')='N'
      )
      WHERE
      compound_id != 'BLANK'
      AND cro = '{cro}'
      AND assay_type = '{assay_type}'
      AND {variant}
      AND {param1} 
      AND {param2} 
      AND {param3}
 ORDER BY
      created_date DESC!';
BEGIN
 IF regexp_count(i_dsname, 'CELL', 1, 'i') > 0 THEN
    v_param1_clause := 'cell_line = ''' || i_param1 || '''';  
    v_param2_clause := handle_null_param(i_param2, 'cell_incubation_hr', 1);
    v_param3_clause := handle_null_param(i_param3, 'pct_serum', 1);
    v_sqltemplate := v_sqltemplate_cell;
  ELSE
    v_param1_clause := 'target = ''' || i_param1 || '''';  
    v_param2_clause := handle_null_param(i_param2, 'atp_conc_um', 1);
    v_param3_clause := handle_null_param(i_param3, 'cofactors', 0);    
    v_sqltemplate := v_sqltemplate_bio;
  END IF;
  v_variant := handle_null_param(i_variant, 'variant', 0);
    --dbms_output.put_line('misc: ' || v_param1_clause || CHR(10) || v_param2_clause || CHR(10) || v_param3_clause);
    v_sqlquery := format(v_sqltemplate, 
        dict_pkg.t_dict_table (
            'cro' => i_cro,
            'assay_type' => i_assay_type,
            'param1' => v_param1_clause,
            'param2' => v_param2_clause,
            'param3' => v_param3_clause,
            'variant' => v_variant
            )
    );
    --dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into v_data_tbl;
RETURN v_data_tbl;
END;
/            

CREATE OR REPLACE FUNCTION most_recent_ft_nbrs(i_cro VARCHAR2, 
                                        i_assay_type varchar2, 
                                        i_param1 varchar2,                                         
                                        i_param2 varchar2, 
                                        i_param3 varchar2,
                                        i_variant varchar2,
                                        i_dsname varchar2) 
                                        RETURN t_compound_id_type_table
AS
 v_compids t_compound_id_type_table; 
 v_sqlquery VARCHAR2(1000);
 v_dsname VARCHAR2(50);
 v_sqltemplate VARCHAR2(1000) := 
 q'[SELECT
    t_compound_id_type(pid, compound_id, created_date)
    FROM (
        SELECT
            pid,
            compound_id,
            created_date
        FROM
            ds3_userdata.%s
        WHERE
                cro = '%s'
            AND assay_type = '%s'
            AND %s 
            AND %s
            AND %s
            AND %s
            AND compound_id != 'BLANK'
        ORDER BY
            created_date DESC
    )]';
    
BEGIN
    v_sqlquery := utl_lms.format_message(v_sqltemplate, i_dsname, i_cro, i_assay_type, i_param1, i_param2, i_param3, i_variant);
    --dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into v_compids;
RETURN v_compids;
END;
/            
            
CREATE OR REPLACE FUNCTION calc_msr2(i_cro VARCHAR2, 
                                    i_assay_type varchar2,                                       
                                    i_param1 varchar2, 
                                    i_param2 varchar2,
                                    i_param3 varchar2,
                                    i_variant varchar2,
                                    i_dsname varchar2,
                                    i_nbr_cmpds number)
return number
as
  n_MSR NUMBER;
  tbl_msr_data t_msr_data_type_table;
  v_param1_clause VARCHAR2(230);
  v_param2_clause VARCHAR2(230);
  v_param3_clause VARCHAR2(230);
  v_variant VARCHAR2(200);
  v_sqlquery VARCHAR2(2000);
  v_sqltemplate VARCHAR2(2000) := q'[
   with ranked_cmpids AS (
    select COMPOUND_ID, IC50_NM, CREATED_DATE, ROW_COUNT, CNT, IC50_LOG10
        from ( SELECT otbl.COMPOUND_ID, 
                        otbl.IC50_NM, 
                        otbl.CREATED_DATE, 
                        otbl.ROW_COUNT, 
                        otbl.cnt, 
                        LOG(10, otbl.IC50) IC50_LOG10 
                FROM (select t.* from 
                        (select COMPOUND_ID, 
                            created_date, 
                            ic50_nm, 
                            ic50,
                            row_number () over ( 
                                partition by t1.compound_id
                                order by t1.created_date desc) row_count,
                            count(*) over (PARTITION BY t1.compound_id) cnt
                    from table(most_recent_ft_nbrs2('{cro}', '{assay_type}', '{param1}', '{param2}', '{param3}', '{variant}', '{dsname}')) t1                
            ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl ) )
        select t_msr_data_type(COMPOUND_ID, CREATED_DATE, ROW_COUNT, IC50_NM_1, IC50_NM_2, DIFF_IC50,AVG_IC50) from (
    SELECT tbl1. COMPOUND_ID, 
            tbl2.CREATED_DATE, 
            tbl1.ROW_COUNT,
            tbl1.IC50_NM IC50_NM_1,
            tbl2.IC50_NM IC50_NM_2,
            (tbl1.IC50_LOG10+tbl2.IC50_LOG10)/2 AVG_IC50, 
            tbl1.IC50_LOG10-tbl2.IC50_LOG10 DIFF_IC50 
    from ranked_cmpids tbl1
    INNER JOIN ranked_cmpids tbl2
    ON tbl1.row_count = tbl2.row_count+1 and tbl1.compound_id = tbl2.compound_id
    ORDER BY tbl1.CREATED_DATE DESC, tbl2.CREATED_DATE DESC
    )
    FETCH NEXT {n_cmpds} ROWS ONLY]';
BEGIN
    v_sqlquery := format(v_sqltemplate,
        dict_pkg.t_dict_table (
            'cro' => i_cro,
            'assay_type' => i_assay_type,
            'dsname' => i_dsname,
            'param1' => i_param1,
            'param2' => i_param2,
            'param3' => i_param3,
            'variant' => i_variant,
            'n_cmpds' => i_nbr_cmpds
            )
    );
    --dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into tbl_msr_data;
    IF sql%rowcount != i_nbr_cmpds THEN
        n_MSR := NULL;
    ELSE
        select POWER(10, 2*STDDEV(DIFF_IC50)) into n_MSR 
          FROM ( table(tbl_msr_data));
    END IF;
RETURN n_MSR;
END;
/
            
CREATE OR REPLACE FUNCTION calc_msr(i_cro VARCHAR2, 
                                    i_assay_type varchar2,                                       
                                    i_param1 varchar2, 
                                    i_param2 varchar2,
                                    i_param3 varchar2,
                                    i_variant varchar2,
                                    i_dsname varchar2,
                                    i_nbr_cmpds number)
return number
as
  n_MSR NUMBER;
  tbl_msr_data t_msr_data_type_table_0;
  v_param1_name VARCHAR2(200);
  v_param2_name VARCHAR2(200);
  v_param3_name VARCHAR2(200);
  v_param1_clause VARCHAR2(230);
  v_param2_clause VARCHAR2(230);
  v_param3_clause VARCHAR2(230);
  v_variant VARCHAR2(200);
  v_sqlquery VARCHAR2(2000);
  v_sqltemplate VARCHAR2(2000) := q'[
    select t_msr_data_type_0(COMPOUND_ID, CREATED_DATE, ROW_COUNT, DIFF_IC50,AVG_IC50) from (
        select COMPOUND_ID, CREATED_DATE, ROW_COUNT, 
            SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) OVER (PARTITION BY COMPOUND_ID) DIFF_IC50,
            (SUM(IC50_LOG10) OVER (PARTITION BY COMPOUND_ID))/2 AVG_IC50
            FROM ( SELECT otbl.COMPOUND_ID, otbl.CREATED_DATE, otbl.ROW_COUNT, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
                        row_number () over ( partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs('{cro}', '{assay_type}', '{param1}', '{param2}', '{param3}', '{variant}', '{dsname}')) t1
                INNER JOIN (select PID, IC50_NM, IC50 from ds3_userdata.{dsname} WHERE VALIDATED != 'INVALIDATED') t2 
                ON t1.PID = t2.PID
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl )
        )
        WHERE ROW_COUNT = 1
        ORDER BY CREATED_DATE DESC
        FETCH NEXT {n_cmpds} ROWS ONLY
         ]';
BEGIN
  IF regexp_count(i_dsname, 'CELL', 1, 'i') > 0 THEN
    v_param1_name := 'cell_line';
    v_param2_name := 'cell_incubation_hr';
    v_param3_name := 'pct_serum';
    v_param3_clause := v_param3_name || ' = ' || i_param3;
  ELSE
    v_param1_name := 'target';
    v_param2_name := 'atp_conc_um';
    v_param3_name := 'cofactors';
    IF i_param3 = '-' THEN
        v_param3_clause := v_param3_name || ' IS NULL';
    ELSE 
        v_param3_clause := v_param3_name || ' = ''''' || i_param3 || '''''';
    END IF;
  END IF;
  v_param1_clause := v_param1_name || '= ''''' || i_param1 || '''''';
  IF i_param2 = '-' THEN
      v_param2_clause := v_param2_name || ' IS NULL';
  ELSE 
      v_param2_clause := v_param2_name || ' = ' || i_param2;
  END IF;
  IF i_variant = '-' THEN 
      v_variant := 'variant is null';
  ELSE 
      v_variant := 'variant =  ''''' || i_variant || '''''';
  END IF;
    --dbms_output.put_line('misc: ' || v_param1_clause || CHR(10) || v_param2_clause || CHR(10) || v_param3_clause);
    v_sqlquery := format(v_sqltemplate,
        dict_pkg.t_dict_table (
            'cro' => i_cro,
            'assay_type' => i_assay_type,
            'dsname' => i_dsname,
            'param1' => v_param1_clause,
            'param2' => v_param2_clause,
            'param3' => v_param3_clause,
            'variant' => v_variant,
            'n_cmpds' => i_nbr_cmpds
            )
    );
    dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into tbl_msr_data;
    IF sql%rowcount != i_nbr_cmpds THEN
        n_MSR := NULL;
    ELSE
        select POWER(10, 2*STDDEV(DIFF_IC50)) into n_MSR 
          FROM ( table(tbl_msr_data));
    END IF;
RETURN n_MSR;
END;
/


CREATE OR REPLACE FUNCTION get_msr_data2(i_cro VARCHAR2, 
                                     i_assay_type varchar2,                                       
                                     i_param1 varchar2, 
                                     i_param2 varchar2,
                                     i_param3 varchar2,
                                     i_variant varchar2,
                                     i_dsname varchar2,
                                     i_nbr_cmpds number)
return t_msr_data_type_table
as
  tbl_msr_data t_msr_data_type_table;
  v_param1_name VARCHAR2(200);
  v_param2_name VARCHAR2(200);
  v_param3_name VARCHAR2(200);
  v_param1_clause VARCHAR2(230);
  v_param2_clause VARCHAR2(230);
  v_param3_clause VARCHAR2(230);
  v_variant VARCHAR2(200);
  v_sqlquery VARCHAR2(2000);
  v_sqltemplate VARCHAR2(2000) := q'[
   with ranked_cmpids AS (
    select COMPOUND_ID, IC50_NM, CREATED_DATE, ROW_COUNT, CNT, IC50_LOG10
        from ( SELECT otbl.COMPOUND_ID, 
                        otbl.IC50_NM, 
                        otbl.CREATED_DATE, 
                        otbl.ROW_COUNT, 
                        otbl.cnt, 
                        LOG(10, otbl.IC50) IC50_LOG10 
                FROM (select t.* from 
                        (select COMPOUND_ID, 
                            created_date, 
                            ic50_nm, 
                            ic50,
                            row_number () over ( 
                                partition by t1.compound_id
                                order by t1.created_date desc) row_count,
                            count(*) over (PARTITION BY t1.compound_id) cnt
                    from table(most_recent_ft_nbrs2('{cro}', '{assay_type}', '{param1}', '{param2}', '{param3}', '{variant}', '{dsname}')) t1                
            ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl ) )
        select t_msr_data_type(COMPOUND_ID, CREATED_DATE, ROW_COUNT, IC50_NM_1, IC50_NM_2, DIFF_IC50,AVG_IC50) from (
    SELECT tbl1. COMPOUND_ID, 
            tbl2.CREATED_DATE, 
            tbl1.IC50_NM IC50_NM_1,
            tbl2.IC50_NM IC50_NM_2,
            tbl1.ROW_COUNT,
            (tbl1.IC50_LOG10+tbl2.IC50_LOG10)/2 AVG_IC50, 
            tbl1.IC50_LOG10-tbl2.IC50_LOG10 DIFF_IC50 
    from ranked_cmpids tbl1
    INNER JOIN ranked_cmpids tbl2
    ON tbl1.row_count = tbl2.row_count+1 and tbl1.compound_id = tbl2.compound_id
    ORDER BY tbl1.CREATED_DATE DESC, tbl2.CREATED_DATE DESC
    )
    FETCH NEXT {n_cmpds} ROWS ONLY]';
BEGIN
    v_sqlquery := format(v_sqltemplate,
        dict_pkg.t_dict_table (
            'cro' => i_cro,
            'assay_type' => i_assay_type,
            'dsname' => i_dsname,
            'param1' => i_param1,
            'param2' => i_param2,
            'param3' => i_param3,
            'variant' => i_variant,
            'n_cmpds' => i_nbr_cmpds
            )
    );
    dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into tbl_msr_data;
    RETURN tbl_msr_data;
END;
/


CREATE OR REPLACE FUNCTION get_msr_data(i_cro VARCHAR2, 
                                     i_assay_type varchar2,                                       
                                     i_param1 varchar2, 
                                     i_param2 varchar2,
                                     i_param3 varchar2,
                                     i_variant varchar2,
                                     i_dsname varchar2,
                                     i_nbr_cmpds number)
return t_msr_data_type_table_0
as
  tbl_msr_data t_msr_data_type_table_0;
  v_param1_name VARCHAR2(200);
  v_param2_name VARCHAR2(200);
  v_param3_name VARCHAR2(200);
  v_param1_clause VARCHAR2(230);
  v_param2_clause VARCHAR2(230);
  v_param3_clause VARCHAR2(230);
  v_variant VARCHAR2(200);
  v_sqlquery VARCHAR2(2000);
  v_sqltemplate VARCHAR2(2000) := q'[
    select t_msr_data_type_0(COMPOUND_ID, CREATED_DATE, ROW_COUNT, DIFF_IC50,AVG_IC50) from (
        select COMPOUND_ID, CREATED_DATE, ROW_COUNT, 
            SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) OVER (PARTITION BY COMPOUND_ID) DIFF_IC50,
            (SUM(IC50_LOG10) OVER (PARTITION BY COMPOUND_ID))/2 AVG_IC50
            FROM ( SELECT otbl.COMPOUND_ID, otbl.CREATED_DATE, otbl.ROW_COUNT, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
                        row_number () over ( partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs('{cro}', '{assay_type}', '{param1}', '{param2}', '{param3}', '{variant}', '{dsname}')) t1
                INNER JOIN (select PID, IC50_NM, IC50 from ds3_userdata.{dsname} WHERE VALIDATED != 'INVALIDATED') t2 
                ON t1.PID = t2.PID
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl )
        )
        WHERE ROW_COUNT = 1
        ORDER BY CREATED_DATE DESC
        FETCH NEXT {n_cmpds} ROWS ONLY
         ]';
BEGIN
  IF regexp_count(i_dsname, 'CELL', 1, 'i') > 0 THEN
    v_param1_name := 'cell_line';
    v_param2_name := 'cell_incubation_hr';
    v_param3_name := 'pct_serum';
    v_param3_clause := v_param3_name || ' = ' || i_param3;
  ELSE
    v_param1_name := 'target';
    v_param2_name := 'atp_conc_um';
    v_param3_name := 'cofactors';
    IF i_param3 = '-' THEN
        v_param3_clause := v_param3_name || ' IS NULL';
    ELSE 
        v_param3_clause := v_param3_name || ' = ''''' || i_param3 || '''''';
    END IF;
  END IF;
  v_param1_clause := v_param1_name || '= ''''' || i_param1 || '''''';
  IF i_param2 = '-' THEN
      v_param2_clause := v_param2_name || ' IS NULL';
  ELSE 
      v_param2_clause := v_param2_name || ' = ' || i_param2;
  END IF;
  IF i_variant = '-' THEN 
      v_variant := 'variant is null';
  ELSE 
      v_variant := 'variant =  ''''' || i_variant || '''''';
  END IF;
    --dbms_output.put_line('misc: ' || v_param1_clause || CHR(10) || v_param2_clause || CHR(10) || v_param3_clause);
    v_sqlquery := format(v_sqltemplate,
        dict_pkg.t_dict_table (
            'cro' => i_cro,
            'assay_type' => i_assay_type,
            'dsname' => i_dsname,
            'param1' => v_param1_clause,
            'param2' => v_param2_clause,
            'param3' => v_param3_clause,
            'variant' => v_variant,
            'n_cmpds' => i_nbr_cmpds
            )
    );
    dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into tbl_msr_data;
    RETURN tbl_msr_data;
END;
/


SET DEFINE OFF;

CREATE OR REPLACE FUNCTION GEN_GEOMEAN_CURVE_TBL(i_experiment_id NUMBER, i_nbr_cmpds number)
return t_gmean_tbl_type_table
as
  tbl_gmean t_gmean_tbl_type_table;
  v_msr_dict DICT_PKG.t_dict_table;
  v_key varchar2(400);
  v_param1_name varchar2(120);
  v_param2_name varchar2(120);
  v_param3_name varchar2(120);
  v_order_by_params varchar2(1000);
  v_where_by_params varchar2(1000);
  v_param_names varchar2(500);
  v_param_names_subq varchar2(500);
  v_dstype VARCHAR2(50);
  v_dsname VARCHAR2(50);
  v_stats_ds VARCHAR2(50);
  v_sqlquery VARCHAR2(32767);
  v_sqltemplate VARCHAR2(32767);
BEGIN
    select t2.protocol into v_dstype 
    from ds3_userdata.tm_experiments t1 
    inner join ds3_userdata.tm_protocols t2 
    on t2.protocol_id = t1.protocol_id
    where t1.experiment_id  = i_experiment_id;
    IF regexp_count(v_dstype, 'BIO', 1, 'i') > 0 THEN
      v_dsname := 'su_biochem_drc';
      v_stats_ds := 'su_biochem_drc_stats';
      v_param1_name := 'target';
      v_param2_name := 'atp_conc_um';
      v_param3_name := 'cofactors';
      v_order_by_params := 't1.target, t1.cofactors'; 
      v_where_by_params := q'[AND t1.target = t2.target
                            AND t1.variant = nvl(t2.variant, '-')
                            AND nvl(t1.cofactors, '-') = nvl(t2.cofactors, '-')
                            AND t1.atp_conc_um = t2.atp_conc_um]';
      v_param_names := q'[target, atp_conc_um, nvl(cofactors, '-') cofactors]';
      v_param_names_subq := q'[nvl(nvl2(cofactor_1, cofactor_1, NULL)
            || nvl2(cofactor_2, ', ' || cofactor_2, NULL), '-') cofactors,]' || v_param1_name || ',' || v_param2_name;
    ELSE
      v_dsname := 'su_cellular_growth_drc';
      v_stats_ds := 'su_cellular_drc_stats';
      v_param1_name := 'cell_line';
      v_param2_name := 'cell_incubation_hr';
      v_param3_name := 'pct_serum';
      v_order_by_params := 't1.cell_line';
      v_where_by_params := 'AND t1.cell_line = t2.cell
                             AND t1.variant = t2.variant
                             AND t1.cell_incubation_hr = t2.inc_hr
                             AND t1.pct_serum = t2.pct_serum';
      v_param_names := v_param1_name || ',' || v_param2_name || ',' || v_param3_name;
      v_param_names_subq := v_param_names;

    END IF;
    v_msr_dict := populate_msr_dict(
        i_experiment_id => i_experiment_id,
        i_param1_name => v_param1_name,
        i_param2_name => v_param2_name,
        i_param3_name => v_param3_name,
        i_where_by_params => v_where_by_params,
        i_param_names => v_param_names,
        i_param_names_subq => v_param_names_subq,
        i_dsname => v_dsname,
        i_stats_ds => v_stats_ds,
        i_nbr_cmpds => i_nbr_cmpds
    );
    
    
    v_sqltemplate := q'!SELECT t_gmean_tbl_type(
    t1.batch_id  ,
    t1.graph     ,
    t1.ic50_nm   ,
    CASE WHEN t1.MSR = 0 THEN
      NULL ELSE 
    round(t2.geo_nm / t1.MSR, 2) END
    || '<br />'
    || t2.geo_nm
    || '<br />'
    || 
    CASE WHEN t1.MSR = 0 THEN
      NULL ELSE
    round(t2.geo_nm * t1.MSR, 2) END,
    '-3 stdev: '
    || round(t2.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
    || round(t2.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    || t2.n_of_m
    || '<br />'
    || 'MSR: '
    || CASE WHEN t1.MSR = 0 THEN 'NaN' 
            WHEN t1.MSR IS NULL THEN 'NaN' 
            ELSE to_char(t1.MSR) END
    || '<br />'
    || '<a href="http://geomean.frontend.kinnate/get-data?type=msr_data&sql_type=get&{param1_name}='
    || t1.{param1_name} 
    || '&{param2_name}=' 
    || CASE WHEN t1.{param2_name} = '-' THEN 'null' 
            WHEN t1.{param2_name} IS NULL THEN 'null' ELSE t1.{param2_name} END
    || '&{param3_name}=' 
    || CASE WHEN t1.{param3_name} = '-' THEN 'null' 
            WHEN t1.{param3_name} IS NULL THEN 'null' ELSE t1.{param3_name} END
    || '&variant=' 
    || t1.variant
    || '&cro='
    || t1.cro
    || '&assay_type=' 
    || t1.assay_type 
    || '&n_limit=20"' 
    || ' target="_blank">MSR Viz</a>',
    'CRO: '
    || t1.cro
    || '<br />'
    || 'Assay Type: '
    || t1.assay_type
    || '<br />'
    || '{param1_name}: '
    || t1.{param1_name}
    || '<br />'
    || 'Variant: '
    || t1.variant
    || '<br />'
    || '{param2_name}: '
    || t1.{param2_name}
    || '<br />'
    || '{param3_name}: '
    || t1.{param3_name}
     ) FROM (
        SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            variant,
            {msr_case} ELSE NULL END msr,
            {param_names}
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    nvl(variant_1, '-') AS variant,
                    plate_set AS plate_set,
                    {param_names_subq}
                FROM
                    su_plate_prop_pivot
            ) t5 ON t2.experiment_id = t5.experiment_id
            AND t5.PLATE_SET = t2.PLATE_SET
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = {expid}
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = {expid}
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = {expid}
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.{stats_ds} t2 
    ON t1.compound_id = t2.compound_id
     AND t1.cro = t2.cro
     AND t1.assay_type = t2.assay_type
        {where_by_params}
    ORDER BY t1.COMPOUND_ID, {order_by_params}!'; 
    v_sqlquery := format(v_sqltemplate,
        dict_pkg.t_dict_table (
            'dsname' => v_dsname,
            'stats_ds' => v_stats_ds,
            'param1_name' => v_param1_name,
            'param2_name' => v_param2_name,
            'param3_name' => v_param3_name,
            'expid'  => i_experiment_id,
            'order_by_params' => v_order_by_params,
            'where_by_params' => v_where_by_params,
            'param_names' => v_param_names,
            'param_names_subq' => v_param_names_subq,
            'msr_case' => v_msr_dict('case'),
            'n_cmpds' => i_nbr_cmpds
            )
    );
   DBMS_OUTPUT.PUT_LINE('v_sqlquery: ' || v_sqlquery);
   execute immediate v_sqlquery bulk collect INTO tbl_gmean;
RETURN tbl_gmean;
END;
/


create or replace function populate_msr_dict(i_experiment_id NUMBER, 
                                             i_param1_name varchar2, 
                                             i_param2_name varchar2,
                                             i_param3_name varchar2,
                                             i_where_by_params varchar2,
                                             i_param_names varchar2,
                                             i_param_names_subq varchar2,
                                             i_dsname varchar2,
                                             i_stats_ds varchar2,
                                             i_nbr_cmpds number
) return DICT_PKG.t_dict_table
as
v_msr number;
msr_dict DICT_PKG.t_dict_table;
v_cro varchar2(200);
v_assay_type varchar2(200);
v_param1 varchar2(200);
v_param2 varchar2(200);
v_param3 varchar2(200);
v_variant varchar2(200);
v_key VARCHAR2(500);
v_case_template VARCHAR2(500) := q'[ WHEN t6.cro || '-'
                        || t7.assay_type || '-'
                        || {param1} || '-'
                        || {param2} || '-'
                        || {param3} || '-' 
                        || variant = '{msr_dict_key}' THEN
                        ROUND({msr_dict_val}, 3)
                        ]';
v_case_stmt VARCHAR2(32767) := 'CASE';
v_sqlquery varchar2(32767);
TYPE T_Ref_Cur IS REF CURSOR;
cv T_Ref_Cur;
v_sqltemplate varchar2(2500) := q'!with expid_rows as (
    SELECT
    t1.{param1_name},     
    t1.{param2_name},    
    t1.{param3_name},
    t1.variant,
    t1.assay_type,
    t1.cro
    FROM (
        SELECT
            substr(t3.display_name, 0, 8) compound_id, 
            t6.cro,
            t7.assay_type,
            variant,
            {param_names}
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN (
                SELECT
                    experiment_id,
                    nvl(variant_1, '-') variant,
                    plate_set,
                    {param_names_subq}
                FROM
                    su_plate_prop_pivot
            ) t5 ON t2.experiment_id = t5.experiment_id
            AND t5.PLATE_SET = t2.PLATE_SET
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = {expid}
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = {expid}
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = {expid}
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.{stats_ds} t2 
    ON t1.compound_id = t2.compound_id
     AND t1.cro = t2.cro
     AND t1.assay_type = t2.assay_type
        {where_by_params} )
    select cro, assay_type, {param1_name}, {param2_name}, {param3_name}, variant from expid_rows!';
 
BEGIN

 v_sqlquery := format(v_sqltemplate,
        dict_pkg.t_dict_table (
            'dsname' => i_dsname,
            'stats_ds' => i_stats_ds,
            'param1_name' => i_param1_name,
            'param2_name' => i_param2_name,
            'param3_name' => i_param3_name,
            'expid'  => i_experiment_id,
            'where_by_params' => i_where_by_params,
            'param_names' => i_param_names,
            'param_names_subq' => i_param_names_subq
            )
    );
    --DBMS_OUTPUT.put_line(v_sqlquery);
    
OPEN cv FOR v_sqlquery;
LOOP
    FETCH cv INTO v_cro, v_assay_type, v_param1, v_param2, v_param3, v_variant;
    EXIT WHEN cv%NOTFOUND;
    v_key := v_cro || '-' || v_assay_type ||'-'|| v_param1|| '-' || v_param2|| '-' || v_param3 || '-' || v_variant;
    DBMS_OUTPUT.PUT_LINE(v_key);
    IF msr_dict.exists(v_key) THEN
        CONTINUE;
    ELSE
        v_sqlquery := format(q'[select calc_msr2('{v_cro}', '{v_assay_type}', '{v_param1}', '{v_param2}', '{v_param3}', '{v_variant}', '{i_dsname}', {i_nbr_cmpds}) from dual]', 
        dict_pkg.t_dict_table (
        'v_cro' => v_cro,
        'v_assay_type' => v_assay_type,
        'v_param1' => v_param1,
        'v_param2' => v_param2,
        'v_param3' => v_param3,
        'v_variant' => v_variant,
        'i_dsname' => i_dsname,
        'i_nbr_cmpds' => i_nbr_cmpds
        )
        );
        --DBMS_OUTPUT.PUT_LINE('query: ' || v_sqlquery);
        execute immediate v_sqlquery
        into v_msr; 
        --DBMS_OUTPUT.PUT_LINE('calcd msr: ' || v_msr);
        msr_dict(v_key) := v_msr;
        IF v_msr IS NULL THEN
          v_msr := 0;
        END IF;
        v_case_stmt := v_case_stmt || format(v_case_template, 
            dict_pkg.t_dict_table (
              'param1' => i_param1_name,
              'param2' => i_param2_name,
              'param3' => i_param3_name,
              'msr_dict_key' => v_key,
              'msr_dict_val' => v_msr 
            )
        );
    END IF;
    --DBMS_OUTPUT.PUT_LINE('calcd msr: ' || msr_dict(v_key));
END LOOP;
msr_dict('case') := v_case_stmt;
DBMS_OUTPUT.PUT_LINE('case: ' || msr_dict('case'));
RETURN msr_dict;
END;
/
    
create or replace function format (template varchar2, args DICT_PKG.t_dict_table) return varchar2 is
        key varchar2 (1000);
        ret varchar2  (32767) := template;
        pattern varchar2 (32) := '(^|[^{]){(\w+)}([^}]|$)';
    begin
        <<substitute>> loop
            key := regexp_substr  (ret, pattern, 1, 1, null, 2);
            exit substitute when key is null;
            ret := regexp_replace (ret, pattern, 
                '\1'||case when args.exists (key) then args (key) else null end||
                '\3', 1, 1);
        end loop substitute;
        return replace (replace (ret, '{{','{'), '}}', '}');
    end;
/


grant execute on calc_msr to DS3_APPDATA;
grant execute on most_recent_ft_nbrs to DS3_APPDATA; -- remember to prefix it with the schema name when calling it from  ds3_appdata!
grant execute on GEN_GEOMEAN_CURVE_TBL to DS3_APPDATA;
