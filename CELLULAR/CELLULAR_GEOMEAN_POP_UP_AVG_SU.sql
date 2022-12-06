SELECT
    t1.batch_id AS BATCH_ID,
    t1.graph AS GRAPH,
    t1.modifier || to_char(round((t1.IC50 * 1000000000), 2), '99990.99') AS IC50_nm, 
    'Min: ' || to_char(round(t1.minimum, 1), '990.9')  || '<br />' ||
	'Max: ' || to_char(round(t1.maximum, 1), '990.9') || '<br />' ||
	'Slope: ' || to_char(round(t1.slope, 1), '90.0') || '<br />' ||
	'R2: ' || to_char(round(t1.r2, 2), '0.09') || '<br />' ||
	'Err: ' || to_char(round(t1.err, 1), '9990.9') AS STATS,
    'CRO: ' || t1.CRO || '<br />' ||
    'Assay Type: ' || t1.ASSAY_TYPE || '<br />' ||
    'Cell Line: ' || t1.CELL_LINE || '<br />' ||
    'Variant: ' || t1.VARIANT || '<br />' ||
    'Inc(hr): ' || t1.CELL_INCUBATION_HR || '<br />' ||
    '% serum: ' || t1.PCT_SERUM || chr(10) AS PROPERTIES
FROM
    ds3_userdata.SU_cellular_growth_drc t1
WHERE
    experiment_id = 199764
    
;
 