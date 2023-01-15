-- 20 most recent FT#'s that have CRO|ASSAY_TYPE|CELL_LINE that are same
SELECT DISTINCT
    compound_id,
    created_date
FROM
    (
        SELECT
            pid,
            compound_id,
            batch_id,
            created_date,
            cro,
            cro,
            assay_type,
            cell_line
        FROM
            su_cellular_growth_drc
        WHERE
                cro = 'Pharmaron'
            AND assay_type = 'HTRF'
            AND cell_line = 'DBTRG-05MG'
            AND compound_id != 'BLANK'
        ORDER BY
            created_date DESC
    )
ORDER BY
    created_date DESC
;



select     
    q.ASSAY_INTENT,
    q.ASSAY_TYPE,
    q.BATCH_ID,
    q.CELL_INCUBATION_HR,
    q.CELL_LINE,
    q.COMPOUND_ID,
    q.COMPOUND_INCUBATION_HR,
    q.CREATED_DATE,
    q.CRO,
    q.DAY_0_NORMALIZATION,
    q.DESCR,
    q.EXPERIMENT_ID,
    q.GRAPH,
    q.IC50_NM,
    q.PASSAGE_NUMBER,
    q.PCT_SERUM,
    q.PROJECT,
    q.SCIENTIST,
    q.TREATMENT,
    q.TREATMENT_CONC_UM,
    q.VARIANT
from (
SELECT
ASSAY_INTENT,
ASSAY_TYPE,
BATCH_ID,
CELL_INCUBATION_HR,
CELL_LINE,
COMPOUND_ID,
COMPOUND_INCUBATION_HR,
CREATED_DATE,
CRO,
nvl(DAY_0_NORMALIZATION, 'N') as DAY_0_NORMALIZATION,
DESCR,
EXPERIMENT_ID,
GRAPH,
IC50_NM,
nvl(MODIFIER, '-') AS MODIFIER,
PASSAGE_NUMBER,
PCT_SERUM,
PROJECT,
SCIENTIST,
TREATMENT,
TREATMENT_CONC_UM,
nvl(VARIANT, '-') as VARIANT,
regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 4) as variant_regexp,
nvl(regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 7), '-') as modifier_regexp,
row_number () over (
           partition by COMPOUND_ID
           order by created_date desc
         ) rn
FROM 
    DS3_USERDATA.SU_CELLULAR_GROWTH_DRC
WHERE
    compound_id = 'FT000953'
    AND CRO = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 1)  
    AND ASSAY_TYPE = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 2)  
    AND CELL_LINE = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 3)
    AND CELL_INCUBATION_HR = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 5)  
    AND PCT_SERUM = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 6) 
    ) q
    where
    VARIANT = variant_regexp
    AND MODIFIER = modifier_regexp 
    AND rn <= 2
ORDER BY CREATED_DATE DESC
;

select t1.*, t2.IC50_NM, LOG(10, t2.IC50) IC50_LOG10 FROM (
select t.* from 
(
select PID, COMPOUND_ID, created_date,
row_number () over (
         partition by compound_id
         order by created_date desc
       ) row_count,
count(*) over (PARTITION BY compound_id) cnt
from table(most_recent_ft_nbr('Pharmaron', 'HTRF', 'DBTRG-05MG', NULL, 1, 10))
--WHERE CREATED_DATE > sysdate - 1000
ORDER BY
    compound_id,
    created_date DESC
    ) t
WHERE t.row_count <=2
AND t.cnt >1
) t1
INNER JOIN ds3_userdata.su_cellular_growth_drc t2 
ON t1.PID = t2.PID
ORDER BY t1.row_count, t1.compound_id 
;



-- TEST DIFFERNCE CALCULATION
select POWER(10, 2*STDDEV(DIFF_IC50)) MSR FROM (
select COMPOUND_ID, SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) DIFF_IC50
FROM (
select t1.COMPOUND_ID, t1.ROW_COUNT, LOG(10, t2.IC50) IC50_LOG10 FROM (
select t.* from 
(
select PID, COMPOUND_ID, created_date,
row_number () over (
         partition by compound_id
         order by created_date desc
       ) row_count,
count(*) over (PARTITION BY compound_id) cnt
from table(most_recent_ft_nbrs2('Pharmaron', 'HTRF', 'DBTRG-05MG',  1, 10))
--WHERE CREATED_DATE > sysdate - 1000
ORDER BY
    compound_id,
    created_date DESC
    ) t
WHERE t.row_count <=2
AND t.cnt >1
FETCH NEXT 20*2 ROWS ONLY
) t1
INNER JOIN ds3_userdata.su_cellular_growth_drc t2 
ON t1.PID = t2.PID
ORDER BY t1.row_count, t1.compound_id 
)
GROUP BY COMPOUND_ID
ORDER BY COMPOUND_ID
)
;

