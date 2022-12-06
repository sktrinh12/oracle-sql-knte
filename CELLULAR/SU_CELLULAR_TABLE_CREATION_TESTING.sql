SELECT
    to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID,
    substr(T1.ID, 1, 8) AS COMPOUND_ID,
    T1.ID AS BATCH_ID,
    --t1.protocol_id       AS protocol_id,
    T3.PROJECT AS PROJECT,
	T3.CRO AS CRO,
    --t1.analysis_id       AS analysis_id,
    T4.DESCR AS DESCR,
    t1.analysis_name     AS analysis_name,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50,
    -log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM,
	substr(T1.RESULT_ALPHA, 1, 1) AS MODIFIER,
    T1.VALIDATED AS VALIDATED,
    --t1.conc              AS conc,
    to_number(t1.param1) AS MINIMUM,
    to_number(t1.param2) AS MAXIMUM,
    to_number(t1.param3) AS SLOPE,
    to_number(t1.param6) AS R2,
    --t1.param5            AS abs_xc50,
    TO_NUMBER(t1.err)    AS err,
--    t1.param_other       AS param_other,
--    t1.pass_fail         AS pass_fail,
--    t1.pre_calc          AS pre_calc,
--    t1.prc               AS prc,
--    t1.rid               AS rid,
--    t1.pid               AS pid,
--    t1.prop1             AS prop1,
--    t4.completed_date,
--    t4.countersigned_date,
    t2.file_blob         AS GRAPH,
    t5.cell_line AS cell_line,
    t5.cell_variant as variant,
    t5.passage_number AS passage_number,
	nvl(T5.WASHOUT, 'N') AS WASHOUT,
    NVL(T5.PCT_SERUM, 10) AS PCT_SERUM,
	T3.ASSAY_TYPE AS ASSAY_TYPE,
    T3.ASSAY_INTENT AS ASSAY_INTENT,
	T3.THREED AS THREED,
	T5.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR,
	T5.CELL_INCUBATION_HR AS CELL_INCUBATION_HR,
    T3.ASSAY_TYPE || ' ' || T5.CELL_INCUBATION_HR AS assay_cell_incubation,
    t5.treatment as treatment,
    t5.treatment_conc_um as treatment_conc_um,
    t3.donor as donor,
    t3.acceptor as acceptor,
--    t4.conc_units,
    t4.created_date      AS created_date,
    T4.ISID              AS SCIENTIST,
    NULL                 AS classification
FROM
    ds3_userdata.tm_conclusions t1
    LEFT JOIN ds3_userdata.tm_graphs      t2 
    ON t1.experiment_id = t2.experiment_id 
    AND t1.analysis_id = t2.analysis_id
    AND t1.id = t2.id
    AND t1.prc = t2.prc
    INNER JOIN ds3_userdata.TM_PROTOCOL_PROPS_PIVOT t3
    ON t1.experiment_id = t3.experiment_id   
    INNER JOIN DS3_USERDATA.tm_experiments T4 
    ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 
    ON t1.experiment_id = t5.experiment_id
    AND t1.id = t5.batch_id
    AND t1.prop1 = t5.prop1
