
select (to_char(power(10, avg(log(10, t1.ic50)) 
    OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum)), 
    '99999.99EEEE') * 1000000000) AS geomean_nM, --t1.*
    t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier,
     count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
     count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
from 
       ds3_userdata.su_cellular_growth_drc t1
WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
        AND trim(t1.washout) = 'N'
        AND t1.compound_id = 'FT000958'
        AND t1.cell_line = 'NCI-H2405'
--        AND t1.MODIFIER IS NULL
        ;


select (to_char(power(10, avg(log(10, t1.ic50)) 
    OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum)), 
    '99999.99EEEE') * 1000000000) AS geomean_nM, --t1.*
    t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier
from 
       ds3_userdata.su_cellular_growth_drc t1
WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
        AND trim(t1.washout) = 'N'
        AND t1.compound_id = 'FT000958'
        AND t1.cell_line = 'Cal12T'
        AND MODIFIER IS NULL
        ;


select * from su_cellular_drc_stats where compound_id = 'FT000958' and cell = 'NCI-H2405'   ;    

select * from su_cellular_drc_stats where compound_id = 'FT000958' and cell = 'Cal12T'   ;
    


select      
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
    max(t0.modifier) as modifier
    FROM 
(
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
        round(stddev(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) * 1000000000, 2) AS stdev,
        round((to_char(power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000), 1) AS geomean_nM,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier))* 1000000000 
                                        - (3 * STDDEV(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier) * 1000000000)), 3) AS nm_minus_3_stdev,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier))* 1000000000 
                                        + (3 * STDDEV(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier) * 1000000000)), 3) AS nM_plus_3_stdev,
        round(ABS(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier))* 1000000000 
                                        - (3 * VARIANCE(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier) * 1000000000)), 3) AS nm_minus_3_var,
        round(abs(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier))* 1000000000 
                                        + (3 * VARIANCE(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier) * 1000000000)), 3) AS nM_plus_3_var,


     count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
     count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
from 
       ds3_userdata.su_cellular_growth_drc t1
WHERE
        t1.assay_intent = 'Screening'
        AND t1.validated = 'VALIDATED'
        AND trim(t1.washout) = 'N'
        AND t1.compound_id = 'FT000958'
        AND t1.cell_line = 'Cal12T'
        ) t0
        WHERE t0.modifier IS NULL
        ;