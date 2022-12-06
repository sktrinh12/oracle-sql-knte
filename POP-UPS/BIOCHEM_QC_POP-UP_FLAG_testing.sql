--main query to test for enzyme inb
SELECT
    MAX(t0.cro)              AS cro,
    MAX(t0.assay_type)       AS assay_type,
    MAX(t0.compound_id)      AS compound_id,
    MAX(t0.target)           AS target,
    MAX(t0.variant)          AS variant,
    MAX(t0.cofactors)        AS cofactors,
    MAX(t0.atp_conc_um)      AS atp_conc_um,
    MAX(t0.geomean_nm)       AS geo_nm,
    MAX(t0.nm_minus_3_stdev) AS nm_minus_3_stdev,
    MAX(t0.nm_plus_3_stdev)  AS nm_plus_3_stdev,
    MAX(t0.nm_minus_3_var)   AS nm_minus_3_var,
    MAX(t0.nm_plus_3_var)    AS nm_plus_3_var,
    MAX(t0.n)
    || ' of '
    || MAX(t0.m)             AS n_of_m
   --  t0.CRO AS CRO,
   --  t0.ASSAY_TYPE AS assay_type,
   --  t0.COMPOUND_ID AS compound_id,
   --  t0.BATCH_ID as batch_id,
   --  t0.TARGET AS target,
   --  t0.VARIANT AS variant,
   --  t0.COFACTORS AS cofactors,
   --  t0.ATP_CONC_UM AS atp_conc_uM,
   --  t0.ic50_nm,
   --  t0.flag,
   --  t0.GEOMEAN_NM AS geo_nM,
   --  t0.nm_minus_3_stdev AS nm_minus_3_stdev,
   --  t0.nm_plus_3_stdev AS nm_plus_3_stdev,
   --  t0.nm_minus_3_var AS nm_minus_3_var,
   --  t0.nm_plus_3_var AS nm_plus_3_var,
   --  t0.n || ' of ' || t0.m AS n_of_m
