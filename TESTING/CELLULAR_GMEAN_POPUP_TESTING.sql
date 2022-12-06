SELECT
    t1.batch_id  AS batch_id,
    t1.compound_id as COMPOUND_ID,
    t1.graph     AS graph,
    t1.ic50_nm   AS ic50_nm,
   -- t2.geo_nm    AS geo_nm,
    '-3 stdev: '
   -- || round(t2.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
   -- || round(t2.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: ',
   -- || t2.n_of_m AS agg_stats,
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
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            cell_line,
            variant,
            inc_hr,
            pct_serum
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS inc_hr,
                    pct_serum AS pct_serum,
                    plate_set As plate_set
                FROM
                    su_plate_prop_pivot
            ) t5 ON t2.experiment_id = t5.experiment_id
            AND t5.PLATE_SET = t2.PLATE_SET
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '207736'
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '207736'
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = '207736'
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.inc_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum
ORDER BY
    t1.batch_id;
    
    
    
    
SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS inc_hr,
                    pct_serum AS pct_serum,
                    plate_set As plate_set
                FROM
                    su_plate_prop_pivot
            where experiment_id = '207736';             
                    
select * from ds3_userdata.su_cellular_drc_stats where compound_id in 
('FT008642',
'FT004203',
'FT008720',
'FT008457',
'FT008721',
'FT004202',
'FT008719',
'FT008460') 
                                                             AND cro = 'Pharmaron'
                                                             AND assay_type = 'CyQuant'
                                                             AND cell = 'Kuramochi'
                                                            
                                                             AND inc_hr = 144
                                                             AND pct_serum = 10
                                                             order by COMPOUND_ID, CELL;


 SELECT
            *                                                             
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS inc_hr,
                    pct_serum AS pct_serum,
                    plate_set As plate_set
                FROM
                    su_plate_prop_pivot
            ) t5 ON t2.experiment_id = t5.experiment_id
            AND t5.PLATE_SET = t2.PLATE_SET
        where t2.experiment_id = '207736';
            
            
            
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
        round(stddev(log(10, t1.ic50)) OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum, t1.modifier), 2) AS stdev,
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
    t0.modifier IS NULL AND
    t0.compound_id in 
    ('FT008642',
'FT004203',
'FT008720',
'FT008457',
'FT008721',
'FT004202',
'FT008719',
'FT008460') AND
t0.cell_line = 'Kuramochi'
AND t0.ASSAY_TYPE = 'CyQuant'
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
            

