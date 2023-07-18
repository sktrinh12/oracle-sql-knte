select 
    q.EXPERIMENT_ID,
    q.PROJECT,
    q.DESCR,
    q.CRO,
    q.ASSAY_TYPE,
    q.BATCH_ID,
    q.COMPOUND_ID,
    q.TARGET,
    q.VARIANT,
    q.COFACTORS,
    q.ATP_CONC_UM,
    q.THIOL_FREE,
    q.GRAPH,
    q.IC50_NM,
    q.ASSAY_INTENT,
    q.CREATED_DATE,
    q.SCIENTIST,
    CASE WHEN UPPER('-USER-') IN ('TESTADMIN', 'SPENCER.TRINH', 'MICHELLE.PEREZ', 'MIMIKA.KOLETSOU') THEN 'http://geomean.frontend.kinnate/get-data?compound_id=' || q.COMPOUND_ID || '&type=biochem_agg&sql_type=get&cro=' || q.CRO || '&assay_type=' || q.ASSAY_TYPE || '&get_mnum_rows=false&variant=' || CASE WHEN q.VARIANT='-' THEN 'null' else q.VARIANT END || '&target=' || q.target || '&atp_conc_um=' || q.ATP_CONC_UM || '&cofactors=' || CASE WHEN q.COFACTORS='-' THEN 'null' else q.COFACTORS END || '&user_name=-USER-' ELSE '<div><a href="#" disabled> FORBIDDEN </a></div>' END FLAG_LINK
from (
SELECT sq.*,
    regexp_substr('-CELLVALUE2-', '[^|]+', 1, 6) regex_cofactors
    FROM (
SELECT 
 EXPERIMENT_ID,
    PROJECT,
    DESCR,
    CRO,
    ASSAY_TYPE,
    BATCH_ID,
    COMPOUND_ID,
    TARGET,
    nvl(VARIANT, '-') as VARIANT,
    nvl(COFACTORS, '-') as COFACTORS,
    nvl(ATP_CONC_UM, '-') as ATP_CONC_UM,
    THIOL_FREE,
    GRAPH, 
    nvl(MODIFIER, '-') AS MODIFIER,
    IC50_NM,
    ASSAY_INTENT,
    CREATED_DATE,
    SCIENTIST,
    VALIDATED
FROM 
    DS3_USERDATA.SU_BIOCHEM_DRC
    ) sq
WHERE
    sq.compound_id = '-PRIMARY-'
    AND sq.assay_intent = 'Screening' 
    AND sq.validated = 'VALIDATED' 
    AND sq.CRO = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 1)
    AND sq.ASSAY_TYPE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 2) 
    AND sq.TARGET = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 3)
    AND sq.ATP_CONC_UM = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 5)
    AND sq.VARIANT = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 4)
    ) q
    WHERE COFACTORS = regex_cofactors
    ORDER BY EXPERIMENT_ID