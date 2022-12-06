--select (case when count(*)>0 then 1 else 0 end) as result from ds3_appdata.browser_groups_users where ISID = -USER- and -USER- in ('BROOKE', 'MICHELLE.PEREZ');


-- check the delete the FT numbers due to wrong structures from CRO
select * from C$PINPOINT.reg_data where FORMATTED_ID = 'FT007890';
select * from C$PINPOINT.reg_data where FORMATTED_ID = 'FT007941';
select * from C$PINPOINT.reg_data where FORMATTED_ID = 'FT007947';
select * from C$PINPOINT.reg_data where FORMATTED_ID = 'FT007889';
select * from C$PINPOINT.reg_data where FORMATTED_ID = 'FT007891';

--CELLULAR GROWTH DRC
SELECT 
        to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID
	,substr(T1.ID, 1, 8) AS COMPOUND_ID
	,T1.ID AS BATCH_ID
	,T4.PROJECT AS PROJECT
	,T4.CRO AS CRO
	,T3.DESCR AS DESCR
	,T1.ANALYSIS_NAME AS ANALYSIS_NAME
	,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
        ,-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
       ,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*1000000000 AS IC50_NM
	,substr(T1.RESULT_ALPHA, 1, 1) AS MODIFIER
	,T1.VALIDATED AS VALIDATED
	,to_number(T1.PARAM1) AS MINIMUM
	,to_number(T1.PARAM2) AS MAXIMUM
	,to_number(T1.PARAM3) AS SLOPE
	,to_number(T1.PARAM6) AS R2
	,to_number(T1.ERR) AS ERR
	,T2.FILE_BLOB AS GRAPH
--      ,t6.paradox_score as paradox_score
	,t5.cell_line AS cell_line
        ,t5.cell_variant as variant
        ,t5.passage_number AS passage_number
	,nvl(T5.WASHOUT, 'N') AS WASHOUT
        ,NVL(T5.PCT_SERUM, 10) AS PCT_SERUM
	,T4.ASSAY_TYPE AS ASSAY_TYPE
        ,T4.ASSAY_INTENT AS ASSAY_INTENT
	,T4.THREED AS THREED
	,T5.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR
	,T5.CELL_INCUBATION_HR AS CELL_INCUBATION_HR
        ,T4.ASSAY_TYPE || ' ' || T5.CELL_INCUBATION_HR AS assay_cell_incubation
        ,t5.treatment as treatment
        ,t5.treatment_conc_um as treatment_conc_um
        ,t4.donor as donor
        ,t4.acceptor as acceptor
	,t3.created_date AS created_date
	,T3.ISID AS SCIENTIST
FROM 
    DS3_USERDATA.TM_EXPERIMENTS T3 
    INNER JOIN DS3_USERDATA.TM_CONCLUSIONS T1 ON T3.EXPERIMENT_ID = T1.EXPERIMENT_ID
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID
	                                                                         AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID
	                                                                         AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
	                                                                                      AND t1.id = t5.batch_id
	                                                                                      AND t1.prop1 = t5.prop1
    --LEFT OUTER JOIN ds3_userdata.ft_paradox t6 ON t1.experiment_id = t6.experiment_id 
    --                                                                           AND t1.id = t6.batch_id
    --	                                                                         AND t1.prop1 = t6.prop1
WHERE 
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND (
		t3.deleted IS NULL
		OR t3.deleted = 'N'
    )
ORDER BY
    T1.ID, 
    T5.CELL_LINE;
    
    
    
-- ENZYME INBH VW
SELECT
  to_char(T1.EXPERIMENT_ID)                                                           AS EXPERIMENT_ID ,
  substr(T1.ID, 1, 8)                                                                      AS COMPOUND_ID ,
  T1.ID                                                                      AS BATCH_ID ,
--  T1.PROTOCOL_ID                                                             AS PROTOCOL_ID ,
 T4.PROJECT                                  AS PROJECT,
T4.CRO AS CRO,
T3.DESCR AS DESCR,
t4.assay_type as assay_type,
T4.ASSAY_INTENT AS ASSAY_INTENT,
--  T1.ANALYSIS_ID                                                             AS ANALYSIS_ID ,
  T1.ANALYSIS_NAME                                                           AS ANALYSIS_NAME ,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) AS IC50 ,
-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC))) AS pIC50,
  to_number(NVL(regexp_replace(T1.RESULT_ALPHA,'[A-DF-Za-z\<\>~=]'),T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM ,
  substr(T1.RESULT_ALPHA,1,1) AS MODIFIER ,
  T1.VALIDATED                               AS VALIDATED ,
  to_number(T1.PARAM1)                                 AS MINIMUM ,
  to_number(T1.PARAM2)                                  AS MAXIMUM ,
  to_number(T1.PARAM3)                                  AS SLOPE ,
 -- to_number(T1.PARAM4)                                  AS PARAM4 ,
--  T1.PARAM5                                  AS IC50_2 ,
  T1.PARAM6                                  AS R2 ,
  to_number(T1.ERR)                                     AS ERR ,
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
t5.cofactor_1 as cofactor_1,
t5.cofactor_2 as cofactor_2,
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



select (case when count(*)>0 then 1 else 0 end) as result from ds3_appdata.browser_groups_users where ISID = '-USER-' and '-USER-' in ('BROOKE', 'MICHELLE.PEREZ', 'TESTADMIN');

select (case when count(*)>0 then 1 else 0 end) result 
from gateway.roles_nontp_personnel 
where ISID = '-USER-' and '-USER-' in ('BROOKE', 'MICHELLE.PEREZ', 'TESTADMIN');

select t1.ISID, t2.isid
from gateway.roles_nontp_personnel t1
FULL JOIN ds3_appdata.browser_groups_users t2 on t1.isid = t2.isid;


select * from gateway.roles_nontp_personnel ;--where PREF_NAME like 'test%';
select * from ds3_appdata.browser_groups_users;

