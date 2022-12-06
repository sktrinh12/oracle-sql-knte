-- USE OF PIDS
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
    || t1.CELL_INCUBATION_HR
    || '<br />'
    || '% serum: '
    || t1.pct_serum
    properties
FROM
    (
        SELECT
            PID,
            compound_id,
            batch_id,
            IC50_NM,
            graph,
            cro,
            assay_type,
            cell_line,
            variant,
            CELL_INCUBATION_HR,
--            day_0_normalization,
            pct_serum
        FROM
             ds3_userdata.su_cellular_growth_drc where experiment_id = 199765--210526 --199764
        and COMPOUND_ID != 'BLANK'
	  ) t1
    INNER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.PID = t2.PID
;



-- NON PIDS
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
    || t1.CELL_INCUBATION_HR
    || '<br />'
    || '% serum: '
    || t1.pct_serum
    properties
FROM
    (
        SELECT
            compound_id,
            batch_id,
            IC50_NM,
            graph,
            cro,
            assay_type,
            cell_line,
            variant,
            CELL_INCUBATION_HR,
--            day_0_normalization,
            pct_serum
        FROM
             ds3_userdata.su_cellular_growth_drc where experiment_id = 199765
        and COMPOUND_ID != 'BLANK'
	  ) t1
    INNER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id                                                        
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell_line
                                                             AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                                                             AND t1.CELL_INCUBATION_HR = t2.CELL_INCUBATION_HR
                                                             AND t1.pct_serum = t2.pct_serum    
;
