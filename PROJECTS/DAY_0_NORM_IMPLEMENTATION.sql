SELECT
     to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID
    ,T1.PROPERTY_NAME AS PROPERTY_NAME
    ,T1.PROPERTY_VALUE AS PROPERTY_VALUE
  FROM
     DS3_USERDATA.TM_PROT_EXP_FIELDS_VALUES T1
     INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T2 ON T1.EXPERIMENT_ID = T2.EXPERIMENT_ID
WHERE
    T1.PROPERTY_NAME NOT IN ('CRO', 'PO/Quote Number', 'Project')
    AND  t2.completed_date IS NOT NULL 
    AND PROPERTY_NAME = 'Day 0 normalization';
    --AND t2.deleted is null or t2.deleted = 'N';
    
--CELLULAR CURVE QC POP-UP    
 SELECT
    t1.batch_id  AS batch_id,
    t1.graph     AS graph,
    t1.ic50_nm   AS ic50_nm,
    t2.geo_nm    AS geo_nm,
    '-3 stdev: '
    || round(t2.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
    || round(t2.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    || t2.n_of_m AS agg_stats,
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
    || t1.inc_hr
    || '<br />'
    || '% serum: '
    || t1.pct_serum
    || '<br />'
    || 'day 0 norm: '
    || t1.day_0_norm
    || CHR(10)   AS properties
FROM
    (
        SELECT
            substr(t1.id, 0, 8)                                                       AS compound_id,
            t1.id                                                                     AS batch_id,
            nvl(t1.result_alpha, to_char(round((t1.result_numeric * 1000000000), 2))) AS ic50_nm,
            t2.file_blob                                                              AS graph,
            t4.cro,
            t5.assay_type,
            cell_line,
            variant,
            inc_hr,
            pct_serum,
            day_0_norm,
            t1.prop1
        FROM
                 ds3_userdata.tm_conclusions t1
            INNER JOIN ds3_userdata.tm_graphs t2 ON t1.experiment_id = t2.experiment_id
                                                    AND t1.id = t2.id
                                                    AND t1.prop1 = t2.prop1
            INNER JOIN (
                SELECT
                    experiment_id,
                    sample_id,
                    prop1,
                    MAX(decode(property_name, 'Cell Line', property_value))            AS cell_line,
                    nvl(MAX(decode(property_name, 'Variant', property_value)), '-')    AS variant,
                    MAX(decode(property_name, 'Cell Incubation (hr)', property_value)) AS inc_hr,
                    MAX(decode(property_name, '% serum', property_value))              AS pct_serum
                FROM
                    ds3_userdata.tm_pes_fields_values
                WHERE
                        experiment_id = '-PRIMARY-'
                    AND sample_id != 'BLANK'
                GROUP BY
                    experiment_id,
                    sample_id,
                    prop1
            )                      t3 ON t1.experiment_id = t3.experiment_id
                    AND t1.id = t3.sample_id
                    AND t1.prop1 = t3.prop1
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '-PRIMARY-'
                    AND property_name = 'CRO'
            )                      t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN ( -- day 0 norm
                SELECT
                    experiment_id,
                    property_value AS DAY_0_NORM
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '-PRIMARY-'
                    AND property_name = 'Day 0 normalization'
            )                      t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '-PRIMARY-'
                    AND property_name = 'Assay Type'
            )                      t5 ON t1.experiment_id = t5.experiment_id
        WHERE
            t1.experiment_id = '-PRIMARY-'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.ft_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.inc_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum
ORDER BY
    t1.batch_id,
    t1.prop1;
    

--CELLULAR QC AVG POP-UP
SELECT 
    t1.batch_id AS BATCH_ID,
    t1.graph AS GRAPH,
    t1.modifier || to_char(round((t1.IC50 * 1000000000), 2), '99990.99') AS IC50_nm,
    'Min: ' || to_char(round(t1.minimum, 1), '990.9')  || '<br />' || 
	'Max: ' || to_char(round(t1.maximum, 1), '990.9') || '<br />' || 
	'Slope: ' || to_char(round(t1.slope, 1), '90.0') || '<br />' || 
	'R2: ' || to_char(round(t1.r2, 2), '0.09') || '<br />' || 
	'Err: ' || to_char(round(t1.err, 1), '9990.9') AS STATS,
    'CRO: ' || t1.CRO || '<br />' || 
    'Assay Type: ' || t1.ASSAY_TYPE || '<br />' || 
    'Cell Line: ' || t1.CELL_LINE || '<br />' || 
    'Variant: ' || t1.VARIANT || '<br />' ||
    'Inc(hr): ' || t1.CELL_INCUBATION_HR || '<br />' || 
    'Day 0 Norm: ' || nvl(t1.DAY_0_NORMALIZATION, '- ') || '<br />' || 
    '% serum: ' || t1.PCT_SERUM || chr(10) AS PROPERTIES
FROM
    ds3_userdata.cellular_growth_drc t1
WHERE
    t1.compound_id IN (
        SELECT
            substr(id, 0, 8) AS compound_id
        FROM
            ds3_userdata.tm_conclusions
        WHERE
            experiment_id = '201704'
        GROUP BY
            id
    )AND t1.cro IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_prot_exp_fields_values
        WHERE
            experiment_id = '201704'
            AND property_name = 'CRO'
    )
    AND t1.assay_type IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_prot_exp_fields_values
        WHERE
            experiment_id = '201704'
            AND property_name = 'Assay Type'
    )
    AND t1.cell_line IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
            experiment_id = '201704'
            AND sample_id != 'BLANK'
            AND property_name = 'Cell Line'
            AND property_value IS NOT NULL
    )
    AND (t1.variant IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
            experiment_id = '201704'
            AND sample_id != 'BLANK'
            AND property_name = 'Variant'
            AND property_value IS NOT NULL
    ) OR t1.variant IS NULL)
    AND t1.cell_incubation_hr IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
            experiment_id = '201704'
            AND sample_id != 'BLANK'
            AND property_name = 'Cell Incubation (hr)'
            AND property_value IS NOT NULL
    )
    AND t1.pct_serum IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
            experiment_id = '201704'
            AND sample_id != 'BLANK'
            AND property_name = '% serum'
            AND property_value IS NOT NULL
    )
