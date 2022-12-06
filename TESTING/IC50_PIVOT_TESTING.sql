SELECT * FROM (
SELECT
    t3.experiment_id as experiment_id
   ,t4.project as project
   ,substr(T1.ID, 1, 8) AS COMPOUND_ID
   ,nvl2(t1.result_alpha, t1.result_alpha, to_char(t1.result_numeric)) AS IC50
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
   ,nvl(t5.pct_serum, 10) || '%' as pct_serum
   ,nvl(T4.DAY_0_NORMALIZATION, 'N') as day_0_normalization
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

) 
pivot
(
    MAX(IC50) AS MEAN_IC50--, MEDIAN(IC50) AS MEDIAN_IC50
    FOR CELL_LINE IN (
        'NCI-H85', 'RWPE-1',
        'CAL12T',
        'CHL1',
        'RT4',
        'COLO 205-vem',
        'VCaP',
        'CHL-1',
        'KG-1',
        'NCI-H1838',
        'CC-LP-1-FP L618V',
        'ZR-75-1',
        'NCI-H1373',
        'CC-LP-1-FP K642R',
        'EBC-1',
        'ICC13-7 N550K',
        'B-CPAP'
    )
)
;

SELECT DISTINCT 
NVL2(T5.CELL_VARIANT, TRIM(T5.cell_line) || ' ' || TRIM(T5.CELL_VARIANT), TRIM(t5.cell_line)) AS CELL_LINE
FROM ds3_userdata.tm_sample_property_pivot t5
;
