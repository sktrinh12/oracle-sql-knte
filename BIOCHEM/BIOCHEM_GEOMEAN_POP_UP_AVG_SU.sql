-- original 
SELECT
    t1.batch_id                                                    AS batch_id,
    t1.graph                                                       AS graph,
    t1.modifier
    || to_char(round((t1.ic50 * to_number('1e9')), 2), '99990.99') AS ic50_nm,
    'Min: '
    || to_char(round(t1.minimum, 1), '990.9')
    || '<br />'
    || 'Max: '
    || to_char(round(t1.maximum, 1), '990.9')
    || '<br />'
    || 'Slope: '
    || to_char(round(t1.slope, 1), '90.0')
    || '<br />'
    || 'R2: '
    || to_char(round(t1.r2, 2), '0.09')
    || '<br />'
    || 'Err: '
    || to_char(round(t1.err, 1), '9990.9')                         AS stats,
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
    || nvl(t1.variant, '-')
    || '<br />'
    || 'Cofactors: '
    || nvl(t1.cofactors, '-')
    || '<br />'
    || 'ATP Conc (uM): '
    || t1.atp_conc_um                                              properties
FROM
    ds3_userdata.su_biochem_drc t1
WHERE
    t1.compound_id IN (
        SELECT
            substr(id, 0, 8) AS compound_id
        FROM
            ds3_userdata.tm_conclusions
        WHERE
            experiment_id = '210464'
        GROUP BY
            id
    )
    AND t1.cro IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_prot_exp_fields_values
        WHERE
                experiment_id = '210464'
            AND property_name = 'CRO'
    )
    AND t1.assay_type IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_prot_exp_fields_values
        WHERE
                experiment_id = '210464'
            AND property_name = 'Assay Type'
    )
    AND t1.target IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
                experiment_id = '210464'
            AND sample_id != 'BLANK'
            AND property_name = 'Target'
            AND property_value IS NOT NULL
    )
    AND ( t1.variant IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
                experiment_id = '210464'
            AND sample_id != 'BLANK'
            AND property_name = 'Variant-1'
    )
          OR t1.variant IS NULL )
    AND ( t1.cofactor_1 IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
                experiment_id = '210464'
            AND sample_id != 'BLANK'
            AND property_name = 'Cofactor-1'
    )
          OR t1.cofactor_1 IS NULL )
    AND ( t1.cofactor_2 IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
                experiment_id = '210464'
            AND sample_id != 'BLANK'
            AND property_name = 'Cofactor-2'
    )
          OR t1.cofactor_2 IS NULL )
    AND t1.atp_conc_um IN (
        SELECT DISTINCT
            property_value
        FROM
            ds3_userdata.tm_pes_fields_values
        WHERE
                experiment_id = '210464'
            AND sample_id != 'BLANK'
            AND property_name = 'ATP Conc (uM)'
            AND property_value IS NOT NULL
    )
;


-- simplified?
SELECT
    t1.batch_id                                                    AS batch_id,
    t1.graph                                                       AS graph,
    t1.modifier
    || to_char(round((t1.ic50 * to_number('1e9')), 2), '99990.99') AS ic50_nm,
    'Min: '
    || to_char(round(t1.minimum, 1), '990.9')
    || '<br />'
    || 'Max: '
    || to_char(round(t1.maximum, 1), '990.9')
    || '<br />'
    || 'Slope: '
    || to_char(round(t1.slope, 1), '90.0')
    || '<br />'
    || 'R2: '
    || to_char(round(t1.r2, 2), '0.09')
    || '<br />'
    || 'Err: '
    || to_char(round(t1.err, 1), '9990.9')                         AS stats,
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
    || nvl(t1.variant, '-')
    || '<br />'
    || 'Cofactors: '
    || nvl(t1.cofactors, '-')
    || '<br />'
    || 'ATP Conc (uM): '
    || t1.atp_conc_um properties
FROM
    ds3_userdata.su_biochem_drc t1
WHERE
        experiment_id = '210464'
    AND compound_id != 'BLANK'
;

