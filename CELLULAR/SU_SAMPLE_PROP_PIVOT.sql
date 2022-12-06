SELECT 
    max(to_char(a.EXPERIMENT_ID)) as EXPERIMENT_ID,
    --d.SAMPLE_ID AS batch_id,
    --d.PROP1,
    max(a.PLATE_SET) AS PLATE_SET,
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
--    INNER JOIN DS3_USERDATA.SU_SAMPLES d ON d.ID = .SAMPLE_ID
    
--WHERE
--    g.SAMPLE_ID != 'BLANK'
--group by 
--    d.EXPERIMENT_ID--, g.SAMPLE_ID--, g.PROP1
;


--CREATE TM_EXPERIMENTS_PROPS_PIVOT
SELECT * 
FROM
( SELECT T1.EXPERIMENT_ID, PROPERTY_TYPE,
T1.PROPERTY_NAME,
T1.PROPERTY_VALUE,
T1.PROTOCOL_ID
FROM DS3_USERDATA.TM_PROT_EXP_FIELDS_VALUES T1
WHERE T1.PROTOCOL_ID = 441
AND T1.PROPERTY_TYPE = 'SELECT'
)
pivot
( MAX(property_value) FOR property_name IN
(   
    'CRO' as CRO,
    'Assay Type' as ASSAY_TYPE,
    'Project' as PROJECT,
    'Assay Intent' as ASSAY_INTENT,
    'Donor' as DONOR,
    'Acceptor' as ACCEPTOR,
    '3D' as THREE_D
ß)
)
;

select * from tm_experiments_PROPS_PIVOT where experiment_id = '191027';


select distinct ID from SU_GROUPINGS;
select distinct ID from SU_PLATES;

select * from SU_GROUPINGS;
select * from SU_ANALYSIS_RESULTS;
select * from SU_PLATES;
select * from SU_SAMPLES;
select * from SU_PROPERTY_DICTIONARY;
select * from SU_PLATE_PROPERTIES;
select * from SU_WELL_SAMPLE_PROPERTIES;
select * from tm_experiments;


SELECT *
FROM
   ds3_userdata.SU_ANALYSIS_RESULTS T1
      INNER JOIN DS3_USERDATA.SU_GROUPINGS T2 ON T1.GROUP_ID = T2.ID
      INNER JOIN DS3_USERDATA.SU_SAMPLES T3 ON T3.ID = T2.SAMPLE_ID
      INNER JOIN ds3_userdata.tm_experiments T4 ON t4.experiment_id = t2.experiment_id
      INNER JOIN ds3_userdata.SU_WELL_SAMPLES T5 ON T5.SAMPLE_ID = T2.SAMPLE_ID AND T2.ID = T5.GROUP_ID
      INNER JOIN DS3_USERDATA.SU_WELL_SAMPLE_PROPERTIES T6 ON T6.WELL_SAMPLE_ID = T5.ID AND regexp_like(T6.PROPERTY_VALUE, 'FT')
      INNER JOIN ds3_userdata.SU_PROPERTY_DICTIONARY T7 ON T7.ID = T6.PROPERTY_DICT_ID
--      INNER JOIN ds3_userdata.SU_PLATE_PROPERTIES T8 ON T8.PROPERTY_DICT_ID = T7.ID
;


SELECT *
FROM
    ds3_userdata.SU_PLATES a 
    INNER JOIN ds3_userdata.SU_PLATE_PROPERTIES b ON b.PLATE_ID = a.ID
    INNER JOIN ds3_userdata.SU_PROPERTY_DICTIONARY c ON c.ID = b.PROPERTY_DICT_ID
--    INNER JOIN DS3_USERDATA.SU_WELL_SAMPLE_PROPERTIES d ON d.PROPERTY_DICT_ID = b.PROPERTY_DICT_ID
;

SELECT * 
FROM 
      ds3_userdata.SU_PROPERTY_DICTIONARY T7
      INNER JOIN ds3_userdata.SU_PLATE_PROPERTIES T8 ON T8.PROPERTY_DICT_ID = T7.ID
;