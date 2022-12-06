SELECT
    *
FROM
    tm_protocol_props_pivot
WHERE
    experiment_id = 206244;

SELECT
    *
FROM
    su_cellular_growth_drc
WHERE
    experiment_id = 206244;

SELECT
    *
FROM
    cellular_growth_drc
WHERE
    experiment_id = 206244;

SELECT
    *
FROM
    (
        SELECT
            CAST(t0.acceptor AS VARCHAR2(200))               AS acceptor,
            CAST(t0.analysis_name AS VARCHAR2(200))          AS analysis_name,
            CAST(t0.assay_cell_incubation AS VARCHAR2(200))  AS assay_cell_incubation,
            CAST(t0.assay_intent AS VARCHAR2(200))           AS assay_intent,
            CAST(t0.assay_type AS VARCHAR2(200))             AS assay_type,
            CAST(t0.batch_id AS VARCHAR2(100))               AS batch_id,
            CAST(t0.cell_incubation_hr AS VARCHAR2(100))     AS cell_incubation_hr,
            CAST(t0.cell_line AS VARCHAR2(100))              AS cell_line,
            CAST(t0.compound_id AS VARCHAR2(32))             AS compound_id,
            CAST(t0.compound_incubation_hr AS VARCHAR2(100)) AS compound_incubation_hr,
            t0.created_date                                  AS created_date,
            CAST(t0.cro AS VARCHAR2(200))                    AS cro,
            CAST(t0.day_0_normalization AS VARCHAR2(32))     AS day_0_normalization,
            CAST(t0.descr AS VARCHAR2(4000))                 AS descr,
            CAST(t0.donor AS VARCHAR2(100))                  AS donor,
            t0.err                                           AS err,
            CAST(t0.experiment_id AS VARCHAR2(40))           AS experiment_id,
            t0.graph                                         AS graph,
            t0.ic50                                          AS ic50,
            t0.ic50_nm                                       AS ic50_nm,
            t0.maximum                                       AS maximum,
            t0.minimum                                       AS minimum,
            CAST(t0.modifier AS VARCHAR2(4))                 AS modifier,
            CAST(t0.passage_number AS VARCHAR2(100))         AS passage_number,
            CAST(t0.pct_serum AS VARCHAR2(100))              AS pct_serum,
            t0.pic50                                         AS pic50,
            CAST(t0.project AS VARCHAR2(32))                 AS project,
            t0.r2                                            AS r2,
            CAST(t0.scientist AS VARCHAR2(100))              AS scientist,
            t0.slope                                         AS slope,
            CAST(t0.threed AS VARCHAR2(100))                 AS threed,
            CAST(t0.treatment AS VARCHAR2(100))              AS treatment,
            CAST(t0.treatment_conc_um AS VARCHAR2(100))      AS treatment_conc_um,
            CAST(t0.validated AS VARCHAR2(11))               AS validated,
            CAST(t0.variant AS VARCHAR2(100))                AS variant,
            CAST(t0.washout AS VARCHAR2(100))                AS washout
        FROM
            cellular_growth_drc t0
        UNION ALL
        SELECT
            CAST(NULL AS VARCHAR2(200))  AS acceptor,
            CAST(NULL AS VARCHAR2(200))  AS analysis_name,
            CAST(NULL AS VARCHAR2(200))  AS assay_cell_incubation,
            CAST(NULL AS VARCHAR2(200))  AS assay_intent,
            CAST(NULL AS VARCHAR2(200))  AS assay_type,
            CAST(NULL AS VARCHAR2(100))  AS batch_id,
            CAST(NULL AS VARCHAR2(100))  AS cell_incubation_hr,
            CAST(NULL AS VARCHAR2(100))  AS cell_line,
            CAST(NULL AS VARCHAR2(32))   AS compound_id,
            CAST(NULL AS VARCHAR2(100))  AS compound_incubation_hr,
            NULL                         AS created_date,
            CAST(NULL AS VARCHAR2(200))  AS cro,
            CAST(NULL AS VARCHAR2(32))   AS day_0_normalization,
            CAST(NULL AS VARCHAR2(4000)) AS descr,
            CAST(NULL AS VARCHAR2(100))  AS donor,
            NULL                         AS err,
            CAST(NULL AS VARCHAR2(100))  AS experiment_id,
            NULL                         AS graph,
            NULL                         AS ic50,
            NULL                         AS ic50_nm,
            NULL                         AS maximum,
            NULL                         AS minimum,
            CAST(NULL AS VARCHAR2(4))    AS modifier,
            CAST(NULL AS VARCHAR2(100))  AS passage_number,
            CAST(NULL AS VARCHAR2(100))  AS pct_serum,
            NULL                         AS pic50,
            CAST(NULL AS VARCHAR2(32))   AS project,
            NULL                         AS r2,
            CAST(NULL AS VARCHAR2(100))  AS scientist,
            NULL                         AS slope,
            CAST(NULL AS VARCHAR2(100))  AS threed,
            CAST(NULL AS VARCHAR2(100))  AS treatment,
            CAST(NULL AS VARCHAR2(100))  AS treatment_conc_um,
            CAST(NULL AS VARCHAR2(11))   AS validated,
            CAST(NULL AS VARCHAR2(100))  AS variant,
            CAST(NULL AS VARCHAR2(100))  AS washout
        FROM
            dual
    )
WHERE
    experiment_id = 206244;

SELECT
    tsu.*
