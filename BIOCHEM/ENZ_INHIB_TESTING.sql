
EXPLAIN PLAN FOR
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


CREATE INDEX TM_PROT_EXP_FIELDS_VALUES_EXPERIMENT_ID_I ON TM_PROT_EXP_FIELDS_VALUES(EXPERIMENT_ID); 
CREATE INDEX TM_PROT_EXP_FIELDS_VALUES_PROTOCOL_ID_I ON TM_PROT_EXP_FIELDS_VALUES(PROTOCOL_ID);


EXPLAIN PLAN FOR
  select 
to_char(EXPERIMENT_ID) as EXPERIMENT_ID,

max(decode(PROPERTY_NAME, 'Species',PROPERTY_VALUE)) SPECIES,
max(decode(PROPERTY_NAME, 'CRO',PROPERTY_VALUE)) CRO,
max(decode(PROPERTY_NAME, 'Day 0 normalization',PROPERTY_VALUE)) DAY_0_NORM,
max(decode(PROPERTY_NAME, 'Project',PROPERTY_VALUE)) AS PROJECT,
max(decode(PROPERTY_NAME, 'PO/Quote Number',PROPERTY_VALUE)) AS QUOTE_NUMBER,
max(decode(PROPERTY_NAME, 'Assay Type',PROPERTY_VALUE)) AS ASSAY_TYPE,
max(decode(PROPERTY_NAME, 'Assay Intent',PROPERTY_VALUE)) AS ASSAY_INTENT,
max(decode(PROPERTY_NAME, 'Thiol-free',PROPERTY_VALUE)) AS THIOL_FREE,
max(decode(PROPERTY_NAME, 'ATP Conc (uM)',PROPERTY_VALUE)) AS ATP_CONC_UM,
max(decode(PROPERTY_NAME, '3D',PROPERTY_VALUE)) AS THREED,
max(decode(PROPERTY_NAME, 'Donor',PROPERTY_VALUE)) AS DONOR,
max(decode(PROPERTY_NAME, 'Acceptor',PROPERTY_VALUE)) AS ACCEPTOR,
max(decode(PROPERTY_NAME, 'Batch ID',PROPERTY_VALUE)) AS BATCH_ID
from TM_PROT_EXP_FIELDS_VALUES group by EXPERIMENT_ID, PROTOCOL_ID;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());



-- profiling on rendering and backend (ask DM for access?)
-- can views be converted to tables?
-- oracle configuration in optimal way? (too much cache can perform poorly)
-- log every query DBA audit rail


--drop sequence COPY_ENZYME_INHIBITION_VW_PID_SEQ;
create sequence COPY_ENZYME_INHIBITION_VW_PID_SEQ INCREMENT BY 1 START WITH 1 MINVALUE 1 MAXVALUE 1000000 CYCLE CACHE 2; 
--create trigger COPY_ENZYME_INHIBITION_VW_TRIGGER
--before insert on COPY_ENZYME_INHIBITION_VW
CREATE TRIGGER COPY_ENZYME_INHIBITION_VW_PID_TRIGGER
  BEFORE INSERT ON COPY_ENZYME_INHIBITION_VW
  FOR EACH ROW
BEGIN
  :new.PID := 'BIO' || to_char(EXTRACT(YEAR FROM q.created_date)) || '-' || COPY_ENZYME_INHIBITION_VW_PID_SEQ.nextval;
END;

--populated PID column after adding PID to the table
--UPDATE COPY_ENZYME_INHIBITION_VW
--   SET PID = COPY_ENZYME_INHIBITION_VW_SEQ.nextval;


--CREATE TABLE DS3_USERDATA.COPY_ENZYME_INHIBITION_VW AS (
--SElECT * FROM DS3_USERDATA.ENZYME_INHIBITION_VW );


