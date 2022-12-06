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
                        experiment_id = '207046'
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
                        experiment_id = '207046'
                    AND property_name = 'CRO'
            )                      t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '207046'
                    AND property_name = 'Assay Type'
            )                      t5 ON t1.experiment_id = t5.experiment_id
        WHERE
            t1.experiment_id = '207046'
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




-- SU equiv

SELECT
    t1.batch_id  AS batch_id,
    t1.graph     AS graph,
    t1.ic50_nm   AS ic50_nm,
--    t2.geo_nm    AS geo_nm,
    '-3 stdev: '
--    || round(t2.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
--    || round(t2.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    ,
--    || t2.n_of_m AS agg_stats,
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
--            nvl(t1.result_alpha, to_char(round((t1.result_numeric * 1000000000), 2))) AS ic50_nm,
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
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id AND SUBSTR(NAME, 1,2) = 'FT'
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS inc_hr,
                    pct_serum AS pct_serum,
                    plate_set AS plate_set
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
                        experiment_id = '207124'
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '207124'
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = '207124'
            AND t3.display_name != 'BLANK'
    )                                  t1
    --LEFT OUTER
--    INNER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
--                                                             AND t1.cro = t2.cro
--                                                             AND t1.assay_type = t2.assay_type
--                                                             AND t1.cell_line = t2.cell
--                                                             AND t1.variant = t2.variant
--                                                             AND t1.inc_hr = t2.inc_hr
--                                                             AND t1.pct_serum = t2.pct_serum
ORDER BY
    t1.batch_id
    ;
    
    
    
-- SU qc curve AVG (individual curves)

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
    '% serum: ' || t1.PCT_SERUM || chr(10) AS PROPERTIES
FROM
    ds3_userdata.SU_cellular_growth_drc t1
WHERE
    t1.compound_id IN (
        select substr(DISPLAY_NAME, 0, 8) AS compound_id  FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
        WHERE experiment_id = '207124'
        AND DISPLAY_NAME != 'BLANK'
        GROUP BY
            DISPLAY_NAME
    ) AND t1.cro IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_prot_exp_fields_values
        WHERE
            experiment_id = '207124'
            AND property_name = 'CRO'
    )
    AND t1.assay_type IN (
        SELECT
            distinct property_value
        FROM
            ds3_userdata.tm_prot_exp_fields_values
        WHERE
            experiment_id = '207124'
            AND property_name = 'Assay Type'
    )
    AND t1.cell_line IN (
        SELECT distinct CELL_LINE
        FROM
            ds3_userdata.su_plate_prop_pivot
        WHERE
            experiment_id = '207124'         
            AND CELL_LINE IS NOT NULL
    )
    AND (t1.variant IN (
        SELECT distinct variant_1
        FROM
            ds3_userdata.su_plate_prop_pivot
        WHERE
            experiment_id = '207124'
            AND variant_1 IS NOT NULL
    ) OR t1.variant IS NULL)
    AND t1.cell_incubation_hr IN (
        SELECT
            distinct cell_incubation_hr
        FROM
            ds3_userdata.su_plate_prop_pivot
        WHERE
            experiment_id = '207124'            
            AND cell_incubation_hr IS NOT NULL
    )
    AND t1.pct_serum IN (
        SELECT
            distinct pct_serum
        FROM
            ds3_userdata.su_plate_prop_pivot
        WHERE
            experiment_id = '207124'           
            AND pct_serum IS NOT NULL
    )
ORDER BY
    t1.batch_id;
    
    
    
