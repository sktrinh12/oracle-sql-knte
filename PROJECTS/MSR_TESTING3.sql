 
    DECLARE
  TYPE sum_multiples IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  n  PLS_INTEGER := 5;   -- number of multiples to sum for display
  sn PLS_INTEGER := 10;  -- number of multiples to sum
  m  PLS_INTEGER := 3;   -- multiple

  FUNCTION get_sum_multiples (
    multiple IN PLS_INTEGER,
    num      IN PLS_INTEGER
  ) RETURN sum_multiples
  IS
    s sum_multiples;
  BEGIN
    FOR i IN 1..num LOOP
      s(i) := multiple * ((i * (i + 1)) / 2);  -- sum of multiples
    END LOOP;
    RETURN s;
  END get_sum_multiples;

BEGIN
  DBMS_OUTPUT.PUT_LINE (
    'Sum of the first ' || TO_CHAR(n) || ' multiples of ' ||
    TO_CHAR(m) || ' is ' || TO_CHAR(get_sum_multiples (m, sn)(n))
  );
END;
/


CREATE OR REPLACE PACKAGE DICT_PKG AUTHID CURRENT_USER IS
  TYPE t_dict_table IS TABLE OF VARCHAR2(200) INDEX BY VARCHAR2(100);
  FUNCTION CREATE_DICT RETURN t_dict_table;
END DICT_PKG;
/

--DROP PACKAGE DICT_PKG;

--CREATE OR REPLACE PACKAGE BODY DICT_PKG IS
--  FUNCTION CREATE_DICT RETURN t_dict_table IS
--    Ret t_dict_table;
--  BEGIN
--    Ret('key_1') := 'zero';
--    Ret('key_2') := 'one';
--    Ret('key_3') := 'two';
--    Ret('key_4') := 'three';
--    Ret('key_5') := 'four';
--    Ret('key_6') := 'nine';
--    RETURN Ret;
--  END CREATE_DICT;
--END DICT_PKG;
--/



DECLARE
--  v CONSTANT DICT_PKG.t_dict_table := DICT_PKG.create_dict();
    v DICT_PKG.t_dict_table;
BEGIN
  DECLARE
    v_key VARCHAR(20);
  BEGIN
    FOR Idx in 1..6 loop
        v_key := 'key_'||to_char(Idx);
        v(v_key) := 10;
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(Idx, '999')||LPAD(v(v_key), 7));

    END LOOP;
  END;
END;
/



create or replace function format (template varchar2, args DICT_PKG.t_dict_table) return varchar2 is
        key varchar2 (32);
        ret varchar2  (32767) := template;
        pattern varchar2 (32) := '(^|[^{]){(\w+)}([^}]|$)';
    begin
        <<substitute>> loop
            key := regexp_substr  (ret, pattern, 1, 1, null, 2);
            exit substitute when key is null;
            ret := regexp_replace (ret, pattern, 
                '\1'||case when args.exists (key) then args (key) else '?'||key||'?' end||
                '\3', 1, 1);
        end loop substitute;
        return replace (replace (ret, '{{','{'), '}}', '}');
    end;
/


declare
    v_msr number;
--    v_param1_name varchar2(50) := 'cell_line';
--    v_param1 varchar(50) := 'DBTRG-05MG';
--    v_param2_name varchar2(50) := 'cell_incubation_hr';
--    v_param2 varchar(50) := '1';
--    v_param3_name varchar(50) := 'pct_serum';
--    v_param3 varchar(50) := '10';
--    v_dsname varchar(32) := 'su_cellular_growth_drc';
    v_param1_name varchar2(50) := 'target';
    v_param1 varchar(50) := 'MET';
    v_param2_name varchar2(50) := 'atp_conc_um';
    v_param2 varchar(50) := '100';
    v_param3_name varchar(50) := 'cofactors';
    v_param3 varchar(50) := NULL;
    v_dsname varchar(32) := 'su_test_biochem_drc';
    i_nbr_cmpds number := 20;
begin
    v_msr := calc_msr2(i_cro => 'Pharmaron',  
--     i_assay_type => 'HTRF', 
--                       i_param1 => '' || v_param1_name || '=' || '''''' || v_param1 || '''''', 
--                       i_param2 => '' || v_param2_name || '=' || v_param2 || '', 
--                       i_param3 => '' || v_param3_name || '='|| v_param3 || '',
                       i_assay_type => 'Caliper', 
                       i_param1 => '' || v_param1_name || '=' || '''''' || v_param1 || '''''', 
                       i_param2 => '' || v_param2_name || '=' || v_param2 || '', 
                       i_param3 => '' || v_param3_name || ' IS NULL' || '', 
                       i_dsname => v_dsname, 
                       i_nbr_cmpds => i_nbr_cmpds);
    dbms_output.put_line ('output: '|| v_msr  );
end;
/

declare
  v_param1 varchar2(300) := 'param1';
  v_param2 varchar2(300) := 'param2';
  v_param3 varchar2(300) := 'param3';
  v_param1_name varchar2(150)  := 'param1_name';
  v_param2_name varchar2(150)  := 'param2_name';
  v_param3_name varchar2(150)  := 'param3_name';
  v_dsname VARCHAR2(32)   := 'dsname';
  v_stats_ds VARCHAR2(32)  := 'stats_ds';
  v_msr number := 3.234;
  i_experiment_id number := 203421;
  v_sqlquery VARCHAR2(32767);
begin
    v_sqlquery := format (
    q'!SELECT t_gmean_tbl_type(
    t1.batch_id  ,
    t1.graph     ,
    t1.ic50_nm   ,
    round(t2.geo_nm - t3.MSR, 2)
    || '<br />'
    || t2.geo_nm
    || '<br />'
    || round(t2.geo_nm + t3.MSR, 2),
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
    || round(t3.MSR, 2),
    'CRO: '
    || t1.cro
    || '<br />'
    || 'Assay Type: '
    || t1.assay_type
    || '<br />'
    || '{param1_name}: '
    || t1.{param1}
    || '<br />'
    || 'Variant: '
    || t1.variant
    || '<br />'
    || '{param2_name}: '
    || t1.{param2}
    || '<br />'
    || '{param3_name}: '
    || t1.{param3}
     ) FROM (
        SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            {param1},
            variant,
            {param2},
            {param3}
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
                    {param1} AS {param1_name},                    
                    {param2} AS {param2_name},
                    {param3} AS {param3_name}
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
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
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
     AND t1.variant = t2.variant
     AND t1.{param1} = t2.{param1}                                                            
     AND t1.{param2} = t2.{param2}
     AND t1.{param3} = t2.{param3}
    LEFT OUTER JOIN (select NULL compound_id, {msr} MSR from dual) t3
    ON t1.compound_id = t1.compound_id
    ORDER BY t1.COMPOUND_ID, t1.{param1}, t1.{param2}!'
    ,
                                               
                                                dict_pkg.t_dict_table (
            'stats_ds' => v_stats_ds,
            'msr' => v_msr,
            'param1' => '''' || v_param1_name || '=' || v_param1 || '''',
            'param2' => v_param2,
            'param3' => v_param3,
            'expid'  => i_experiment_id)
    );
                                            dbms_output.put_line ('output: '|| v_sqlquery  );
end;
/
