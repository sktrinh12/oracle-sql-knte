
select * from table(get_msr_data('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', '-', 'su_cellular_growth_drc',20));
select * from table(get_msr_data2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', '-', 'su_cellular_growth_drc',20));
select * from table(get_msr_data2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc',20));
select * from table(get_msr_data2('Pharmaron', 'pRb 807 HTRF', 'WM3629', '18', '2', '-', 'su_cellular_growth_drc', 20));
select * from table(get_msr_data2('Pharmaron', 'HTRF', 'A-375', '1', '10', '-', 'su_cellular_growth_drc', 20));
select * from table(get_msr_data2('Pharmaron', 'Caliper', 'MET', '100', '-', 'wt', 'su_biochem_drc', 20));
select * from table(get_msr_data2('Pharmaron', 'Caliper', 'GSK3B', '100', '-', '-', 'su_biochem_drc', 20));
select * from table(get_msr_data2('Pharmaron', 'Caliper', 'CDK9', '100', 'CCNT1', '-', 'su_biochem_drc', 20));
select * from table(get_msr_data2('Pharmaron', 'Caliper', 'CDK1', '100', 'CCNB1', '-', 'su_biochem_drc', 20));
select * from table(get_msr_data2('Pharmaron', 'ADP-GLO', 'CDK12', '18', 'CCNK', '-', 'su_biochem_drc', 20));

-- cellular

SELECT
    calc_msr2('Pharmaron', 'HTRF', 'A-375', '1', '10', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual;


SELECT
    calc_msr2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --1.17

SELECT
    calc_msr('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --2.80

SELECT
    calc_msr2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --2.29

SELECT
    calc_msr2('Pharmaron', 'pRb 807 HTRF', 'WM3629', '18', '2', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --2.37
    
    
SELECT
    calc_msr('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; --1.174
    

    

SELECT
    calc_msr2('Pharmaron', 'HTRF', 'A-375', '1', '10', '-', 'su_cellular_growth_drc', 20) msr
FROM
    dual; -- 1.53
   
SELECT
    calc_msr2('Carna Biosciences', 'nanoBRET', 'HEK-293', '2', '1', 'CDK2-CCNE1-Nluc', 'su_cellular_growth_drc', 20) msr
FROM
    dual; -- NULL since less than specified 20
    
    
-- BIOCHEM

SELECT
    calc_msr2('Pharmaron', 'Caliper', 'MET', '100', '-', 'wt', 'su_biochem_drc', 20) msr
FROM
    dual; -- 2.27
    
SELECT
    calc_msr2('Pharmaron', 'ADP-GLO', 'CDK13', '5', 'CCNK', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- NULL

SELECT
    calc_msr2('Pharmaron', 'ADP-GLO', 'CDK12', '18', 'CCNK', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- NULL
    
    
SELECT
    calc_msr2('Pharmaron', 'Caliper', 'GSK3B', '100', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 11.82
    
    
SELECT
    calc_msr2('Pharmaron', 'IMAP_Fluorescence Polarization', 'PDE4D', '-', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- NULL
    
    
SELECT
    calc_msr2('ReactionBio', 'radiometric HotSpot', 'BRAF', '10', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- NULL
    
    
SELECT
    calc_msr2('Pharmaron', 'Caliper', 'CDK9', '100', 'CCNT1', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 1.81
    
    
SELECT
    calc_msr2('Pharmaron', 'Caliper', 'MET', '100', '-', 'G1163R', 'su_biochem_drc', 20) msr
FROM
    dual; -- NULL

SELECT
    calc_msr2('Pharmaron', 'Caliper', 'CDK1', '100', 'CCNB1', '-', 'su_biochem_drc', 20) msr
FROM
    dual; -- 3.18    

  select cro, assay_type, experiment_id, target, atp_conc_um, cofactors, variant from su_biochem_drc where experiment_id=209179;
  
  
  select cro, assay_type, experiment_id, cell_line, cell_incubation_hr, pct_serum, variant from su_cellular_growth_drc where cro = 'Pharmaron'  and cell_incubation_hr is null ;
select cro, assay_type, experiment_id, cell_line, cell_incubation_hr, pct_serum, variant from su_cellular_growth_drc where experiment_id = 175684;

select cro, assay_type, experiment_id, cell_line, cell_incubation_hr, pct_serum, variant from su_cellular_growth_drc where experiment_id = 211215;
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211253, 20) ; --bio
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211252, 20) ; --bio
SELECT * from DS3_USERDATA.GEN_GEOMEAN_CURVE_TBL(211208, 20); --bio
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211215, 20); --cell 
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(210084, 20); --cell
SELECT * from DS3_USERDATA.GEN_GEOMEAN_CURVE_TBL(211262, 20); -- cell

SELECT
    calc_msr2('Pharmaron', 'Caliper', 'GSK3B', '100', '-', '-', 'su_biochem_drc', 20) msr
FROM
    dual; 

-- 8.46 mins to run biochem 
-- 20 s to run cell / 44 s for v2


select 
    || ' target="_blank">MSR Viz</a>'
    || ' <br />'
    || '<select name="n_limit" id="n_limit"><option value="33">33</option></select>'
|| '<div>
  <h2>N Number</h2>
  <ul>
    <li><a href="#">10</a></li>
    <li><a href="#">11</a></li>
    <li><a href="#">12</a></li>
    <li><a href="#">13</a></li>    
  </ul>
</div>'
|| '<form>  
<label> Select Cars </label>  
<select>  
<option value = "BMW"> BMW   
</option>  
<option value = "Mercedes"> Mercedes   
</option>  
<option value = "Audi"> Audi  
</option>  
<option value = "Skoda"> Skoda  
</option>  
</select>  
<input type = "button" onclick = "msgprint()" value = "Message Print">
</form>' 
|| '<script type = "text/javascript">  
         function msgprint() {  
            alert("You are Successfully Called the JavaScript function");  
         }  
</script>'
from dual;
