
-- cellular

SELECT
    calc_msr2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --2.25

SELECT
    calc_msr2('Pharmaron', 'pRb 807 HTRF', 'WM3629', '18', '2', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --2.38
    

SELECT
    calc_msr2('Pharmaron', 'HTRF', 'A-375', '1', '10', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; -- 1.74
   
SELECT
    calc_msr2('Carna Biosciences', 'nanoBRET', 'HEK-293', '2', '1', 'CDK2-CCNE1-Nluc', 'su_cellular_growth_drc', 20) msr
FROM
    dual; -- 3.89
    
    
-- BIOCHEM

SELECT
    calc_msr2('Pharmaron', 'Caliper', 'MET', '100', '-', 'wt', 'su_biochem_drc', 20) msr
FROM
    dual; -- 2.38
    
SELECT
    calc_msr2('Pharmaron', 'ADP-GLO', 'CDK13', '5', 'CCNK', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 18.80

SELECT
    calc_msr2('Pharmaron', 'ADP-GLO', 'CDK12', '18', 'CCNK', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 11.73
    
    
SELECT
    calc_msr2('Pharmaron', 'Caliper', 'GSK3B', '100', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 11.82
    
    
SELECT
    calc_msr2('Pharmaron', 'IMAP_Fluorescence Polarization', 'PDE4D', '-', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 4.68
    
    
  select cro, assay_type, experiment_id, target, atp_conc_um, cofactors, variant from su_biochem_drc where cro = 'Pharmaron'   and experiment_id=209708;
  
  
  select cro, assay_type, experiment_id, cell_line, cell_incubation_hr, pct_serum, variant from su_cellular_growth_drc where cro = 'Pharmaron'  and cell_incubation_hr is null ;
select cro, assay_type, experiment_id, cell_line, cell_incubation_hr, pct_serum, variant from su_cellular_growth_drc where experiment_id = 175684;


select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211253, 20) ; --bio
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211215, 20); --cell

SELECT
    calc_msr2('Pharmaron', 'Caliper', 'GSK3B', '100', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; 
    
select nvl2(NULL, 'test', NULL) ||nvl2('ok', ', ' || 'asdf', NULL) test from dual;


select 508/60 from dual; -- 8.46 mins to run biochem 

                  
         SELECT
            compound_id,
                            variant,                                    
           ic50_nm,
       cell_line,
       cell_incubation_hr,
       pct_serum,
            cro,
            assay_type,
            calc_msr2(cro, 
                assay_type, 
                '' || 'cell_line = ' || '''''' || cell_line || '''''', 
                '' || 'cell_incubation_hr = ' || cell_incubation_hr || '', 
                '' || 'pct_serum = ' || pct_serum || '', 
                '' || 'variant ' || CASE WHEN variant IS NULL THEN ' is null' ELSE ' = ' || '''' || variant || '''' || '' END,
                'su_cellular_growth_drc', 20) msr
                from su_cellular_growth_drc where experiment_id = 211215
                ;            