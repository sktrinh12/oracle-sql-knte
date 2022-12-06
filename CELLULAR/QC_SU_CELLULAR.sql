select count(*) from cellular_growth_drc where compound_id = 'FT000953' and VALIDATED = 'VALIDATED' and ASSAY_INTENT = 'Screening';

select count(*) from SU_cellular_growth_drc where compound_id = 'FT000953' and VALIDATED = 'VALIDATED' and ASSAY_INTENT = 'Screening';


select * from SU_cellular_growth_drc where compound_id = 'FT000953' and VALIDATED = 'VALIDATED' and ASSAY_INTENT = 'Screening';

select * from cellular_growth_drc where compound_id = 'FT000953' and VALIDATED = 'VALIDATED' and ASSAY_INTENT = 'Screening';




-- QC the SU and cellular growth tables
select t0.* from
(
select * from cellular_growth_drc where compound_id = 'FT000953' and VALIDATED = 'VALIDATED' and ASSAY_INTENT = 'Screening' 
) t0
RIGHT OUTER JOIN
(
select * from su_cellular_growth_drc where compound_id = 'FT000953' and VALIDATED = 'VALIDATED' and ASSAY_INTENT = 'Screening'
) t1
ON t0.DESCR = t1.DESCR
AND t0.ERR = t1.ERR
AND t0.experiment_id = t1.experiment_id
;