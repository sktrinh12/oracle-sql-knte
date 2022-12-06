
-- VIEW FOR COMPOUNDS
SELECT
    T1.REG_ID AS REG_ID
    ,T1.FORMATTED_ID AS COMPOUND_ID
    ,substr(T2.PROJECT_NAME, 0, 3) || lpad(to_char(T1.REG_ID), 6, '0') AS project_compound_id
    ,T2.PROJECT_NAME AS PROJECT
    ,t2.peyn_comment AS project_target
    ,T1.SMILES AS SMILES
    ,T1.STRUCTURE_NAME AS STRUCTURE_NAME
    ,T1.ADDITIONAL_COMMENTS AS STEREO_COMMENTS
    ,T1.CAS_NUMBER AS CAS_NUMBER
    ,T1.ALIAS AS ALIAS
    ,T1.REG_DATE AS REG_DATE
    ,T1.COMMENTS AS COMMENTS
  FROM
     C$PINPOINT.REG_DATA T1
     INNER JOIN C$PINPOINT.REG_PROJECTS T2 ON T1.PROJECT_ID = T2.ID -- 1-to-many where T1.PROJECT_ID has many
  WHERE
    T1.REG_ID>0 -- exclude salts
AND T2.PROJECT_NAME LIKE 'KIN-%'; -- KINNATE projects

-- TESTING SUBQURIES TO UNDERSTAND THEIR CONTENT
select substr(PROJECT_NAME,03) as test from C$PINPOINT.REG_PROJECTS;
select ID from C$PINPOINT.REG_PROJECTS;
select PROJECT_ID from C$PINPOINT.REG_DATA WHERE PROJECT_ID IS NOT NULL;
select count(DISTINCT FORMATTED_ID) from C$PINPOINT.REG_DATA WHERE FORMATTED_ID LIKE 'FT%';
select * from user_forms where project_id = 14000 and DS_IDS LIKE  '%-594%';

select DISTINCT FORMATTED_ID from C$PINPOINT.REG_DATA WHERE FORMATTED_ID LIKE 'FT%';
SELECT * FROM COMPOUND_VW;
SELECT * FROM KINASE_PANEL_VW;

select * from user_queries where project_id = 14000 and param_list LIKE  '%784%';
SELECT regexp_replace('~50 nM','[A-DF-Za-z\<\>~=]') FROM DS3_USERDATA.TM_CONCLUSIONS; -- table can be anything
SELECT DISTINCT RESULT_ALPHA FROM DS3_USERDATA.TM_CONCLUSIONS WHERE RESULT_ALPHA IS NOT NULL;

-- ENZYME INHIBITION DRC (DOSE RESPONSE CURVE) SQL STMT
SELECT
  to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID ,
  substr(T1.ID, 1, 8) AS COMPOUND_ID,
  T1.ID AS BATCH_ID ,
  T4.PROJECT AS PROJECT,
  T4.CRO AS CRO,
  T3.DESCR AS DESCR,
  t4.assay_type as assay_type,
  T4.ASSAY_INTENT AS ASSAY_INTENT,
  T1.ANALYSIS_NAME AS ANALYSIS_NAME,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) AS IC50 ,
-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC))) AS pIC50,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM,
  substr(T1.RESULT_ALPHA,1,1) AS MODIFIER,
  T1.VALIDATED AS VALIDATED,
  to_number(T1.PARAM1) AS MINIMUM,
  to_number(T1.PARAM2) AS MAXIMUM,
  to_number(T1.PARAM3) AS SLOPE,
  T1.PARAM6 AS R2,
  to_number(T1.ERR) AS ERR,
case
when t1.result_numeric >0 then power(10,(log(10,t1.result_numeric)-t1.result_delta))
else null
end as IC50_MIN_CONFIDENCE,
case
when (t1.result_numeric >0 and t1.result_delta <100) then power(10,(log(10,t1.result_numeric)+t1.result_delta))
else null
end as IC50_MAX_CONFIDENCE,
case
when t1.result_numeric >0 then -log(10, t1.result_numeric) - t1.result_delta
else null
end as PIC50_MIN_CONFIDENCE,
case
when (t1.result_numeric >0 and t1.result_delta <100) then -log(10, t1.result_numeric) + t1.result_delta
else null
end as PIC50_MAX_CONFIDENCE,
 -- T1.PASS_FAIL                               AS PASS_FAIL ,
  T2.FILE_BLOB                               AS GRAPH ,
