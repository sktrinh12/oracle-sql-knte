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
    MAX(t0.nm_minus_3_stdev) AS nm_minus_3_stdev,
    MAX(t0.nm_plus_3_stdev) AS nm_plus_3_stdev,
    MAX(t0.nm_minus_3_var) AS nm_minus_3_var,
    MAX(t0.nm_plus_3_var) AS nm_plus_3_var,
    MAX(t0.n) || ' of ' || MAX(t0.m) AS n_of_m
    FROM 
    (
    SELECT  
        t3.CRO,  
        t3.ASSAY_TYPE,  
        t3.COMPOUND_ID,  
        t3.BATCH_ID,  
        t3.TARGET,  
        t3.VARIANT,  
        t3.COFACTORS,  
        t3.ATP_CONC_UM,  
        t3.MODIFIER,
        t3.flag,
        ROUND(POWER(10, 
        AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
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
        )) * TO_NUMBER('1.0e+09'), 1) AS geomean_nM,
        ROUND(POWER(10, 
        AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
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
          ) - (3 * stddev(CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL
            END) OVER(PARTITION BY
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
        )) ) * TO_NUMBER('1.0e+09'), 1) AS nM_minus_3_stdev,
        ROUND(POWER(10, 
          AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
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
         ) + (3 * stddev(CASE WHEN t3.flag = 0 THEN log(10, t3.ic50) ELSE NULL
          END) OVER(PARTITION BY
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
         )) ) * TO_NUMBER('1.0e+09'), 1) AS nM_plus_3_stdev,
        ROUND(POWER(10, 
          AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
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
        ) - (3 * variance(CASE WHEN t3.flag = 0 THEN log(10, t3.ic50) ELSE NULL
            END) OVER(PARTITION BY
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
        )) ) * TO_NUMBER('1.0e+09'), 1) AS nM_minus_3_var,
        ROUND(POWER(10, 
        AVG(CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
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
        ) + (3 * variance(CASE WHEN t3.flag = 0 THEN log(10, t3.ic50) ELSE NULL
          END) OVER(PARTITION BY
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
        )) ) * TO_NUMBER('1.0e+09'), 1) AS nM_plus_3_var,
        row_number() OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant, t3.cofactors, t3.atp_conc_um, t3.modifier ORDER BY t3.ic50 ) AS n,
        count(t3.ic50) OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant, t3.cofactors, t3.atp_conc_um )  AS m
        FROM 
        (
          SELECT  
          t1.CRO,  
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
                ASSAY_INTENT = 'Screening'
            AND VALIDATED = 'VALIDATED' 
            AND COMPOUND_ID = 'FT001051' 
        ) t3 
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
        
        
        
        
        
SELECT
    t0.experiment_id,
    t0.batch_id,
    CAST(substr(t0.batch_id, 10, 2) AS INT) AS batch_number,
    t0.target,
    t0.flag,
    t0.variant,
    base64encode(t1.graph) as PLOT,
    t1.ic50_nm,
    t1.cofactors,
    t0.prop1
FROM
    ds3_userdata.test_biochem_ic50_flags t0
    INNER JOIN DS3_USERDATA.ENZYME_INHIBITION_VW t1 
    ON t0.experiment_id = t1.experiment_id
    AND t0.batch_id = t1.batch_id
    AND nvl(t0.target, '-') = nvl(t1.target, '-')
    AND nvl(t0.variant,'-') = nvl(t1.variant,'-')
WHERE
    t0.batch_id LIKE 'FT001051%'
ORDER BY
    batch_number,
    t0.experiment_id,
    t0.target;