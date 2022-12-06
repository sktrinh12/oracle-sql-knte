SELECT
    t3.experiment_id as experiment_id
   ,t4.project as project
    ,substr(T1.ID, 1, 8) AS COMPOUND_ID
    ,nvl2(t1.result_alpha, t1.result_alpha, to_char(t1.result_numeric)) as IC50
    ,t4.cro
    ,t4.assay_type
    ,NVL2(T5.VARIANT, TRIM(T5.TARGET) || ' ' || TRIM(T5.VARIANT), TRIM(t5.target)) as target
        ,NVL(NVL2(t5.cofactor_1, t5.cofactor_1, NULL) 
        || 
        NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), '-')
    AS cofactors
    ,nvl2(t5.atp_conc_um, t5.atp_conc_um || 'uM', ' ') as atp_conc_um
    ,CASE WHEN t4.thiol_free = 'Y' THEN 'thiol-free' 
     ELSE 'thiol' END AS thiol
FROM
    DS3_USERDATA.TM_CONCLUSIONS T1
      INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
      INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
      INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 181
    AND nvl(t3.deleted,  'N') = 'N'
    AND T1.ID != 'BLANK'
    AND t4.assay_intent = 'Screening'
    AND t1.validated = 'VALIDATED' 
UNION ALL
SELECT
    t2.experiment_id as experiment_id
   ,t6.project as project
   ,substr(T3.NAME, 1, 8) AS COMPOUND_ID
   ,nvl2(t1.reported_result, t1.reported_result, to_char(t1.result_numeric)) AS IC50

   ,t6.cro AS CRO
   ,t6.assay_type
   ,NVL2(T5.VARIANT_1, TRIM(T5.TARGET) || ' ' || TRIM(T5.VARIANT_1), TRIM(t5.target)) as target
   ,NVL(NVL2(t5.cofactor_1, t5.cofactor_1, NULL) || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), '-')
    AS cofactors
    ,nvl2(t5.atp_conc_um, t5.atp_conc_um || 'uM', ' ') as atp_conc_um
    ,CASE WHEN t5.thiol_free = 'Y' THEN 'thiol-free' 
     ELSE 'thiol' END AS thiol
FROM
    ds3_userdata.SU_ANALYSIS_RESULTS T1
      INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
      INNER JOIN DS3_USERDATA.SU_SAMPLES T3 ON T3.ID = T2.SAMPLE_ID
      INNER JOIN ds3_userdata.tm_experiments T4 ON t4.experiment_id = t2.experiment_id      
      INNER JOIN ds3_userdata.SU_PLATE_PROP_PIVOT t5 ON t2.experiment_id = t5.experiment_id AND T5.PLATE_SET = T2.PLATE_SET
      INNER JOIN ds3_userdata.tm_experiments_PROPS_PIVOT T6 ON t6.experiment_id = t4.experiment_id      
WHERE
     t4.completed_date IS NOT NULL
     AND nvl(t4.deleted, 'N') = 'N'
     AND t4.protocol_id = 501
     AND T3.DISPLAY_NAME != 'BLANK'
     AND t6.assay_intent = 'Screening'
     AND t1.STATUS = 1
;