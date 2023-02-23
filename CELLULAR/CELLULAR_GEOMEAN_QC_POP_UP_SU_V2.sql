select 
    q.ASSAY_INTENT,
    q.ASSAY_TYPE,
    q.BATCH_ID,
    q.CELL_INCUBATION_HR,
    q.CELL_LINE,
    q.COMPOUND_ID,
    q.COMPOUND_INCUBATION_HR,
    q.CREATED_DATE,
    q.CRO,
    q.DAY_0_NORMALIZATION,
    q.DESCR,
    q.EXPERIMENT_ID,
    q.GRAPH,
    q.IC50_NM,
    q.PASSAGE_NUMBER,
    q.PCT_SERUM,
    q.PROJECT,
    q.SCIENTIST,
    q.THREED,
    q.TREATMENT,
    q.TREATMENT_CONC_UM,
    q.VARIANT
from (
SELECT
ASSAY_INTENT,
ASSAY_TYPE,
BATCH_ID,
CELL_INCUBATION_HR,
CELL_LINE,
COMPOUND_ID,
COMPOUND_INCUBATION_HR,
CREATED_DATE,
CRO,
nvl(DAY_0_NORMALIZATION, 'N') as DAY_0_NORMALIZATION,
DESCR,
EXPERIMENT_ID,
GRAPH,
IC50_NM,
nvl(MODIFIER, '-') AS MODIFIER,
PASSAGE_NUMBER,
PCT_SERUM,
PROJECT,
SCIENTIST,
THREED,
nvl(TREATMENT, '-') AS TREATMENT,
nvl(TREATMENT_CONC_UM, '-') AS TREATMENT_CONC_UM,
nvl(VARIANT, '-') as VARIANT,
regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 4) as variant_regexp,
nvl(regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 7), '-') as modifier_regexp
FROM 
    DS3_USERDATA.SU_CELLULAR_GROWTH_DRC
WHERE
    compound_id = 'FT007615'
    AND assay_intent = 'Screening' 
    AND validated = 'VALIDATED' 
    AND trim(washout) = 'N' 
    AND CRO = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 1)  
    AND ASSAY_TYPE = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 2)  
    AND CELL_LINE = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 3)
    AND CELL_INCUBATION_HR = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 5)
    AND PCT_SERUM = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 6)  
--    AND THREED = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 8)
--    AND TREATMENT = regexp_substr('KYinno|CellTiter-Glo|Ba/F3|TPR-MET-D1228A|72|10||N|', '[^|]+', 1, 9)
    ) q
    where
    VARIANT = variant_regexp
    AND MODIFIER = modifier_regexp
    ORDER BY EXPERIMENT_ID;
    
    
    
    
    select 
    q.ASSAY_INTENT,
    q.ASSAY_TYPE,
    q.BATCH_ID,
    q.CELL_INCUBATION_HR,
    q.CELL_LINE,
    q.COMPOUND_ID,
    q.COMPOUND_INCUBATION_HR,
    q.CREATED_DATE,
    q.CRO,
    q.DAY_0_NORMALIZATION,
    q.DESCR,
    q.EXPERIMENT_ID,
    q.GRAPH,
    q.IC50_NM,
    q.PASSAGE_NUMBER,
    q.PCT_SERUM,
    q.PROJECT,
    q.SCIENTIST,
    q.THREED,
    q.TREATMENT,
    q.TREATMENT_CONC_UM,
    q.VARIANT
from (
SELECT sq.*,
    regexp_substr('-CELLVALUE2-', '[^|]+', 1, 4) as variant_regexp,
    nvl(regexp_substr('-CELLVALUE2-', '[^|]+', 1, 9), '-') as modifier_regexp
from (
SELECT
ASSAY_INTENT,
ASSAY_TYPE,
BATCH_ID,
CELL_INCUBATION_HR,
CELL_LINE,
COMPOUND_ID,
COMPOUND_INCUBATION_HR,
CREATED_DATE,
CRO,
nvl(DAY_0_NORMALIZATION, 'N') as DAY_0_NORMALIZATION,
DESCR,
EXPERIMENT_ID,
GRAPH,
IC50_NM,
nvl(MODIFIER, '-') AS MODIFIER,
PASSAGE_NUMBER,
PCT_SERUM,
PROJECT,
SCIENTIST,
case threed when 'Y' then '3D' else '-' end AS threed,
--case when treatment is not null then treatment else '-' end AS treatment,
WASHOUT,
VALIDATED,
nvl(TREATMENT, '-') AS TREATMENT,
nvl(TREATMENT_CONC_UM, '-') AS TREATMENT_CONC_UM,
nvl(VARIANT, '-') as VARIANT
FROM 
    DS3_USERDATA.SU_CELLULAR_GROWTH_DRC
) sq
WHERE
    sq.compound_id = '-PRIMARY-'
    AND sq.assay_intent = 'Screening' 
    AND sq.validated = 'VALIDATED' 
    AND trim(sq.washout) = 'N' 
    AND sq.CRO = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 1)  
    AND sq.ASSAY_TYPE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 2)  
    AND sq.CELL_LINE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 3)
    AND sq.CELL_INCUBATION_HR = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 5)
    AND sq.PCT_SERUM = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 6)  
    AND sq.THREED = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 7)
    AND sq.TREATMENT = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 8)
    )
     q
    where
    VARIANT = variant_regexp
    AND MODIFIER = modifier_regexp
    ORDER BY EXPERIMENT_ID