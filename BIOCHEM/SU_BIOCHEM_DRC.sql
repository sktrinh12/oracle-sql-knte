SELECT
 'BIO'||'-'||EXTRACT(YEAR FROM t3.CREATED_DATE)||'-'||t1.PROP1||'-'||ROW_NUMBER() 
         OVER (PARTITION BY t1.PROP1 ORDER BY t1.PROP1) PID,
  to_char(T1.EXPERIMENT_ID)                                                           AS EXPERIMENT_ID ,
  substr(T1.ID, 1, 8)                                                                      AS COMPOUND_ID ,
  T1.ID                                                                      AS BATCH_ID ,
 T4.PROJECT                                  AS PROJECT,
T4.CRO AS CRO,
T3.DESCR AS DESCR,
t4.assay_type as assay_type,
T4.ASSAY_INTENT AS ASSAY_INTENT,
  T1.ANALYSIS_NAME                                                           AS ANALYSIS_NAME ,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) AS IC50 ,
-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC))) AS pIC50,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM ,
  substr(T1.RESULT_ALPHA,1,1) AS MODIFIER ,
  T1.VALIDATED                               AS VALIDATED ,
  to_number(T1.PARAM1)                                 AS MINIMUM ,
  to_number(T1.PARAM2)                                  AS MAXIMUM ,
  to_number(T1.PARAM3)                                  AS SLOPE ,
  to_number(T1.PARAM6)                                  AS R2 ,
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
  T2.FILE_BLOB                               AS GRAPH ,
t5.target as target,
t5.variant as variant,
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
  DS3_USERDATA.TM_CONCLUSIONS T1
  INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
  INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
  INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
  INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
  t3.completed_date IS NOT NULL
  AND t1.protocol_id = 181
    AND ( t3.deleted IS NULL
         OR nvl(T3.DELETED,'N')='N')
UNION ALL
SELECT
    'BIO'||'-'||EXTRACT(YEAR FROM t4.CREATED_DATE)||T1.ID||'-'||t2.Plate_set PID,
    to_char(t4.experiment_id) EXPERIMENT_ID,
    substr(t3.display_name, 1, 8) COMPOUND_ID,
    t3.display_name BATCH_ID,
    t7.project PROJECT,
    t7.cro CRO,
    T4.DESCR DESCR,
    T7.ASSAY_TYPE ASSAY_TYPE,
    T7.ASSAY_INTENT ASSAY_INTENT,
    T8.NAME ANALYSIS_NAME,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) IC50,
    - log(10, to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric))) PIC50,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 IC50_NM,
    substr(t1.reported_result, 1, 1) MODIFIER,
    CASE T1.STATUS
        WHEN 1 THEN
            'VALIDATED'
        WHEN 2 THEN
            'INVALIDATED'
        WHEN 3 THEN
            'PUBLISHED'
        ELSE
            'INVALIDATED'
    END VALIDATED,
    to_number(t1.param1) minimum,
    to_number(t1.param2) maximum,
    to_number(t1.param3) slope,
    to_number(t1.r2) r2,
    to_number(t1.err) ERR,
    CASE
        WHEN t1.result_numeric > 0 THEN
            power(10,(log(10, t1.result_numeric) - t1.result_delta))
        ELSE
            NULL
    END IC50_MIN_CONFIDENCE,
    CASE
        WHEN ( t1.result_numeric > 0
               AND t1.result_delta < 100 ) THEN
            power(10,(log(10, t1.result_numeric) + t1.result_delta))
        ELSE
            NULL
    END IC50_MAX_CONFIDENCE,
    CASE
        WHEN t1.result_numeric > 0 THEN
            - log(10, t1.result_numeric) - t1.result_delta
        ELSE
            NULL
    END PIC50_MIN_CONFIDENCE,
    CASE
        WHEN ( t1.result_numeric > 0
               AND t1.result_delta < 100 ) THEN
            - log(10, t1.result_numeric) + t1.result_delta
        ELSE
            NULL
    END PIC50_MAX_CONFIDENCE,
    t5.data GRAPH,
    t6.target TARGET,
    t6.variant_1 VARIANT,
    t6.target
    || nvl2(t6.variant_1, ' ' || t6.variant_1, NULL) TARGET_VARIANT,
    t6.cofactor_1 COFACTOR_1,
    t6.cofactor_2 COFACTOR_2,
    substr(nvl2(t6.cofactor_1, ', ' || t6.cofactor_1, NULL)
           || nvl2(t6.cofactor_2, ', ' || t6.cofactor_2, NULL), 3) COFACTORS,
    t6.target
    || nvl2(substr(nvl2(t6.cofactor_1, ', /' || t6.cofactor_1, NULL)
                   || nvl2(t6.cofactor_2, ', ' || t6.cofactor_2, NULL), 3), substr(nvl2(t6.cofactor_1, ', /' || t6.cofactor_1, NULL)
                                                                                   || nvl2(t6.cofactor_2, ', ' || t6.cofactor_2, NULL),
                                                                                   3), NULL) TARGET_COFACTORS,
    t6.thiol_free THIOL_FREE,
    nvl(t6.atp_conc_um, t6.atp_conc_um) ATP_CONC_UM,
    t6.substrate_incubation SUBSTRATE_INCUBATION_MIN,
    t4.created_date CREATED_DATE,
    t4.isid SCIENTIST
FROM
         ds3_userdata.SU_ANALYSIS_RESULTS t1
    INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
    INNER JOIN DS3_USERDATA.SU_SAMPLES T3 ON T2.SAMPLE_ID = T3.ID
    INNER JOIN ds3_userdata.tm_experiments t4 ON t2.experiment_id = t4.experiment_id AND t4.protocol_id = 501
    INNER JOIN ds3_userdata.SU_CHARTS t5 ON t1.id = t5.result_id
    RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT T6 ON T6.EXPERIMENT_ID = T2.EXPERIMENT_ID
    AND T6.PLATE_SET = T2.PLATE_SET
    INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T7 ON T7.EXPERIMENT_ID = T2.EXPERIMENT_ID
    INNER JOIN DS3_USERDATA.SU_ANALYSIS_LAYERS      T8 ON T1.LAYER_ID = T8.ID
WHERE
    t4.completed_date IS NOT NULL
    AND ( t4.deleted IS NULL
         OR nvl(T4.DELETED,'N')='N')
;
