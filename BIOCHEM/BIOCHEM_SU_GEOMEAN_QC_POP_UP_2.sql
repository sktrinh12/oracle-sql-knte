SELECT
    t1.batch_id  AS batch_id,
    t1.graph     AS graph,
    t1.ic50_nm   AS ic50_nm,
    t2.geo_nm    AS geo_nm,
    '-3 stdev: '
    || round(t2.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
    || round(t2.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    || t2.n_of_m AS agg_stats,
    'CRO: '
    || t1.cro
    || '<br />'
    || 'Assay Type: '
    || t1.assay_type
    || '<br />'
    || 'Target: '
    || t1.target
    || '<br />'
    || 'Variant: '
    || t1.variant
    || '<br />'
    || 'cofactor-1: '
    || t1.cofactor_1
    || '<br />'
    || 'cofactor-2: '
    || t1.cofactor_2
    || '<br />'
    || 'atp_conc_um: '
    || t2.atp_conc_um
 properties
FROM
    (
        SELECT
             substr(t3.display_name, 1, 8)                                                                           compound_id,
                    t3.display_name                                                                                         batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            target,
            variant,
            cofactor_1,
            cofactor_2,
            nvl2(cofactor_1, cofactor_1, NULL)
            || nvl2(cofactor_2, ', ' || cofactor_2, NULL) cofactors,
            atp_conc_um
        FROM
                ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                        SELECT
                            experiment_id,
                            target,
                            variant_1 variant,
                            cofactor_1,
                            cofactor_2,
                            plate_set,
                            atp_conc_um
                         FROM
                su_plate_prop_pivot
                ) t5 ON t2.experiment_id = t5.experiment_id
                    AND t5.PLATE_SET = t2.PLATE_SET
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '-PRIMARY-'
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '-PRIMARY-'
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
        
            t2.experiment_id = '-PRIMARY-'
            AND t3.display_name != 'BLANK'
    )                                 t1
    LEFT JOIN ds3_userdata.su_biochem_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                            AND t1.cro = t2.cro
                                                            AND t1.assay_type = t2.assay_type
                                                            AND t1.target = t2.target
                                                            AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                                                            AND nvl(t1.cofactors, '-') = nvl(t2.cofactors,'-')
                                                            AND t1.atp_conc_um = t2.atp_conc_um
                                                            ORDER BY t1.COMPOUND_ID, t1.TARGET, t2.COFACTORS
;