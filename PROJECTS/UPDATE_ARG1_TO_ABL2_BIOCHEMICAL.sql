
select * from tm_pes_fields_values
WHERE
                property_name = 'Target'
                and property_value = 'ABL2'
            ;
            
UPDATE tm_pes_fields_values
        SET
            property_value = 'ABL2'
        WHERE
                property_name = 'Target'
            AND property_value = 'ARG1';