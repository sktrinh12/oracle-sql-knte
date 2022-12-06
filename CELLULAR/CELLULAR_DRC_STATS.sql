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
    T5.CELL_LINE