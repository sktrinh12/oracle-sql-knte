--Union of CELLULAR_GROWTH_DRC + SU_CELLULAR_GROWTH_DRC
SELECT
    CAST(T0.ACCEPTOR AS VARCHAR2(200))               AS ACCEPTOR,
    CAST(T0.ANALYSIS_NAME AS VARCHAR2(200))          AS ANALYSIS_NAME,
    CAST(T0.ASSAY_CELL_INCUBATION AS VARCHAR2(200))  AS ASSAY_CELL_INCUBATION,
    CAST(T0.ASSAY_INTENT AS VARCHAR2(200))           AS ASSAY_INTENT,
    CAST(T0.ASSAY_TYPE AS VARCHAR2(200))             AS ASSAY_TYPE,
    CAST(T0.BATCH_ID AS VARCHAR2(100))               AS BATCH_ID,
    CAST(T0.CELL_INCUBATION_HR AS VARCHAR2(100))     AS CELL_INCUBATION_HR,
    CAST(T0.CELL_LINE AS VARCHAR2(100))              AS CELL_LINE,
    CAST(T0.COMPOUND_ID AS VARCHAR2(32))             AS COMPOUND_ID,
    CAST(T0.COMPOUND_INCUBATION_HR AS VARCHAR2(100)) AS COMPOUND_INCUBATION_HR,
    T0.CREATED_DATE                                  AS CREATED_DATE,
    CAST(T0.CRO AS VARCHAR2(200))                    AS CRO,
    CAST(T0.DAY_0_NORMALIZATION AS VARCHAR2(32))     AS DAY_0_NORMALIZATION,
    CAST(T0.DESCR AS VARCHAR2(4000))                 AS DESCR,
    CAST(T0.DONOR AS VARCHAR2(100))                  AS DONOR,
    T0.ERR                                           AS ERR,
    CAST(T0.EXPERIMENT_ID AS VARCHAR2(40))           AS EXPERIMENT_ID,
    T0.GRAPH                                         AS GRAPH,
    T0.IC50                                          AS IC50,
    T0.IC50_NM                                       AS IC50_NM,
    T0.MAXIMUM                                       AS MAXIMUM,
    T0.MINIMUM                                       AS MINIMUM,
    CAST(T0.MODIFIER AS VARCHAR2(4))                 AS MODIFIER,
    CAST(T0.PASSAGE_NUMBER AS VARCHAR2(100))         AS PASSAGE_NUMBER,
    CAST(T0.PCT_SERUM AS VARCHAR2(100))              AS PCT_SERUM,
    T0.PIC50                                         AS PIC50,
    CAST(T0.PROJECT AS VARCHAR2(32))                 AS PROJECT,
    T0.R2                                            AS R2,
    CAST(T0.SCIENTIST AS VARCHAR2(100))              AS SCIENTIST,
    T0.SLOPE                                         AS SLOPE,
    CAST(T0.THREED AS VARCHAR2(100))                 AS THREED,
    CAST(T0.TREATMENT AS VARCHAR2(100))              AS TREATMENT,
    CAST(T0.TREATMENT_CONC_UM AS VARCHAR2(100))      AS TREATMENT_CONC_UM,
    CAST(T0.VALIDATED AS VARCHAR2(11))               AS VALIDATED,
    CAST(T0.VARIANT AS VARCHAR2(100))                AS VARIANT,
    CAST(T0.WASHOUT AS VARCHAR2(100))                AS WASHOUT
FROM
    CELLULAR_GROWTH_DRC T0
UNION ALL
SELECT
    TSU.*
