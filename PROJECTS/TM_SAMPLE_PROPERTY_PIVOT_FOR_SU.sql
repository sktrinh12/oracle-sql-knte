
select * from ds3_appdata.version_history;



SELECT 
    to_char(EXPERIMENT_ID) as EXPERIMENT_ID,
    SAMPLE_ID AS batch_id,
    PROP1,
    max(decode(PROPERTY_NAME, 'CONC',PROPERTY_VALUE)) CONC,
    max(decode(PROPERTY_NAME, 'BATCH',PROPERTY_VALUE)) BATCH,
    max(decode(PROPERTY_NAME, 'Cell Line',PROPERTY_VALUE)) AS CELL_LINE,
    max(decode(PROPERTY_NAME, 'Variant',PROPERTY_VALUE)) CELL_VARIANT,
    max(decode(PROPERTY_NAME, 'Passage Number',PROPERTY_VALUE)) PASSAGE_NUMBER,
    max(decode(PROPERTY_NAME, 'Target',PROPERTY_VALUE)) TARGET,
    max(decode(PROPERTY_NAME, 'Variant-1',PROPERTY_VALUE)) VARIANT,
    max(decode(PROPERTY_NAME, 'Cofactor-1',PROPERTY_VALUE)) AS COFACTOR_1,
    max(decode(PROPERTY_NAME, 'Cofactor-2',PROPERTY_VALUE)) COFACTOR_2,
    max(decode(PROPERTY_NAME, 'Washout',PROPERTY_VALUE)) WASHOUT,
    max(decode(PROPERTY_NAME, 'Compound Incubation (hr)',PROPERTY_VALUE)) COMPOUND_INCUBATION_HR,
    max(decode(PROPERTY_NAME, 'Cell Incubation (hr)',PROPERTY_VALUE)) CELL_INCUBATION_HR,
    max(decode(PROPERTY_NAME, 'ATP Conc (uM)',PROPERTY_VALUE)) ATP_CONC_UM,
    max(decode(PROPERTY_NAME, '% serum',PROPERTY_VALUE)) PCT_SERUM,
    max(decode(PROPERTY_NAME, 'Treatment',PROPERTY_VALUE)) TREATMENT,
    max(decode(PROPERTY_NAME, 'Treatment Conc (uM)',PROPERTY_VALUE)) TREATMENT_CONC_UM,
    max(decode(PROPERTY_NAME, 'Substrate Incubation (min)',PROPERTY_VALUE)) SUBSTRATE_INCUBATION_MIN
FROM
    ds3_userdata.TM_PES_FIELDS_VALUES 
WHERE
    sample_id != 'BLANK'
group by 
    EXPERIMENT_ID, PROTOCOL_ID, SAMPLE_ID,PROP1;



SELECT 
    to_char(a.EXPERIMENT_ID) as EXPERIMENT_ID,
    g.SAMPLE_ID AS batch_id, --SU_SAMPLES could be the NAME column
    g.PROP1, -- SU GROUPINGS has sample_NUMBER
    max(decode(c.PROPERTY_NAME, 'CONC',b.PROPERTY_VALUE)) CONC,
    max(decode(c.PROPERTY_NAME, 'BATCH',b.PROPERTY_VALUE)) BATCH,
    max(decode(c.PROPERTY_NAME, 'Cell Line',b.PROPERTY_VALUE)) AS CELL_LINE,
    max(decode(c.PROPERTY_NAME, 'Variant',b.PROPERTY_VALUE)) CELL_VARIANT,
    max(decode(c.PROPERTY_NAME, 'Passage Number',b.PROPERTY_VALUE)) PASSAGE_NUMBER,
    max(decode(c.PROPERTY_NAME, 'Target',b.PROPERTY_VALUE)) TARGET,
    max(decode(c.PROPERTY_NAME, 'Variant-1',b.PROPERTY_VALUE)) VARIANT,
    max(decode(c.PROPERTY_NAME, 'Cofactor-1',b.PROPERTY_VALUE)) AS COFACTOR_1,
    max(decode(c.PROPERTY_NAME, 'Cofactor-2',b.PROPERTY_VALUE)) COFACTOR_2,
    max(decode(c.PROPERTY_NAME, 'Washout',b.PROPERTY_VALUE)) WASHOUT,
    max(decode(c.PROPERTY_NAME, 'Compound Incubation (hr)',b.PROPERTY_VALUE)) COMPOUND_INCUBATION_HR,
    max(decode(c.PROPERTY_NAME, 'Cell Incubation (hr)',b.PROPERTY_VALUE)) CELL_INCUBATION_HR,
    max(decode(c.PROPERTY_NAME, 'ATP Conc (uM)',b.PROPERTY_VALUE)) ATP_CONC_UM,
    max(decode(c.PROPERTY_NAME, '% serum',b.PROPERTY_VALUE)) PCT_SERUM,
    max(decode(c.PROPERTY_NAME, 'Treatment',b.PROPERTY_VALUE)) TREATMENT,
    max(decode(c.PROPERTY_NAME, 'Treatment Conc (uM)',b.PROPERTY_VALUE)) TREATMENT_CONC_UM,
    max(decode(c.PROPERTY_NAME, 'Substrate Incubation (min)',b.PROPERTY_VALUE)) SUBSTRATE_INCUBATION_MIN
