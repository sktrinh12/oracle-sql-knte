select ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET, 
          IC50 ,
          LOG(10, ic50),
          POWER(10, AVG(LOG(10, ic50)) OVER(PARTITION BY
          CRO,
          ASSAY_TYPE, 
          COMPOUND_ID, 
          BATCH_ID,  
          TARGET,  
          VARIANT, 
          COFACTORS,  
          ATP_CONC_UM, 
          MODIFIER )
          ) * TO_NUMBER('1e9') as geomean
FROM DS3_USERDATA.ENZYME_INHIBITION_VW
WHERE COMPOUND_ID = 'FT007578' AND TARGET = 'AurB';



select * from FT_BIOCHEM_DRC_STATS;

select * from enzyme_inhibition_vw;

select * from ds3_userdata.tm_pes_fields_values where property_name like '%ofactor%';

select * from cellular_growth_drc; 


--- check the cellular_growth_drc
SELECT
    to_char(t1.experiment_id)                                                                                  AS experiment_id,
    substr(t1.id, 1, 8)                                                                                        AS compound_id,
    t1.id                                                                                                      AS batch_id,
    t4.project                                                                                                 AS project,
    t4.cro                                                                                                     AS cro,
    t3.descr                                                                                                   AS descr,
    t1.analysis_name                                                                                           AS analysis_name,
    to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric))                    AS ic50,
    -- if in regex_replace replacement_string parameter is omitted, the function simply removes all matched patterns, and returns the resulting string.
    -- nvl will just return the result_numeric if the resulting regexp_replace generates a NULL
    - log(10, to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)))         AS pic50,
    to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * to_number('1e9') AS ic50_nm,
    substr(t1.result_alpha, 1, 1)                                                                              AS modifier,
    t1.validated                                                                                               AS validated,
    to_number(t1.param1)                                                                                       AS minimum,
    to_number(t1.param2)                                                                                       AS maximum,
    to_number(t1.param3)                                                                                       AS slope,
    to_number(t1.param6)                                                                                       AS r2,
    to_number(t1.err)                                                                                          AS err,
    t2.file_blob                                                                                               AS graph,
    t5.target                                                                                                  AS target,
    t5.cell_variant                                                                                            AS variant,
    t5.cofactor_1                                                                                              AS cofactor_1,
    t5.cofactor_2                                                                                              AS cofacto_2,
    t5.atp_conc_um                                                                                             AS atp_conc_um,
--    t5.passage_number                                                                                          AS passage_number,
--    nvl(t5.washout, 'N')                                                                                       AS washout,
--    nvl(t5.pct_serum, 10)                                                                                      AS pct_serum,
    t4.assay_type                                                                                              AS assay_type,
    t4.assay_intent                                                                                            AS assay_intent,
--    t4.threed                                                                                                  AS threed,
--    t5.compound_incubation_hr                                                                                  AS compound_incubation_hr,
--    t5.cell_incubation_hr                                                                                      AS cell_incubation_hr,
    t4.assay_type
    || ' '
    || t5.target                                                                                               AS assay_target,
--    t5.treatment                                                                                               AS treatment,
--    t5.treatment_conc_um                                                                                       AS treatment_conc_um,
--    t4.donor                                                                                                   AS donor,
--    t4.acceptor                                                                                                AS acceptor,
    t3.created_date                                                                                            AS created_date,
    t3.isid                                                                                                    AS scientist
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
    AND t1.protocol_id = 181
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
ORDER BY
    t1.id,
    t5.cell_line;
    
Select * from ds3_userdata.tm_conclusions where PROTOCOL_ID = '101'; 
--181 = ic50_enz, 201 = ic50_cell_cell_float, 101=IC50

Select distinct protocol_id from ds3_userdata.tm_conclusions;

Select * from ds3_userdata.tm_sample_property_pivot;

