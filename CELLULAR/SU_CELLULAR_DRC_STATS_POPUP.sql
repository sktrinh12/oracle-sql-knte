SELECT
    MAX(t0.cro)                AS cro,
    MAX(t0.assay_type)         AS assay_type,
    MAX(t0.compound_id)        AS compound_id,
    MAX(t0.cell_line)          AS cell,
    MAX(t0.variant)            AS variant,
    MAX(t0.cell_incubation_hr) AS inc_hr,
    MAX(t0.pct_serum)          AS pct_serum,
    MAX(t0.geomean_nm)         AS geo_nm,
    MAX(t0.nm_minus_3_stdev)   AS nm_minus_3_stdev,
    MAX(t0.nm_plus_3_stdev)    AS nm_plus_3_stdev,
    MAX(t0.nm_minus_3_var)     AS nm_minus_3_var,
    MAX(t0.nm_plus_3_var)      AS nm_plus_3_var,
    MAX(t0.n)
    || ' of '
    || MAX(t0.m)               AS n_of_m,
    MAX(t0.cellvalue_two)      AS cellvalue_two,
    MAX(t0.stdev)              AS stdev
FROM
    (
        SELECT
            t1.cro,
            t1.assay_type,
            t1.compound_id,
            t1.batch_id,
            t1.cell_line,
            nvl(t1.variant, '-')                                                                  AS variant,
            t1.cell_incubation_hr,
            t1.pct_serum,
            t1.modifier,
            t1.cro
            || '|'
            || t1.assay_type
            || '|'
            || t1.cell_line
            || '|'
            || nvl(t1.variant, '-')
            || '|'
            || t1.cell_incubation_hr
            || '|'
            || t1.pct_serum
            || '|'
            || nvl(t1.modifier, '-')                                                                        AS cellvalue_two,
            round(STDDEV(log(10, t1.ic50))
                  OVER(PARTITION BY t1.compound_id, t1.cell_line, t1.variant, t1.cell_incubation_hr, t1.pct_serum,
                                    t1.modifier), 2)                                                                      AS stdev,
            round((to_char(power(10, AVG(log(10, t1.ic50))
                                     OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                                       t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000),
                                                       1) AS geomean_nm,
            round(((power(10, AVG(log(10, t1.ic50))
                              OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                                t1.cell_incubation_hr, t1.pct_serum, t1.modifier) -(3 * STDDEV(log(10, t1.ic50))
                                                                                                        OVER(PARTITION BY t1.compound_id,
                                                                                                        t1.cell_line, t1.variant, t1.
                                                                                                        cell_incubation_hr, t1.pct_serum,
                                                                                                                          t1.modifier)))) *
                                                                                                                          1000000000),
                                                                                                                          1)                                                     AS
                                                                                                                          nm_minus_3_stdev,
            round(((power(10, AVG(log(10, t1.ic50))
                              OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                                t1.cell_incubation_hr, t1.pct_serum, t1.modifier) +(3 * STDDEV(log(10, t1.ic50))
                                                                                                        OVER(PARTITION BY t1.compound_id,
                                                                                                        t1.cell_line, t1.variant, t1.
                                                                                                        cell_incubation_hr, t1.pct_serum,
                                                                                                                          t1.modifier)))) *
                                                                                                                          1000000000),
                                                                                                                          1)                                                     AS
                                                                                                                          nm_plus_3_stdev,
            round(((power(10, AVG(log(10, t1.ic50))
                              OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                                t1.cell_incubation_hr, t1.pct_serum, t1.modifier) -(3 * VARIANCE(log(10, t1.ic50))
                                                                                                        OVER(PARTITION BY t1.compound_id,
                                                                                                        t1.cell_line, t1.variant, t1.
                                                                                                        cell_incubation_hr, t1.pct_serum,
                                                                                                                          t1.modifier)))) *
                                                                                                                          1000000000),
                                                                                                                          1)                                                     AS
                                                                                                                          nm_minus_3_var,
            round(((power(10, AVG(log(10, t1.ic50))
                              OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                                t1.cell_incubation_hr, t1.pct_serum, t1.modifier) +(3 * VARIANCE(log(10, t1.ic50))
                                                                                                        OVER(PARTITION BY t1.compound_id,
                                                                                                        t1.cell_line, t1.variant, t1.
                                                                                                        cell_incubation_hr, t1.pct_serum,
                                                                                                                          t1.modifier)))) *
                                                                                                                          1000000000),
                                                                                                                          1)                                                     AS
                                                                                                                          nm_plus_3_var,
            COUNT(t1.ic50)
            OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                              t1.cell_incubation_hr, t1.pct_serum, t1.modifier)                               AS n,
            COUNT(t1.ic50)
            OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                              t1.cell_incubation_hr, t1.pct_serum)                                            AS m
        FROM
            ds3_userdata.su_cellular_growth_drc t1
        WHERE
                t1.assay_intent = 'Screening'
            AND t1.validated = 'VALIDATED'
    ) t0
WHERE
    t0.modifier IS NULL
GROUP BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum
ORDER BY
    t0.compound_id,
    t0.cro,
    t0.assay_type,
    t0.cell_line,
    t0.variant,
    t0.cell_incubation_hr,
    t0.pct_serum;

