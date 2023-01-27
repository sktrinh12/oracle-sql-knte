declare
msr_dict DICT_PKG.t_dict_table;
v_key VARCHAR(500);
BEGIN
FOR item IN
(
with expid_rows as (
SELECT
--    t1.batch_id,
--    t1.ic50_nm,
--    t2.geo_nm,
    t1.cro,
    t1.assay_type,
    t1.cell_line,    
    t1.variant,
    t1.CELL_INCUBATION_HR,
    t1.pct_serum
FROM
    (
        SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            --t3.display_name                                                                     AS batch_id,
            --to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            --t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            cell_line,
            variant,
            cell_incubation_hr,
            pct_serum
            
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            --INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    cell_line,
                    nvl(variant_1, '-') variant,
                    cell_incubation_hr,
                    pct_serum ,
                    plate_set 
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
                        experiment_id = 211215
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = 211215
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = 211215
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.cell_incubation_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum 
                                                             --ORDER BY t1.COMPOUND_ID, t1.CELL_LINE, t1.VARIANT
)
select cro, assay_type, cell_line, variant, cell_incubation_hr, pct_serum from expid_rows
)
LOOP
v_key := item.cro || '-' || item.assay_type ||'-'||item.cell_line || '-' || item.variant || '-' || item.cell_incubation_hr || '-' || item.pct_serum;
if msr_dict.exists(v_key) THEN
    CONTINUE;
ELSE
    msr_dict(v_key) := calc_msr2(item.cro, item.assay_type, item.cell_line, item.cell_incubation_hr, item.pct_serum, item.variant, 'su_cellular_growth_drc', 20);
END IF;
DBMS_OUTPUT.PUT_LINE
('calcd msr: ' || msr_dict(v_key));
END LOOP;
END;
/

declare
v_msr_dict DICT_PKG.t_dict_table;
BEGIN
 v_msr_dict := populate_msr_dict( i_experiment_id=> 210084, i_param1_name=>'cell_line' , i_param2_name=>'cell_incubation_hr', i_param3_name=>'pct_serum',
i_param_names=>'cell_line , cell_incubation_hr, pct_serum',
i_where_by_params=> 'AND t1.cell_line = t2.cell AND t1.variant = t2.variant AND t1.cell_incubation_hr = t2.inc_hr AND t1.pct_serum = t2.pct_serum',
i_param_names_subq=> 'cell_line , cell_incubation_hr, pct_serum',
i_dsname=>'su_cellular_growth_drc', i_stats_ds=>'su_cellular_drc_stats',i_nbr_cmpds=> 20);
END;
/


declare
v_msr_dict DICT_PKG.t_dict_table;
BEGIN
 v_msr_dict := populate_msr_dict( i_experiment_id=> 211252, 
    i_param1_name=>'target' , 
    i_param2_name=>'atp_conc_um', 
    i_param3_name=>'cofactors',
    i_param_names=> q'[target, nvl(cofactors, '-') cofactors, atp_conc_um]',
    i_where_by_params=> q'!AND t1.target = t2.target AND t1.variant = nvl(t2.variant, '-') AND t1.atp_conc_um = t2.atp_conc_um AND nvl(t1.cofactors, '-') = nvl(t2.cofactors, '-')!',
    i_param_names_subq=> q'[nvl2(cofactor_1, cofactor_1, NULL)
            || nvl2(cofactor_2, ', ' || cofactor_2, NULL) cofactors, target, atp_conc_um]',
    i_dsname=>'su_biochem_drc', 
    i_stats_ds=>'su_biochem_drc_stats',
    i_nbr_cmpds=> 20);
END;
/



select IC50_NM from su_cellular_growth_drc where 
compound_id = 'FT008947' and
cro = 'Pharmaron' and assay_type = 'CellTiter-Glo'
and cell_line = 'Ba/F3'
and cell_incubation_hr = '72'
and pct_serum = '10'
and variant IS NULL
order by created_date DESC;
