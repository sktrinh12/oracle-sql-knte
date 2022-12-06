
--USE OF PID [DOES NOT WORK]

WITH DATA AS
      ( SELECT 'BIO-8000-1|BIO-2020-37-316|BIO-2021-1-434|BIO-2021-1-439|BIO-2021-1-449|BIO-2021-1-499|BIO-2021-1-514|BIO-2021-1-516|BIO-2022-1-172|BIO-2022-1-175|BIO-2021-1-206|BIO-2021-1-217|BIO-2021-1-226|BIO-2021-1-228|BIO-2021-1-239|BIO-2022-1-241|BIO-2022-1-253|BIO-2022-1-259|BIO-2022-1-265|BIO-2021-1-268|BIO-2021-1-281|BIO-2021-1-287|BIO-2021-1-298|BIO-2021-1-301|BIO-2021-1-309|BIO-2021-1-317|BIO-2021-1-325|BIO-2021-1-326|BIO-2022-1-147|BIO-2022-1-158|BIO-2022-1-161|BIO-2022-1-168|BIO-2021-1-333|BIO-2021-1-336|BIO-2021-1-340|BIO-2021-1-350|BIO-2021-1-354|BIO-2021-1-362|BIO-2021-1-367|BIO-2021-1-379|BIO-2021-1-388|BIO-2021-1-400|BIO-2021-1-404|BIO-2021-1-415|BIO-2021-1-419|BIO-2021-1-428|BIO-2022-33-55|BIO-2021-8-481' str FROM dual
      )
    select regexp_substr(str, '[^|]+', 1, level) AS SPLIT 
   FROM DATA
   connect by INSTR(str, '|', 1, LEVEL - 1) > 0
   ;

SELECT
t1.pid t1_pid, t2.pid t2_pid,
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
    || 'cofactors: '
    || t1.cofactors
    || '<br />'
    || 'atp_conc_um: '
    || t1.atp_conc_um
    properties
FROM
    (
        SELECT
            pid,
            BATCH_ID,
            IC50_NM,
            ATP_CONC_UM,
            COFACTORS,
            VARIANT,
            TARGET,
            ASSAY_TYPE,
            CRO,
            GRAPH
        FROM
        su_biochem_drc where experiment_id = 195945
        and COMPOUND_ID != 'BLANK' 
    ) t1
    left outer JOIN ds3_userdata.su_biochem_drc_stats t2 ON t1.pid = t2.pid                                                    
    ;


-- NON-PIDS
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
    || t1.atp_conc_um
    properties
FROM
    (
        SELECT
            COMPOUND_ID,
            BATCH_ID,
            IC50_NM,
            GRAPH,
            cro,
            assay_type,
            target,
            variant,
            cofactor_1,
            cofactor_2,
            cofactors,
            atp_conc_um
        FROM
        su_biochem_drc where experiment_id = 195945
        and COMPOUND_ID != 'BLANK' 
    ) t1
    INNER JOIN ds3_userdata.su_biochem_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                            AND t1.cro = t2.cro
                                                            AND t1.assay_type = t2.assay_type
                                                            AND t1.target = t2.target
                                                            AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                                                            AND nvl(t1.cofactors, '-') = nvl(t2.cofactors, '-')
                                                            AND t1.atp_conc_um = t2.atp_conc_um
    ;
    
    
    
select PID, COMPOUND_ID,
            BATCH_ID,
            IC50_NM,
            GRAPH,
            cro,
            assay_type,
            target,
            variant,
            cofactor_1,
            cofactor_2,
            cofactors,
            atp_conc_um,
            modifier
from su_biochem_drc where experiment_id = '195945'

;


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
--                            nvl(variant_1, '-') variant,
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
                        experiment_id = '211211'
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = '211211'
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
        
            t2.experiment_id = '211211'
            AND t3.display_name != 'BLANK'
    )                                 t1
    LEFT OUTER JOIN ds3_userdata.su_biochem_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                            AND t1.cro = t2.cro
                                                            AND t1.assay_type = t2.assay_type
                                                            AND t1.target = t2.target
                                                            AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
                                                            AND t1.atp_conc_um = t2.atp_conc_um
;

select * from ds3_userdata.su_biochem_drc_stats;