SELECT
    t1.assay_type,
    t1.cell_line,
    t1.variant,
    t1.cell_incubation_hr,
    t1.pct_serum,
    ic50 * 100000000                                                                      AS ic50,
    round((to_char(power(10, AVG(log(10, t1.ic50))
                             OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                               t1.cell_incubation_hr, t1.pct_serum, t1.modifier)), '99999.99EEEE') * 1000000000), 3) AS
                                               geomean,
    round(power(10, AVG(log(10, t1.ic50))
                      OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                                        t1.cell_incubation_hr, t1.pct_serum, t1.modifier))* 1000000000, 3) 
                                        - (3 * STDDEV(t1.ic50)
                                                                                                OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.
                                                                                                cell_line, t1.variant, t1.cell_incubation_hr,
                                                                                                t1.pct_serum,t1.modifier) * 1000000000) AS nm_minus_3_stdev,
    stddev(t1.ic50)
  OVER(PARTITION BY t1.compound_id, t1.cro, t1.assay_type, t1.cell_line, t1.variant,
                    t1.cell_incubation_hr, t1.pct_serum, t1.modifier) * 1000000000 AS stdev
FROM
    ds3_userdata.su_cellular_growth_drc t1;


select * from su_cellular_drc_stats where compound_id = 'FT000953' and cro = 'Pharmaron' and assay_type = 'HTRF' and cell = 'DBTRG-05MG' and inc_hr = 1;


-- POP up
select q.* from (
SELECT
    compound_id,
    cro,
    assay_type,
    cell_line,
    cell_incubation_hr,
    pct_serum,
    variant,
    modifier,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 1) as CRO_REGEXP,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 2) as ASSAY_TYPE_REGEXP,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 3) as CELL_LINE_REGEXP,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 4) as VARIANT_REGEXP,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 5) as CELL_INCUBATION_HR_REGEXP,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 6) as PCT_SERUM_REGEXP,
    regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|2|', '[^|]+', 1, 7) as MODIFIER_REGEXP
FROM
    ds3_userdata.SU_CELLULAR_GROWTH_DRC t1
WHERE
    compound_id = 'FT000953'
    ) q
    where q.cro = q.CRO_REGEXP
    AND q.assay_type = q.assay_type_regexp
    AND q.cell_line = q.cell_line_regexp
    AND q.cell_incubation_hr = q.cell_incubation_hr_regexp
    and q.pct_serum = q.pct_serum_regexp
    and (q.modifier = q.modifier_regexp OR q.modifier is null and q.modifier_regexp is null)
;
    
SELECT
ASSAY_CELL_INCUBATION,
ASSAY_INTENT,
ASSAY_TYPE,
BATCH_ID,
CELL_INCUBATION_HR,
CELL_LINE,
COMPOUND_ID,
COMPOUND_INCUBATION_HR,
CREATED_DATE,
CRO,
DAY_0_NORMALIZATION,
DESCR,
EXPERIMENT_ID,
GRAPH,
IC50_NM,
PASSAGE_NUMBER,
PCT_SERUM,
PROJECT,
SCIENTIST,
TREATMENT,
TREATMENT_CONC_UM,
VARIANT
FROM 
    DS3_USERDATA.SU_CELLULAR_GROWTH_DRC
WHERE
    compound_id = '-PRIMARY-'
    AND CRO = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 1)  
    AND ASSAY_TYPE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 2)  
    AND CELL_LINE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 3)  
    AND VARIANT = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 4)  
    AND CELL_INCUBATION_HR = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 5)  
    AND PCT_SERUM = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 6)  
    AND MODIFIER = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 7) 
    ;

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
TREATMENT,
TREATMENT_CONC_UM,
nvl(VARIANT, '-') as VARIANT,
regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 4) as variant_regexp,
nvl(regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 7), '-') as modifier_regexp
FROM 
    DS3_USERDATA.SU_CELLULAR_GROWTH_DRC
WHERE
    compound_id = 'FT000953'
    AND CRO = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 1)  
    AND ASSAY_TYPE = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 2)  
    AND CELL_LINE = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 3)
    AND CELL_INCUBATION_HR = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 5)  
    AND PCT_SERUM = regexp_substr('Pharmaron|HTRF|DBTRG-05MG|-|1|10|', '[^|]+', 1, 6) 
    ) q
    where
    VARIANT = variant_regexp
    AND MODIFIER = modifier_regexp 
    ORDER BY EXPERIMENT_ID
;

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
nvl(TREATMENT, '-') AS TREATMENT,
nvl(TREATMENT_CONC_UM, '-') AS TREATMENT_CONC_UM,
nvl(VARIANT, '-') as VARIANT,
regexp_substr('-CELLVALUE2-', '[^|]+', 1, 4) as variant_regexp,
nvl(regexp_substr('-CELLVALUE2-', '[^|]+', 1, 7), '-') as modifier_regexp
FROM 
    DS3_USERDATA.SU_CELLULAR_GROWTH_DRC
WHERE
    compound_id = '-PRIMARY-'
    AND CRO = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 1)  
    AND ASSAY_TYPE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 2)  
    AND CELL_LINE = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 3)
    AND CELL_INCUBATION_HR = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 5)  
    AND PCT_SERUM = regexp_substr('-CELLVALUE2-', '[^|]+', 1, 6) 
    ) q
    where
    VARIANT = variant_regexp
    AND MODIFIER = modifier_regexp
    ORDER BY EXPERIMENT_ID
;