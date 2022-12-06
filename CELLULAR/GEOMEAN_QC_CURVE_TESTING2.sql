   
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
                        experiment_id = '206264'
                    AND sample_id != 'BLANK'
                     GROUP BY
                    experiment_id,
                    sample_id,
                    prop1;
   
   SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS inc_hr,
                    pct_serum AS pct_serum
                FROM
                    su_plate_prop_pivot
                    
            WHERE        experiment_id = '207124'
            ;
            
 select distinct SUBSTR(NAME, 1,8) from            
ds3_userdata.su_groupings   t2   
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            where experiment_id = 207124 and SUBSTR(NAME, 1,2) = 'FT';
            
        select * from ds3_userdata.su_cellular_drc_stats where COMPOUND_ID IN (
        'FT002787',
        'FT001255',
        'FT000949',
        'FT008465',
        'FT008409',
        'FT000958',
        'FT002386',
        'FT000953'
    )
    AND CELL IN (
    'NCI-H1975',
    'HCC827',
    'NCI-H1975',
    'PC-9',
    'HCC827'
)
AND INC_HR = 120 AND PCT_SERUM = 10
;




SELECT
  to_char(T1.EXPERIMENT_ID)                                                           AS EXPERIMENT_ID ,
  substr(T1.ID, 1, 8)                                                                      AS COMPOUND_ID ,
  T1.ID                                                                      AS BATCH_ID ,
 T4.PROJECT                                  AS PROJECT,
T4.CRO AS CRO,
  T1.ANALYSIS_NAME                                                           AS ANALYSIS_NAME ,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),to_number(TO_CHAR(t1.result_numeric,'9.99EEEE')))) AS IC50 ,
  substr(T1.RESULT_ALPHA,1,1) AS MODIFIER ,
  T1.VALIDATED                               AS VALIDATED ,
  to_number(TO_CHAR(t1.param1,'FM9999999990.0'))                                 AS MINIMUM ,
  to_number(TO_CHAR(t1.param2,'FM9999999990.0'))                                  AS MAXIMUM ,
  to_number(TO_CHAR(t1.param3,'FM9999999990.0'))                                  AS SLOPE ,

  to_number(TO_CHAR(t1.param6,'FM9999999990.099'))                                  AS R2 ,
  to_number(T1.ERR)                                     AS ERR ,
 
  T2.FILE_BLOB                               AS GRAPH ,
t5.target || ' ' || t5.variant as target,
SUBSTR(
    NVL2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,2) AS cofactors,
T5.WASHOUT AS WASHOUT,
  T3.ISID                                    AS SCIENTIST
FROM
  DS3_USERDATA.TM_CONCLUSIONS T1
  INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
  INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
  INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
  INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
  t3.completed_date IS NOT NULL
  AND (t1.protocol_id = 181 OR t1.protocol_id = 201)
AND (t3.deleted IS NULL OR t3.deleted = 'N')
;