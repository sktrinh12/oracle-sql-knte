 select * from TM_PROT_EXP_FIELDS_VALUES;
 
 
 -- classical screening PIC50
 SELECT
    t3.experiment_id as experiment_id
   ,t4.project as project
   ,substr(T1.ID, 1, 8) AS COMPOUND_ID
   ,CASE 
        WHEN substr(t1.result_alpha, 0, 1) = '>' THEN
            '<' || to_char(-log(10, to_number(substr(t1.result_alpha, 2, length(t1.result_alpha)))))
        WHEN substr(t1.result_alpha, 0, 1) = '<' THEN
           '>' || to_char(-log(10, to_number(substr(t1.result_alpha, 2, length(t1.result_alpha)))))
        ELSE to_char(-log(10, t1.result_numeric))
    END AS PIC50
   ,t4.cro AS CRO
   ,CASE t4.assay_type
       WHEN 'CellTiter-Glo' THEN 'CTG'
        ELSE t4.assay_type END AS ASSAY_TYPE
   ,NVL2(T5.CELL_VARIANT, TRIM(T5.cell_line) || ' ' || TRIM(T5.CELL_VARIANT), TRIM(t5.cell_line)) AS CELL_LINE
   ,CASE t5.washout
       WHEN 'Y' THEN 'wash'
       WHEN 'N' THEN 'no wash'
       ELSE ' ' END AS washout
   ,t5.compound_incubation_hr as compound_incubation_hr
   ,t5.cell_incubation_hr as cell_incubation_hr
   ,nvl(t5.pct_serum, 2) || '%' as pct_serum
FROM
    ds3_userdata.tm_conclusions t1
      INNER JOIN ds3_userdata.tm_experiments t3 ON t1.experiment_id = t3.experiment_id
      INNER JOIN ds3_userdata.tm_protocol_props_pivot t4 ON t1.experiment_id = t4.experiment_id
      INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND (t3.deleted IS NULL OR t3.deleted = 'N')
    AND T1.ID != 'BLANK'
    AND t4.assay_intent = 'Screening'
    AND t1.validated = 'VALIDATED'
    AND t4.donor IS NULL
    AND t4.acceptor IS NULL
    AND t4.threed = 'N';
    
    
    
-- SU equivalent PIC50
SELECT
--    t4.protocol_id
    t2.experiment_id as experiment_id
   ,t6.project as project
   ,substr(T3.NAME, 1, 8) AS COMPOUND_ID
   ,CASE 
        WHEN substr(t1.reported_result, 0, 1) = '>' THEN
            '<' || to_char(-log(10, to_number(substr(t1.reported_result, 2, length(t1.reported_result)))))
        WHEN substr(t1.reported_result, 0, 1) = '<' THEN
           '>' || to_char(-log(10, to_number(substr(t1.reported_result, 2, length(t1.reported_result)))))
        ELSE to_char(-log(10, t1.result_numeric))
    END AS PIC50
   ,t6.cro AS CRO
   ,CASE t6.assay_type
       WHEN 'CellTiter-Glo' THEN 'CTG'
        ELSE t6.assay_type END AS ASSAY_TYPE
   ,NVL2(T5.CELL_VARIANT, TRIM(T5.cell_line) || ' ' || TRIM(T5.CELL_VARIANT), TRIM(t5.cell_line)) AS CELL_LINE
   ,CASE t5.washout
       WHEN 'Y' THEN 'wash'
       WHEN 'N' THEN 'no wash'
       ELSE ' ' END AS washout
   ,t5.compound_incubation_hr as compound_incubation_hr
   ,t5.cell_incubation_hr as cell_incubation_hr
   ,nvl(t5.pct_serum, 2) || '%' as pct_serum
