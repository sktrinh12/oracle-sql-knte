select 
t1.species,
t1.method,
t1.matrix,
t1.result_type_1,
MAX( t1.result_1) AS RESULT_1,
t1.unit_1,
t1.result_type_2,
MAX(t1.result_2) AS RESULT_2,
t1.unit_2,
t2.method,
t2.condition,
t2.media,
MAX(t2.result) AS RESULT,
t2.unit,
t3.cell_types,
MAX(t3.B_A) AS B_A,
MAX(t3.A_B) AS A_B,
MAX(t3.EFFLUX_RATIO) AS EFFLUX_RATIO,
MAX(t3.PCT_RECOVERY_AB) AS PCT_RECOVERY_AB
from FT_DMPK_STABILITY t1 
INNER JOIN FT_DMPK_SOLUBILITY t2 
ON t1.compound_id = t2.compound_id
INNER JOIN FT_DMPK_PERMeABILITY t3
ON t1.compound_id = t3.compound_id
WHERE t1.COMPOUND_ID = 'FT008391' AND t1.MATRIX IN ('Hepatocytes', 'Liver Microsomes') AND t1.RESULT_TYPE_1 IN ('T 1/2', '% Remaining') 
GROUP BY t1.SPECIES, t1.METHOD, t1.matrix, t1.result_type_1, t1.unit_1, t1.result_type_2, t1.unit_2, t2.method, t2.condition, t2.media, t2.unit, t3.cell_types
ORDER BY t1.SPECIES, t1.METHOD;



select * from FT_DMPK_STABILITY where COMPOUND_ID = 'FT008391';
select * from ft_dmpk_solubility where COMPOUND_ID = 'FT008391';
select * from ft_dmpk_permeability where COMPOUND_ID = 'FT008391';

select * from ft_dmpk_permeability where COMPOUND_ID = 'FT002787';


select 
t1.species,
t1.method,
t1.matrix,
t1.result_type_1,
MAX( t1.result_1),
t1.unit_1,
t1.result_type_2,
MAX(t1.result_2),
MAX(t1.unit_2)
from FT_DMPK_STABILITY t1 
WHERE t1.COMPOUND_ID = 'FT008391' AND t1.MATRIX IN ('Hepatocytes', 'Liver Microsomes') AND t1.RESULT_TYPE_1 IN ('T 1/2', '% Remaining')
GROUP BY t1.SPECIES, t1.METHOD, t1.matrix, t1.result_type_1, t1.unit_1, t1.result_type_2
ORDER BY  t1.SPECIES, t1.METHOD
;


select 
t1.species,
t1.method,
t1.matrix,
t1.result_type_1,
t1.result_1,
t1.unit_1,
t1.result_type_2
from FT_DMPK_STABILITY t1 
WHERE t1.COMPOUND_ID = 'FT008391' AND t1.MATRIX IN ('Hepatocytes', 'Liver Microsomes') AND t1.RESULT_TYPE_1 IN ('T 1/2', '% Remaining')
ORDER BY  t1.SPECIES, t1.METHOD
;


select 
t1.species,
t1.method,
t1.matrix,
t1.result_type_1,
t1.result_1,
t1.unit_1,
t1.result_type_2,
t3.cell_types,
t3.B_A AS B_A,
t3.A_B AS A_B,
t3.EFFLUX_RATIO,
t3.PCT_RECOVERY_AB
from FT_DMPK_STABILITY t1,
ft_dmpk_permeability t3
WHERE t1.COMPOUND_ID = 'FT008391' AND t1.MATRIX IN ('Hepatocytes', 'Liver Microsomes') AND t1.RESULT_TYPE_1 IN ('T 1/2', '% Remaining')
ORDER BY  t1.SPECIES, t1.METHOD
;