FROM
    (
        SELECT
            t3.cro,
            t3.assay_type,
            t3.compound_id,
            t3.batch_id,
            t3.target,
            t3.variant,
            t3.cofactors,
            t3.atp_conc_um,
            t3.modifier,
            t3.ic50_nm,
            t3.flag,
            round(power(10, AVG(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                             t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag)) * to_number('1.0e+09'), 1)  AS geomean_nm,
            round(power(10, AVG(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                             t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag) -(3 * STDDEV(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                                                                                                         t3.target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_minus_3_stdev,
            round(power(10, AVG(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                             t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag) +(3 * STDDEV(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                                                                                                         t3.target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_plus_3_stdev,
            round(power(10, AVG(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                             t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag) -(3 * VARIANCE(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                                                                                                         t3.target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_minus_3_var,
            round(power(10, AVG(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                             t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag) +(3 * VARIANCE(
                CASE
                    WHEN t3.flag = 0 THEN
                        log(10, t3.ic50)
                    ELSE
                        NULL
                END
            )
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id,  
        --t3.BATCH_ID,  
                                                                                                         t3.target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_plus_3_var,
        --count(t3.ic50) OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant, t3.cofactors, t3.atp_conc_um, t3.modifier ) AS n,
            ROW_NUMBER()
            OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant,
                              t3.cofactors, t3.atp_conc_um, t3.modifier
                 ORDER BY
                     t3.ic50
            )                                                                                AS n,
            COUNT(t3.ic50)
            OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant,
                              t3.cofactors, t3.atp_conc_um)                                              AS m
        FROM
            (
                SELECT
                    t1.cro,
                    t1.assay_type,
                    t1.experiment_id,
                    t1.compound_id,
                    t1.batch_id,
                    t1.target,
                    t1.variant,
                    t1.cofactors,
                    t1.atp_conc_um,
                    t1.modifier,
                    t2.flag,
                    t1.ic50,
                    t1.ic50_nm
                FROM
                         ds3_userdata.enzyme_inhibition_vw t1
                    INNER JOIN ds3_userdata.test_biochem_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                          AND t1.batch_id = t2.batch_id
                                                                          AND nvl(t1.target, '-') = nvl(t2.target, '-')
                                                                          AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                WHERE
                        assay_intent = 'Screening'
                    AND validated = 'VALIDATED'
                    AND compound_id = 'FT001051' 
            --AND t1.TARGET = 'CDK7'
            ) t3
    ) t0
WHERE
    t0.modifier IS NULL
       --ORDER BY TARGET, COFACTORS, CAST(SUBSTR(N_OF_M, 1, 1) AS INT), BATCH_ID ;
GROUP BY
    compound_id,
    cro,
    assay_type,
    target,
    variant,
    cofactors,
    atp_conc_um
ORDER BY
    target,
    cofactors,
    CAST(substr(n_of_m, 1, 1) AS INT);

--testing to show all data points and n of m (used in geomean all view)
SELECT
    t0.cro              AS cro,
    t0.assay_type       AS assay_type,
    t0.compound_id      AS compound_id,
    t0.batch_id         AS batch_id,
    t0.target           AS target,
    t0.variant          AS variant,
    t0.cofactors        AS cofactors,
    t0.atp_conc_um      AS atp_conc_um,
    t0.ic50_nm,
    t0.flag,
    t0.geomean_nm       AS geo_nm,
    t0.nm_minus_3_stdev AS nm_minus_3_stdev,
    t0.nm_plus_3_stdev  AS nm_plus_3_stdev,
    t0.nm_minus_3_var   AS nm_minus_3_var,
    t0.nm_plus_3_var    AS nm_plus_3_var,
    t0.n
    || ' of '
    || t0.m             AS n_of_m
FROM
    (
        SELECT
            t3.cro,
            t3.assay_type,
            t3.compound_id,
            t3.batch_id,
            t3.target,
            t3.variant,
            t3.cofactors,
            t3.atp_conc_um,
            t3.modifier,
            t3.flag,
            t3.ic50,
            t3.ic50_nm,
            round(power(10, 
        --AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
             AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag)) * to_number('1.0e+09'), 1)  AS geomean_nm,
            round(power(10, 
        --AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
             AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag
          --) - (3 * stddev(CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL
            --END) OVER(PARTITION BY
                                              ) -(3 * STDDEV(log(10, t3.ic50))
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id, t3.
                                                                                                        target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_minus_3_stdev,
            round(power(10, 
          --AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
             AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag
         --) + (3 * stddev(CASE WHEN t3.flag = 0 THEN log(10, t3.ic50) ELSE NULL
         -- END) OVER(PARTITION BY
                                              ) +(3 * STDDEV(log(10, t3.ic50))
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id, t3.
                                                                                                        target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_plus_3_stdev,
            round(power(10, 
          --AVG( CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
             AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag
        --) - (3 * variance(CASE WHEN t3.flag = 0 THEN log(10, t3.ic50) ELSE NULL
         --   END) OVER(PARTITION BY
                                              ) -(3 * VARIANCE(log(10, t3.ic50))
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id, t3.
                                                                                                        target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_minus_3_var,
            round(power(10, 
        --AVG(CASE WHEN t3.flag = 0 THEN LOG(10, t3.ic50) ELSE NULL END) OVER(PARTITION BY
             AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag
        --) + (3 * variance(CASE WHEN t3.flag = 0 THEN log(10, t3.ic50) ELSE NULL
                                              ) +(3 * VARIANCE(log(10, t3.ic50))
                                                                                                        OVER(PARTITION BY t3.cro, t3.
                                                                                                        assay_type, t3.compound_id, t3.
                                                                                                        target, t3.variant,
                                                                                                                          t3.cofactors,
                                                                                                                          t3.atp_conc_um,
                                                                                                                          t3.modifier,
                                                                                                                          t3.flag))) *
                                                                                                                          to_number('1.0e+09'),
                                                                                                                          1) AS nm_plus_3_var,
            ROW_NUMBER()
            OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant,
                              t3.cofactors, t3.atp_conc_um, t3.modifier
                 ORDER BY
                     t3.ic50
            )                                                                                AS n,
            COUNT(t3.ic50)
            OVER(PARTITION BY t3.compound_id, t3.cro, t3.assay_type, t3.target, t3.variant,
                              t3.cofactors, t3.atp_conc_um)                                              AS m
        FROM
            (
                SELECT
                    t1.cro,
                    t1.assay_type,
                    t1.experiment_id,
                    t1.compound_id,
                    t1.batch_id,
                    t1.target,
                    t1.variant,
                    t1.cofactors,
                    t1.atp_conc_um,
                    t1.modifier,
                    t2.flag,
                    t1.ic50,
                    t1.ic50_nm
                FROM
                         ds3_userdata.enzyme_inhibition_vw t1
                    INNER JOIN ds3_userdata.test_biochem_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                          AND t1.batch_id = t2.batch_id
                                                                          AND t1.target = t2.target
                                                                          AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                WHERE
                        t1.assay_intent = 'Screening'
                    AND t1.validated = 'VALIDATED'
                    AND t1.compound_id = 'FT001051'
            --AND t1.TARGET = 'CDK7'
            ) t3
    ) t0
WHERE
    t0.modifier IS NULL
ORDER BY
    t0.target,
    t0.variant,
    t0.cofactors;

SELECT
    t0.experiment_id,
    t0.batch_id,
    t0.target,
    t0.variant,
    t0.flag,
    t0.prop1,
    round(t1.ic50_nm, 2),
    t1.cofactors,
    base64encode(t1.graph)
FROM
         ds3_userdata.test_biochem_ic50_flags t0
    INNER JOIN ds3_userdata.enzyme_inhibition_vw t1 ON t0.experiment_id = t1.experiment_id
                                                       AND t0.batch_id = t1.batch_id
                                                       AND nvl(t0.target, '-') = nvl(t1.target, '-')
                                                       AND nvl(t0.variant, '-') = nvl(t1.variant, '-')
WHERE
    t1.compound_id = 'FT000194';
                        
                        
--JOIN ALL COLUMSN FOR DISPLAY ON APP [BIOCHEM]
SELECT
    t3.cro,
    t3.assay_type,
    t3.compound_id,
    t3.experiment_id,
    t3.batch_id,
    t3.target,
    t3.variant,
    t3.cofactors,
    t3.atp_conc_um,
    t3.modifier,
    base64encode(t3.graph)                                                          AS graph,
    t3.prop1,
    round(t3.ic50_nm, 2)                                                            AS ic50_nm,
    t3.flag,
    round(power(10, AVG(log(10, t3.ic50))
                    OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                      t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag)) * to_number('1.0e+09'), 1) AS geomean_nm
FROM
    (
        SELECT
            t1.cro,
            t1.assay_type,
            t1.experiment_id,
            t1.compound_id,
            t1.batch_id,
            t1.target,
            t1.variant,
            t1.cofactors,
            t1.atp_conc_um,
            t1.modifier,
            t1.graph,
            t2.flag,
            t2.prop1,
            t1.ic50,
            t1.ic50_nm
        FROM
                 ds3_userdata.enzyme_inhibition_vw t1
            INNER JOIN ds3_userdata.test_biochem_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                  AND t1.batch_id = t2.batch_id
                                                                  AND nvl(t1.target, '-') = nvl(t2.target, '-')
                                                                  AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
        WHERE
                t1.assay_intent = 'Screening'
            AND t1.validated = 'VALIDATED'
    ) t3
WHERE
    t3.compound_id = 'FT000194';

-- get individual geomean based on new flags
SELECT
   --MAX(t0.CRO) AS CRO,
   --MAX(t0.ASSAY_TYPE) AS assay_type,
   --MAX(t0.COMPOUND_ID) AS compound_id,
   --MAX(t0.TARGET) AS target,
   --MAX(t0.VARIANT) AS variant,
   --MAX(t0.COFACTORS) AS cofactors,
    MAX(t0.flag)       AS flag,
    MAX(t0.prop1)      AS prop1,
   --MAX(t0.ATP_CONC_UM) AS atp_conc_uM,
    MAX(t0.geomean_nm) AS geo_nm
FROM
    (
        SELECT
            t3.cro,
            t3.assay_type,
            t3.compound_id,
            t3.batch_id,
            t3.target,
            t3.variant,
            t3.cofactors,
            t3.atp_conc_um,
            t3.modifier,
            t3.ic50_nm,
            t3.prop1,
            t3.flag,
            round(power(10, AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                              t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag)) * to_number('1.0e+09'), 1) AS geomean_nm
        FROM
            (
                SELECT
                    t1.cro,
                    t1.assay_type,
                    t1.experiment_id,
                    t1.compound_id,
                    t1.batch_id,
                    t1.target,
                    t1.variant,
                    t1.cofactors,
                    t1.atp_conc_um,
                    t1.modifier,
                    t2.flag,
                    t2.prop1,
                    t1.ic50,
                    t1.ic50_nm
                FROM
                         ds3_userdata.enzyme_inhibition_vw t1
                    INNER JOIN ds3_userdata.test_biochem_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                          AND t1.batch_id = t2.batch_id
                                                                          AND nvl(t1.target, '-') = nvl(t2.target, '-')
                                                                          AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                WHERE
                        t1.assay_intent = 'Screening'
                    AND t1.validated = 'VALIDATED'
                    AND t1.compound_id = 'FT000194'
            ) t3
    ) t0
WHERE
        t0.prop1 = 18
    AND t0.target = 'CDK12'
            --AND t0.VARIANT = 'C1039S'
    AND t0.variant IS NULL
    AND t0.cofactors = 'CCNK'
GROUP BY
    compound_id,
    cro,
    assay_type,
    target,
    variant,
    cofactors,
    flag,
    atp_conc_um;

--CELLULAR
SELECT
    t3.cro,
    t3.assay_type,
    t3.compound_id,
    t3.experiment_id,
    t3.batch_id,
    t3.cell_line,
    t3.variant,
    t3.pct_serum,
    t3.passage_number,
    t3.washout,
    t3.cell_incubation_hr,
    base64encode(t3.graph)                                                                               AS graph,
    t3.prop1,
    round(t3.ic50_nm, 2)                                                                                 AS ic50_nm,
    t3.flag,
    round(power(10, AVG(log(10, t3.ic50))
                    OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.cell_line, t3.variant,
                                      t3.pct_serum, t3.washout, t3.passage_number, t3.cell_incubation_hr, t3.flag)) * to_number('1.0e+09'),
                                      1) AS geomean_nm,
    round(exp(AVG(ln(t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.cell_line, t3.variant,                          --http://timothychenallen.blogspot.com/2006/03/sql-calculating-geometric-mean-geomean.html
                                              t3.pct_serum, t3.washout, t3.passage_number, t3.cell_incubation_hr, t3.flag))* to_number('1.0e+09'), 2) AS geomean_2
FROM
    (
        SELECT
            t1.cro,
            t1.assay_type,
            t1.experiment_id,
            t1.compound_id,
            t1.batch_id,
            t1.cell_line,
            t1.variant,
            t1.pct_serum,
            t1.washout,
            t1.cell_incubation_hr,
            t1.passage_number,
            t1.graph,
            t2.flag,
            t2.prop1,
            t1.ic50,
            t1.ic50_nm
        FROM
                 ds3_userdata.cellular_growth_drc t1
            INNER JOIN ds3_userdata.test_cellular_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                   AND t1.batch_id = t2.batch_id
                                                                   AND nvl(t1.cell_line, '-') = nvl(t2.cell_line, '-')
                                                                   --AND nvl(t1.pct_serum, '-') = nvl(t2.pct_serum, '-')
                                                                   AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
        WHERE
                t1.assay_intent = 'Screening'
            AND t1.validated = 'VALIDATED'
    ) t3;--WHERE t0.COMPOUND_ID = 'FT001051'
                         --AND t0.EXPERIMENT_ID = '138671'
                         --AND t0.PROP1 = 46
                         --AND t0.TARGET = 'CDK12'
                         --AND t0.VARIANT IS NULL
                         --AND t0.COFACTORS = 'CCNA2'
                         --AND t0.MODIFIER IS NULL
                         --AND t0.ATP_CONC_UM = 0.3
                         --AND t0.CRO = 'ProQinase'
                         --AND t0.ASSAY_TYPE = 'radiometric';

SELECT
    COUNT(*)
FROM
         ds3_userdata.cellular_growth_drc t1
    INNER JOIN ds3_userdata.test_cellular_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                           AND t1.batch_id = t2.batch_id
                                                           AND nvl(t1.cell_line, '-') = nvl(t2.cell_line, '-')
                                                           AND nvl(t1.pct_serum, '-') = nvl(t2.pct_serum, '-')
                --AND nvl(t1.cell_incubation_hr, '-') = nvl(t2.cell_incubation_hr, '-')
                                                           AND nvl(t1.variant, '-') = nvl(t2.variant, '-');

SELECT
    t1.experiment_id,
    COUNT(*),
    dbms_lob.substr(t1.graph, 4000, 50) AS substring_graph
FROM
    (
        SELECT
            t3.cro,
            t3.assay_type,
            t3.compound_id,
            t3.experiment_id,
            t3.batch_id,
            t3.cell_line,
            t3.variant,
            t3.pct_serum,
            t3.passage_number,
            t3.washout,
            t3.cell_incubation_hr,
            base64encode(t3.graph)                                                                                   AS graph,
            t3.prop1,
            round(t3.ic50_nm, 2)                                                                                     AS ic50_nm,
            t3.flag,
            round(power(10, AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.cell_line, t3.variant,
                                              t3.pct_serum, t3.washout, t3.passage_number, t3.cell_incubation_hr, t3.flag)) * to_number(
                                              '1.0e+09'), 1) AS geomean
        FROM
            (
                SELECT
                    t1.cro,
                    t1.assay_type,
                    t1.experiment_id,
                    t1.compound_id,
                    t1.batch_id,
                    t1.cell_line,
                    t1.variant,
                    t1.pct_serum,
                    t1.washout,
                    t1.passage_number,
                    t1.cell_incubation_hr,
                    t1.graph,
                    t2.flag,
                    t2.prop1,
                    t1.ic50,
                    t1.ic50_nm
                FROM
                         ds3_userdata.cellular_growth_drc t1
                    INNER JOIN ds3_userdata.test_cellular_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                           AND t1.batch_id = t2.batch_id
                                                                           AND nvl(t1.cell_line, '-') = nvl(t2.cell_line, '-')
                                                                           AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                WHERE
                        t1.assay_intent = 'Screening'
                    AND t1.validated = 'VALIDATED'
            ) t3
        WHERE
            t3.compound_id = 'FT000953'
    ) t1
GROUP BY
    t1.experiment_id,
    dbms_lob.substr(t1.graph, 4000, 50)
HAVING
    COUNT(*) > 1;




SELECT
    COUNT(*),
    experiment_id,
    dbms_lob.substr(graph, 4000, 50) AS substring_graph
FROM
    (
        SELECT
            t1.cro,
            t1.assay_type,
            t1.experiment_id,
            t1.compound_id,
            t1.batch_id,
            t1.cell_line,
            t1.variant,
            t1.pct_serum,
            t1.washout,
            t1.passage_number,
            t1.cell_incubation_hr,
            base64encode(t1.graph) AS graph,
            t1.ic50,
            t1.ic50_nm
        FROM
            ds3_userdata.cellular_growth_drc t1
    )
WHERE COMPOUND_ID = 'FT001051'
GROUP BY
    experiment_id,
    dbms_lob.substr(graph, 4000, 50)
;



               
SELECT t1.CRO,
                     t1.ASSAY_TYPE,
                     t1.experiment_id,
                     t1.COMPOUND_ID,
                     t1.BATCH_ID,
                     t1.COFACTORS,
                     t1.TARGET,
                     t1.VARIANT,
                     BASE64ENCODE(t1.GRAPH) as GRAPH,
                     t1.ic50,                                         
                     t1.ic50_nm
               FROM DS3_USERDATA.enzyme_inhibition_vw t1               
               WHERE t1.COMPOUND_ID = 'FT000086'                          
               AND t1.experiment_id = '138672'
               AND t1.BATCH_ID = 'FT000086-01'
               AND t1.TARGET = 'CDK1'
               AND t1.VARIANT IS NULL
               AND t1.COFACTORS = 'CCNE1'
               ;
               
                           
               
SELECT
                    max(t1.cro),
                    max(t1.assay_type),
                    t1.experiment_id,
                    t1.compound_id,
                    max(t1.batch_id),
                    t1.target,
                    t1.variant,
                    t1.cofactors,
                    t1.atp_conc_um,
                    max(t1.modifier),
                    max(t2.flag),
                    max(t1.ic50),
                    max(t1.ic50_nm),
                    count(*)

                FROM
                         ds3_userdata.enzyme_inhibition_vw t1
                    INNER JOIN ds3_userdata.test2_biochem_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                        AND t1.batch_id = t2.batch_id
                                                                        AND nvl(t1.target, '-') = nvl(t2.target, '-')
                                                                        AND nvl(t1.variant, '-') = nvl(t2.variant, '-')    
                                                                        
                WHERE
                   --     t1.assay_intent = 'Screening'
                   -- AND t1.validated = 'VALIDATED'
                    t1.compound_id = 'FT000086'
                    
                GROUP BY
  t1.experiment_id,
   t1.compound_id, 
    t1.target,
    t1.VARIANT,
    t1.COFACTORS,
    t1.ATP_CONC_UM
;
          
 SELECT t1.CRO,
         t1.ASSAY_TYPE,
         t1.experiment_id,
         t1.COMPOUND_ID,
         t1.BATCH_ID,
         t1.COFACTORS,
         t1.TARGET,
         t1.VARIANT,
         BASE64ENCODE(t1.GRAPH) as GRAPH,
         t1.ic50,                                         
         t1.ic50_nm
               FROM DS3_USERDATA.enzyme_inhibition_vw t1    
               INNER JOIN ds3_userdata.test_biochem_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                        AND t1.batch_id = t2.batch_id
                                                                        AND nvl(t1.target, '-') = nvl(t2.target, '-')
                                                                        AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                                                                        AND nvl(t1.cofactors, '-') = nvl(t2.cofactors, '-')
                                                                        
               WHERE t1.COMPOUND_ID = 'FT000086'                          
               AND t1.experiment_id = '138672'
               AND t1.BATCH_ID = 'FT000086-01'
               AND t1.TARGET = 'CDK13'
               AND t1.VARIANT IS NULL
              AND t1.COFACTORS = 'CCNK'
               ;                   
               
               
SELECT * FROM ds3_userdata.test_biochem_ic50_flags WHERE TARGET = 'CDK13' AND COFACTORS = 'CCNK' AND BATCH_ID = 'FT000086-01' AND EXPERIMENT_ID = '138672';


SELECT t1.CRO,
                     t1.ASSAY_TYPE,
                     t1.experiment_id,
                     t1.COMPOUND_ID,
                     t1.BATCH_ID,
                     t1.target,
                     t1.VARIANT,                    
                     t1.COFACTORS,
                     t1.ATP_CONC_UM,
                     BASE64ENCODE(t1.GRAPH) as GRAPH,
                     t1.ic50,                                         
                     t1.ic50_nm
               FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1
               WHERE t1.COMPOUND_ID = 'FT001051'
--               AND t1.EXPERIMENT_ID = ''
               AND t1.TARGET = 'CDK13'
               AND t1.VARIANT IS NULL
              AND t1.COFACTORS = 'CCNK'
--              AND t1.ATP_CONC_UM IS NULL
              ;
              
              

    SELECT
            t3.cro,
            t3.assay_type,
            t3.compound_id,
            t3.experiment_id,
            t3.batch_id,
            t3.cell_line,
            t3.variant,
            t3.pct_serum,
            t3.passage_number,
            t3.washout,
            t3.cell_incubation_hr,
            --base64encode(t3.graph)                                                                                   AS graph,
            t3.prop1,
            round(t3.ic50_nm, 2)                                                                                     AS ic50_nm,
            t3.flag,
            round(power(10, AVG(log(10, t3.ic50))
                            OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.cell_line, t3.variant,
                                              t3.pct_serum, t3.washout, t3.passage_number, t3.cell_incubation_hr, t3.flag)) * to_number(
                                              '1.0e+09'), 2) AS geomean
        FROM
            (
                SELECT
                    t1.cro,
                    t1.assay_type,
                    t1.experiment_id,
                    t1.compound_id,
                    t1.batch_id,
                    t1.cell_line,
                    t1.variant,
                    t1.pct_serum,
                    t1.washout,
                    t1.passage_number,
                    t1.cell_incubation_hr,
                    --t1.graph,
                    t2.flag,
                    t2.prop1,
                    t1.ic50,
                    t1.ic50_nm
                FROM
                         ds3_userdata.cellular_growth_drc t1
                    INNER JOIN ds3_userdata.test_cellular_ic50_flags t2 ON t1.experiment_id = t2.experiment_id
                                                                           AND t1.batch_id = t2.batch_id
                                                                           AND nvl(t1.cell_line, '-') = nvl(t2.cell_line, '-')
                                                                           AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                
              )    
            t3
        WHERE
            t3.compound_id = 'FT002787'
              AND t3.CELL_LINE = 'WM3629'
              --AND t3.PASSAGE_NUMBER = 15
              AND t3.CELL_INCUBATION_HR = 24             
;


Select * from ds3_userdata.cellular_growth_drc where COMPOUND_ID = 'FT000086';

Select * from ds3_userdata.test2_cellular_ic50_flags;