FROM
    (
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
            INNER JOIN ds3_userdata.tm_protocol_props_pivot t8 ON t8.experiment_id = t2.experiment_id --MAY NEED THE SU EQUIVALENT?
            INNER JOIN ds3_userdata.su_plate_prop_pivot     t9 ON t9.experiment_id = t2.experiment_id --ONLY HAS VARIANT_1 & NEEDS VARIANT_2
                                                              AND t9.plate_set = t2.plate_set
            INNER JOIN ds3_userdata.tm_protocols            t10 ON t10.protocol_id = t4.protocol_id
        WHERE
                t10.protocol_id = 441
            AND t4.completed_date IS NOT NULL
            AND ( t4.deleted IS NULL
                  OR t4.deleted = 'N' )
    ) tsu
ORDER BY
    compound_id,
    cell_line;
        
        
        
        
        
--DIFF SQL (WORKING)
SELECT
    *
FROM
    (
        SELECT
            CAST(t4.acceptor AS VARCHAR(100))                                                                    AS acceptor,
            CAST(t1.analysis_name AS VARCHAR2(200))                                                              AS analysis_name,
            CAST(t4.assay_type
                 || ' '
                 || t5.cell_incubation_hr AS VARCHAR2(200))                                                           AS assay_cell_incubation,
            CAST(t4.assay_intent AS VARCHAR(200))                                                                AS assay_intent,
            CAST(t4.assay_type AS VARCHAR(200))                                                                  AS assay_type,
            CAST(t1.id AS VARCHAR2(100))                                                                         AS batch_id,
            CAST(t5.cell_incubation_hr AS VARCHAR(100))                                                          AS cell_incubation_hr,
            CAST(t5.cell_line AS VARCHAR(100))                                                                   AS cell_line,
            CAST(substr(t1.id, 1, 8) AS VARCHAR2(32))                                                            AS compound_id,
            CAST(t5.compound_incubation_hr AS VARCHAR(100))                                                      AS compound_incubation_hr,
            t3.created_date                                                                                      AS created_date,
            CAST(t4.cro AS VARCHAR2(200))                                                                        AS cro,
            CAST(nvl(t4.day_0_normalization, 'N') AS VARCHAR2(32))                                               AS day_0_normalization,
            CAST(t3.descr AS VARCHAR2(4000))                                                                     AS descr,
            CAST(t4.donor AS VARCHAR(200))                                                                       AS donor,
            to_number(t1.err)                                                                                    AS err,
            CAST(to_char(t1.experiment_id) AS VARCHAR(40))                                                       AS experiment_id,
            t2.file_blob                                                                                         AS graph,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric))              AS ic50,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            to_number(t1.param2)                                                                                 AS maximum,
            to_number(t1.param1)                                                                                 AS minimum,
            CAST(substr(t1.result_alpha, 1, 1) AS VARCHAR2(4))                                                   AS modifier,
            CAST(t5.passage_number AS VARCHAR(100))                                                              AS passage_number,
            CAST(nvl(t5.pct_serum, 10) AS VARCHAR2(100))                                                         AS pct_serum,
            - log(10, to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)))   AS pic50,
            CAST(t4.project AS VARCHAR2(32))                                                                     AS project,
            to_number(t1.param6)                                                                                 AS r2,
            CAST(t3.isid AS VARCHAR(100))                                                                        AS scientist,
            to_number(t1.param3)                                                                                 AS slope,
            CAST(t4.threed AS VARCHAR(50))                                                                       AS threed,
            CAST(t5.treatment AS VARCHAR(100))                                                                   AS treatment,
            CAST(t5.treatment_conc_um AS VARCHAR(100))                                                           AS treatment_conc_um,
            CAST(t1.validated AS VARCHAR(11))                                                                    AS validated,
            CAST(t5.cell_variant AS VARCHAR(100))                                                                AS variant,
            CAST(nvl(t5.washout, 'N') AS VARCHAR2(100))                                                          AS washout
        FROM
                 ds3_userdata.tm_experiments t3
            INNER JOIN ds3_userdata.tm_conclusions           t1 ON t3.experiment_id = t1.experiment_id
            INNER JOIN ds3_userdata.tm_graphs                t2 ON t1.id = t2.id
                                                    AND t1.experiment_id = t2.experiment_id
                                                    AND t1.prop1 = t2.prop1
            INNER JOIN ds3_userdata.tm_protocol_props_pivot  t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                                   AND t1.id = t5.batch_id
                                                                   AND t1.prop1 = t5.prop1
        WHERE
            t3.completed_date IS NOT NULL
            AND t1.protocol_id = 201
            AND ( t3.deleted IS NULL
                  OR t3.deleted = 'N' )
        UNION ALL
        SELECT
            tsu.*
        FROM
            (
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
                    INNER JOIN ds3_userdata.tm_protocol_props_pivot t8 ON t8.experiment_id = t2.experiment_id --MAY NEED THE SU EQUIVALENT?
                    INNER JOIN ds3_userdata.su_plate_prop_pivot     t9 ON t9.experiment_id = t2.experiment_id --ONLY HAS VARIANT_1 & NEEDS VARIANT_2
                                                                      AND t9.plate_set = t2.plate_set
                    INNER JOIN ds3_userdata.tm_protocols            t10 ON t10.protocol_id = t4.protocol_id
                WHERE
                        t10.protocol_id = 441
                    AND t4.completed_date IS NOT NULL
                    AND ( t4.deleted IS NULL
                          OR t4.deleted = 'N' )
            ) tsu
        ORDER BY
            compound_id,
            cell_line
    )
WHERE
    experiment_id = 
--        206224 
     206244;