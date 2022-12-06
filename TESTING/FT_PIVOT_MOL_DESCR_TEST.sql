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


DROP VIEW FOUNT.CALCULATE_PROPERTIES_PIVOT_VW;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "FOUNT"."CALCULATE_PROPERTIES_PIVOT_VW" AS 
(
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
);

select * from FOUNT.CALCULATED_PROPERTIES FETCH NEXT 100 ROWS ONLY;

GRANT SELECT ON "FOUNT"."CALCULATE_PROPERTIES_PIVOT_VW" TO "DS3_APPDATA";