SELECT
    to_char(t1.experiment_id)                                                                            AS experiment_id,
    substr(t1.id, 1, 8)                                                                                  AS compound_id,
    t1.id                                                                                                AS batch_id,
    t5.target                                                                                            AS target,
    t5.variant                                                                                           AS variant
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1;

--INNER JOIN ds3_userdata.biochem_reuslt_flag t6 ON t1.experiment_id = t6.experiment_id
--                                                            AND t1.id = t6.batch_id
--                                                            AND t5.target = t6.target
--                                                            AND t5.variant = t6.variant

SELECT
    to_char(t1.experiment_id)                                                                            AS experiment_id,
    substr(t1.id, 1, 8)                                                                                  AS compound_id,
    t1.id                                                                                                AS batch_id,
    t5.target                                                                                            AS target,
    t5.variant                                                                                           AS variant,
--    substr(nvl2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
--           || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), 3)                                       AS cofactors,
    --t6.flag                                                                                                    AS flag
    T4.PROJECT                                  AS PROJECT,
T4.CRO AS CRO,
T3.DESCR AS DESCR,
t4.assay_type as assay_type,
T4.ASSAY_INTENT AS ASSAY_INTENT,
--  T1.ANALYSIS_ID                                                             AS ANALYSIS_ID ,
  T1.ANALYSIS_NAME                                                           AS ANALYSIS_NAME ,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) AS IC50 ,
-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC))) AS pIC50,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM ,
  substr(T1.RESULT_ALPHA,1,1) AS MODIFIER ,
  T1.VALIDATED                               AS VALIDATED ,
  to_number(T1.PARAM1)                                 AS MINIMUM ,
  to_number(T1.PARAM2)                                  AS MAXIMUM ,
  to_number(T1.PARAM3)                                  AS SLOPE ,
 -- to_number(T1.PARAM4)                                  AS PARAM4 ,
--  T1.PARAM5                                  AS IC50_2 ,
  T1.PARAM6                                  AS R2 ,
  to_number(T1.ERR)                                     AS ERR ,
case
when t1.result_numeric >0 then power(10,(log(10,t1.result_numeric)-t1.result_delta))
else null
end as IC50_MIN_CONFIDENCE,
case
when (t1.result_numeric >0 and t1.result_delta <100) then power(10,(log(10,t1.result_numeric)+t1.result_delta))
else null
end as IC50_MAX_CONFIDENCE,
case
when t1.result_numeric >0 then -log(10, t1.result_numeric) - t1.result_delta
else null
end as PIC50_MIN_CONFIDENCE,
case
when (t1.result_numeric >0 and t1.result_delta <100) then -log(10, t1.result_numeric) + t1.result_delta
else null
end as PIC50_MAX_CONFIDENCE,
 -- T1.PASS_FAIL                               AS PASS_FAIL ,
  T2.FILE_BLOB                               AS GRAPH ,
  t5.target || NVL2(t5.variant, ' ' || t5.variant, NULL) AS target_variant,
t5.cofactor_1 as cofactor_1,
t5.cofactor_2 as cofactor_2,
SUBSTR(
    NVL2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,3) AS cofactors,
t5.target || NVL2(SUBSTR(
    NVL2(t5.cofactor_1, ', /' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,3),SUBSTR(
    NVL2(t5.cofactor_1, ', /' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,3), null) AS target_cofactors,
T4.THIOL_FREE AS THIOL_FREE,
    nvl(T4.ATP_CONC_UM, t5.atp_conc_um) AS ATP_CONC_UM,
    t5.substrate_incubation_min as substrate_incubation_min,
t3.created_date as created_date,
  T3.ISID                                    AS SCIENTIST
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
   INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
   INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 181
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
ORDER BY
    t1.id,
    t5.target,
    t5.variant;
    
    
select * from ds3_userdata.tm_conclusions where ID LIKE 'FT002787-%' and protocol_id = 181 ;


SELECT id, protocol_id, experiment_id,
COUNT(experiment_id) OVER (PARTITION BY experiment_id) AS Total,
AVG(RESULT_NUMERIC) OVER (PARTITION BY experiment_id) AS Average_result,
SUM(RESULT_NUMERIC) OVER (PARTITION BY experiment_id) AS Total_result
FROM ds3_userdata.tm_conclusions;

select EXPERIMENT_ID, ID from ds3_userdata.tm_conclusions where ID LIKE 'FT002787-%' and protocol_id = 181 ;

select experiment_id, count(experiment_id) as total, AVG(RESULT_NUMERIC) as avg_result, SUM(RESULT_NUMERIC) as tot_result
FROM ds3_userdata.tm_conclusions GROUP BY experiment_id AS agg;


       
SELECT sys_context('USERENV', 'CURRENT_USER') FROM dual;

select * from ds3_userdata.enzyme_inhibition_vw;
select * from ds3_userdata.TM_GRAPHS fetch next 10 rows only;
select * from ds3_userdata.TM_CONCLUSIONS fetch next 10 rows only;
select * from ds3_userdata.tm_experiments fetch next 10 rows only;
select * from ds3_userdata.tm_sample_property_pivot fetch next 10 rows only;