--better testing version that exlucdes IC50 < 10000
select POWER(10, 2*STDDEV(DIFF_IC50)) MSR
    FROM (
        select COMPOUND_ID, SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) DIFF_IC50
        FROM (
        SELECT otbl.COMPOUND_ID, otbl.ROW_COUNT, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
                        row_number () over (
                         partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs2('Pharmaron', 'HTRF', 'DBTRG-05MG', 1, 10)) t1
                INNER JOIN ds3_userdata.su_cellular_growth_drc t2 
                ON t1.PID = t2.PID
                WHERE t2.ic50_nm < 10000
                ORDER BY
                    t1.compound_id,
                    t1.created_date DESC
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        FETCH NEXT 20*2 ROWS ONLY
        ) otbl 
       
        )
         GROUP BY COMPOUND_ID
         ORDER BY COMPOUND_ID
         )        
;


select calc_msr('Pharmaron', 'HTRF', 'DBTRG-05MG', NULL, 1, 10, 30) MSR from dual;
select calc_msr2('Pharmaron', 'HTRF', 'DBTRG-05MG', 1, 10, 20) MSR from dual;
select calc_msr2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', 72, 10, 20) MSR from dual;

-- RUN CALC_MSR for each unique combination of cro|assay|cell|var|cell_incu|pct_serum
-- significantly slower (~25-30s) depends on how many rows
SELECT
    t1.batch_id  AS batch_id,
    t1.graph     AS graph,
    t1.ic50_nm   AS ic50_nm,
    round(t2.geo_nm - t3.MSR, 2)
    || '<br />'
    || t2.geo_nm
    || '<br />'
    || round(t2.geo_nm + t3.MSR, 2) AS geo_nm,
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
    || round(t3.MSR, 2) 
    agg_stats,
    'CRO: '
    || t1.cro
    || '<br />'
    || 'Assay Type: '
    || t1.assay_type
    || '<br />'
    || 'Cell Line: '
    || t1.cell_line
    || '<br />'
    || 'Variant: '
    || t1.variant
    || '<br />'
    || 'Inc(hr): '
    || t1.cell_incubation_hr
    || '<br />'
    || '% serum: '
    || t1.pct_serum
     properties
