SELECT
    it.experiment_id,
    it.compound_id,
    it.project_name,
    it.cro,
    it.assay_type,
    it.created_date,
    it.ic50,
    it.ic50_nm,
    it.variant,
    it.target,
    it.atp_conc_um,
    it.cofactors,
    nvl2(ot.flag, ot.flag, 0) flag
FROM
    (
        SELECT
            'BIO'
            || '-'
            || EXTRACT(YEAR FROM created_date)
            || '-'
            || t1.prop1
            || '-'
            || ROW_NUMBER()
               OVER(PARTITION BY t1.prop1
                    ORDER BY
                        t1.prop1
               )                                                                                                    pid,
            to_char(t1.experiment_id)                                                                            experiment_id,
            substr(t1.id, 1, 8)                                                                                  compound_id,
            t4.project                                                                                           project_name,
            t4.cro                                                                                               cro,
            t4.assay_type                                                                                        assay_type,
            t3.created_date                                                                                      created_date,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric))              ic50,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 ic50_nm,
            t5.variant,
            t5.target,
            t5.atp_conc_um,
            nvl2(t5.cofactor_1, t5.cofactor_1, NULL)
            || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL)                                                  cofactors
        FROM
                 ds3_userdata.tm_experiments t3
            INNER JOIN ds3_userdata.tm_conclusions           t1 ON t3.experiment_id = t1.experiment_id
            INNER JOIN ds3_userdata.tm_protocol_props_pivot  t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                                   AND t1.id = t5.batch_id
                                                                   AND t1.prop1 = t5.prop1
        WHERE
            t3.completed_date IS NOT NULL
            AND t1.protocol_id = 181
            AND nvl(t3.deleted, 'N') = 'N'
            AND t1.validated = 'VALIDATED'
        UNION ALL
        SELECT
            'BIO'
            || '-'
            || t1.id
            || '-'
            || t2.plate_set                                                                                          pid,
            to_char(t4.experiment_id)                                                                                experiment_id,
            substr(t3.display_name, 1, 8)                                                                            compound_id,
            t8.project                                                                                               project_name,
            t8.cro,
            t8.assay_type,
            t4.created_date,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric))              ic50,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 ic50_nm,
            t9.variant_1                                                                                             variant,
            t9.target,
            t9.atp_conc_um,
            nvl2(t9.cofactor_1, t9.cofactor_1, NULL)
            || nvl2(t9.cofactor_2, ', ' || t9.cofactor_2, NULL)                                                      cofactors
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.tm_experiments          t4 ON t2.experiment_id = t4.experiment_id
                                                         AND t4.protocol_id = 501
            INNER JOIN ds3_userdata.tm_protocol_props_pivot t8 ON t8.experiment_id = t2.experiment_id
            RIGHT OUTER JOIN ds3_userdata.su_plate_prop_pivot     t9 ON t9.experiment_id = t2.experiment_id
                                                                    AND t9.plate_set = t2.plate_set
        WHERE
            t4.completed_date IS NOT NULL
            AND t1.status = 1
            AND nvl(t4.deleted, 'N') = 'N'
    )                               it
    LEFT OUTER JOIN ds3_userdata.biochem_ic50_flags ot ON it.pid = ot.pid
WHERE
        it.compound_id = 'FT009094'
    AND it.cro = 'Pharmaron'
    AND it.assay_type = 'Caliper'
    AND it.target = 'CDK2'
    AND it.atp_conc_um = 100
    AND it.cofactors = 'CCNE1'
    AND it.variant IS NULL
    AND nvl2(ot.flag, ot.flag, 0) = 0
    ;

SELECT
    *
FROM
    TABLE ( most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'CDK2', '100', 'CCNE1',
                                 '-', 'su_biochem_drc') )
WHERE
    compound_id = 'FT009094';

SELECT
    *
