CREATE TABLE COPY_tm_pes_fields_values AS select * from ds3_userdata.tm_pes_fields_values; 
DELETE FROM copy_tm_pes_fields_values;
DROP TABLE copy_tm_pes_fields_values;


-- NEW NAMES
select * from copy_tm_pes_fields_values
where property_name = 'Target'
and property_value IN (
 'HTR2B',
'TNK2',
'BMPR1A',
'ARG1',
'AURKA',
'AURKB',
'AURKC',
'BRK1',
'CHEK2',
'MERTK',
'DYRK1A',
'DYRK1B',
'MAPK3',
'MAPK1',
'CSF1R',
'INSRR',
'MAP4K5',
'LYN',
'MAP2K1',
'MAP2K2',
'MERTK',
'MKNK1',
'MKNK2',
'MAPK14',
'MAPK11',
'RPS6KB1',
'PDE4D',
'PRKCZ',
'MST1R',
'SIK1',
'MAP3K11',
'TEK',
'TEK',
'KDR',
'YES1',
'MAP3K20'
); -- DEV: 1,134 rows | expect 1,134 + 1,426 = 2560 rows
-- PROD: 1156  Rows | after change -> 2582  Rows = 1156 + 1426 = 2582

-- OLD NAMES
select * from copy_tm_pes_fields_values
where property_name = 'Target'
and property_value IN ('5HT2B',
'ACK1',
'ALK3/BMPR1A',
'ARG',
'AurA',
'AurB',
'AurC',
'BRK',
'CHK2',
'C-MER',
'DYRK1a',
'DYRK1b',
'ERK1',
'ERK2',
'FMS',
'IRR/INSRR',
'KHS/MAP4K5',
'LYNa',
'MEK1',
'MEK2',
'MER',
'MNK1',
'MNK2',
'P38a/MAPK14',
'P38b/MAPK11',
'p70S6K/RPS6KB1',
'PDE4D2',
'PKCzeta',
'RON/MST1R',
'SNF1LK',
'SPRK1',
'TIE2',
'TIE2/TEK',
'VEGFR2',
'YES',
'ZAK/MLTK'
); -- DEV: 1,426 rows
-- PROD: 1426  Rows

-- OLD NAMES
select * from copy_tm_pes_fields_values
where property_name like 'Cofactor%'
and property_value IN 
('MAT1',
'MEK1',
'p25',
'p35'); -- DEV: 387 rows
-- PROD: 387  Rows

-- NEW NAMES
select * from copy_tm_pes_fields_values
where property_name like 'Cofactor%'
and property_value IN 
('MNAT1',
'MAP2K1',
'CDK5R1 (p25)',
'CDK5R1'); -- 962 rows | expect 962 + 387 = 1349 rows
-- PROD: 971  Rows | 1358  Rows => 962 + 387 = 1358