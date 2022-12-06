select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from CELLULAR_GROWTH_DRC where EXPERIMENT_ID = 139224 and compound_id = 'FT000011'; --CELL2018-1,2,3,4
                                                                                                                                   --22.295,18.38,22.27,19.47

--select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from CELLULAR_GROWTH_DRC where PID like 'CELL2020%';

select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from CELLULAR_GROWTH_DRC where EXPERIMENT_ID = 152804 and compound_id = 'FT000953'; --CELL2020-142,150,154,160,184
                                                                                                                                   --4.59,4.44,4.31,6.92,6.93

select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from CELLULAR_GROWTH_DRC where experiment_ID = 147664 and compound_id = 'FT000960'; --CELL2020-544 -> 177.9522

--select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from enzyme_inhibition_vw where PID like 'BIO2018%';

select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from enzyme_inhibition_vw where experiment_id = 150031 and compound_id = 'FT000956'; --BIO2020-58,59,60,61,62,63,64
                                                                                                                                    --1.713, 14.908, 1000,0.618,98.21,1000,0.7277

select PID, EXPERIMENT_ID, COMPOUND_ID,IC50_NM from enzyme_inhibition_vw where experiment_id = 138645 and compound_id = 'FT000012'; --BIO2018-67,68,70,71,73
                                                                                                                                    --329.43,229.277,70.089,6921.62, 1514.349