FROM
    ds3_userdata.SU_ANALYSIS_RESULTS T1
      INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
      INNER JOIN DS3_USERDATA.SU_SAMPLES T3 ON T3.ID = T2.SAMPLE_ID
      --INNER JOIN ds3_userdata.tm_experiments T4 ON t4.experiment_id = t2.experiment_id      
      INNER JOIN ds3_userdata.SU_PLATE_PROP_PIVOT t5 ON t2.experiment_id = t5.experiment_id AND T5.PLATE_SET = T2.PLATE_SET
      INNER JOIN ds3_userdata.tm_experiments_PROPS_PIVOT T6 ON t6.experiment_id = t5.experiment_id      
      --RIGHT OUTER JOIN ds3_userdata.su_sample_property_pivot t5 ON t2.experiment_id = t5.experiment_id AND t3.name = t5.batch_id AND t5.PROP1 = T2.SAMPLE_NUMBER
--      RIGHT OUTER JOIN ds3_userdata.tm_protocol_props_pivot t6 ON t4.experiment_id = t6.experiment_id
WHERE
--     t4.completed_date IS NOT NULL
--     AND (t4.deleted IS NULL OR t4.deleted = 'N')
     T3.DISPLAY_NAME != 'BLANK'
     AND t6.assay_intent = 'Screening'
     AND t1.STATUS = 1 -- VALIDATED
     AND t6.donor IS NULL
     AND t6.acceptor IS NULL
     AND (t6.three_d = 'N' OR t6.three_d IS NULL)
;    
    



select * from su_analysis_results T1
INNER JOIN DS3_USERDATA.SU_GROUPINGS            T2 ON T1.GROUP_ID = T2.ID
INNER JOIN ds3_userdata.TM_PES_FIELDS_VALUES    T3 ON T3.PROP1 = T2.SAMPLE_NUMBER
AND T3.EXPERIMENT_ID = t2.EXPERIMENT_ID
INNER JOIN ds3_userdata.su_sample_property_pivot t4 ON t2.experiment_id = t4.experiment_id AND t3.prop1 = t4.prop1;

select * from ds3_userdata.TM_PES_FIELDS_VALUES;
select * from DS3_USERDATA.SU_GROUPINGS;
select * from tm_conclusions;
select * from su_analysis_results;
select * from DS3_USERDATA.SU_SAMPLES;
select * from ds3_userdata.su_sample_property_pivot;
select * from ds3_userdata.tm_sample_property_pivot;
select * from ds3_userdata.tm_experiments;
select * from ds3_userdata.tm_protocol_props_pivot;
select * from su_sample_property_pivot;
select * from ds3_userdata.tm_experiments_PROPS_PIVOT;
select * from ds3_userdata.SU_PLATE_PROP_PIVOT ORDER BY EXPERIMENT_ID;

select distinct EXPERIMENT_ID from DS3_USERDATA.SU_GROUPINGS ORDER BY EXPERIMENT_ID;



select DISTINCT T4.EXPERIMENT_ID-- T1.ID, T1.LAYER_ID, T1.STATUS, T1.RULE_ID, T1.REPORTED_RESULT, T1.GROUP_ID, T2.ID, T3.ID, 
from su_analysis_results T1
INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
INNER JOIN DS3_USERDATA.SU_SAMPLES t3 ON t2.sample_id = t3.ID
INNER JOIN ds3_userdata.tm_experiments T4 ON t4.experiment_id = t2.experiment_id      
INNER JOIN ds3_userdata.SU_PLATE_PROP_PIVOT t5 ON t2.experiment_id = t5.experiment_id AND T5.PLATE_SET = T2.PLATE_SET
--INNER JOIN ds3_userdata.tm_protocol_props_pivot t6 ON t4.experiment_id = t6.experiment_id
;



