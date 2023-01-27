
SELECT
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
            assay_type,
            target
        FROM
            su_biochem_drc
        WHERE
                cro = 'Pharmaron'
            AND assay_type = 'Caliper'
            AND target = 'MET'
            AND atp_conc_um = 100
            AND cofactors is null
            and variant = 'wt'
            AND compound_id != 'BLANK'
        ORDER BY
            created_date DESC
    )
ORDER BY
    created_date DESC
;



SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t7.cro,
            t5.experiment_id,
            t7.assay_type,
            t5.variant,
                t5.target, 
                t5.atp_conc_um, 
                t5.cofactors,
                t1.created_date,
                 T1.STATUS validation
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN (
                SELECT
                    experiment_id,
                    nvl(variant_1, '-') variant,
                    plate_set,
                    nvl2(cofactor_1, cofactor_1, NULL) || nvl2(cofactor_2, ', ' || cofactor_2, NULL) cofactors,
                    atp_conc_um,
                    target
                FROM
                    su_plate_prop_pivot
            ) t5 ON t2.experiment_id = t5.experiment_id
            AND t5.PLATE_SET = t2.PLATE_SET
            INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT t7 ON t7.EXPERIMENT_ID = t2.EXPERIMENT_ID

        WHERE

             t3.display_name != 'BLANK'
             AND T1.STATUS = 1
            AND t7.cro = 'Pharmaron'
            AND t7.assay_type = 'Caliper'
            AND t5.target = 'MET'
            AND t5.atp_conc_um = 100
            AND t5.cofactors is null
            and t5.variant = 'wt'
    ORDER BY
            t1.created_date DESC
;


--BIOCHEMICAL

select * from (
SELECT
  to_char(T1.EXPERIMENT_ID)                                                           AS EXPERIMENT_ID ,
  substr(T1.ID, 1, 8)                                                                      AS COMPOUND_ID ,
 T4.PROJECT PROJECT,
T4.CRO AS CRO,
t4.assay_type as assay_type,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) IC50 ,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) * 1000000000 IC50_NM,
  T1.VALIDATED VALIDATION,
t5.target TARGET,
t5.variant VARIANT,
nvl2(t5.cofactor_1, t5.cofactor_1, NULL) || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL) cofactors,
    nvl(T4.ATP_CONC_UM, t5.atp_conc_um) AS ATP_CONC_UM,
t3.created_date as created_date
FROM
  DS3_USERDATA.TM_CONCLUSIONS T1
--  INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
  INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
  INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
  INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
  t3.completed_date IS NOT NULL
  AND t1.protocol_id = 181
AND nvl(t3.deleted, 'N') = 'N'
AND t1.validated = 'VALIDATED' 

UNION ALL

SELECT
    to_char(t4.experiment_id) EXPERIMENT_ID,
    substr(t3.display_name, 1, 8) COMPOUND_ID,
    t7.project PROJECT,
    t7.cro CRO,
    T7.ASSAY_TYPE ASSAY_TYPE,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) IC50,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 IC50_NM,
    case when t1.STATUS = 1 then 'VALIDATED' ELSE 'UNVALIDATED' END VALIDATION,
    t6.target TARGET,
    t6.variant_1 VARIANT,
    nvl2(cofactor_1, cofactor_1, NULL) || nvl2(cofactor_2, ', ' || cofactor_2, NULL) COFACTORS,
    t6.atp_conc_um ATP_CONC_UM,
    t4.created_date CREATED_DATE
FROM
         ds3_userdata.SU_ANALYSIS_RESULTS t1
    INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
    INNER JOIN DS3_USERDATA.SU_SAMPLES T3 ON T2.SAMPLE_ID = T3.ID
    INNER JOIN ds3_userdata.tm_experiments t4 ON t2.experiment_id = t4.experiment_id AND t4.protocol_id = 501
    RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT T6 ON T6.EXPERIMENT_ID = T2.EXPERIMENT_ID
    AND T6.PLATE_SET = T2.PLATE_SET
    INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T7 ON T7.EXPERIMENT_ID = T2.EXPERIMENT_ID
WHERE
    t4.completed_date IS NOT NULL
    AND t1.STATUS = 1
    AND nvl(T4.DELETED,'N')='N'
    )
    where 
      compound_id != 'BLANK'
             AND VALIDATION = 'VALIDATED'
            AND cro = 'Pharmaron'
            AND assay_type = 'Caliper'
            AND target = 'MET'
            AND atp_conc_um = 100
            AND cofactors is null
            and variant = 'wt'
 ORDER BY
        created_date DESC
;



--CELLULAR
SELECT * FROM (

-- select COMPOUND_ID, created_date, ic50_nm, ic50,
--                        row_number () over (
--                         partition by compound_id
--                         order by created_date desc
--                       ) row_count,
--                count(*) over (PARTITION BY compound_id) cnt
--                FROM (
SELECT 
    to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID
	,substr(T1.ID, 1, 8) AS COMPOUND_ID
	,T4.PROJECT AS PROJECT
	,T4.CRO AS CRO
	,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
       ,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM
	,T1.VALIDATED  VALIDATION
	,t5.cell_line cell_line
        ,t5.cell_variant as variant
        ,NVL(T5.PCT_SERUM, 10) PCT_SERUM
	,T5.CELL_INCUBATION_HR CELL_INCUBATION_HR
    ,T4.ASSAY_TYPE ASSAY_TYPE
	,t3.created_date created_date
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
    
    UNION ALL


        SELECT        
            to_char(T4.EXPERIMENT_ID) experiment_id,           
            SUBSTR(T3.DISPLAY_NAME, 1, 8)  COMPOUND_ID,
            T8.PROJECT ,                    
            T8.CRO ,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))              AS IC50,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM,            
               CASE T1.STATUS
                    WHEN 1 THEN  'VALIDATED'                    
                    ELSE         'INVALIDATED'
                END VALIDATION,
            T9.CELL_LINE ,
            T9.VARIANT_1 variant,
            NVL(T9.PCT_SERUM, 10) PCT_SERUM,          
            T9.CELL_INCUBATION_HR,
            T8.ASSAY_TYPE,       
            T4.CREATED_DATE 
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
            compound_id = 'FT008741'
--            compound_id != 'BLANK'
             AND VALIDATION = 'VALIDATED'
            AND cro = 'Pharmaron'
            AND assay_type = 'CellTiter-Glo'
            AND cell_line = 'Ba/F3'
            AND cell_incubation_hr = 72
            AND pct_serum = 10
            and variant = 'TPR-MET-wt'
            
 ORDER BY
        created_date DESC
        
--FETCH NEXT 20 rows only
            ;
            
            
select * from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc'));

select * from table(most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'MET', '100', '-', 'wt', 'su_biochem_drc'));




SELECT
    calc_msr2('Pharmaron', 'Caliper', 'MET', '100', '-', 'wt', 'su_biochem_drc', 20) msr
FROM
    dual; -- 2.38
    

SELECT
    calc_msr2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --2.25


with tblA as (
select * from table(most_recent_ft_nbrs('Pharmaron', 'CellTiter-Glo', 'cell_line =''Ba/F3''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'variant = ''TPR-MET-wt''', 'su_cellular_growth_drc')) t0
inner join (select PID, COMPOUND_ID, IC50, IC50_NM FROM su_cellular_growth_drc where validated = 'VALIDATED') t1
ON t1.pid = t0.pid 
order by t0.created_date DESC, COMPOUND_ID
)
select * from tblA
;


select * from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc'))
--order by CREATED_DATE DESC, COMPOUND_ID
;


