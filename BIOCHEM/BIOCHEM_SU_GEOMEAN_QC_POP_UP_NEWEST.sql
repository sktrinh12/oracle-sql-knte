SELECT
    tmain.batch_id       AS batch_id,
    tmain.graph          AS graph,
    tmain.ic50_nm        AS ic50_nm,
    tsec.geo_nm          AS geo_nm,
    '-3 stdev: '
    || round(tsec.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
    || round(tsec.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    || tsec.n_of_m       AS agg_stats,
    'CRO: '
    || tmain.cro
    || '<br />'
    || 'Assay Type: '
    || tmain.assay_type
    || '<br />'
    || 'Target: '
    || tmain.target
    || '<br />'
    || 'Variant: '
    || tmain.variant
    || '<br />'
    || 'cofactor-1: '
    || tmain.cofactor_1
    || '<br />'
    || 'cofactor-2: '
    || tmain.cofactor_2
    || '<br />'
    || 'atp_conc_um: '
    || tmain.atp_conc_um properties
FROM
         (
        SELECT
            compound_id,
            batch_id,
            ic50_nm,
            graph,
            cro,
            assay_type,
            target,
            variant,
            cofactor_1,
            cofactor_2,
            cofactors,
            atp_conc_um
        FROM
            (
                SELECT
                    substr(t3.display_name, 1, 8)                                                                           compound_id,
                    t3.display_name                                                                                         batch_id,
                    to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 ic50_nm,
                    t5.data                                                                                                 graph,
                    t7.cro                                                                                                  cro,
                    t7.assay_type                                                                                           assay_type,
                    t6.target                                                                                               target,
                    t6.variant_1                                                                                            variant,
                    t6.cofactor_1                                                                                           cofactor_1,
                    t6.cofactor_2                                                                                           cofactor_2,
                    substr(nvl2(t6.cofactor_1, ', ' || t6.cofactor_1, NULL)
                           || nvl2(t6.cofactor_2, ', ' || t6.cofactor_2, NULL), 3)                                                 cofactors,
                    t6.atp_conc_um                                                                                          atp_conc_um
                FROM
                         ds3_userdata.su_analysis_results t1
                    INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
                    INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
                    INNER JOIN ds3_userdata.tm_experiments          t4 ON t2.experiment_id = t4.experiment_id                                                                 
                    INNER JOIN ds3_userdata.su_charts               t5 ON t1.id = t5.result_id
                    RIGHT OUTER JOIN ds3_userdata.su_plate_prop_pivot     t6 ON t6.experiment_id = t2.experiment_id
                                                                            AND t6.plate_set = t2.plate_set
                    INNER JOIN ds3_userdata.tm_protocol_props_pivot t7 ON t7.experiment_id = t2.experiment_id
                WHERE
--                    ( t4.deleted IS NULL
--                      OR nvl(t4.deleted, 'N') = 'N' )
                    --AND 
                    t4.experiment_id = 211211
                    AND t3.display_name != 'BLANK'
            )
    ) tmain
    LEFT OUTER JOIN ds3_userdata.su_biochem_drc_stats tsec ON tmain.compound_id = tsec.compound_id
                                                         AND tmain.cro = tsec.cro
                                                         AND tmain.assay_type = tsec.assay_type
                                                         AND tmain.target = tsec.target
                                                         AND nvl(tmain.variant, '-') = nvl(tsec.variant, '-')
                                                         AND nvl(tmain.cofactors, '-') = nvl(tsec.cofactors, '-')
                                                         AND tmain.atp_conc_um = tsec.atp_conc_um
;