--    AND t1.day_0_normalization IN (
--        SELECT
--            distinct property_value
--        FROM
--            ds3_userdata.tm_pes_fields_values
--        WHERE
--            experiment_id = '201704'
--            --AND sample_id != 'BLANK'
--            AND property_name = 'Day 0 normalization'
--            --AND property_value IS NOT NULL
--    )
ORDER BY
    t1.batch_id;

    
select * from ds3_userdata.cellular_growth_drc where experiment_id = '197844';
select * from ds3_userdata.ft_cellular_drc_stats;

--ft_cellular_drc_stats for GEOMEAN
SELECT
    max(t0.cro) AS CRO,
    max(experiment_id) AS EXP_ID,
    max(t0.assay_type) AS assay_type,
    max(t0.compound_id) AS compound_id,
    max(t0.cell_line) AS cell,
    max(t0.variant) AS variant,
    max(t0.cell_incubation_hr) AS inc_hr,
    max(t0.pct_serum) AS pct_serum,
    t0.day_0_norm AS day_0_norm,
    max(t0.geomean_nM) AS geo_nM,
    max(t0.nm_minus_3_stdev) AS nm_minus_3_stdev,
    max(t0.nm_plus_3_stdev) AS nm_plus_3_stdev,
    max(t0.nm_minus_3_var) AS nm_minus_3_var,
    max(t0.nm_plus_3_var) AS nm_plus_3_var,
    max(t0.n) || ' of ' || max(t0.m) AS n_of_m
FROM (
    SELECT
        t1.cro,
        t1.experiment_id,
        t1.assay_type,
        t1.compound_id,
        t1.batch_id,
        t1.cell_line,
        nvl(t1.variant, '-') AS variant,
        t1.cell_incubation_hr,
        t1.day_0_norm,
        t1.pct_serum,
        t1.modifier,
        round((to_char(power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm)), '99999.99EEEE') * 1000000000), 1) AS geomean_nM,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm) - (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm)))) * 1000000000), 1) AS nM_minus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm) + (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm)))) * 1000000000), 1) AS nM_plus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm) - (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm)))) * 1000000000), 1) AS nM_minus_3_var,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm) + (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm)))) * 1000000000), 1) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t1.day_0_norm) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.day_0_norm) AS m
    FROM
        ds3_userdata.cellular_growth_drc t1
WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
) t0
WHERE
    t0.modifier IS NULL AND
    t0.compound_id = 'FT000953'
GROUP BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum,
    t0.day_0_norm
ORDER BY 
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum;

--cellular growth drc
SELECT 
    to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID
	,substr(T1.ID, 1, 8) AS COMPOUND_ID
	,T1.ID AS BATCH_ID
	,T4.PROJECT AS PROJECT
	,T4.CRO AS CRO
	,T3.DESCR AS DESCR
	,T1.ANALYSIS_NAME AS ANALYSIS_NAME
	,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
    ,-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
    ,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM
	,substr(T1.RESULT_ALPHA, 1, 1) AS MODIFIER
	,T1.VALIDATED AS VALIDATED
	,to_number(T1.PARAM1) AS MINIMUM
	,to_number(T1.PARAM2) AS MAXIMUM
	,to_number(T1.PARAM3) AS SLOPE
	,to_number(T1.PARAM6) AS R2
	,to_number(T1.ERR) AS ERR
	,T2.FILE_BLOB AS GRAPH
	,t5.cell_line AS cell_line
    ,t5.cell_variant as variant
    ,t5.passage_number AS passage_number
	,nvl(T5.WASHOUT, 'N') AS WASHOUT
    ,NVL(T5.PCT_SERUM, 10) AS PCT_SERUM
    ,NVL(t4.day_0_norm, 'N') as DAY_0_NORM
	,T4.ASSAY_TYPE AS ASSAY_TYPE
    ,T4.ASSAY_INTENT AS ASSAY_INTENT
	,T4.THREED AS THREED
	,T5.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR
	,T5.CELL_INCUBATION_HR AS CELL_INCUBATION_HR
    ,T4.ASSAY_TYPE || ' ' || T5.CELL_INCUBATION_HR AS assay_cell_incubation
    ,t5.treatment as treatment
    ,t5.treatment_conc_um as treatment_conc_um
    ,t4.donor as donor
    ,t4.acceptor as acceptor
	,t3.created_date AS created_date
	,T3.ISID AS SCIENTIST
FROM 
    DS3_USERDATA.TM_EXPERIMENTS T3 
    INNER JOIN DS3_USERDATA.TM_CONCLUSIONS T1 ON T3.EXPERIMENT_ID = T1.EXPERIMENT_ID
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID
	                                                                         AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID
	                                                                         AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
	                                                                                      AND t1.id = t5.batch_id
	                                                                                      AND t1.prop1 = t5.prop1
WHERE 
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND (
		t3.deleted IS NULL
		OR t3.deleted = 'N'
    )
ORDER BY
    T1.EXPERIMENT_ID DESC,
    T1.ID,
    T5.CELL_LINE;

    
--TM_PROTOCOL_PROPS_PIVOT    
select 
to_char(EXPERIMENT_ID) as EXPERIMENT_ID,
max(decode(PROPERTY_NAME, 'Species',PROPERTY_VALUE)) SPECIES,
max(decode(PROPERTY_NAME, 'CRO',PROPERTY_VALUE)) CRO,
max(decode(PROPERTY_NAME, 'Day 0 normalization',PROPERTY_VALUE)) DAY_0_NORM,
max(decode(PROPERTY_NAME, 'Project',PROPERTY_VALUE)) AS PROJECT,
max(decode(PROPERTY_NAME, 'PO/Quote Number',PROPERTY_VALUE)) AS QUOTE_NUMBER,
max(decode(PROPERTY_NAME, 'Assay Type',PROPERTY_VALUE)) AS ASSAY_TYPE,
max(decode(PROPERTY_NAME, 'Assay Intent',PROPERTY_VALUE)) AS ASSAY_INTENT,
max(decode(PROPERTY_NAME, 'Thiol-free',PROPERTY_VALUE)) AS THIOL_FREE,
max(decode(PROPERTY_NAME, 'ATP Conc (uM)',PROPERTY_VALUE)) AS ATP_CONC_UM,
max(decode(PROPERTY_NAME, '3D',PROPERTY_VALUE)) AS THREED,
max(decode(PROPERTY_NAME, 'Donor',PROPERTY_VALUE)) AS DONOR,
max(decode(PROPERTY_NAME, 'Acceptor',PROPERTY_VALUE)) AS ACCEPTOR,
max(decode(PROPERTY_NAME, 'Batch ID',PROPERTY_VALUE)) AS BATCH_ID
from TM_PROT_EXP_FIELDS_VALUES group by EXPERIMENT_ID, PROTOCOL_ID ORDER BY EXPERIMENT_ID DESC;


