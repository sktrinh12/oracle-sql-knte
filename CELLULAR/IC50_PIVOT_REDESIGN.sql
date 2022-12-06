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
--    cell_line,
--    count(cell_line)
--    assay_type,
--    count(assay_type)
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
    AND t4.threed = 'N';
--GROUP BY ASSAY_TYPE




SELECT 
        t1.compound_id,
        t1.CELL_LINE, 
        t1.ASSAY_TYPE,
        t1.PROJECT,
        T1.CRO,
        T1.COMPOUND_INCUBATION_HR,
        T1.WASHOUT,
        T1.CELL_INCUBATION_HR,
        T1.PCT_SERUM,
        T1.DAY_0_NORMALIZATION,
        CASE WHEN max(t1.PREFIX) = '>' OR max(t1.PREFIX) = '<'
            THEN TO_CHAR(MAX(TO_NUMBER(TRIM(regexp_replace(t1.ic50, '[><]+', '')))), '99999.999EEEE')
            ELSE TO_CHAR(AVG(TRIM(regexp_replace(t1.ic50, '[^0-9.]+', ''))), '99999.999EEEE')
        END AS AVG_IC50,
        CASE WHEN max(t1.PREFIX) = '>' OR max(t1.PREFIX) = '<'
        THEN TO_CHAR(MAX(TO_NUMBER(TRIM(regexp_replace(t1.ic50, '[><]+', '')))), '99999.999EEEE')
            ELSE TO_CHAR(EXP(AVG(LN(TRIM(regexp_replace(t1.ic50, '[^0-9.]+', ''))))), '99999.999EEEE')
        END AS GMEAN_IC50,
        CASE WHEN max(t1.PREFIX) = '>'
        THEN 1 ELSE 0 
        END AS MODIFIER_PREFIX
FROM (
SELECT
    t3.experiment_id as experiment_id
   ,t4.project as project
   ,substr(T1.ID, 1, 8) AS COMPOUND_ID
   ,nvl2(t1.result_alpha, t1.result_alpha, to_char(t1.result_numeric)) AS IC50
   ,SUBSTR(nvl2(t1.result_alpha, t1.result_alpha, to_char(t1.result_numeric)), 1,1) AS PREFIX
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
    AND t4.threed = 'N' ) T1
GROUP BY t1.ASSAY_TYPE, t1.CELL_LINE,
            t1.cell_incubation_hr,
            t1.compound_incubation_hr,
            t1.pct_serum,
            t1.day_0_normalization,
            t1.CRO,
            t1.project,
            t1.washout,
            t1.compound_id,
            t1.prefix
;

select to_number(regexp_replace('~1.2E10', '[>]+', '')) from dual;