FROM
    (
        SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            cell_line,
            variant,
            cell_incubation_hr,
            pct_serum
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS cell_incubation_hr,
                    pct_serum AS pct_serum,
                    plate_set AS plate_set
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
                        experiment_id = 210084
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = 210084
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = 210084
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.cell_incubation_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum   
--     LEFT OUTER JOIN (select NULL COMPOUND_ID, calc_msr('Pharmaron', 'HTRF', 'DBTRG-05MG', NULL, 1, 10, 30) MSR FROM DUAL) t3-
     LEFT OUTER JOIN (select NULL COMPOUND_ID, calc_msr('Pharmaron', 'HTRF', 'DBTRG-05MG', NULL, 1, 10, 30) MSR FROM DUAL) t3
   ON t1.compound_id = t1.compound_id
   ORDER BY t1.COMPOUND_ID, t1.CELL_LINE, t1.VARIANT
;
    
-- RIGHT OUTER JOIN to just one call of the CALC_MSR
-- quicker, ~10s
SELECT
    t1.batch_id  AS batch_id,
    t1.graph     AS graph,
    t1.ic50_nm   AS ic50_nm,
    round(t2.geo_nm - t1.MSR, 2)
    || '<br />'
    || t2.geo_nm
    || '<br />'
    || round(t2.geo_nm + t1.MSR, 2) AS geo_nm,
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
    || round(t1.MSR, 2) 
    agg_stats,
    'CRO: '
    || t1.cro
    || '<br />'
    || 'Assay Type: '
    || t1.assay_type
    || '<br />'
    || 'Cell Line: '
    || t1.cell_line
    || '<br />'
    || 'Variant: '
    || t1.variant
    || '<br />'
    || 'Inc(hr): '
    || t1.cell_incubation_hr
    || '<br />'
    || '% serum: '
    || t1.pct_serum
     properties
FROM
    (
        SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            cell_line,
            variant,
            cell_incubation_hr,
            pct_serum,
            CALC_MSR(t6.CRO, t7.ASSAY_TYPE, CELL_LINE, VARIANT, CELL_INCUBATION_HR, PCT_SERUM, 20) MSR
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS cell_incubation_hr,
                    pct_serum AS pct_serum,
                    plate_set AS plate_set
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
                        experiment_id = 210084
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = 210084
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = 210084
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.cell_incubation_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum      
   ORDER BY t1.COMPOUND_ID, t1.CELL_LINE, t1.VARIANT
;

select * from GEN_GEOMEAN_CURVE_TBL('210084', 20);

select * from most_recent_ft_nbrs2('Pharmaron', 'HTRF', 'DBTRG-05MG', 1, 10);

select calc_msr2('Pharmaron', 'HTRF', 'DBTRG-05MG', 1, 10, 20) MSR from dual;

select * from GEN_GEOMEAN_CURVE_TBL(209788, 20); --36.3
select * from GEN_GEOMEAN_CURVE_TBL(211260, 20); --2.71
select * from GEN_GEOMEAN_CURVE_TBL(211259, 20); --2.52
select * from GEN_GEOMEAN_CURVE_TBL(211258, 20); --2.45
select * from GEN_GEOMEAN_CURVE_TBL(211257, 20); --26.4
select * from GEN_GEOMEAN_CURVE_TBL(211256, 20); --36.3

select PID, COMPOUND_ID, CRO, ASSAY_TYPE, CELL_LINE, VARIANT, CELL_INCUBATION_HR, PCT_SERUM from su_cellular_growth_drc where experiment_id = 209788;


select PID, COMPOUND_ID, CRO, ASSAY_TYPE, CELL_LINE, VARIANT, CELL_INCUBATION_HR, PCT_SERUM from su_cellular_growth_drc where experiment_id = 210084;



SELECT n FROM
(SELECT LEVEL n FROM dual CONNECT BY LEVEL <=150)
WHERE n >= 10
;

SELECT rownum*10 n
FROM all_objects
WHERE rownum <= 20
;


select regexp_substr (
    '{name} said: Hi my name is {name}, I am aged {age}, yes {age}!', 
    '(^|[^{]){(\w+)}([^}]|$)',
    1, 
    1,
    null,
    2) regexp_result
from dual
;


select regexp_replace (
    '{name} said: Hi my name is {name}, I am aged {age}, yes {age}!',
    '(^|[^{]){(\w+)}([^}]|$)', 
    '\1'||'name'||
    '\3', 1, 1)
                
from dual
;

declare 
    type vararg is table of varchar2 (96) index by varchar2 (32);
    
    function format (template varchar2, args vararg) return varchar2 is
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
            dbms_output.put_line ('ret: '||ret);   
        end loop;
        return replace (replace (ret, '{{','{'), '}}', '}');
    end;
begin
    dbms_output.put_line ('output: '||format (q'[
{name} said: Hi my name is {name}, I am aged {age}, yes {age}! 
Missing key {somekey}; Replaced placeholders {{name}}, {{age}}. Again I am {age}]',
        vararg ('name' => 'Jane', 
                'age'  => '26')));
end;
/


declare
    v_template nvarchar2(500)  := q'[SELECT t_compound_id_type(pid, compound_id, created_date) bulk collect into v_compids FROM ( SELECT pid, compound_id, created_date FROM ds3_userdata.%s WHERE cro = v_cro AND assay_type = v_assay_type AND %s AND %s AND %s AND compound_id != 'BLANK' ORDER BY created_date DESC)]';
    v_name     nvarchar2(50)   := 'Jane';
    v_age      nvarchar2(50)   := '26';
    v_dsname   nvarchar2(50) := 'su_biochem';
    v_output   nvarchar2(1000) := utl_lms.format_message(v_template, v_name, v_age, v_dsname);
begin
    dbms_output.put_line('output: ' || v_output);
end;
/

