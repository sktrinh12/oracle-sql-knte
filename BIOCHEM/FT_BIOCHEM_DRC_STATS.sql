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
            AND COMPOUND_ID = 'FT007578' 
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
        t0.ATP_CONC_UM