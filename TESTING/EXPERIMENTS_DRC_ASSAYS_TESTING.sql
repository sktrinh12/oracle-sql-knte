SELECT
    q.*
FROM
    (
        SELECT
            to_char(t1.experiment_id) AS experiment_id,
            t1.property_name          AS property_name,
            t1.property_value         AS property_value
        FROM
                 ds3_userdata.tm_prot_exp_fields_values t1
            INNER JOIN ds3_userdata.tm_experiments t2 ON t1.experiment_id = t2.experiment_id
        WHERE
            t1.property_name NOT IN ( 'CRO', 'PO/Quote Number', 'Project' )
            AND t2.completed_date IS NOT NULL
            AND t2.deleted IS NULL
            OR t2.deleted = 'N'
    ) q
WHERE
    q.experiment_id = '191027';

SELECT
    *
FROM
    tm_prot_exp_fields_values
WHERE
    experiment_id = '191027';

SELECT
    *
FROM
    ds3_userdata.tm_experiments
WHERE
    experiment_id = '191027';

SELECT
    q.*
FROM
    (
        SELECT
            t1.id            AS experiment_id,
            t1.table_data    AS table_data,
            t1.nice_name     AS nice_name,
            t1.mod_date      AS mod_date,
            t1.doc           AS doc,
            t1.obj_type      AS obj_type,
            t1.doc_id        AS doc_id,
            t1.extension     AS extension,
            t1.isid          AS isid,
            t1.added_date    AS added_date,
            t1.ondisk        AS ondisk,
            t1.file_name     AS file_name,
            t1.script_id     AS script_id,
            t1.description   AS description,
            t1.doc_order     AS doc_order,
            t1.collapsed     AS collapsed,
            t1.doc_annotated AS doc_annotated,
            t1.form_id       AS form_id,
            t1.pdf           AS pdf
        FROM
            ds3_userdata.tm_template_dict t1
    ) q
WHERE
    q.experiment_id = '207124';
     
     
--


SELECT
    to_char(t1.experiment_id)                                                                                               AS experiment_id,
    substr(t1.id, 1, 8)                                                                                                     AS compound_id,
    t1.id                                                                                                                   AS batch_id,
    t4.project                                                                                                              AS project,
    t4.cro                                                                                                                  AS cro,
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
    t3.isid                                                                                                                 AS scientist
FROM
         ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_graphs                t2 ON t1.id = t2.id
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
          OR t3.deleted = 'N' );

--SU
Select 
    to_char(t4.experiment_id)                                                                                               AS experiment_id,
    substr(t3.display_name, 1, 8)                                                                                           AS compound_id,
    t3.display_name                                                                                                         AS batch_id,
    t8.project                                                                                                              AS project,
    t8.cro                                                                                                                  AS cro,
    t6.name                                                                                                                 AS analysis_name,
    TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))                             AS IC50,
    substr(t1.reported_result, 1, 1)                                                                                        AS modifier,
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
    t4.isid                                                                                                                 AS scientist
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
;


SELECT
    *
FROM
    sample_properties_list;

SELECT
    t1.experiment_id,
    t1.sample_id,
    t1.prop1,
    LISTAGG(t1.property_name
            || ': '
               || t1.property_value, ', ') WITHIN GROUP(
    ORDER BY
        t1.experiment_id, t1.sample_id, t1.prop1
    ) AS properties
FROM
         ds3_userdata.tm_pes_fields_values t1
    INNER JOIN ds3_userdata.tm_experiments t2 ON t1.experiment_id = t2.experiment_id
WHERE
    t1.property_value IS NOT NULL
    AND t1.property_name != 'CONC'
        AND t2.completed_date IS NOT NULL
            AND ( t2.deleted IS NULL
                  OR t2.deleted = 'N' )
GROUP BY
    t1.experiment_id,
    t1.sample_id,
    t1.prop1
ORDER BY
    t1.experiment_id,
    t1.sample_id,
    t1.prop1;
    
    
select * from tm_pes_fields_values;

select * from su_plate_prop_pivot;

SELECT column_name
  FROM all_tab_cols
  WHERE table_name = 'SU_PLATE_PROP_PIVOT';