FROM
    TABLE ( most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10',
                                 '-', 'su_cellular_growth_drc') );
                                 
                                 
     
      
      with ranked_cmpids AS (
    select COMPOUND_ID, IC50_NM, CREATED_DATE, ROW_COUNT, CNT, IC50_LOG10
        from ( SELECT otbl.COMPOUND_ID, 
                        otbl.IC50_NM, 
                        otbl.CREATED_DATE, 
                        otbl.ROW_COUNT, 
                        otbl.cnt, 
                        LOG(10, otbl.IC50) IC50_LOG10 
                FROM (select t.* from 
                        (select COMPOUND_ID, 
                            created_date, 
                            ic50_nm, 
                            ic50,
                            row_number () over ( 
                                partition by t1.compound_id
                                order by t1.created_date desc) row_count,
                            count(*) over (PARTITION BY t1.compound_id) cnt
                    from table(most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'CDK2', '100', 'CCNE1', '-', 'su_biochem_drc')) t1                
            ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl ) )
        select COMPOUND_ID, CREATED_DATE, ROW_COUNT, IC50_NM_1, IC50_NM_2, DIFF_IC50,AVG_IC50 from (
    SELECT tbl1. COMPOUND_ID, 
            tbl2.CREATED_DATE, 
            tbl1.ROW_COUNT,
            tbl1.IC50_NM IC50_NM_1,
            tbl2.IC50_NM IC50_NM_2,
            (tbl1.IC50_LOG10+tbl2.IC50_LOG10)/2 AVG_IC50, 
            tbl1.IC50_LOG10-tbl2.IC50_LOG10 DIFF_IC50 
    from ranked_cmpids tbl1
    INNER JOIN ranked_cmpids tbl2
    ON tbl1.row_count = tbl2.row_count+1 and tbl1.compound_id = tbl2.compound_id
    ORDER BY tbl1.CREATED_DATE DESC, tbl2.CREATED_DATE DESC
    )
    FETCH NEXT 20 ROWS ONLY
;
    
    
    
    SELECT
                t3.PID,
                t3.CREATED_DATE,
                t3.CRO,
                t3.ASSAY_TYPE,
                t3.COMPOUND_ID,
                t3.EXPERIMENT_ID,
                t3.BATCH_ID,
                t3.TARGET,
                t3.VARIANT,
                t3.COFACTORS,
                t3.ATP_CONC_UM,
                BASE64ENCODE(t3.GRAPH) as GRAPH,
                ROUND(t3.ic50_nm,2) as IC50_NM,
                t3.flag,
                t3.COMMENT_TEXT,
                t3.USER_NAME,
                t3.CHANGE_DATE,
             ROUND( POWER(10,
               AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
                    t3.CRO,
                    t3.ASSAY_TYPE,
                    t3.COMPOUND_ID,
                    t3.TARGET,
                    t3.VARIANT,
                    t3.COFACTORS,
                    t3.ATP_CONC_UM,
                    t3.flag
                )) * TO_NUMBER('1.0e+09'), 1) AS GEOMEAN
                FROM (
              SELECT t1.CRO,
                     t1.ASSAY_TYPE,
                     t1.experiment_id,
                     t1.COMPOUND_ID,
                     t1.BATCH_ID,
                     t1.TARGET,
                     t1.VARIANT,
                     t1.CREATED_DATE,
                     t1.COFACTORS,
                     t1.ATP_CONC_UM,
                     t1.MODIFIER,
                     t1.GRAPH,
                     nvl2(t2.flag, t2.flag, 0) flag,
                     t1.ic50,
                     t1.ic50_nm,
                     nvl2(t2.COMMENT_TEXT, t2.COMMENT_TEXT, 'ENTER COMMENT') COMMENT_TEXT,
                     nvl2(t2.USER_NAME, t2.USER_NAME, 'TESTADMIN') USER_NAME,
                     nvl2(t2.CHANGE_DATE, t2.CHANGE_DATE, SYSDATE) CHANGE_DATE,
                     t1.PID
               FROM DS3_USERDATA.SU_BIOCHEM_DRC t1
               LEFT OUTER JOIN DS3_USERDATA.BIOCHEM_IC50_FLAGS t2
               ON t1.pid = t2.pid) t3
             WHERE t3.COMPOUND_ID = 'FT009094'
                  AND t3.CRO = 'Pharmaron'
                  AND t3.TARGET = 'CDK2'
                  AND t3.ATP_CONC_UM = 100
                  AND t3.ASSAY_TYPE = 'Caliper'
                  AND t3.COFACTORS = 'CCNE1'
                  AND t3.VARIANT IS NULL
;

select * from BIOCHEM_IC50_FLAGS;


select * from su_biochem_drc where pid = 'BIO-21206-1';