FROM
    ds3_userdata.SU_PLATES a 
    INNER JOIN ds3_userdata.SU_PLATE_PROPERTIES b ON b.PLATE_ID = a.ID
    INNER JOIN ds3_userdata.SU_PROPERTY_DICTIONARY c ON c.ID = b.PROPERTY_DICT_ID
    INNER JOIN ds3_userdata.SU_GROUPINGS d ON d.EXPERIMENT_ID = a.EXPERIMENT_ID
    INNER JOIN ds3_userdata.TM_PES_FIELDS_VALUES g on g.PROP1 = d.SAMPLE_NUMBER 
WHERE
    g.SAMPLE_ID != 'BLANK'
group by 
    a.EXPERIMENT_ID,g.SAMPLE_ID,g.PROP1;
  
  
  
  
  
  
     
SELECT * from SU_SAMPLE_PROPERTY_PIVOT;

select * from ds3_userdata.SU_WELLS;

select * from ds3_userdata.su_property_dictionary;

select * from ds3_userdata.su_plate_properties;
    
select * from ds3_userdata.su_samples; 

select * from ds3_userdata.su_groupings; -- where sample_id = 1125;  
    
select * from ds3_userdata.tm_experiments;

select * from ds3_userdata.TM_PES_FIELDS_VALUES ;
    
    
select * from ds3_userdata.su_plates;
select * from ds3_userdata.su_well_samples;


select * from su_property_dictionary b
INNER JOIN ds3_userdata.SU_GROUPINGS d ON d.PROPERTY_DICT_ID = b.PROPERTY_DICT_ID;

select a.EXPERIMENT_ID
       --,max(decode(c.PROPERTY_NAME, 'CONC',b.PROPERTY_VALUE)) CONC
from ds3_userdata.su_plates a
--INNER JOIN ds3_userdata.SU_PLATE_PROPERTIES b ON a.ID = b.PLATE_ID 
INNER JOIN ds3_userdata.SU_GROUPINGS d ON d.experiment_id = a.experiment_id
--INNER JOIN ds3_userdata.SU_SAMPLES e on e.ID = d.SAMPLE_ID
--INNER JOIN ds3_userdata.TM_EXPERIMENTS f on f.EXPERIMENT_ID = a.EXPERIMENT_ID
INNER JOIN ds3_userdata.su_well_samples h on h.GROUP_ID = d.id
INNER JOIN ds3_userdata.su_well_sample_properties i on i.well_sample_id = h.id
INNER JOIN ds3_userdata.su_property_dictionary j on i.property_dict_id = j.id
AND j.dictionary_type = 'Well Sample'
AND j.property_name IN (
    'Cell Line',
    'Target',
    'Passage Number',
    'Variant-1',
    'Cofactor-1',
    'Cofactor-2',
    'Washout',
    'Compound Incubation (hr)',
    'Cell Incubation (hr)',
    'ATP Conc (uM)',
    '% serum',
    'Treatment',
    'Treatment Conc (uM)',
    'Substrate Incubation (min)'
)
GROUP BY a.EXPERIMENT_ID;