SELECT  
    t5.experiment_id,
    t3.display_name,
    t5.PLATE_SET,
 LISTAGG(
 nvl2(t5.COFACTOR_1, 'COFACTOR_1: ', '') || nvl2(t5.COFACTOR_1,  t5.COFACTOR_1 || '<br />' , '') ||
 nvl2(t5.COFACTOR_2, 'COFACTOR_2: ', '') || nvl2(t5.COFACTOR_2, t5.COFACTOR_2 || '<br />', '') ||
 nvl2(t5.CELL_INCUBATION_HR, 'CELL_INCUBATION_HR: ', '') || nvl2(t5.CELL_INCUBATION_HR, t5.CELL_INCUBATION_HR || '<br />', '') ||
 nvl2(t5.CELL_LINE, 'CELL_LINE: ', '') || nvl2(t5.CELL_LINE, t5.CELL_LINE || '<br />', '') ||
 nvl2(t5.WASHOUT, 'WASHOUT: ', '') || nvl2(t5.WASHOUT, t5.WASHOUT || '<br />', '')  ||
 nvl2(t5.PASSAGE_NUMBER, 'PASSAGE_NUMBER: ', '') || nvl2(t5.PASSAGE_NUMBER, t5.PASSAGE_NUMBER || '<br />', '')  ||
 nvl2(t5.PCT_SERUM, 'PCT_SERUM: ', '') || nvl2(t5.PCT_SERUM, t5.PCT_SERUM || '<br />', '')  ||
 nvl2(t5.SUBSTRATE_INCUBATION, 'SUBSTRATE_INCUBATION: ', '') || nvl2(t5.SUBSTRATE_INCUBATION, t5.SUBSTRATE_INCUBATION || '<br />' , '') ||
 nvl2(t5.THIOL_FREE, 'THIOL_FREE: ', '') || nvl2(t5.THIOL_FREE, t5.THIOL_FREE || '<br />', '')  ||
 nvl2(t5.PLATE_NUMBER, 'PLATE_NUMBER: ', '') || nvl2(t5.PLATE_NUMBER, t5.PLATE_NUMBER || '<br />', '') ||
 nvl2(t5.TREATMENT_CONC_UM, 'TREATMENT_CONC_UM: ', '') || nvl2(t5.TREATMENT_CONC_UM, t5.TREATMENT_CONC_UM || '<br />', '') || 
 nvl2(t5.TREATMENT, 'TREATMENT: ', '') || nvl2(t5.TREATMENT, t5.TREATMENT || '<br />', '') || 
 nvl2(t5.TAB_NAME, 'TAB_NAME: ', '') || nvl2(t5.TAB_NAME, t5.TAB_NAME || '<br />', '') || 
 nvl2(t5.COMPOUND_INCUBATION_HR, 'COMPOUND_INCUBATION_HR: ', '') || nvl2(t5.COMPOUND_INCUBATION_HR, t5.COMPOUND_INCUBATION_HR || '<br />', '') || 
 nvl2(t5.ATP_CONC_UM, 'ATP_CONC_UM: ', '') || nvl2(t5.ATP_CONC_UM, t5.ATP_CONC_UM || '<br />', '') ||
 nvl2(t5.TARGET, 'TARGET: ', '') || nvl2(t5.TARGET, t5.TARGET || '<br />' , ' ') ||
 nvl2(t5.VARIANT_1, 'VARIANT: ', '') || nvl2(t5.VARIANT_1, t5.VARIANT_1 || '<br />', ''), ', ' )
    WITHIN GROUP(
    ORDER BY
        t5.experiment_id, t3.display_name, t5.plate_set
    ) AS properties  
    from  ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN DS3_USERDATA.TM_EXPERIMENTS          T4 ON T2.EXPERIMENT_ID = T4.EXPERIMENT_ID
            INNER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT     T5 ON T5.EXPERIMENT_ID = T2.EXPERIMENT_ID
                                                                    AND T5.PLATE_SET = T2.PLATE_SET
WHERE
    t4.completed_date IS NOT NULL
            AND ( t4.deleted IS NULL
                  OR t4.deleted = 'N' )
            AND t3.display_name != 'BLANK'
GROUP BY
    t5.experiment_id,
    t3.display_name,
    t5.plate_set
;

SELECT * FROM tm_experiments;
SELECT * FROM su_groupings;
SELECT * FROM su_samples;
select * from TM_CONCLUSIONS;