FROM
    (
        SELECT
            CAST(T8.ACCEPTOR AS VARCHAR2(100))                                                                      AS ACCEPTOR,
            CAST(T6.NAME AS VARCHAR2(200))                                                                          AS ANALYSIS_NAME,
            CAST(T8.ASSAY_TYPE
                 || ' '
                 || T9.CELL_INCUBATION_HR AS VARCHAR(200))                                                          AS ASSAY_CELL_INCUBATION,
            CAST(T8.ASSAY_INTENT AS VARCHAR2(200))                                                                  AS ASSAY_INTENT,
            CAST(T8.ASSAY_TYPE AS VARCHAR2(200))                                                                    AS ASSAY_TYPE,
            CAST(T3.DISPLAY_NAME AS VARCHAR2(200))                                                                  AS BATCH_ID,
            CAST(T9.CELL_INCUBATION_HR AS VARCHAR2(100))                                                            AS CELL_INCUBATION_HR,
            CAST(T9.CELL_LINE AS VARCHAR2(100))                                                                     AS CELL_LINE,
            CAST(SUBSTR(T3.DISPLAY_NAME, 1, 8) AS VARCHAR2(32))                                                     AS COMPOUND_ID,
            CAST(T9.COMPOUND_INCUBATION_HR AS VARCHAR2(100))                                                        AS COMPOUND_INCUBATION_HR,
            T4.CREATED_DATE                                                                                         AS CREATED_DATE,
            CAST(T8.CRO AS VARCHAR2(200))                                                                           AS CRO,
            CAST(NVL(T8.DAY_0_NORMALIZATION, 'N') AS VARCHAR2(32))                                                  AS DAY_0_NORMALIZATION,
            CAST(T4.DESCR AS VARCHAR2(4000))                                                                        AS DESCR,
            CAST(T8.DONOR AS VARCHAR2(200))                                                                         AS DONOR,
            TO_NUMBER(T1.ERR)                                                                                       AS ERR,
            CAST(TO_CHAR(T4.EXPERIMENT_ID) AS VARCHAR2(40))                                                         AS EXPERIMENT_ID,
            T7.DATA                                                                                                 AS GRAPH,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))              AS IC50,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM,
            TO_NUMBER(T1.PARAM2)                                                                                    AS MAXIMUM,
            TO_NUMBER(T1.PARAM1)                                                                                    AS MINIMUM,
            CAST(SUBSTR(T1.REPORTED_RESULT, 1, 1) AS VARCHAR2(4))                                                   AS MODIFIER,
            CAST(T9.PASSAGE_NUMBER AS VARCHAR2(100))                                                                AS PASSAGE_NUMBER,
            CAST(NVL(T9.PCT_SERUM, 10) AS VARCHAR2(100))                                                            AS PCT_SERUM,
            - LOG(10, TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)))   AS PIC50,
            CAST(T8.PROJECT AS VARCHAR2(32))                                                                        AS PROJECT,
            TO_NUMBER(T1.R2)                                                                                        AS R2,
            CAST(T4.ISID AS VARCHAR2(100))                                                                          AS SCIENTIST,
            TO_NUMBER(T1.PARAM3)                                                                                    AS SLOPE,
            CAST(T8.THREED AS VARCHAR2(50))                                                                         AS THREED,
            CAST(T9.TREATMENT AS VARCHAR2(100))                                                                     AS TREATMENT,
            CAST(T9.TREATMENT_CONC_UM AS VARCHAR2(100))                                                             AS TREATMENT_CONC_UM,
            CAST(
                CASE T1.STATUS
                    WHEN 1 THEN
                        'VALIDATED'
                    WHEN 2 THEN
                        'INVALIDATED'
                    WHEN 3 THEN
                        'PUBLISHED'
                    ELSE
                        'INVALIDATED'
                END
            AS VARCHAR(11))                                                                                         AS VALIDATED,
            CAST(T9.VARIANT_1 AS VARCHAR2(100))                                                                     AS VARIANT,
            CAST(NVL(T9.WASHOUT, 'N') AS VARCHAR2(100))                                                             AS WASHOUT
        FROM
                 DS3_USERDATA.SU_ANALYSIS_RESULTS T1
            INNER JOIN DS3_USERDATA.SU_GROUPINGS            T2 ON T1.GROUP_ID = T2.ID
            INNER JOIN DS3_USERDATA.SU_SAMPLES              T3 ON T2.SAMPLE_ID = T3.ID
            INNER JOIN DS3_USERDATA.TM_EXPERIMENTS          T4 ON T2.EXPERIMENT_ID = T4.EXPERIMENT_ID
            INNER JOIN DS3_USERDATA.SU_CLASSIFICATION_RULES T5 ON T1.RULE_ID = T5.ID
            INNER JOIN DS3_USERDATA.SU_ANALYSIS_LAYERS      T6 ON T1.LAYER_ID = T6.ID
            INNER JOIN DS3_USERDATA.SU_CHARTS               T7 ON T1.ID = T7.RESULT_ID
            INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T8 ON T8.EXPERIMENT_ID = T2.EXPERIMENT_ID --MAY NEED THE SU EQUIVALENT?
            RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT     T9 ON T9.EXPERIMENT_ID = T2.EXPERIMENT_ID --ONLY HAS VARIANT_1 & NEEDS VARIANT_2
                                                                    AND T9.PLATE_SET = T2.PLATE_SET
            INNER JOIN DS3_USERDATA.TM_PROTOCOLS            T10 ON T10.PROTOCOL_ID = T4.PROTOCOL_ID
        WHERE
                T10.PROTOCOL_ID = 441
            AND T4.COMPLETED_DATE IS NOT NULL
            AND ( T4.DELETED IS NULL
                  OR T4.DELETED = 'N' )
       
    ) TSU
    ORDER BY
        COMPOUND_ID,
        CELL_LINE
;