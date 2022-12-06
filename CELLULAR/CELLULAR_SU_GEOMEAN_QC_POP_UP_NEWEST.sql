SELECT
    tmain.batch_id  AS batch_id,
    tmain.graph     AS graph,
    tmain.ic50_nm   AS ic50_nm,
    tsec.geo_nm    AS geo_nm,
    '-3 stdev: '
    || round(tsec.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
    || round(tsec.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    || tsec.n_of_m AS agg_stats,
    'CRO: '
    || tmain.cro
    || '<br />'
    || 'Assay Type: '
    || tmain.assay_type
    || '<br />'
    || 'Cell Line: '
    || tmain.cell_line
    || '<br />'
    || 'Variant: '
    || tmain.variant
    || '<br />'
    || 'Inc(hr): '
    || tmain.CELL_INCUBATION_HR
    || '<br />'
    || '% serum: '
    || tmain.pct_serum
    properties
FROM
    (
        SELECT
            compound_id,
            batch_id,
            IC50_NM,
            graph,
            cro,
            assay_type,
            cell_line,
            variant,
            CELL_INCUBATION_HR,
            pct_serum
        FROM
        (SELECT 
            T3.DISPLAY_NAME         BATCH_ID,
            SUBSTR(T3.DISPLAY_NAME, 1, 8)  COMPOUND_ID,
            T8.ASSAY_TYPE,
            T8.CRO ,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM,
            T7.DATA   GRAPH,
             T9.CELL_LINE ,
             T9.CELL_INCUBATION_HR,
             T9.VARIANT_1 variant,
             NVL(T9.PCT_SERUM, 10) PCT_SERUM
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
            where t4.experiment_id = 211215
            AND T3.DISPLAY_NAME != 'BLANK'
        )
	  ) tmain
    LEFT OUTER JOIN ds3_userdata.su_cellular_drc_stats tsec ON tmain.compound_id = tsec.compound_id                                                        
                                                             AND tmain.cro = tsec.cro
                                                             AND tmain.assay_type = tsec.assay_type
                                                             AND tmain.cell_line = tsec.cell
                                                             AND nvl(tmain.variant, '-') = nvl(tsec.variant, '-')
                                                             AND tmain.CELL_INCUBATION_HR = tsec.INC_HR
                                                             AND tmain.pct_serum = tsec.pct_serum