--Final union'ed sql statement PIC50
SELECT
    t3.experiment_id as experiment_id
   ,t4.project as project
   ,substr(T1.ID, 1, 8) AS COMPOUND_ID
   ,CASE 
        WHEN substr(t1.result_alpha, 0, 1) = '>' THEN
            '<' || to_char(-log(10, to_number(substr(t1.result_alpha, 2, length(t1.result_alpha)))))
        WHEN substr(t1.result_alpha, 0, 1) = '<' THEN
           '>' || to_char(-log(10, to_number(substr(t1.result_alpha, 2, length(t1.result_alpha)))))
        ELSE to_char(-log(10, t1.result_numeric))
    END AS PIC50
   ,t4.cro AS CRO
   ,CASE t4.assay_type
       WHEN 'CellTiter-Glo' THEN 'CTG'
        ELSE t4.assay_type END AS ASSAY_TYPE
   ,NVL2(T5.CELL_VARIANT, TRIM(T5.cell_line) || ' ' || TRIM(T5.CELL_VARIANT), TRIM(t5.cell_line)) AS CELL_LINE
   ,CASE t5.washout
       WHEN 'Y' THEN 'wash'
       WHEN 'N' THEN 'no wash'
       ELSE ' ' END AS washout
   ,t5.compound_incubation_hr as compound_incubation_hr
   ,t5.cell_incubation_hr as cell_incubation_hr
   ,nvl(t5.pct_serum, 2) || '%' as pct_serum
FROM
    ds3_userdata.tm_conclusions t1
      INNER JOIN ds3_userdata.tm_experiments t3 ON t1.experiment_id = t3.experiment_id
      INNER JOIN ds3_userdata.tm_protocol_props_pivot t4 ON t1.experiment_id = t4.experiment_id
      INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND (t3.deleted IS NULL OR t3.deleted = 'N')
    AND T1.ID != 'BLANK'
    AND t4.assay_intent = 'Screening'
    AND t1.validated = 'VALIDATED'
    AND t4.donor IS NULL
    AND t4.acceptor IS NULL
    AND t4.threed = 'N'
UNION ALL
SELECT
    t2.experiment_id as experiment_id
   ,t6.project as project
   ,substr(T3.NAME, 1, 8) AS COMPOUND_ID
   ,CASE 
        WHEN substr(t1.reported_result, 0, 1) = '>' THEN
            '<' || to_char(-log(10, to_number(substr(t1.reported_result, 2, length(t1.reported_result)))))
        WHEN substr(t1.reported_result, 0, 1) = '<' THEN
           '>' || to_char(-log(10, to_number(substr(t1.reported_result, 2, length(t1.reported_result)))))
        ELSE to_char(-log(10, t1.result_numeric))
    END AS PIC50
   ,t6.cro AS CRO
   ,CASE t6.assay_type
       WHEN 'CellTiter-Glo' THEN 'CTG'
        ELSE t6.assay_type END AS ASSAY_TYPE
   ,NVL2(T5.CELL_VARIANT, TRIM(T5.cell_line) || ' ' || TRIM(T5.CELL_VARIANT), TRIM(t5.cell_line)) AS CELL_LINE
   ,CASE t5.washout
       WHEN 'Y' THEN 'wash'
       WHEN 'N' THEN 'no wash'
       ELSE ' ' END AS washout
   ,t5.compound_incubation_hr as compound_incubation_hr
   ,t5.cell_incubation_hr as cell_incubation_hr
   ,nvl(t5.pct_serum, 2) || '%' as pct_serum
FROM
    ds3_userdata.SU_ANALYSIS_RESULTS T1
      INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
      INNER JOIN DS3_USERDATA.SU_SAMPLES T3 ON T3.ID = T2.SAMPLE_ID
      INNER JOIN ds3_userdata.tm_experiments T4 ON t4.experiment_id = t2.experiment_id      
      INNER JOIN ds3_userdata.SU_PLATE_PROP_PIVOT t5 ON t2.experiment_id = t5.experiment_id AND T5.PLATE_SET = T2.PLATE_SET
      INNER JOIN ds3_userdata.tm_experiments_PROPS_PIVOT T6 ON t6.experiment_id = t4.experiment_id      
WHERE
     t4.completed_date IS NOT NULL
     AND (t4.deleted IS NULL OR t4.deleted = 'N')
     AND T3.DISPLAY_NAME != 'BLANK'
     AND t6.assay_intent = 'Screening'
     AND t1.STATUS = 1 -- VALIDATED
     AND t6.donor IS NULL
     AND t6.acceptor IS NULL
     AND (t6.three_d = 'N' OR t6.three_d IS NULL)