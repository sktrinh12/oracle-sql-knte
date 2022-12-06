SELECT
    CAST(t8.acceptor AS VARCHAR2(100))                                                                       AS acceptor,
    CAST(t6.name AS VARCHAR2(200))                                                                           AS analysis_name,
    CAST(t8.assay_type
         || ' '
         || t9.cell_incubation_hr AS VARCHAR(200))                                                                AS assay_cell_incubation,
    CAST(t8.assay_intent AS VARCHAR2(200))                                                                   AS assay_intent,
    CAST(t8.assay_type AS VARCHAR2(200))                                                                     AS assay_type,
    CAST(t3.display_name AS VARCHAR2(200))                                                                   AS batch_id,
    CAST(t9.cell_incubation_hr AS VARCHAR2(100))                                                             AS cell_incubation_hr,
    CAST(t9.cell_line AS VARCHAR2(100))                                                                      AS cell_line,
    CAST(substr(t3.display_name, 1, 8) AS VARCHAR2(32))                                                      AS compound_id,
    CAST(t9.compound_incubation_hr AS VARCHAR2(100))                                                         AS compound_incubation_hr,
    t4.created_date                                                                                          AS created_date,
    CAST(t8.cro AS VARCHAR2(200))                                                                            AS cro,
    CAST(nvl(t8.day_0_normalization, 'N') AS VARCHAR2(32))                                                   AS day_0_normalization,
    CAST(t4.descr AS VARCHAR2(4000))                                                                         AS descr,
    CAST(t8.donor AS VARCHAR2(200))                                                                          AS donor,
    to_number(t1.err)                                                                                        AS err,
    CAST(to_char(t4.experiment_id) AS VARCHAR2(40))                                                          AS experiment_id,
    t7.data                                                                                                  AS graph,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric))              AS ic50,
    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
    to_number(t1.param2)                                                                                     AS maximum,
    to_number(t1.param1)                                                                                     AS minimum,
    CAST(substr(t1.reported_result, 1, 1) AS VARCHAR2(4))                                                    AS modifier,
    CAST(t9.passage_number AS VARCHAR2(100))                                                                 AS passage_number,
    CAST(nvl(t9.pct_serum, 10) AS VARCHAR2(100))                                                             AS pct_serum,
    - log(10, to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)))   AS pic50,
    CAST(t8.project AS VARCHAR2(32))                                                                         AS project,
    to_number(t1.r2)                                                                                         AS r2,
    CAST(t4.isid AS VARCHAR2(100))                                                                           AS scientist,
    to_number(t1.param3)                                                                                     AS slope,
    CAST(t8.threed AS VARCHAR2(50))                                                                          AS threed,
    CAST(t9.treatment AS VARCHAR2(100))                                                                      AS treatment,
    CAST(t9.treatment_conc_um AS VARCHAR2(100))                                                              AS treatment_conc_um,
    CAST(
        CASE t1.status
            WHEN 1 THEN
                'VALIDATED'
            WHEN 2 THEN
                'INVALIDATED'
            WHEN 3 THEN
                'PUBLISHED'
            ELSE
                'INVALIDATED'
        END
    AS VARCHAR(11))                                                                                          AS validated,
    CAST(t9.variant_1 AS VARCHAR2(100))                                                                      AS variant,
    CAST(nvl(t9.washout, 'N') AS VARCHAR2(100))                                                              AS washout
FROM
         ds3_userdata.su_analysis_results t1
    INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4 ON t2.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.su_classification_rules t5 ON t1.rule_id = t5.id
    INNER JOIN ds3_userdata.su_analysis_layers      t6 ON t1.layer_id = t6.id
    INNER JOIN ds3_userdata.su_charts               t7 ON t1.id = t7.result_id
    INNER JOIN ds3_userdata.tm_protocol_props_pivot t8 ON t8.experiment_id = t2.experiment_id
    RIGHT OUTER JOIN ds3_userdata.su_plate_prop_pivot     t9 ON t9.experiment_id = t2.experiment_id
                                                            AND t9.plate_set = t2.plate_set
    INNER JOIN ds3_userdata.tm_protocols            t10 ON t10.protocol_id = t4.protocol_id
WHERE
        t10.protocol_id = 481
    --AND t4.completed_date IS NOT NULL
    AND nvl(t4.deleted, 'N') = 'N'
ORDER BY
    compound_id,
    cell_line;

SELECT
    t.*,
    nvl(t.deleted, 'n')
FROM
    (
        SELECT
            *
        FROM
                 ds3_userdata.tm_protocols t10
            INNER JOIN ds3_userdata.tm_experiments t4 ON t10.protocol_id = t4.protocol_id
        WHERE
            t4.protocol_id = 481
    ) t;

SELECT
    t4.completed_date
FROM
         ds3_userdata.tm_protocols t10
    INNER JOIN ds3_userdata.tm_experiments t4 ON t10.protocol_id = t4.protocol_id
WHERE
    t4.protocol_id = 481;

select * from su_cellular_combo;

select distinct BATCH_ID from su_cellular_combo;