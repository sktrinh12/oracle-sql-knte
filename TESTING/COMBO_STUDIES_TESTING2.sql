SELECT
    table_name,
    COUNT(*) num_colms,
    CASE
        WHEN COUNT(*) >= 30 THEN
            'GREATER'
        ELSE
            'LESS'
    END      cond
FROM
    all_tab_columns
WHERE
    owner = 'DS3_USERDATA'
GROUP BY
    table_name
ORDER BY
    table_name;

SELECT
    *
FROM
    analytical_chem_files_vw
WHERE
    compound_id = 'FT008460';

SELECT
    'CELL-COMBO'
    || '-'
    || t1.id
    || '-'
    || t2.plate_set                                                                                          pid,
    t8.acceptor,
    t6.name                                                                                                  analysis_name,
    t8.assay_type
    || ' '
    || t9.cell_incubation_hr                                                                                 assay_cell_incubation,
    t8.assay_intent,
    t8.assay_type,
    t3.display_name                                                                                          batch_id,
    t9.cell_incubation_hr,
    t9.cell_line,
    substr(t3.display_name, 1, 8)                                                                            compound_id,
    t9.compound_incubation_hr,
    t4.created_date,
    t8.cro,
    nvl(t8.day_0_normalization, 'N')                                                                         day_0_normalization,
    t4.descr,
    t8.donor,
    to_number(t1.err)                                                                                        err,
    to_char(t4.experiment_id)                                                                                experiment_id,
    t7.data                                                                                                  graph,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric))              AS ic50,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
    to_number(t1.param2)                                                                                     AS maximum,
    to_number(t1.param1)                                                                                     AS minimum,
    CASE
        WHEN REGEXP_LIKE ( substr(t1.reported_result, 1, 1),
                           '[0-9]' ) THEN
            ''
        ELSE
            substr(t1.reported_result, 1, 1)
    END                                                                                                      AS modifier,
    t9.passage_number,
    nvl(t9.pct_serum, 10)                                                                                    pct_serum,
    - log(10, to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)))   AS pic50,
    t8.project,
    to_number(t1.r2)                                                                                         AS r2,
    t4.isid                                                                                                  scientist,
    to_number(t1.param3)                                                                                     AS slope,
    t8.threed,
    t9.treatment,
    t9.treatment_conc_um,
    CASE t1.status
        WHEN 1 THEN
            'VALIDATED'
        WHEN 2 THEN
            'INVALIDATED'
        WHEN 3 THEN
            'PUBLISHED'
        ELSE
            'INVALIDATED'
    END                                                                                                      AS validated,
    t9.variant_1                                                                                             variant,
            --EXTRACT(YEAR FROM t4.CREATED_DATE)  YEAR,
    nvl(t9.washout, 'N')                                                                                     AS washout
FROM
         ds3_userdata.su_analysis_results t1
    INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4 ON t2.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.su_classification_rules t5 ON t1.rule_id = t5.id
    INNER JOIN ds3_userdata.su_analysis_layers      t6 ON t1.layer_id = t6.id
    INNER JOIN ds3_userdata.su_charts               t7 ON t1.id = t7.result_id
    INNER JOIN ds3_userdata.tm_protocol_props_pivot t8 ON t8.experiment_id = t2.experiment_id --MAY NEED THE SU EQUIVALENT?
    RIGHT OUTER JOIN ds3_userdata.su_plate_prop_pivot     t9 ON t9.experiment_id = t2.experiment_id --ONLY HAS VARIANT_1 & NEEDS VARIANT_2
                                                            AND t9.plate_set = t2.plate_set
    INNER JOIN ds3_userdata.tm_protocols            t10 ON t10.protocol_id = t4.protocol_id
WHERE
        t10.protocol_id = 481
            --AND T4.COMPLETED_DATE IS NOT NULL
    --AND nvl(t4.deleted, 'N') = 'N'
;


select * 
FROM
    ds3_userdata.su_analysis_results t1
    INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4 ON t2.experiment_id = t4.experiment_id
 --   INNER JOIN ds3_userdata.su_classification_rules t5 ON t1.rule_id = t5.id
--    INNER JOIN ds3_userdata.su_analysis_layers      t6 ON t1.layer_id = t6.id
--    INNER JOIN ds3_userdata.su_charts               t7 ON t1.id = t7.result_id
--    INNER JOIN ds3_userdata.tm_protocol_props_pivot t8 ON t8.experiment_id = t2.experiment_id --MAY NEED THE SU EQUIVALENT?
--    RIGHT OUTER JOIN ds3_userdata.su_plate_prop_pivot     t9 ON t9.experiment_id = t2.experiment_id --ONLY HAS VARIANT_1 & NEEDS VARIANT_2
--                                                            AND t9.plate_set = t2.plate_set
--    INNER JOIN ds3_userdata.tm_protocols            t10 ON t10.protocol_id = t4.protocol_id
where t2.experiment_id = '206325';--'195884';


select * from ds3_userdata.tm_experiments
where experiment_id = '206325';