--CELLULAR ALL
SELECT
        t3.PID,
        t3.CRO,
        t3.ASSAY_TYPE,
        t3.COMPOUND_ID,
        t3.EXPERIMENT_ID,
        t3.BATCH_ID,
        t3.CELL_LINE,
        t3.VARIANT,
        t3.PCT_SERUM,
        t3.PASSAGE_NUMBER,
        t3.WASHOUT,
        t3.CELL_INCUBATION_HR,
        BASE64ENCODE(t3.GRAPH) as GRAPH,
        ROUND(t3.ic50_nm,2) as IC50_NM,
        t3.flag,
    ROUND( POWER(10,
       AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
        t3.CRO,
        t3.ASSAY_TYPE,
        t3.COMPOUND_ID,
        t3.CELL_LINE,
        t3.VARIANT,
        t3.PCT_SERUM,
        t3.CELL_INCUBATION_HR,
        t3.flag
    )) * TO_NUMBER('1.0e+09'), 2) AS GEOMEAN
    FROM (
  SELECT t1.CRO,
         t1.ASSAY_TYPE,
         t1.experiment_id,
         t1.COMPOUND_ID,
         t1.BATCH_ID,
         t1.CELL_LINE,
         t1.VARIANT,
         t1.PCT_SERUM,
         t1.WASHOUT,
         t1.PASSAGE_NUMBER,
         t1.CELL_INCUBATION_HR,
         t1.GRAPH,
         t2.flag,
         t1.ic50,
         t1.PID,
         t1.ic50_nm
    FROM DS3_USERDATA.SU_CELLULAR_GROWTH_DRC t1
    INNER JOIN DS3_USERDATA.CELLULAR_IC50_FLAGS t2
    ON t1.pid = t2.pid) t3
     WHERE t3.COMPOUND_ID = 'FT008817' AND t3.CRO = 'Pharmaron'
                      AND t3.CELL_LINE = 'Kuramochi'
                      AND t3.PCT_SERUM = 10
                      AND t3.ASSAY_TYPE = 'CyQuant'
                      AND t3.CELL_INCUBATION_HR = 144
                      AND t3.VARIANT IS NULL
;

-- BIOCHEM ALL
SELECT
        t3.PID,
        t3.CRO,
        t3.ASSAY_TYPE,
        t3.COMPOUND_ID,
        t3.EXPERIMENT_ID,
        t3.BATCH_ID,
        t3.TARGET,
        t3.VARIANT,
        t3.ATP_CONC_UM,        
        t3.COFACTORS,
        t3.MODIFIER,
        BASE64ENCODE(t3.GRAPH) as GRAPH,
        ROUND(t3.ic50_nm,2) as IC50_NM,
        t3.flag,
    ROUND( POWER(10,
       AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
        t3.CRO,
        t3.ASSAY_TYPE,
        t3.COMPOUND_ID,
        t3.TARGET,
        t3.VARIANT,
        t3.COFACTORS,
        t3.flag
    )) * TO_NUMBER('1.0e+09'), 2) AS GEOMEAN
    FROM (
  SELECT t1.CRO,
         t1.ASSAY_TYPE,
         t1.experiment_id,
         t1.COMPOUND_ID,
         t1.BATCH_ID,
         t1.TARGET,
         nvl(t1.VARIANT, '-') VARIANT,         
         t1.ATP_CONC_UM,
         t1.COFACTORS,
         t1.MODIFIER,
         t1.GRAPH,
         t2.flag,
         t1.ic50,
         t1.PID,
         t1.ic50_nm
    FROM DS3_USERDATA.SU_BIOCHEM_DRC t1
    INNER JOIN DS3_USERDATA.BIOCHEM_IC50_FLAGS t2
    ON t1.pid = t2.pid) t3
     WHERE t3.COMPOUND_ID = 'FT004202' 
--                      AND t3.CRO = 'Pharmaron'
--                      AND t3.TARGET = 'CDK4'
--                      AND t3.VARIANT = '-'
--                      AND t3.ATP_CONC_UM = 1000
--                      AND t3.COFACTORS = 'CCND1'
--                      AND t3.MODIFIER = 5
;

--CELLULAR STATS

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
    max(t0.n) || ' of ' || max(t0.m) AS n_of_m,
    max(t0.stdev) as stdev,
    max(t0.flag)
FROM (
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
        t2.flag,       
        round(stddev(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t2.flag) * 1000000000, 2) AS stdev,
        round((to_char(power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t2.flag)), '99999.99EEEE') * 1000000000), 1) AS geomean_nM,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t2.flag))* 1000000000 
                                        - (3 * STDDEV(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier, t2.flag) * 1000000000)), 3) AS nm_minus_3_stdev,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t2.flag))* 1000000000 
                                        + (3 * STDDEV(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier, t2.flag) * 1000000000)), 3) AS nM_plus_3_stdev,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t2.flag))* 1000000000 
                                        - (3 * VARIANCE(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier, t2.flag) * 1000000000)), 3) AS nm_minus_3_var,
        round(abs(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier, t2.flag))* 1000000000 
                                        + (3 * VARIANCE(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier, t2.flag) * 1000000000)), 3) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
    FROM
        ds3_userdata.su_cellular_growth_drc t1
        INNER JOIN ds3_userdata.CELLULAR_IC50_FLAGS t2 ON t1.PID = t2.PID

WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
) t0
WHERE
    t0.modifier IS NULL
    AND t0.compound_id = 'FT008817'
GROUP BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum
;

--BIOCHEM STATS

SELECT
    max(t0.cro) AS CRO,
    max(t0.assay_type) AS assay_type,
    max(t0.compound_id) AS compound_id,
    max(t0.target) AS target,
    max(t0.variant) AS variant,
    max(t0.atp_conc_um) AS atp_conc_um,
    max(t0.cofactors) AS cofactors,
    max(t0.geomean_nM) AS geo_nM,
    max(t0.nm_minus_3_stdev) AS nm_minus_3_stdev,
    max(t0.nm_plus_3_stdev) AS nm_plus_3_stdev,
    max(t0.nm_minus_3_var) AS nm_minus_3_var,
    max(t0.nm_plus_3_var) AS nm_plus_3_var,
    max(t0.n) || ' of ' || max(t0.m) n_of_m,
    max(t0.stdev) stdev,
    max(t0.flag) FLAG
FROM (
    SELECT
        t1.cro,
        t1.assay_type,
        t1.compound_id,
        t1.batch_id,
        t1.target,
        nvl(t1.variant, '-') AS variant,
        t1.atp_conc_um,
        t1.cofactors,
        t1.modifier,
        t2.flag,       
        round(stddev(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant, t1.cofactors, t2.flag) * 1000000000, 2) AS stdev,
        round((to_char(power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant, t1.cofactors, t2.flag)), '99999.99EEEE') * 1000000000), 1) AS geomean_nM,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant,
                                        t1.cofactors, t2.flag))* 1000000000 
                                        - (3 * STDDEV(t1.ic50)
                                          OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, 
                                          t1.variant, t1.cofactors,
                                          t2.flag) * 1000000000)), 3) AS nm_minus_3_stdev,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant,
                                        t1.cofactors, t2.flag))* 1000000000 
                                        + (3 * STDDEV(t1.ic50)
                                          OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, 
                                          t1.variant, t1.cofactors,
                                          t2.flag) * 1000000000)), 3) AS nM_plus_3_stdev,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant,
                                        t1.cofactors, t2.flag))* 1000000000 
                                        - (3 * VARIANCE(t1.ic50)
                                            OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, 
                                            t1.variant, t1.cofactors,
                                            t2.flag) * 1000000000)), 3) AS nm_minus_3_var,
        round(abs(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant,
                                        t1.cofactors,  t2.flag))* 1000000000 
                                        + (3 * VARIANCE(t1.ic50)
                                            OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type,
                                            t1.variant, t1.cofactors,
                                            t2.flag) * 1000000000)), 3) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant, t1.cofactors,  t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.target, t1.variant, t1.cofactors) AS m
    FROM
        ds3_userdata.su_biochem_drc t1
        INNER JOIN ds3_userdata.BIOCHEM_IC50_FLAGS t2 ON t1.PID = t2.PID

WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
) t0
WHERE
    --t0.modifier IS NULL
    mod(t0.modifier,1) = 0
    AND t0.compound_id = 'FT004202'
GROUP BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.target,
    t0.variant,
    t0.cofactors
;

select t3.ic50_nm,t2.flag,
    ROUND( POWER(10,
       AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
        t3.CRO,
        t3.ASSAY_TYPE,
        t3.COMPOUND_ID,
        t3.CELL_LINE,
        t3.VARIANT,
        t3.PCT_SERUM,                
        t3.CELL_INCUBATION_HR,
        t2.FLAG
    )) * TO_NUMBER('1.0e+09'), 2) AS GEOMEAN

from su_cellular_growth_drc t3
inner join cellular_ic50_flags t2 on t2.pid = t3.pid
where
t3.CELL_LINE = 'MOLM-13'
and t3.BATCH_ID = 'FT008817-01';


DROP TABLE ds3_userdata.biochem_ic50_flags;

CREATE TABLE ds3_userdata.biochem_ic50_flags
    AS
        ( SELECT
            pid,
            0 AS flag
        FROM
            ds3_userdata.su_biochem_drc
        );
        
        
select * from ds3_userdata.su_biochem_drc;


select t1.compound_id, t1.modifier
FROM
        ds3_userdata.su_cellular_growth_drc t1
        ;
        
select t1.compound_id, t1.modifier, mod(t1.modifier,1) AS check_mod
FROM
        ds3_userdata.su_biochem_drc t1
        where mod(t1.modifier,1) = 0
        ;
        
select reported_result from
ds3_userdata.SU_ANALYSIS_RESULTS ;