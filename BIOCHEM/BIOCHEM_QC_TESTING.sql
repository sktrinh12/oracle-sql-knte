-- OVER(PARTITION BY -- It is used to break the data into small partitions and is been separated by a boundary or in simple dividing the input into logical groups
-- max() to get one value from the column, similar to what distinct would be doing, since it is a multiple outputted values
Select * from (
SELECT
    max(t0.cro) AS CRO,
    max(t0.assay_type) AS assay_type,
    max(t0.compound_id) AS compound_id,
    max(t0.cell_line) AS cell,
    max(t0.variant) AS variant,
    max(t0.cell_incubation_hr) AS inc_hr,
    max(t0.pct_serum) AS pct_serum,
    max(t0.geomean_nM) AS geo_nM,
    max(t0.nm_minus_3_stdev) AS nm_minus_3_stdev,
    max(t0.nm_plus_3_stdev) AS nm_plus_3_stdev,
    max(t0.nm_minus_3_var) AS nm_minus_3_var,
    max(t0.nm_plus_3_var) AS nm_plus_3_var,
    max(t0.n) || ' of ' || max(t0.m) AS n_of_m
FROM (
    SELECT
        t1.cro,
        t1.assay_type,
        t1.compound_id,
        t1.batch_id,
        t1.cell_line,
        nvl(t1.variant, '-') AS variant, -- to ensure it is a string and not NULL
        t1.cell_incubation_hr,
        t1.pct_serum,
        t1.modifier,
        round((to_char(power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000), 1) AS geomean_nM,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) - (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_minus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) + (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_plus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) - (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_minus_3_var,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) + (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
    FROM
        ds3_userdata.cellular_growth_drc t1
WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
) t0
WHERE
    t0.modifier IS NULL
GROUP BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum
ORDER BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum)
    WHERE COMPOUND_ID = 'FT007578';


select * from ds3_userdata.cellular_growth_drc where VALIDATED != 'VALIDATED' and batch_id = 'FT007615-02';
select * from DS3_USERDATA.ENZYME_INHIBITION_VW;

SELECT
        t1.cro,
        t1.assay_type,
        t1.compound_id,
        t1.batch_id,
        t1.cell_line,
        nvl(t1.variant, '-') AS variant,
        t1.cell_incubation_hr,
        t1.pct_serum,
        t1.modifier,
        round((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)) * 1000000000), 1) AS geomean_nM,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) - (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_minus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) + (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_plus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) - (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_minus_3_var,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) + (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
    FROM
        ds3_userdata.cellular_growth_drc t1;
        
        
        
select CRO, ASSAY_TYPE, COMPOUND_ID, BATCH_ID, CELL_LINE, VARIANT, CELL_INCUBATION_HR, PCT_SERUM, MODIFIER, IC50 from ds3_userdata.cellular_growth_drc WHERE COMPOUND_ID = 'FT007578'; --FETCH NEXT 10 ROWS ONLY;

select CRO, ASSAY_TYPE, COMPOUND_ID, BATCH_ID, TARGET, VARIANT, COFACTORS, ATP_CONC_UM, MODIFIER, IC50 from ds3_userdata.enzyme_inhibition_vw WHERE COMPOUND_ID = 'FT007578';

SELECT
    MAX(t0.CRO) AS CRO,
    MAX(t0.ASSAY_TYPE) AS assay_type,
    MAX(t0.COMPOUND_ID) AS compound_id,
    MAX(t0.CELL_LINE) AS cell,
    MAX(t0.VARIANT) AS variant,
    MAX(t0.CELL_INCUBATION_HR) AS inc_hr,
    MAX(t0.PCT_SERUM) AS pct_serum,
    MAX(t0.GEOMEAN) AS geo_nM,
    MAX(t0.GEOMEAN_V2) as geo_nM_v2
    FROM 
    ( SELECT  t1.CRO,  t1.ASSAY_TYPE,  t1.COMPOUND_ID,  t1.BATCH_ID,  t1.CELL_LINE,  t1.VARIANT,  t1.CELL_INCUBATION_HR,  t1.PCT_SERUM,  t1.MODIFIER,
        ROUND((TO_CHAR(POWER(10, AVG(LOG(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000), 1) AS geomean,
        ROUND(TO_NUMBER('1.0e+09') * POWER(10, (AVG(LOG(10, IC50)) 
            OVER(PARTITION BY t1.CRO,
                              t1.ASSAY_TYPE, 
                              t1.COMPOUND_ID, 
                              t1.BATCH_ID,  
                              t1.CELL_LINE,  
                              t1.VARIANT, 
                              t1.CELL_INCUBATION_HR,  
                              t1.PCT_SERUM, 
                              t1.MODIFIER ))),1) AS GEOMEAN_V2 -- this way of calculating produces slightly different results (off by +2)
        FROM DS3_USERDATA.CELLULAR_GROWTH_DRC t1 
        WHERE
                ASSAY_INTENT = 'Screening'
            AND VALIDATED = 'VALIDATED' 
            AND COMPOUND_ID = 'FT007578' --change for testing
        ) t0
        WHERE
        t0.MODIFIER IS NULL
        GROUP BY
        t0.COMPOUND_ID,
        t0.CRO,
        t0.ASSAY_TYPE,
        t0.CELL_LINE,
        t0.VARIANT,
        t0.CELL_INCUBATION_HR,
        t0.PCT_SERUM;
               
 select to_char(55566.75,'99999.99EEEE') FROM DUAL;
 select TO_CHAR(12345.67, '99999G99') from dual;
        
SELECT CRO, ASSAY_TYPE, COMPOUND_ID, BATCH_ID, CELL_LINE, VARIANT 
    FROM ds3_userdata.cellular_growth_drc WHERE VARIANT IS NULL; 
        
-- use of enzyme inb view to query 
SELECT 
        t3.CRO,  
        t3.ASSAY_TYPE,
        t3.experiment_id,
        t3.COMPOUND_ID,  
        t3.BATCH_ID,  
        t3.TARGET,  
        t3.VARIANT,  
        t3.COFACTORS,  
        t3.ATP_CONC_UM,  
        t3.MODIFIER,
        case when t3.flag = 0 then 'include' else 'exclude' end AS FLAG,
        --t3.ic50 * TO_NUMBER('1.0e+09') AS IC_50,
        to_char(t3.ic50, '99999.99EEEE') * 1000000000 AS IC_50,
ROUND((to_char(POWER(10, 
      AVG( case when t3.flag = 0 then LOG(10,  t3.ic50 ) else null end) OVER(PARTITION BY
          t3.CRO,
          t3.ASSAY_TYPE, 
          t3.COMPOUND_ID, 
          t3.BATCH_ID,  
          t3.TARGET,  
          t3.VARIANT, 
          t3.COFACTORS,  
          t3.ATP_CONC_UM, 
          t3.MODIFIER,
          t3.flag
          )), '99999.99EEEE') * 1000000000), 1 ) AS geomean_NM
          --)) * TO_NUMBER('1.0e+09'), 1) AS geomean_nM
FROM (
SELECT  t1.CRO,  
        t1.ASSAY_TYPE,
        t1.experiment_id,
        t1.COMPOUND_ID,  
        t1.BATCH_ID,  
        t1.TARGET,  
        t1.VARIANT,  
        t1.COFACTORS,  
        t1.ATP_CONC_UM,  
        t1.MODIFIER,
        t2.flag,
        t1.ic50
        FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1                                   
        INNER JOIN DS3_USERDATA.TEST_BIOCHEM_IC50_FLAGS t2 
        ON t1.experiment_id = t2.experiment_id
        AND t1.batch_id = t2.batch_id
        AND t1.target = t2.target        
        AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
        WHERE
                t1.ASSAY_INTENT = 'Screening'
            AND VALIDATED = 'VALIDATED' 
            AND t1.COMPOUND_ID = 'FT000194'
            --AND t2.flag = 0
        ORDER BY EXPERIMENT_ID, TARGET
        ) t3
        ;
            

SELECT  t1.CRO,  
        t1.ASSAY_TYPE,
        t1.experiment_id,
        t1.COMPOUND_ID,  
        t1.BATCH_ID,  
        t1.TARGET,  
        t1.VARIANT,  
        t1.COFACTORS,  
        t1.ATP_CONC_UM,  
        t1.MODIFIER,  
        t1.ic50,
        to_char(t1.ic50, '99999.99EEEE') * 1000000000 AS IC_50,
        ROUND((to_char(POWER(10, 
      AVG(LOG(10,  t1.ic50 )) OVER(PARTITION BY
          --t1.CRO,
          --t1.ASSAY_TYPE, 
          t1.COMPOUND_ID, 
          t1.BATCH_ID,  
          t1.TARGET,  
          t1.VARIANT
--          t1.COFACTORS  
--          t1.ATP_CONC_UM, 
--          t1.MODIFIER
          )), '99999.99EEEE') * 1000000000), 1 ) AS geomean_NM
        FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1                                   
        
        WHERE
                t1.ASSAY_INTENT = 'Screening'
            AND VALIDATED = 'VALIDATED' 
            AND t1.COMPOUND_ID = 'FT000194'
            AND t1.COFACTORS = 'CCNA2'
        ORDER BY EXPERIMENT_ID, TARGET, COFACTORS;



SELECT  t1.CRO,  
        t1.ASSAY_TYPE,
        t1.experiment_id,
        t1.COMPOUND_ID,  
        t1.BATCH_ID,  
        t1.TARGET,  
        t1.VARIANT,  
        t1.COFACTORS,  
        t1.ATP_CONC_UM,  
        t1.MODIFIER,
        t2.flag,
                

        FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1                                   
        INNER JOIN DS3_USERDATA.TEST_BIOCHEM_IC50_FLAGS t2 
        ON t1.experiment_id = t2.experiment_id
        AND t1.batch_id = t2.batch_id
        AND t1.target = t2.target        
        AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
        WHERE
                t1.ASSAY_INTENT = 'Screening'
            AND VALIDATED = 'VALIDATED' 
            AND t1.COMPOUND_ID = 'FT000194'
           
        ORDER BY EXPERIMENT_ID, TARGET, COFACTORS;

select * from ds3_userdata.TEST_BIOCHEM_IC50_FLAGS where batch_id like 'FT000194%' ORDER BY EXPERIMENT_ID;





select * from ds3_userdata.tm_sample_property_pivot;


--main query to test for enzyme inb
SELECT
    MAX(t0.CRO) AS CRO,
    MAX(t0.ASSAY_TYPE) AS assay_type,
    MAX(t0.COMPOUND_ID) AS compound_id,
    MAX(t0.TARGET) AS target,
    MAX(t0.VARIANT) AS variant,
    MAX(t0.COFACTORS) AS cofactors,
    MAX(t0.ATP_CONC_UM) AS atp_conc_uM,
    MAX(t0.GEOMEAN_NM) AS geo_nM,
    max(t0.nm_minus_3_stdev) AS nm_minus_3_stdev,
    max(t0.nm_plus_3_stdev) AS nm_plus_3_stdev,
    max(t0.nm_minus_3_var) AS nm_minus_3_var,
    max(t0.nm_plus_3_var) AS nm_plus_3_var,
    max(t0.n) || ' of ' || max(t0.m) AS n_of_m
    FROM 
    (
    SELECT  CRO,  
        ASSAY_TYPE,  
        COMPOUND_ID,  
        BATCH_ID,  
        TARGET,  
        VARIANT,  
        COFACTORS,  
        ATP_CONC_UM,  
        MODIFIER,
        ROUND(POWER(10, AVG(LOG(10, ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER )) * TO_NUMBER('1.0e+09'), 1) AS geomean_nM,
        ROUND(POWER(10, AVG(LOG(10, ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER )  
          - (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER )) )          
          * TO_NUMBER('1.0e+09'), 1) AS nM_minus_3_stdev,
        ROUND(POWER(10, AVG(LOG(10, ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER ) 
          + (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY
              CRO,
              ASSAY_TYPE, 
              COMPOUND_ID, 
              BATCH_ID,  
              TARGET,  
              VARIANT, 
              COFACTORS,  
              ATP_CONC_UM, 
              MODIFIER )) 
              ) * TO_NUMBER('1.0e+09'), 1) AS nM_plus_3_stdev,
        ROUND(POWER(10, AVG(LOG(10, ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER )
          - (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY
              CRO,
              ASSAY_TYPE, 
              COMPOUND_ID, 
              BATCH_ID,  
              TARGET,  
              VARIANT, 
              COFACTORS,  
              ATP_CONC_UM, 
              MODIFIER )) 
              ) * TO_NUMBER('1.0e+09'), 1) AS nM_minus_3_var,
        ROUND(POWER(10, AVG(LOG(10, ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER ) 
          + (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY
              CRO,
              ASSAY_TYPE, 
              COMPOUND_ID, 
              BATCH_ID,  
              TARGET,  
              VARIANT, 
              COFACTORS,  
              ATP_CONC_UM, 
              MODIFIER )) 
              ) * TO_NUMBER('1.0e+09'), 1) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant, t1.cofactors, t1.atp_conc_um, t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant, t1.cofactors, t1.atp_conc_um) AS m
        FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1 
        WHERE
                ASSAY_INTENT = 'Screening'
            AND VALIDATED = 'VALIDATED' 
            AND COMPOUND_ID = 'FT000194' 
        ) t0
        WHERE
        t0.MODIFIER IS NULL
        GROUP BY
        t0.COMPOUND_ID,
        t0.CRO,
        t0.ASSAY_TYPE,
        t0.TARGET,
        t0.VARIANT,
        t0.COFACTORS,
        t0.ATP_CONC_UM;

select * from FT_CELLULAR_DRC_STATS WHERE COMPOUND_ID = 'FT007578';
select * from ENZYME_INHIBITION_VW;
        
        
---CELLULAR_CURVE_QC-popup
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
            t1.prop1
        FROM
                 ds3_userdata.tm_conclusions t1 -- ID/PROTOCOL_ID/EXPERIMENT_ID/ANALYSIS_ID/ANALYSIS_NAME/RESULT_NUMERIC/RESULT_ALPHA/CREATION_DATE/CONC/VALIDATED/PARAM1/PARAM2/PARAM3/PARAM4/PARAM5/PARAM6/ERR/PARAM_OTHER/PASS_FAIL/PRE_CALC/PRC/RID/PID/PROP1/RESULT_DELTA
            INNER JOIN ds3_userdata.tm_graphs t2 -- EXPERIMENT_ID/ID/CREATOR/CREATION_DATE/ANALYSIS_ID/FILE_BLOB/PRC/PROP1
            ON t1.experiment_id = t2.experiment_id
                                                    AND t1.id = t2.id
                                                    AND t1.prop1 = t2.prop1
            INNER JOIN (
                SELECT
                    experiment_id,
                    sample_id,
                    prop1,
                    MAX(decode(property_name, 'Cell Line', property_value))            AS cell_line, -- if property_name is 'cell line' then set to property_value
                    nvl(MAX(decode(property_name, 'Variant', property_value)), '-')    AS variant, -- Max(decode is string aggregation to concatentate based on the columns since this is a group by, need to grab the one value
                    MAX(decode(property_name, 'Cell Incubation (hr)', property_value)) AS inc_hr,
                    MAX(decode(property_name, '% serum', property_value))              AS pct_serum
                FROM
                    ds3_userdata.tm_pes_fields_values
                WHERE
                        experiment_id = '189424' -- DM mask variable where the experiment id is passed in from the UI
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
                    ds3_userdata.tm_prot_exp_fields_values -- protocol_id/exp_id/prop_name/prop_val/prop_date_val
                WHERE
                        experiment_id = '189424' -- pass mask var again
                    AND property_name = 'CRO'
            )                      t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values -- PROTOCOL_ID/EXPERIMENT_ID/PROP1/SAMPLE_ID/PROPERTY_NAME/PROPERTY_VALUE/CONC
                WHERE
                        experiment_id = '189424' -- pass mask var again
                    AND property_name = 'Assay Type'
            )                      t5 ON t1.experiment_id = t5.experiment_id
        WHERE
            t1.experiment_id = '189424' 
    )                                  t1
    -- return all values in table1 (left table) with matching rows of right table (table2)
    -- ASSAY_TYPE/COMPOUND_ID/CELL/VARIANT/INC_HR/PCT_SERUM/GEO_NM/NM_MINUS_3_STDEV/NM_PLUS_3_STDEV/NM_MINUS_3_VAR/NM_PLUS_3_VAR/N_OF_M/CRO
    LEFT OUTER JOIN ds3_userdata.ft_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.inc_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum
ORDER BY
    t1.batch_id,
    t1.prop1
;



-- just grab column names from tables
SELECT column_name
  FROM all_tab_cols
 WHERE table_name = 'FT_CELLULAR_DRC_STATS';
-- peak at tables and their data 
select * from                  tm_prot_exp_fields_values;
select * from                  ds3_userdata.tm_conclusions;
select * from                  ds3_userdata.tm_graphs;
select * from                  tm_pes_fields_values   ;
select * from         ft_cellular_drc_stats;

-- test second sub-query select
SELECT
            substr(t1.id, 0, 8)                                                       AS compound_id,
            t1.id                                                                     AS batch_id,
            nvl(t1.result_alpha, to_char(round((t1.result_numeric * 1000000000), 2))) AS ic50_nm,
            t2.file_blob                                                              AS graph,
            --t4.cro,
            --t5.assay_type,
            --cell_line,
            --variant,
            --inc_hr,
            --pct_serum,
            t1.prop1
        FROM
                 ds3_userdata.tm_conclusions t1
            INNER JOIN ds3_userdata.tm_graphs t2 ON t1.experiment_id = t2.experiment_id
                                                    AND t1.id = t2.id
                                                    AND t1.prop1 = t2.prop1;
                                                    
-- test 3rd sub-query select                                                    
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
                GROUP BY
                    experiment_id,
                    sample_id,
                    prop1;
                    
Select experiment_id,sample_id,prop1,
    count(experiment_id) as count,
    max(decode(property_name, 'Cell Line', property_value)) as cell_line,
    max(decode(property_name, 'Cell Incubation (hr)', property_value)) as inc_hr,
    max(decode(property_name, '% serum', property_value)) as pct_serum from ds3_userdata.tm_pes_fields_values where SAMPLE_ID = 'FT000086-01' AND PROP1 IN ('10', '11', '34', '36', '7', '8', '9', '1', '2', '3')
    GROUP BY
                    experiment_id,
                    sample_id,
                    prop1;
                       
                       
Select experiment_id,sample_id,prop1 from tm_pes_fields_values where SAMPLE_ID = 'FT000086-01';  
-- example to use max(decode( to conduct string aggregation + group by                    
select
  experiment_id ,
  max( decode( ta.val_number, 1 , ta.property_name, null ) ) ||
  max( decode( ta.val_number, 2 , ',' || ta.property_value, null ) ) ||
  max( decode( ta.val_number, 3 , ',' || ta.prop1, null ) ) ||
  max( decode( ta.val_number, 4 , ',' || ta.sample_id, null ) ) ||
  max( decode( ta.val_number, 5 , ',' || ta.protocol_id, null ) ) ||
  max( decode( ta.val_number, 6 , ',' || ta.experiment_id, null ) ) as string
from
  ( select
      experiment_id,
      property_name,
      property_value,
      prop1,
      sample_id,
      protocol_id,
      row_number() over ( partition by experiment_id order by conc ) as val_number ,
      conc
    from tm_pes_fields_values
    WHERE CONC IS NOT NULL
  ) ta
group by experiment_id
order by experiment_id;                        
                 
                    
Select * from tm_pes_fields_values FETCH NEXT 1 ROWS ONLY;
Select experiment_id, count(experiment_id) over(partition by experiment_id) from tm_pes_fields_values ;
Select experiment_id, count(experiment_id) from tm_pes_fields_values group by experiment_id;

Select experiment_id, 
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
        from cellular_growth_drc t1 where experiment_id = '150308';
        
select experiment_id, ic50, cell_line, pct_serum, cell_incubation_hr, modifier , cro, assay_type from cellular_growth_drc where experiment_id = '150308';
