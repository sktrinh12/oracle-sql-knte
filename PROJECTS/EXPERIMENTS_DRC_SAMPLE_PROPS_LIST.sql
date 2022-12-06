SELECT 
EXPERIMENT_ID,
SAMPLE_ID,
PLATE_SET,
CASE WHEN SUBSTR(PROPERTIES, 1, 1) = ',' THEN
    SUBSTR(PROPERTIES, 2, LENGTH(PROPERTIES))
    ELSE
    PROPERTIES
    END AS PROPERTIES
FROM (
SELECT  
    t5.experiment_id AS EXPERIMENT_ID,
    t3.display_name AS SAMPLE_ID,
    t5.PLATE_SET AS PLATE_SET,
 LISTAGG(
 nvl2(t5.COFACTOR_1, 'Cofactor 1: ', '') || nvl2(t5.COFACTOR_1,  t5.COFACTOR_1 || ', ' , '') ||
 nvl2(t5.COFACTOR_2, ', Cofactor 2: ', '') || nvl2(t5.COFACTOR_2, t5.COFACTOR_2, '') ||
 nvl2(t5.CELL_INCUBATION_HR, ', Cell Incub (hr): ', '') || nvl2(t5.CELL_INCUBATION_HR, t5.CELL_INCUBATION_HR, '') ||
 nvl2(t5.CELL_LINE, ', Cell line: ', '') || nvl2(t5.CELL_LINE, t5.CELL_LINE, '') ||
 nvl2(t5.WASHOUT, ', Washout: ', '') || nvl2(t5.WASHOUT, t5.WASHOUT, '')  ||
 nvl2(t5.PASSAGE_NUMBER, ', Passage #: ', '') || nvl2(t5.PASSAGE_NUMBER, t5.PASSAGE_NUMBER, '')  ||
 nvl2(t5.PCT_SERUM, ', Serum (%): ', '') || nvl2(t5.PCT_SERUM, t5.PCT_SERUM, '')  ||
 nvl2(t5.SUBSTRATE_INCUBATION, ', Substrate Incub: ', '') || nvl2(t5.SUBSTRATE_INCUBATION, t5.SUBSTRATE_INCUBATION, '') ||
 nvl2(t5.THIOL_FREE, ', Thiol free: ', '') || nvl2(t5.THIOL_FREE, t5.THIOL_FREE, '')  ||
 nvl2(t5.PLATE_NUMBER, ', Plate #: ', '') || nvl2(t5.PLATE_NUMBER, t5.PLATE_NUMBER, '') ||
 nvl2(t5.TREATMENT_CONC_UM, ', Trt Conc (um): ', '') || nvl2(t5.TREATMENT_CONC_UM, t5.TREATMENT_CONC_UM, '') || 
 nvl2(t5.TREATMENT, ', Trt: ', '') || nvl2(t5.TREATMENT, t5.TREATMENT, '') || 
 nvl2(t5.TAB_NAME, ', Tab name: ', '') || nvl2(t5.TAB_NAME, t5.TAB_NAME, '') || 
 nvl2(t5.COMPOUND_INCUBATION_HR, ', Cmpd Incub (hr): ', '') || nvl2(t5.COMPOUND_INCUBATION_HR, t5.COMPOUND_INCUBATION_HR, '') || 
 nvl2(t5.ATP_CONC_UM, ', ATP Conc. (uM): ', '') || nvl2(t5.ATP_CONC_UM, t5.ATP_CONC_UM, '') ||
 nvl2(t5.TARGET, ', Target: ', '') || nvl2(t5.TARGET, t5.TARGET, '') ||
 nvl2(t5.VARIANT_1, ', Variant: ', '') || nvl2(t5.VARIANT_1, t5.VARIANT_1, ''), ', ' )
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
--ORDER BY
--    t5.experiment_id,
--    t3.display_name,
--    t5.plate_set
UNION ALL
SELECT
    q1.experiment_id AS EXPERIMENT_ID,
    q1.sample_id AS COMPOUND_ID,
    q1.prop1 AS PLATE_SET,
    LISTAGG(q1.property_name
            || ': '
               || q1.property_value, ', ') WITHIN GROUP(
    ORDER BY
        q1.experiment_id, q1.sample_id, q1.prop1
    ) AS properties
FROM
         ds3_userdata.tm_pes_fields_values q1
    INNER JOIN ds3_userdata.tm_experiments q2 ON q1.experiment_id = q2.experiment_id
WHERE
    q1.property_value IS NOT NULL
    AND q1.property_name != 'CONC'
        AND q2.completed_date IS NOT NULL
            AND ( q2.deleted IS NULL
                  OR q2.deleted = 'N' )
GROUP BY
    q1.experiment_id,
    q1.sample_id,
    q1.prop1
    ) q
--where q.EXPERIMENT_ID = '207124'
ORDER BY
    q.experiment_id,
    q.sample_id,
    q.plate_set
;
    
