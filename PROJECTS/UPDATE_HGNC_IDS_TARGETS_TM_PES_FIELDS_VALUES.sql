DECLARE
    TYPE str_list_type IS
        TABLE OF VARCHAR2(15);
    v_target_values_old str_list_type;
    v_target_values_new str_list_type;
    v_target_values_tmp str_list_type;
    v_str_value_old     VARCHAR2(15);
    v_str_value_new     VARCHAR2(15);
BEGIN
    v_target_values_old := str_list_type('5HT2B', 'ACK1', 'ALK3/BMPR1A', 'ARG', 'AurA',
                                        'AurB', 'AurC', 'BRK', 'CHK2', 'C-MER',
                                        'DYRK1a', 'DYRK1b', 'ERK1', 'ERK2', 'FMS',
                                        'IRR/INSRR', 'KHS/MAP4K5', 'LYNa', 'MEK1', 'MEK2',
                                        'MER', 'MNK1', 'MNK2', 'P38a/MAPK14', 'P38b/MAPK11',
                                        'p70S6K/RPS6KB1', 'PDE4D2', 'PKCzeta', 'RON/MST1R', 'SNF1LK',
                                        'SPRK1', 'TIE2', 'TIE2/TEK', 'VEGFR2', 'YES',
                                        'ZAK/MLTK');

    v_target_values_new := str_list_type('HTR2B', 'TNK2', 'BMPR1A', 'ARG1', 'AURKA',
                                        'AURKB', 'AURKC', 'BRK1', 'CHEK2', 'MERTK',
                                        'DYRK1A', 'DYRK1B', 'MAPK3', 'MAPK1', 'CSF1R',
                                        'INSRR', 'MAP4K5', 'LYN', 'MAP2K1', 'MAP2K2',
                                        'MERTK', 'MKNK1', 'MKNK2', 'MAPK14', 'MAPK11',
                                        'RPS6KB1', 'PDE4D', 'PRKCZ', 'MST1R', 'SIK1',
                                        'MAP3K11', 'TEK', 'TEK', 'KDR', 'YES1',
                                        'MAP3K20');

    FOR indx IN v_target_values_old.first..v_target_values_old.last LOOP
        v_str_value_old := v_target_values_old(indx);
        v_str_value_new := v_target_values_new(indx);
        dbms_output.put_line('NEW DATA (TARGETS): '
                             || ':: '
                             || v_str_value_old
                             || ' -> '
                             || v_str_value_new);

        UPDATE copy_tm_pes_fields_values
        SET
            property_value = v_str_value_new
        WHERE
                property_name = 'Target'
            AND property_value = v_str_value_old;

    END LOOP;

END;