SELECT *
FROM
(SELECT T1.EXPERIMENT_ID AS EXPERIMENT_ID ,
T1.PLATE_SET AS PLATE_SET ,
T2.PROPERTY_VALUE AS PROPERTY_VALUE ,
T3.PROPERTY_NAME AS PROPERTY_NAME
FROM DS3_USERDATA.SU_PLATES T1
JOIN DS3_USERDATA.SU_PLATE_PROPERTIES T2 ON T2.PLATE_ID = T1.ID
JOIN DS3_USERDATA.SU_PROPERTY_DICTIONARY T3 ON T2.PROPERTY_DICT_ID = T3.ID
)
pivot
( MAX(property_value) FOR property_name IN
( 'Variant' as VARIANT,
    'Cell Line' as CELL_LINE,
    'Target' as TARGET,
    'Passage Number' as PASSAGE_NUMBER,
    'Variant-1' AS VARIANT_1,
    'Cofactor-1' AS COFACTOR_1,
    'Cofactor-2' AS COFACTOR_2,
    'Washout' AS WASHOUT,
    'Compound Incubation (hr)' AS COMPOUND_INCUBATION_HR,
    'Cell Incubation (hr)' AS CELL_INCUBATION_HR,
    'ATP Conc (uM)' AS ATP_CONC_UM, 
    '% serum' AS PCT_SERUM,
    'Treatment' AS TREATMENT,
    'Treatment Conc (uM)' AS TREATMENT_CONC_UM,
    'Substrate Incubation (min)' AS SUBSTRATE_INCUBATION_MIN 
));




SELECT *
FROM
(
SELECT
t1.group_id AS group_id,
t3.property_name AS property_name,
case when row_number() over (partition by t1.group_id, t2.property_value order by 1) = 1 -- enumerates the rows and orders by ordinal (the first) in the table; when the row number == 1; then set the property_value to the t2.property_value
then t2.property_value end as property_value
FROM ds3_userdata.su_well_samples t1
JOIN ds3_userdata.su_well_sample_properties t2 on t2.well_sample_id = t1.id
JOIN ds3_userdata.su_property_dictionary t3 on t2.property_dict_id = t3.id
AND t3.dictionary_type = 'Well Sample'
AND t3.property_name IN (
    'Cell Line',
    'Target',
    'Passage Number',
    'Variant-1',
    'Cofactor-1',
    'Cofactor-2',
    'Washout',
    'Compound Incubation (hr)',
    'Cell Incubation (hr)',
    'ATP Conc (uM)',
    '% serum',
    'Treatment',
    'Treatment Conc (uM)',
    'Substrate Incubation (min)'
)
)
PIVOT(
listagg(property_value, ', ') within group (order by property_value)
FOR property_name IN(
    'Variant' as VARIANT,
    'Cell Line' as CELL_LINE,
    'Target' as TARGET,
    'Passage Number' as PASSAGE_NUMBER,
    'Variant-1' AS VARIANT_1,
    'Cofactor-1' AS COFACTOR_1,
    'Cofactor-2' AS COFACTOR_2,
    'Washout' AS WASHOUT,
    'Compound Incubation (hr)' AS COMPOUND_INCUBATION_HR,
    'Cell Incubation (hr)' AS CELL_INCUBATION_HR,
    'ATP Conc (uM)' AS ATP_CONC_UM, 
    '% serum' AS PCT_SERUM,
    'Treatment' AS TREATMENT,
    'Treatment Conc (uM)' AS TREATMENT_CONC_UM,
    'Substrate Incubation (min)' AS SUBSTRATE_INCUBATION_MIN 
    )
);


    
SELECT
    to_char(T1.EXPERIMENT_ID) AS EXPERIMENT_ID,
    substr(T1.ID, 1, 8) AS COMPOUND_ID,
    T1.ID AS BATCH_ID,
    T4.PROJECT AS PROJECT,
	T4.CRO AS CRO,
    T3.DESCR AS DESCR,
    t1.analysis_name     AS analysis_name,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
        ,-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
       ,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*TO_NUMBER('1.0e+09') AS IC50_NM,
	substr(T1.RESULT_ALPHA, 1, 1) AS MODIFIER,
    T1.VALIDATED AS VALIDATED,
    to_number(t1.param1) AS MINIMUM,
    to_number(t1.param2) AS MAXIMUM,
    to_number(t1.param3) AS SLOPE,
    to_number(t1.param6) AS R2,
    TO_NUMBER(t1.err)    AS err,
    t2.file_blob         AS GRAPH,
    t5.cell_line AS cell_line,
    t5.cell_variant as variant,
    t5.passage_number AS passage_number,
	nvl(T5.WASHOUT, 'N') AS WASHOUT,
    NVL(T5.PCT_SERUM, 10) AS PCT_SERUM,
	T4.ASSAY_TYPE AS ASSAY_TYPE,
    T4.ASSAY_INTENT AS ASSAY_INTENT,
	T4.THREED AS THREED,
	T5.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR,
	T5.CELL_INCUBATION_HR AS CELL_INCUBATION_HR,
    T4.ASSAY_TYPE || ' ' || T5.CELL_INCUBATION_HR AS assay_cell_incubation,
    t5.treatment as treatment,
    t5.treatment_conc_um as treatment_conc_um,
    t4.donor as donor,
    t4.acceptor as acceptor,
    t3.created_date      AS created_date,
    T3.ISID              AS SCIENTIST,
    NULL                 AS classification