--TM_SAMPLE_PROPERTY_PIVOT
SELECT 
    to_char(EXPERIMENT_ID) as EXPERIMENT_ID,
    SAMPLE_ID AS batch_id,
    PROP1,
    max(decode(PROPERTY_NAME, 'CONC',PROPERTY_VALUE)) CONC,
    max(decode(PROPERTY_NAME, 'BATCH',PROPERTY_VALUE)) BATCH,
    max(decode(PROPERTY_NAME, 'Cell Line',PROPERTY_VALUE)) AS CELL_LINE,
    max(decode(PROPERTY_NAME, 'Variant',PROPERTY_VALUE)) CELL_VARIANT,
    max(decode(PROPERTY_NAME, 'Passage Number',PROPERTY_VALUE)) PASSAGE_NUMBER,
    max(decode(PROPERTY_NAME, 'Target',PROPERTY_VALUE)) TARGET,
    max(decode(PROPERTY_NAME, 'Variant-1',PROPERTY_VALUE)) VARIANT,
    max(decode(PROPERTY_NAME, 'Cofactor-1',PROPERTY_VALUE)) AS COFACTOR_1,
    max(decode(PROPERTY_NAME, 'Cofactor-2',PROPERTY_VALUE)) COFACTOR_2,
    max(decode(PROPERTY_NAME, 'Washout',PROPERTY_VALUE)) WASHOUT,
    max(decode(PROPERTY_NAME, 'Compound Incubation (hr)',PROPERTY_VALUE)) COMPOUND_INCUBATION_HR,
    max(decode(PROPERTY_NAME, 'Cell Incubation (hr)',PROPERTY_VALUE)) CELL_INCUBATION_HR,
    max(decode(PROPERTY_NAME, 'ATP Conc (uM)',PROPERTY_VALUE)) ATP_CONC_UM,
    max(decode(PROPERTY_NAME, '% serum',PROPERTY_VALUE)) PCT_SERUM,
    max(decode(PROPERTY_NAME, 'Treatment',PROPERTY_VALUE)) TREATMENT,
    max(decode(PROPERTY_NAME, 'Treatment Conc (uM)',PROPERTY_VALUE)) TREATMENT_CONC_UM,
    max(decode(PROPERTY_NAME, 'Substrate Incubation (min)',PROPERTY_VALUE)) SUBSTRATE_INCUBATION_MIN,
    max(decode(PROPERTY_NAME, 'Day 0 normalization',PROPERTY_VALUE)) DAY_0_NORM
FROM
    TM_PES_FIELDS_VALUES 
WHERE
    sample_id != 'BLANK'
group by 
    EXPERIMENT_ID, PROTOCOL_ID,SAMPLE_ID,PROP1
order by EXPERIMENT_ID DESC;


select * FROM TM_PES_FIELDS_VALUES WHERE EXPERIMENT_ID = '197864' AND PROPERTY_NAME like '%';


select * FROM TM_PROT_EXP_FIELDS_DICT WHERE PROPERTY_TYPE = 'CHECKBOX';

select * FROM TM_PROT_EXP_FIELDS_VALUES WHERE PROPERTY_TYPE = 'CHECKBOX' ORDER BY EXPERIMENT_ID DESC;