t5.target as target,
t5.variant as variant,
t5.target || NVL2(t5.variant, ' ' || t5.variant, NULL) AS target_variant,
SUBSTR(
    NVL2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,3) AS cofactors,
t5.target || NVL2(SUBSTR(
    NVL2(t5.cofactor_1, ', /' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,3),SUBSTR(
    NVL2(t5.cofactor_1, ', /' || t5.cofactor_1, NULL)
        || NVL2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)
    ,3), null) AS target_cofactors,
T4.THIOL_FREE AS THIOL_FREE,
    nvl(T4.ATP_CONC_UM, t5.atp_conc_um) AS ATP_CONC_UM,
    t5.substrate_incubation_min as substrate_incubation_min,
t3.created_date as created_date,
  T3.ISID                                    AS SCIENTIST
FROM
  DS3_USERDATA.TM_CONCLUSIONS T1
  INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
  INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
  INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
  INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id AND t1.id = t5.batch_id AND t1.prop1 = t5.prop1
WHERE
  t3.completed_date IS NOT NULL
  AND t1.protocol_id = 181
AND (t3.deleted IS NULL OR t3.deleted = 'N')
ORDER BY
T1.ID, T5.TARGET, T5.VARIANT;


SELECT * FROM v$version;

DESCRIBE FT_KINASE_PANEL;

--SELECT DISTINCT EXPERIMENT_ID FROM (
SELECT * FROM (
    SELECT  REGEXP_SUBSTR (BATCH_ID, '[^-]+', 1, 1)    AS COMPD_ID,
            REGEXP_SUBSTR (BATCH_ID, '[^-]+', 1, 2)    AS BATCH_NUM,
            TECHNOLOGY,
            PCT_INHIBITION_AVG,
            EXPERIMENT_ID,
            VALIDATED,
            VALIDATION_COMMENT
            --KINASE,
            BATCH_ID,
            LOT_NUMBER,
            ORDER_NUMBER
            --ATP
    
    FROM    FT_KINASE_PANEL
) WHERE COMPD_ID = 'FT002787' AND EXPERIMENT_ID = '168345';
--);

-- get all experiment ids
SELECT DISTINCT EXPERIMENT_ID FROM (
SELECT * FROM (
    SELECT  REGEXP_SUBSTR (BATCH_ID, '[^-]+', 1, 1)    AS COMPD_ID,
            REGEXP_SUBSTR (BATCH_ID, '[^-]+', 1, 2)    AS BATCH_NUM,
            TECHNOLOGY,
            PCT_INHIBITION_AVG,
            EXPERIMENT_ID,
            VALIDATED,
            VALIDATION_COMMENT
            --KINASE,
            BATCH_ID,
            LOT_NUMBER,
            ORDER_NUMBER
            --ATP
    
    FROM    FT_KINASE_PANEL
    )
);


SELECT * FROM tm_prot_exp_fields_values WHERE experiment_id IN 
    ('187204', '186326','150088', '157624', '193104', '191324')
    AND PROPERTY_NAME = 'CRO';
    
    
SELECT * FROM FT_KINASE_PANEL WHERE BATCH_ID = 'FT000953-03' ORDER BY KINASE;


SELECT CONC FROM FT_KINASE_PANEL WHERE EXPERIMENT_ID = '187205' ORDER BY KINASE FETCH NEXT 1 ROWS ONLY;

SELECT DISTINCT TECHNOLOGY FROM FT_KINASE_PANEL WHERE EXPERIMENT_ID = '187205';


SELECT * FROM tm_prot_exp_fields_values WHERE experiment_id IN 
    ('195444');

SELECT * FROM tm_prot_exp_fields_values WHERE experiment_id = '195444' AND property_name = 'CRO';

SELECT * FROM FT_KINASE_PANEL WHERE EXPERIMENT_ID = '195444';

SELECT (case when count(*) > 20 then 1 else 0 end) as result FROM FT_KINASE_PANEL WHERE BATCH_ID LIKE 'FT002787' || '%';



select * from FT_PHARM_GROUP;

select * fount.protocol_target_list_vw where protocol_id = '441';