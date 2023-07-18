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
            CRO || '|' || ASSAY_TYPE || '|' || TARGET || '|' || NVL(VARIANT, '-')  || '|' || ATP_CONC_UM || '|' || NVL(COFACTORS, '-') || '|' ||  MODIFIER AS CELLVALUE_TWO,
    q.SCIENTIST
--CASE WHEN UPPER('spencer.trinh') IN ('TESTADMIN', 'MICHELLE.PEREZ', 'MIMIKA.KOLETSOU', 'SPENCER.TRINH') THEN 'http://geomean.frontend.kinnate/get-data?compound_id=' || q.COMPOUND_ID || '&type=biochem_agg&sql_type=get&cro=' || q.CRO || '&assay_type=' || q.ASSAY_TYPE || '&get_mnum_rows=false&variant=' || CASE WHEN q.VARIANT='-' THEN 'null' else q.VARIANT END || '&target=' || q.target || '&atp_conc_um=' || q.atp_conc_um || '&cofactors=' || CASE WHEN q.cofactors ='-' THEN 'null' ELSE q.cofactors END || '&user_name=spencer.trinh' ELSE '<div><a href="#" disabled> FORBIDDEN </a></div>' END FLAG_LINK

from (
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

WHERE 
    compound_id = 'FT002787'
    AND assay_intent = 'Screening'
    AND validated = 'VALIDATED'
    AND CRO = regexp_substr('ReactionBio|radiometric HotSpot|BRAF|R506_K507insVLR|10|-', '[^|]+', 1, 1)
    AND ASSAY_TYPE = regexp_substr('ReactionBio|radiometric HotSpot|BRAF|R506_K507insVLR|10|-', '[^|]+', 1, 2) 
    AND TARGET = regexp_substr('ReactionBio|radiometric HotSpot|BRAF|R506_K507insVLR|10|-', '[^|]+', 1, 3)
    AND (VARIANT = regexp_substr('ReactionBio|radiometric HotSpot|BRAF|R506_K507insVLR|10|-', '[^|]+', 1, 4 ) OR VARIANT is null)
    AND (COFACTORS = regexp_substr('ReactionBio|radiometric HotSpot|BRAF|R506_K507insVLR|10|-', '[^|]+', 1, 6) OR COFACTORS is null) 
    AND (ATP_CONC_UM = regexp_substr('ReactionBio|radiometric HotSpot|BRAF|R506_K507insVLR|10|-', '[^|]+', 1, 5) OR ATP_CONC_UM is null)
    ) q 

    ORDER BY EXPERIMENT_ID ;
    
    
    
    select * from su_biochem_drc_stats fetch next 2 rows only;

    select * from ft_biochem_drc_stats where compound_id = 'FT002787';

    select * from su_biochem_drc fetch next 2 rows only;