FROM
    ds3_userdata.tm_conclusions t1
    LEFT JOIN ds3_userdata.tm_graphs      t2 
    ON t1.experiment_id = t2.experiment_id 
    AND t1.analysis_id = t2.analysis_id
    AND t1.id = t2.id
    AND t1.prc = t2.prc
    INNER JOIN ds3_userdata.tm_experiments t3
    ON t1.experiment_id = t3.experiment_id   
    INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 
    ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 
    ON t1.experiment_id = t5.experiment_id
    AND t1.id = t5.batch_id
    AND t1.prop1 = t5.prop1;
UNION ALL
SELECT
    t3.display_name    AS id,
    t4.protocol_id     AS protocol_id,
    t4.experiment_id   AS experiment_id,
    t6.analysis_id,
    t6.name            AS analysis_name,
    to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
        ,-log(10, to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
       ,to_number(NVL(regexp_replace(T1.RESULT_ALPHA, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*TO_NUMBER('1.0e+09') AS IC50_NM,
	substr(T1.RESULT_ALPHA, 1, 1) AS MODIFIER,    
    CASE t1.status
        WHEN 1 THEN
            'VALIDATED'
        WHEN 2 THEN
            'INVALIDATED'
        WHEN 3 THEN
            'PUBLISHED'
        ELSE
            'INVALIDATED'
    END                validated,
    t1.param1          AS MINIMUM,
    t1.param2          AS MAXIMUM,
    t1.param3          AS SLOPE,
    t1.R2              AS R2,
    TO_NUMBER(t1.err)  AS err,
    t7.data            AS GRAPH,
    t4.created_date    AS created_date,
    T4.ISID            AS SCIENTIST,
    t5.label           AS classification   
FROM
    ds3_userdata.su_analysis_results                t1
    INNER JOIN ds3_userdata.su_groupings            t2 
    ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3
    ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4
    ON t2.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.su_classification_rules t5
    ON t1.rule_id = t5.id
    INNER JOIN ds3_userdata.su_analysis_layers      t6
    ON t1.layer_id = t6.id
    INNER JOIN ds3_userdata.su_charts               t7
    ON t1.id = t7.result_id;
    
    
    





SELECT 
    to_char(EXPERIMENT_ID) as EXPERIMENT_ID,
    SAMPLE_ID AS batch_id,
    PROP1,
    max(( CASE PROPERTY_NAME
        WHEN 'CONC' THEN PROPERTY_VALUE
        ELSE NULL
      END )) AS CONC,
    max(( CASE PROPERTY_NAME 
        WHEN 'BATCH' THEN PROPERTY_VALUE
        ELSE NULL
      END )) AS BATCH,
    max(( CASE PROPERTY_NAME
        WHEN 'Cell Line' THEN PROPERTY_VALUE
        ELSE NULL
      END )) AS CELL_LINE,
    max(( CASE PROPERTY_NAME 
        WHEN 'Variant' THEN PROPERTY_VALUE
        ELSE NULL
      END )) AS CELL_VARIANT,
    max(( CASE PROPERTY_NAME 
        WHEN 'Passage Number' THEN PROPERTY_VALUE
        ELSE NULL
      END )) AS PASSAGE_NUMBER,
     max(( CASE PROPERTY_NAME 
        WHEN 'Target' THEN PROPERTY_VALUE
        ELSE NULL
       END )) AS TARGET,
     max(( CASE PROPERTY_NAME
        WHEN 'Variant-1' THEN PROPERTY_VALUE
        ELSE NULL
       END )) AS VARIANT,
     max(( CASE PROPERTY_NAME
        WHEN 'Cofactor-1' THEN PROPERTY_VALUE
        ELSE NULL
       END )) AS COFACTOR_1,
     max(( CASE PROPERTY_NAME
        WHEN 'Cofactor-2' THEN PROPERTY_VALUE
        ELSE NULL
       END )) AS COFACTOR_2,
     max(( CASE PROPERTY_NAME
        WHEN 'Washout' THEN PROPERTY_VALUE
        ELSE NULL
       END )) AS WASHOUT,
     max(( CASE PROPERTY_NAME
        WHEN 'Compound Incubation (hr) AS' THEN PROPERTY_VALUE
        ELSE NULL
       END )) COMPOUND_INCUBATION_HR,
     max(( CASE PROPERTY_NAME
        WHEN 'Cell Incubation (hr) AS' THEN PROPERTY_VALUE
        ELSE NULL
       END )) CELL_INCUBATION_HR,
     max(( CASE PROPERTY_NAME
        WHEN 'ATP Conc (uM) AS' THEN PROPERTY_VALUE
        ELSE NULL
       END )) ATP_CONC_UM,
     max(( CASE PROPERTY_NAME
        WHEN '% serum' THEN PROPERTY_VALUE
        ELSE NULL
       END )) AS PCT_SERUM,
     max(( CASE PROPERTY_NAME
        WHEN 'Treatment' THEN PROPERTY_VALUE    
        ELSE NULL
       END )) AS TREATMENT,
     max(( CASE PROPERTY_NAME
        WHEN 'Treatment Conc (uM)' THEN PROPERTY_VALUE  
        ELSE NULL
       END )) AS TREATMENT_CONC_UM,
     max(( CASE PROPERTY_NAME
        WHEN 'Substrate Incubation (min)' THEN PROPERTY_VALUE   
        ELSE NULL
       END )) AS SUBSTRATE_INCUBATION_MIN
FROM
    ds3_userdata.TM_PES_FIELDS_VALUES 
WHERE
    sample_id != 'BLANK'
group by 
    EXPERIMENT_ID, PROTOCOL_ID,SAMPLE_ID,PROP1;
    
    

--_TAB_NAME:Results View,
SELECT
r.smiles as SMILES,
     lpad(a.prc, 2, '0')       AS plate_NUMBER, 
     G.PLATE_NAME as PLATE,
     i.project,
     i.cro,
     i.quote_number,
      i.assay_type as assay_type,   
     substr(a.id,1,8)          AS compound_id,
a.id          AS batch_id,         
     substr(a.id,1,8)         AS structure,
     a.ANALYSIS_ID AS Analysis_ID,
     c.file_blob   AS graph,
     nvl(TO_CHAR(a.result_numeric,'9.99EEEE'),a.result_alpha) AS ic50,
round(-log(10, a.result_numeric), 2) as pic50, 
     TO_CHAR(a.param3,'FM9999999990.0') AS slope,
     TO_CHAR(a.param1,'FM9999999990.0') AS min,
     TO_CHAR(a.param2,'FM9999999990.0') AS max,
     TO_CHAR(a.param6,'FM9999999990.099') AS r2,
j.paradox_score,
     nvl(e.properties,'no constraint') AS curve_constraint,
     h.cell_line AS cell_line,
     h.cell_variant as variant,
     h.washout as washout,
     h.compound_incubation_hr,
     h.cell_incubation_hr,
     d.stock_phrase
     || ':'
     || d.comments AS comments
 FROM
     ds3_userdata.tm_conclusions a
INNER JOIN c$pinpoint.reg_data r ON substr(a.id,1,8) = r.formatted_id
     INNER JOIN (
         SELECT
             MIN(prop1) AS prop1,
             sample_id,
             experiment_id,
             unique_plate_id
         FROM
             ds3_userdata.tm_samples
         WHERE
             samptype = 'S'
         GROUP BY
             sample_id,
             experiment_id,
             unique_plate_id
     ) b ON a.experiment_id = b.experiment_id
            AND a.id = b.sample_id
     LEFT OUTER JOIN ds3_userdata.tm_graphs c ON a.id = c.id
                                                 AND a.experiment_id = c.experiment_id
                                                 AND a.analysis_id = c.analysis_id
                                                 AND a.prc = c.prc
     LEFT OUTER JOIN ds3_userdata.tm_comments d ON a.experiment_id = d.experiment_id
                                                   AND a.analysis_id = d.analysis_id
                                                   AND a.id = d.sample_id
                                                   AND a.prop1 = d.prop1
     LEFT OUTER JOIN (select experiment_id, analysis_id, sample_id, prc, properties from ds3_userdata.tm_sample_analysis_props group by experiment_id, analysis_id, sample_id, prc, properties) e ON a.experiment_id = e.experiment_id
                                                                AND a.analysis_id = e.analysis_id
                                                                AND a.id = e.sample_id
                                                                AND a.prc = e.prc
     LEFT OUTER JOIN ds3_userdata.tm_storage_plate f ON b.unique_plate_id = f.unique_plate_id
     LEFT OUTER JOIN ds3_userdata.TM_STORAGE_PLATE G ON f.unique_plate_id = g.unique_plate_id
     LEFT OUTER JOIN ds3_userdata.tm_sample_property_pivot h ON a.experiment_id = h.experiment_id AND a.id = h.batch_id AND a.prop1 = h.prop1
     LEFT OUTER JOIN ds3_userdata.tm_protocol_props_pivot i ON a.experiment_id = i.experiment_id
LEFT OUTER JOIN ds3_userdata.ft_paradox j on a.experiment_id = j.experiment_id AND a.id = j.batch_id AND a.prop1 = j.prop1
 WHERE
     a.experiment_id = '196865' -- -EXPERIMENT_ID-
 ORDER BY
     lpad(a.prc, 2, '0'),
     b.prop1,
     a.analysis_name;
     

SELECT
             MIN(prop1) AS prop1,
             sample_id,
             experiment_id,
             unique_plate_id
         FROM
             ds3_userdata.tm_samples
         WHERE
             samptype = 'S'
         GROUP BY
             sample_id,
             experiment_id,
             unique_plate_id;
     
select prop1, sample_id, experiment_id from ds3_userdata.tm_samples;
---SQLSEP-
--_TAB_NAME:Compound List,


SELECT
    distinct substr(a.id,1,8)          AS compound_id
FROM
    ds3_userdata.tm_conclusions a
WHERE
     a.experiment_id = '196865' -- -EXPERIMENT_ID-
ORDER BY
    substr(a.id,1,8);





--WORKING EXAMPLE
SELECT
    t3.display_name    AS id,
    t4.protocol_id     AS protocol_id,
    t4.experiment_id   AS experiment_id,
    t6.analysis_id,
    t6.name            AS analysis_name,
    to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC)) AS IC50
        ,-log(10, to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))) AS pIC50
       ,to_number(NVL(regexp_replace(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~=]'), T1.RESULT_NUMERIC))*TO_NUMBER('1.0e+09') AS IC50_NM,
	substr(T1.REPORTED_RESULT, 1, 1) AS MODIFIER,    
    CASE t1.status
        WHEN 1 THEN
            'VALIDATED'
        WHEN 2 THEN
            'INVALIDATED'
        WHEN 3 THEN
            'PUBLISHED'
        ELSE
            'INVALIDATED'
    END                validated,
    t1.param1          AS MINIMUM,
    t1.param2          AS MAXIMUM,
    t1.param3          AS SLOPE,
    t1.R2              AS R2,
    TO_NUMBER(t1.err)  AS err,
    t7.data            AS GRAPH,
    
    t9.cell_line AS cell_line,
    t9.cell_variant as variant,
    t9.passage_number AS passage_number,
	nvl(T9.WASHOUT, 'N') AS WASHOUT,
    NVL(T9.PCT_SERUM, 10) AS PCT_SERUM,
	T8.ASSAY_TYPE AS ASSAY_TYPE,
    T8.ASSAY_INTENT AS ASSAY_INTENT,
	T8.THREED AS THREED,
	T9.COMPOUND_INCUBATION_HR AS COMPOUND_INCUBATION_HR,
	T9.CELL_INCUBATION_HR AS CELL_INCUBATION_HR,
    T8.ASSAY_TYPE || ' ' || T9.CELL_INCUBATION_HR AS assay_cell_incubation,
    t9.treatment as treatment,
    t9.treatment_conc_um as treatment_conc_um,
    t8.donor as donor,
    t8.acceptor as acceptor,
    
    t4.created_date    AS created_date,
    T4.ISID            AS SCIENTIST,
    t5.label           AS classification   
FROM
    ds3_userdata.su_analysis_results                t1
    INNER JOIN ds3_userdata.su_groupings            t2 
    ON t1.group_id = t2.id
    INNER JOIN ds3_userdata.su_samples              t3
    ON t2.sample_id = t3.id
    INNER JOIN ds3_userdata.tm_experiments          t4
    ON t2.experiment_id = t4.experiment_id
    INNER JOIN ds3_userdata.su_classification_rules t5
    ON t1.rule_id = t5.id
    INNER JOIN ds3_userdata.su_analysis_layers      t6
    ON t1.layer_id = t6.id
    INNER JOIN ds3_userdata.su_charts               t7
    ON t1.id = t7.result_id
    INNER JOIN ds3_userdata.TM_PROTOCOL_PROPS_PIVOT t8
    ON t8.experiment_id = t2.experiment_id
    INNER JOIN ds3_userdata.SU_SAMPLE_PROPERTY_PIVOT t9
    ON t9.experiment_id = t2.experiment_id  
WHERE --t4.completed_date IS NOT NULL
    t3.display_name != 'BLANK'
    --AND 
    --t4.protocol_id = 201
    AND (
		t4.deleted IS NULL
		OR t4.deleted = 'N'
    )
ORDER BY
    T3.DISPLAY_NAME, 
    T9.CELL_LINE;



   
SELECT * from ds3_userdata.tm_conclusions;
SELECT * from ds3_userdata.su_analysis_results;
SELECT * from ds3_userdata.su_charts; 
SELECT * from ds3_userdata.su_samples; 
SELECT * FROM ds3_userdata.tm_graphs;
SELECT * FROM ds3_userdata.tm_experiments WHERE protocol_id= '201';
SELECT * FROM ds3_userdata.su_analysis_layers;
SELECT * FROM ds3_userdata.TM_PROTOCOL_PROPS_PIVOT;
SELECT * FROM ds3_userdata.TM_PROT_EXP_FIELDS_VALUES;
select * from ds3_userdata.su_property_dictionary where dictionary_type = 'Well Sample';
SELECT * from SU_SAMPLE_PROPERTY_PIVOT;
SELECT * from TM_SAMPLE_PROPERTY_PIVOT;

select 
to_char(EXPERIMENT_ID) as EXPERIMENT_ID,
max(decode(PROPERTY_NAME, 'Species',PROPERTY_VALUE)) SPECIES,
max(decode(PROPERTY_NAME, 'CRO',PROPERTY_VALUE)) CRO,
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


SELECT *
FROM
    (SELECT 
        T1.EXPERIMENT_ID AS EXPERIMENT_ID ,
        T1.PLATE_SET AS PLATE_SET ,
        T2.PROPERTY_VALUE AS PROPERTY_VALUE ,
        T3.PROPERTY_NAME AS PROPERTY_NAME
     FROM DS3_USERDATA.SU_PLATES T1
        JOIN DS3_USERDATA.SU_PLATE_PROPERTIES T2 ON T2.PLATE_ID = T1.ID
        JOIN DS3_USERDATA.SU_PROPERTY_DICTIONARY T3 ON T2.PROPERTY_DICT_ID = T3.ID
    )
PIVOT
    (MAX(property_value) FOR property_name IN
        ('ATP Conc (uM)' as ATP_CONC_UM,
          'Target' as TARGET,
          'Variant-1' as VARIANT_1,
          'Cofactors' AS COFACTORS
        )
    );