select 
				ID,
				PROTOCOL_ID,
				EXPERIMENT_ID,
				ANALYSIS_ID,
				ANALYSIS_NAME,
				RESULT_NUMERIC,
				RESULT_ALPHA,
			--	CREATION_DATE,
				CONC,
			--	VALIDATED,
			--	PARAM1,
			--	PARAM2,
			--	PARAM3,
			--	PARAM4,
			--	PARAM5,
			--	PARAM6,
			--	ERR,
			--	PARAM_OTHER,
			--	PASS_FAIL,
			--	PRE_CALC,
			--	PRC,
			--	RID,
			--	PID,
			--	PROP1,
				RESULT_DELTA,
				to_number(nvl(regexp_replace(result_alpha, '[A-DF-Za-z\<\>~=]'), result_numeric))                    
        AS ic50 from tm_conclusions;

SELECT column_name
  FROM all_tab_cols
 WHERE table_name = 'TM_CONCLUSIONS';




select  SUBSTR(NVL2(cofactor_1, ', ' || cofactor_1, NULL)
    || NVL2(cofactor_2, ', ' || cofactor_2, NULL)
    , 3) from ds3_userdata.enzyme_inhibition_vw where compound_id = 'FT004201' AND target = 'CDK7';


SELECT t1.batch_id AS batch_id, t1.graph AS graph, t1.ic50_nm AS ic50_nm, t2.geo_nm AS geo_nm, '-3 stdev: ' || round(t2.nm_minus_3_stdev, 1) || '
' || '+3 stdev: ' || round(t2.nm_plus_3_stdev, 1) || '
' || 'n of m: ' || t2.n_of_m AS agg_stats, 'CRO: ' || t1.cro || '
' || 'Assay Type: ' || t1.assay_type || '
' || 'Target: ' || t1.target || '
' || 'Variant: ' || t1.variant || '
' || 'cofactor-1: ' || t1.cofactor_1 || '
' || 'cofactor-2: ' || t1.cofactor_2 || 'atp_conc_um: ' || t2.atp_conc_um || CHR(10) AS properties FROM ( SELECT substr(t1.id, 0, 8) AS compound_id, t1.id AS batch_id, nvl(t1.result_alpha, to_char(round((t1.result_numeric * 1000000000), 2))) AS ic50_nm, t2.file_blob AS graph, t4.cro, t5.assay_type, target, variant, cofactor_1, cofactor_2, atp_conc_um, t1.prop1 FROM ds3_userdata.tm_conclusions t1 INNER JOIN ds3_userdata.tm_graphs t2 ON t1.experiment_id = t2.experiment_id AND t1.id = t2.id AND t1.prop1 = t2.prop1 INNER JOIN ( SELECT experiment_id, sample_id, prop1, MAX(decode(property_name, 'Target', property_value)) AS target, nvl(MAX(decode(property_name, 'Variant', property_value)), '-') AS variant, MAX(decode(property_name, 'Cofactor-1', property_value)) AS cofactor_1, MAX(decode(property_name, 'Cofactor-2', property_value)) AS cofactor_2, MAX(decode(property_name, 'ATP Conc (uM)', property_value)) AS atp_conc_um FROM ds3_userdata.tm_pes_fields_values WHERE experiment_id = '195386' AND sample_id != 'BLANK' GROUP BY experiment_id, sample_id, prop1 ) t3 ON t1.experiment_id = t3.experiment_id AND t1.id = t3.sample_id AND t1.prop1 = t3.prop1 INNER JOIN ( SELECT experiment_id, property_value AS cro FROM ds3_userdata.tm_prot_exp_fields_values WHERE experiment_id = '195386' AND property_name = 'CRO' ) t4 ON t1.experiment_id = t4.experiment_id INNER JOIN ( SELECT experiment_id, property_value AS assay_type FROM ds3_userdata.tm_prot_exp_fields_values WHERE experiment_id = '195386' AND property_name = 'Assay Type' ) t5 ON t1.experiment_id = t5.experiment_id WHERE t1.experiment_id = '195386' ) t1 LEFT OUTER JOIN ds3_userdata.ft_biochem_drc_stats t2 ON t1.compound_id = t2.compound_id AND t1.cro = t2.cro AND t1.assay_type = t2.assay_type AND t1.target = t2.target AND t1.variant = t2.variant AND t1.atp_conc_um = t2.atp_conc_um ORDER BY t1.batch_id, t1.prop1;
