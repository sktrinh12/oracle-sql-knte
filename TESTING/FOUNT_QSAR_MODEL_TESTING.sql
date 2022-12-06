select CLOSESTSMILES from FOUNT.calculated_ft_vk_qsar_models where regno = 'VK001051' FETCH NEXT 1 ROWS ONLY;


select regno, kinnate_alias from FOUNT.calculated_ft_vk_qsar_models; --WHERE CLOSESTSMILES IS NOT NULL;




select * from (
    select COMPOUND_ID, PROPERTY_NAME, NUMERIC_VALUE 
    from fount.calculated_properties --where compound_id = 'FT008148'
)
pivot (
-- LISTAGG orders data within each group specified in the ORDER BY clause and then concatenates the values of the measure column
    listagg(numeric_value, ', ') within group (order by property_name)
    for property_name in (
    'ROF5_Violations',
    'Num_H_Acceptors_Lipinski',
    'Num_H_Donors_Lipinski',
    'ALogP',
    'Molecular_Weight',
    'Molecular_PolarSurfaceArea',
    'Molecular_FractionalPolarSurfaceArea',
    'Num_RotatableBonds',
    'logD_7.4',
    'logD_4.5',
    'logD_2.0',
    'Sol_7.4',
    'Sol_4.5',
    'Sol_2.0',
    'Intrinsic_Sol',
    'pKa Apparent1',
    'pKa Apparent2'
    )
    )
;


SELECT
     T1.COMPOUND_ID AS COMPOUND_ID
    ,T1.PROPERTY_SOURCE AS PROPERTY_SOURCE
    ,T1.PROPERTY_NAME AS PROPERTY_NAME
    ,T1.NUMERIC_VALUE AS NUMERIC_VALUE
FROM
    FOUNT.CALCULATED_PROPERTIES T1
WHERE
    DATATYPE = 'NUMERIC';

select distinct PROPERTY_SOURCE from FOUNT.CALCULATED_PROPERTIES;