UNION ALL
SELECT
    t4.experiment_id                AS experiment_id,
    t3.display_name                 AS BATCH_ID,
    substr(t3.display_name,1,8)     AS COMPOUND_ID,
    --t4.protocol_id     AS protocol_id,
    --t6.analysis_id,
    T8.PROJECT AS PROJECT,
	T8.CRO AS CRO,
    T4.DESCR AS DESCR,
    t6.name                         AS analysis_name,
    to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
        ,-log(10, to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
       ,to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM,
	substr(T1.REPORTED_RESULT, 1, 1) AS MODIFIER,
    CASE t1.status
        WHEN 1 THEN
            'VALIDATED'
        WHEN 2 THEN
            'INVALIDATED'
        WHEN 3 THEN
            'PUBLISHED'
        ELSE
            'INVALIDATED'
    END                validated,
    to_number(t1.param1)          AS MINIMUM,
    to_number(t1.param2)          AS MAXIMUM,
    to_number(t1.param3)          AS SLOPE,
    to_number(t1.R2)              AS R2,
    TO_NUMBER(t1.err)  AS err,
    t7.data            AS GRAPH,

    t9.cell_line AS cell_line,
    t9.cell_variant as variant,
    t9.passage_number AS passage_number,
	nvl(T9.WASHOUT, 'N') AS WASHOUT,
    NVL(T9.PCT_SERUM, 10) AS PCT_SERUM,
	T8.ASSAY_TYPE AS ASSAY_TYPE,
    T8.ASSAY_INTENT AS ASSAY_INTENT,
	T8.THREED AS THREED,
	T9.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR,
	T9.CELL_INCUBATION_HR AS CELL_INCUBATION_HR,
    T8.ASSAY_TYPE || ' ' || T9.CELL_INCUBATION_HR AS assay_cell_incubation,
    t9.treatment as treatment,
    t9.treatment_conc_um as treatment_conc_um,
    t8.donor as donor,
    t8.acceptor as acceptor,    
    t4.created_date    AS created_date,
    T4.ISID              AS SCIENTIST,
    t5.label           AS classification   
FROM
    ds3_userdata.su_analysis_results                t1
    INNER JOIN ds3_userdata.su_groupings            t2 
    ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3
    ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4
    ON t2.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.su_classification_rules t5
    ON t1.rule_id = t5.id
    INNER JOIN ds3_userdata.su_analysis_layers      t6
    ON t1.layer_id = t6.id
    INNER JOIN ds3_userdata.su_charts               t7
    ON t1.id = t7.result_id
    INNER JOIN ds3_userdata.TM_PROTOCOL_PROPS_PIVOT t8
    ON t8.experiment_id = t2.experiment_id
    INNER JOIN ds3_userdata.SU_SAMPLE_PROPERTY_PIVOT t9
    ON t9.experiment_id = t2.experiment_id;  
    
    
    
    
--UNION ALL
--SELECT
--    t3.display_name       AS id,
--    t4.protocol_id        AS protocol_id,
--    t4.experiment_id      AS experiment_id,
--    t5.well_analysis_id   AS analysis_id,
--    t5.name               AS analysis_name,
--    t1.value              AS result_numeric,
--    NULL                  AS result_alpha,
--    t1.created_date       AS created_date,
--    t2.conc               AS conc,
--    CASE t1.status
--        WHEN 1 THEN
--            'VALIDATED'
--        WHEN 2 THEN
--            'INVALIDATED'
--        WHEN 3 THEN
--            'PUBLISHED'
--        ELSE
--            'INVALIDATED'
--    END                   validated,
--    NULL                  AS param1,
--    NULL                  AS param2,
--    NULL                  AS param3,
--    NULL                  AS param4,
--    NULL                  AS param5,
--    NULL                  AS r2,
--    NULL                  AS err,
--    NULL                  AS param_other,
--    NULL                  AS pass_fail,
--    NULL                  AS pre_calc,
--    NULL                  AS prc,
--    NULL                  AS rid,
--    t7.plate_number       AS pid,
--    NULL                  AS prop1,
--    t4.completed_date     AS completed_date,
--    t4.countersigned_date AS countersigned_date,
--    NULL                  AS dr_chart,
--    t2.conc_unit          AS conc_units,
--    t4.created_date       AS experiment_creation_date,
--    NULL                  AS classification
--FROM
--    ds3_userdata.su_well_results t1,
--    ds3_userdata.su_well_samples t2,
--    ds3_userdata.su_samples      t3,
--    ds3_userdata.tm_experiments  t4,
--    ds3_userdata.su_well_layers  t5,
--    ds3_userdata.su_wells        t6,
--    ds3_userdata.su_plates       t7
--WHERE
--        t1.well_id = t2.well_id
--    AND t1.layer_id = t5.id
--    AND t2.sample_id = t3.id
--    AND t5.experiment_id = t4.experiment_id
--    AND t6.id = t1.well_id
--    AND t6.plate_id = t7.id




--SELECT
--    to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID,
--    substr(T1.ID, 1, 8) AS COMPOUND_ID,
--    T1.ID AS BATCH_ID,
--    T3.PROJECT AS PROJECT,
--	T3.CRO AS CRO,
--    T4.DESCR AS DESCR,
--    t1.analysis_name     AS analysis_name,
--    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
--        ,-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
--       ,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM,
--	substr(T1.RESULT_ALPHA, 1, 1) AS MODIFIER,
--    T1.VALIDATED AS VALIDATED,
--    to_number(t1.param1) AS MINIMUM,
--    to_number(t1.param2) AS MAXIMUM,
--    to_number(t1.param3) AS SLOPE,
--    to_number(t1.param6) AS R2,
--    TO_NUMBER(t1.err)    AS err,
--    t2.file_blob         AS GRAPH,
--    t5.cell_line AS cell_line,
--    t5.cell_variant as variant,
--    t5.passage_number AS passage_number,
--	nvl(T5.WASHOUT, 'N') AS WASHOUT,
--    NVL(T5.PCT_SERUM, 10) AS PCT_SERUM,
--	T3.ASSAY_TYPE AS ASSAY_TYPE,
--    T3.ASSAY_INTENT AS ASSAY_INTENT,
--	T3.THREED AS THREED,
--	T5.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR,
--	T5.CELL_INCUBATION_HR AS CELL_INCUBATION_HR,
--    T3.ASSAY_TYPE || ' ' || T5.CELL_INCUBATION_HR AS assay_cell_incubation,
--    t5.treatment as treatment,
--    t5.treatment_conc_um as treatment_conc_um,
--    t3.donor as donor,
--    t3.acceptor as acceptor,
--    t4.created_date      AS created_date,
--    T4.ISID              AS SCIENTIST,
--    NULL                 AS classification
--FROM
--    ds3_userdata.tm_conclusions t1
--    LEFT JOIN ds3_userdata.tm_graphs      t2 
--    ON t1.experiment_id = t2.experiment_id 
--    AND t1.analysis_id = t2.analysis_id
--    AND t1.id = t2.id
--    AND t1.prc = t2.prc
--    INNER JOIN ds3_userdata.TM_PROTOCOL_PROPS_PIVOT t3
--    ON t1.experiment_id = t3.experiment_id   
--    INNER JOIN DS3_USERDATA.tm_experiments T4 
--    ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
--    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 
--    ON t1.experiment_id = t5.experiment_id
--    AND t1.id = t5.batch_id
--    AND t1.prop1 = t5.prop1
--UNION ALL
SELECT
    to_char(t4.experiment_id)                AS EXPERIMENT_ID,
    t3.display_name                 AS BATCH_ID,
    substr(t3.display_name,1,8)     AS COMPOUND_ID,
    T8.PROJECT AS PROJECT,
	T8.CRO AS CRO,
    T4.DESCR AS DESCR,
    t6.name                         AS analysis_name,
    to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
        ,-log(10, to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
       ,to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM,
	substr(T1.REPORTED_RESULT, 1, 1) AS MODIFIER,
    CASE t1.status
        WHEN 1 THEN
            'VALIDATED'
        WHEN 2 THEN
            'INVALIDATED'
        WHEN 3 THEN
            'PUBLISHED'
        ELSE
            'INVALIDATED'
    END                validated,
    to_number(t1.param1)          AS MINIMUM,
    to_number(t1.param2)          AS MAXIMUM,
    to_number(t1.param3)          AS SLOPE,
    to_number(t1.R2)              AS R2,
    TO_NUMBER(t1.err)  AS err,
    t7.data            AS GRAPH,

    t9.cell_line AS cell_line,
    t9.variant_1 as variant,
    t9.passage_number AS passage_number,
	nvl(T9.WASHOUT, 'N') AS WASHOUT,
    NVL(T9.PCT_SERUM, 10) AS PCT_SERUM,
	T8.ASSAY_TYPE AS ASSAY_TYPE,
    T8.ASSAY_INTENT AS ASSAY_INTENT,
	T8.THREED AS THREED,
	T9.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR,
	T9.CELL_INCUBATION_HR AS CELL_INCUBATION_HR,
    T8.ASSAY_TYPE || ' ' || T9.CELL_INCUBATION_HR AS assay_cell_incubation,
    t9.treatment as treatment,
    t9.treatment_conc_um as treatment_conc_um,
    t8.donor as donor,
    t8.acceptor as acceptor,
    t4.created_date    AS created_date,
    T4.ISID              AS SCIENTIST,
    t5.label           AS classification   
FROM
    ds3_userdata.su_analysis_results                t1
    INNER JOIN ds3_userdata.su_groupings            t2 
    ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3
    ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4
    ON t2.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.su_classification_rules t5
    ON t1.rule_id = t5.id
    INNER JOIN ds3_userdata.su_analysis_layers      t6
    ON t1.layer_id = t6.id
    INNER JOIN ds3_userdata.su_charts               t7
    ON t1.id = t7.result_id
    INNER JOIN ds3_userdata.TM_PROTOCOL_PROPS_PIVOT t8
    ON t8.experiment_id = t2.experiment_id
    RIGHT OUTER JOIN ds3_userdata.SU_PLATE_PROP_PIVOT     t9
    ON t9.experiment_id = t2.experiment_id
    AND t9.PLATE_SET = t2.PLATE_SET;  
    
    
    
  select * from ds3_userdata.SU_PLATE_PROP_PIVOT;  
  
-- select * from ds3_userdata.su_sample_property_pivot;

--select * from DS3_USERDATA.SU_PLATE_PROPERTIES;
select distinct PROPERTY_NAME from DS3_USERDATA.SU_PROPERTY_DICTIONARY ;


select * from tm_sample_property_pivot ;


SELECT
    column_name
FROM
    all_tab_columns
WHERE
    table_name = 'CELLULAR_GROWTH_DRC'
ORDER BY
    column_name;

SELECT
    column_name
FROM
    all_tab_columns
WHERE
    table_name = 'SU_CELLULAR_GROWTH_DRC'
ORDER BY
    column_name;

SELECT
    t0.acceptor,
    t0.analysis_name,
    t0.assay_cell_incubation,
    t0.assay_intent,
    t0.assay_type,
    t0.batch_id,
    CAST(t0.cell_incubation_hr AS VARCHAR2(100))     AS cell_incubation_hr,
    CAST(t0.cell_line AS VARCHAR2(100))              AS cell_line,
    t0.compound_id,
    CAST(t0.compound_incubation_hr AS VARCHAR2(100)) AS compound_incubation_hr,
    t0.created_date,
    t0.cro,
    CAST(t0.day_0_normalization AS VARCHAR2(32))     AS day_0_normalization,
    t0.descr,
    t0.donor,
    t0.err,
    t0.experiment_id,
    t0.graph,
    t0.ic50,
    t0.ic50_nm,
    t0.maximum,
    t0.minimum,
    t0.modifier,
    CAST(t0.passage_number AS VARCHAR2(100))         AS passage_number,
    CAST(t0.pct_serum AS VARCHAR2(100))              AS pct_serum,
    t0.pic50,
    t0.project,
    t0.r2,
    t0.scientist,
    t0.slope,
    CAST(t0.threed AS VARCHAR2(100))                 AS threed,
    CAST(t0.treatment AS VARCHAR2(100))              AS treatment,
    CAST(t0.treatment_conc_um AS VARCHAR2(100))      treatment_conc_um,
    CAST(t0.validated AS VARCHAR2(11))               AS validated,
    CAST(t0.variant AS VARCHAR2(100))                AS variant,
    CAST(t0.washout AS VARCHAR2(100))                AS washout
FROM
    cellular_growth_drc t0
UNION ALL
SELECT
    t1.acceptor,
    t1.analysis_name,
    t1.assay_cell_incubation,
    t1.assay_intent,
    t1.assay_type,
    t1.batch_id,
    t1.cell_incubation_hr,
    t1.cell_line,
    t1.compound_id,
    t1.compound_incubation_hr,
    t1.created_date,
    t1.cro,
    t1.day_0_normalization,
    t1.descr,
    t1.donor,
    t1.err,
    t1.experiment_id,
    t1.graph,
    t1.ic50,
    t1.ic50_nm,
    t1.maximum,
    t1.minimum,
    t1.modifier,
    t1.passage_number,
    t1.pct_serum,
    t1.pic50,
    t1.project,
    t1.r2,
    t1.scientist,
    t1.slope,
    t1.threed,
    t1.treatment,
    t1.treatment_conc_um,
    t1.validated,
    t1.variant,
    t1.washout
FROM
    su_cellular_growth_drc t1;