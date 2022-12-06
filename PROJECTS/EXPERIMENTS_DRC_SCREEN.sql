SELECT q.* FROM (
SELECT
    to_char(t1.experiment_id)                                                                                               AS experiment_id,
    substr(t1.id, 1, 8)                                                                                                     AS compound_id,
    t1.id                                                                                                                   AS batch_id,
    t4.project                                                                                                              AS project,
    t4.cro                                                                                                                  AS cro,
    T3.DESCR                                                                                                                AS DESCR,
    T3.CREATED_DATE                                                                                                         AS created_date,
    t1.analysis_name                                                                                                        AS analysis_name,
    to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), to_number(to_char(t1.result_numeric, '9.99EEEE')))) AS ic50,
    substr(t1.result_alpha, 1, 1)                                                                                           AS modifier,
    t1.validated                                                                                                            AS validated,
    to_number(to_char(t1.param1, 'FM9999999990.0'))                                                                         AS minimum,
    to_number(to_char(t1.param2, 'FM9999999990.0'))                                                                         AS maximum,
    to_number(to_char(t1.param3, 'FM9999999990.0'))                                                                         AS slope,
    to_number(to_char(t1.param6, 'FM9999999990.099'))                                                                       AS r2,
    to_number(t1.err)                                                                                                       AS err,
    t2.file_blob                                                                                                            AS graph,
    t3.isid                                                                                                                 AS scientist,
    t1.prop1                                                                                                                AS plate_set
FROM
         ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_graphs t2 ON t1.id = t2.id
                                            AND t1.experiment_id = t2.experiment_id
                                            AND t1.prop1 = t2.prop1
    INNER JOIN ds3_userdata.tm_experiments           t3 ON t1.experiment_id = t3.experiment_id
    INNER JOIN ds3_userdata.tm_protocol_props_pivot  t4 ON t1.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1
WHERE
    t3.completed_date IS NOT NULL
    AND ( t1.protocol_id IN ( 181, 201 ) )
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
UNION ALL
Select 
    to_char(t4.experiment_id)                                                                                               AS experiment_id,
    substr(t3.display_name, 1, 8)                                                                                           AS compound_id,
    t3.display_name                                                                                                         AS batch_id,
    t8.project                                                                                                              AS project,
    t8.cro                                                                                                                  AS cro,
    T4.DESCR                                                                                                                AS DESCR,
    T4.CREATED_DATE                                                                                                         AS created_date,
    t6.name                                                                                                                 AS analysis_name,
    TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))                             AS IC50,
    CASE
        WHEN REGEXP_LIKE(SUBSTR(T1.reported_result,1,1), '[0-9]') 
        THEN ''
        ELSE
        substr(t1.reported_result, 1, 1)
    END                                                                                                                     AS modifier,
    CASE T1.STATUS
                    WHEN 1 THEN
                        'VALIDATED'
                    WHEN 2 THEN
                        'INVALIDATED'
                    WHEN 3 THEN
                        'PUBLISHED'
                    ELSE
                        'INVALIDATED'
    END                                                                                                                     AS validated,
    to_number(to_char(t1.param1, 'FM9999999990.0'))                                                                         AS minimum,
    to_number(to_char(t1.param2, 'FM9999999990.0'))                                                                         AS maximum,
    to_number(to_char(t1.param3, 'FM9999999990.0'))                                                                         AS slope,
    to_number(to_char(t1.r2, 'FM9999999990.099'))                                                                           AS r2,
    to_number(t1.err)                                                                                                       AS err,
    t5.data                                                                                                                 AS graph,
    t4.isid                                                                                                                 AS scientist,
    t2.PLATE_SET                                                                                                            AS plate_set
 FROM
                 DS3_USERDATA.SU_ANALYSIS_RESULTS T1
            INNER JOIN DS3_USERDATA.SU_GROUPINGS            T2 ON T1.GROUP_ID = T2.ID
            INNER JOIN DS3_USERDATA.SU_SAMPLES              T3 ON T2.SAMPLE_ID = T3.ID
            INNER JOIN DS3_USERDATA.TM_EXPERIMENTS          T4 ON T2.EXPERIMENT_ID = T4.EXPERIMENT_ID AND T4.PROTOCOL_ID IN (501, 441)
            INNER JOIN DS3_USERDATA.SU_CHARTS               T5 ON T1.ID = T5.RESULT_ID
            INNER JOIN DS3_USERDATA.SU_ANALYSIS_LAYERS      T6 ON T1.LAYER_ID = T6.ID
            RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT T7 ON T7.EXPERIMENT_ID = T2.EXPERIMENT_ID --ONLY HAS VARIANT_1 & NEEDS VARIANT_2
                                                                    AND T7.PLATE_SET = T2.PLATE_SET
            INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T8 ON T8.EXPERIMENT_ID = T2.EXPERIMENT_ID            
        WHERE
            T4.COMPLETED_DATE IS NOT NULL
            AND ( T4.DELETED IS NULL
                  OR T4.DELETED = 'N' )
            AND T3.DISPLAY_NAME != 'BLANK'
        
        
) q
--WHERE q.experiment_id = '207124'
ORDER BY
            q.EXPERIMENT_ID,
            q.batch_id,
            q.plate_set
;