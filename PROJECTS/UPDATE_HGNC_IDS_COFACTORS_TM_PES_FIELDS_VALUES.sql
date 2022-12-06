DECLARE
    TYPE str_list_type IS
        TABLE OF VARCHAR2(15);
    v_target_values_old str_list_type;
    v_target_values_new str_list_type;
    v_target_values_tmp str_list_type;
    v_str_value_old     VARCHAR2(15);
    v_str_value_new     VARCHAR2(15);
BEGIN
    v_target_values_old := str_list_type('MAT1', 'MEK1', 'p25', 'p35');
    v_target_values_new := str_list_type('MNAT1', 'MAP2K1', 'CDK5R1 (p25)', 'CDK5R1');
    FOR indx IN v_target_values_old.first..v_target_values_old.last LOOP
        v_str_value_old := v_target_values_old(indx);
        v_str_value_new := v_target_values_new(indx);
        dbms_output.put_line('NEW DATA (COFACTORS): '
                             || ':: '
                             || v_str_value_old
                             || ' -> '
                             || v_str_value_new);

        UPDATE copy_tm_pes_fields_values
        SET
            property_value = v_str_value_new
        WHERE
                property_name like 'Cofactor%'
            AND property_value = v_str_value_old;

    END LOOP;

END;