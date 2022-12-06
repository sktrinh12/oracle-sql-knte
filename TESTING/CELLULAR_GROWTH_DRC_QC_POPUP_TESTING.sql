SELECT
    m.*,
    p.isid AS user_id
FROM
    tm_monitors m
LEFT JOIN
    gateway.roles_nontp_personnel p ON upper(m.isid) = upper(p.isid)
WHERE
    p.isid IS NULL;
    
    
select * from su_cellular_growth_drc where compound_id = 'FT005609'; 


-- abs value for negative 3 std/var bc it is below the 0 mark which signfies 10-fold less in concentration, not negative value (geomean can't be negative)
SELECT
    t1.assay_type,
    t1.cell_line,
    t1.variant,
    t1.cell_incubation_hr,
    t1.pct_serum,
    ic50 * 100000000                                                                      AS ic50,
    round((to_char(power(10, AVG(log(10, t1.ic50))
                             OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                               t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000), 3) AS
                                               geomean,
    round(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier))* 1000000000, 3) 
                                        - (3 * STDDEV(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier) * 1000000000) AS nm_minus_3_stdev,
    stddev(t1.ic50)
  OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                    t1.cell_incubation_hr, t1.pct_serum, t1.modifier) * 1000000000 AS stdev
FROM
    ds3_userdata.su_cellular_growth_drc t1
    where compound_id = 'FT005609'
order by t1.cell_line;



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
    max(t0.cellvalue_two) as cellvalue_two,
    max(t0.stdev) as stdev
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
        t1.cro || '|' || t1.assay_type || '|' || t1.cell_line || '|' || nvl(t1.variant, '-') || '|' || t1.cell_incubation_hr || '|' || t1.pct_serum || '|' || t1.modifier AS cellvalue_two,
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
    FROM
        ds3_userdata.su_cellular_growth_drc t1
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
    t0.pct_serum
    ;
    
--OLD
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
    max(t0.cellvalue_two) as cellvalue_two,
    max(t0.stdev) as stdev
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
        t1.cro || '|' || t1.assay_type || '|' || t1.cell_line || '|' || nvl(t1.variant, '-') || '|' || t1.cell_incubation_hr || '|' || t1.pct_serum || '|' || t1.modifier AS cellvalue_two,
        round(stddev(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.cro, t1.assay_type, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)*1000000000, 2) AS stdev,
        round((to_char(power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000), 1) AS geomean_nM,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) - (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_minus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) + (3 * stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_plus_3_stdev,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) - (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_minus_3_var,
        round(((power(10, avg(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) + (3 * variance(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier)))) * 1000000000), 1) AS nM_plus_3_var,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier) AS n,
        count(t1.ic50) OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum) AS m
    FROM
        ds3_userdata.su_cellular_growth_drc t1
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
    t0.pct_serum;