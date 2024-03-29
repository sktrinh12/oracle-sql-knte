-- MOL STRUCTURE 0.083 s
SELECT MOLFILE
FROM C$PINPOINT.REG_DATA
WHERE FORMATTED_ID = 'FT009591';
--WHERE FORMATTED_ID = 'FT007615';

-- BIOCHEMICAL GEOMEAN 2.961 s
select assay_type, 
target, 
variant, 
cofactors, 
geo_nm,
n_of_m,
created_date,
--CASE WHEN created_date >= TRUNC(SYSDATE) - 50 THEN 1 ELSE 0 END DATE_HIGHLIGHT
CASE WHEN created_date >= TO_DATE('2022-05-16', 'YYYY-MM-DD') THEN 1 ELSE 0 END DATE_HIGHLIGHT
from su_biochem_drc_stats 
WHERE COMPOUND_ID = 'FT007615' ORDER BY CREATED_DATE DESC;

-- BIOCHEM #2 1.877
SELECT         MAX(t0.COMPOUND_ID) AS compound_id ,
    MAX(t0.CRO) AS CRO ,
    MAX(t0.ASSAY_TYPE) AS assay_type ,
    MAX(t0.TARGET) AS target ,
    MAX(t0.VARIANT) AS variant ,
    MAX(t0.COFACTORS) AS cofactors ,
    MAX(t0.GEOMEAN_NM) AS geo_nM ,max(t0.n) || ' of ' || max(t0.m) AS n_of_m ,
    max(t0.created_date) as created_date         ,
    max(t0.date_highlight) as date_highlight         
    FROM (        
    SELECT         t1.CRO ,
    t1.ASSAY_TYPE ,
    t1.PROJECT ,
    t1.COMPOUND_ID ,
    t1.BATCH_ID ,
    t1.TARGET ,
    t1.VARIANT ,
    t1.COFACTORS ,
    t1.ATP_CONC_UM ,
    t1.THIOL_FREE ,
    t2.flag ,
    t1.created_date ,
    t1.MODIFIER ,
    ROUND(POWER(10, AVG(LOG(10, ic50)) 
    OVER(PARTITION BY           t1.CRO,           
    t1.ASSAY_TYPE,            
    t1.COMPOUND_ID,            
    t1.TARGET,             
    t1.VARIANT,            
    t1.COFACTORS,             
    t1.ATP_CONC_UM ,           
    t1.MODIFIER,           
    t2.FLAG )) * TO_NUMBER('1.0e+09'), 1) AS geomean_nM ,
    count(t1.ic50) 
    OVER(PARTITION BY t1.compound_id, 
    t1.cro, 
    t1.assay_type, 
    t1.target, 
    t1.variant, 
    t1.cofactors, 
    t1.atp_conc_um, 
    t1.modifier, 
    t2.flag) AS n ,
    count(t1.ic50) OVER(PARTITION BY t1.compound_id, 
    t1.cro, 
    t1.assay_type, 
    t1.target, 
    t1.variant, 
    t1.cofactors, 
    t1.atp_conc_um) AS m,         
    CASE WHEN created_date >= TO_DATE('07-01-2023',
            'MM-DD-YYYY') AND created_date <= TO_DATE('07-19-2023',
            'MM-DD-YYYY') THEN 1 ELSE 0 END DATE_HIGHLIGHT
         
    FROM  ds3_USERDATA.SU_BIOCHEM_DRC t1 
    LEFT OUTER JOIN ds3_USERDATA.BIOCHEM_IC50_FLAGS t2 ON t1.pid = t2.pid  
    WHERE                 ASSAY_INTENT = 'Screening'             AND VALIDATED = 'VALIDATED'          )          t0 
    WHERE t0.compound_id = 'FT009591'         
    GROUP BY t0.COMPOUND_ID,         
    t0.PROJECT,         
    t0.CRO,         
    t0.ASSAY_TYPE,         
    t0.TARGET,         
    t0.VARIANT,         
    t0.COFACTORS,         
    t0.ATP_CONC_UM,         
    t0.THIOL_FREE,         
    t0.flag         
    ORDER BY CREATED_DATE DESC
;

-- CELLULAR GEOMEAN 0.04 s
select assay_type, 
cell,
variant,
geo_nm,
n_of_m,
created_date
from SU_CELLULAR_DRC_STATS 
WHERE COMPOUND_ID = 'FT009591' ORDER BY CREATED_DATE DESC;

-- compound batch 0.041 s
select
BATCH_ID,
BATCH_REGISTERED_PROJECT,
--BARCODE,
registered_date,
SUPPLIER,
net_weight_mg 
from COMPOUND_BATCH 
where compound_id = 'FT009591' ORDER BY registered_date DESC;

-- in vivo pk 0.042 s
select species, dose, experiment_id, administration, auclast_d_result, cl_obs_result, cmax_result, cmax_ratio_result, 
KP_RESULT, KP_UU_RESULT, F_RESULT, VSS_OBS_RESULT, MRTINF_OBS_RESULT, T1_2_RESULT, created_date
from FT_DMPK_IN_VIVO_PIVOT_VW WHERE COMPOUND_ID = 'FT009591' ORDER BY created_date DESC;


-- metabolic stability 0.048 s
select cyp, result, comments, 
experiment_date --created_date 
from FT_CYP_INHIBITION_VW WHERE COMPOUND_ID = 'FT009591' 
ORDER BY 
experiment_date --created_date 
DESC; 

-- pxr 0.044 s
select FOLD_INDUCTION, UNIT, CONC, 
--created_date 
experiment_date
from FT_PXR_VW WHERE COMPOUND_ID = 'FT009591' 
ORDER BY 
experiment_date
--created_date 
DESC;

-- permeability 0.047 s
select BATCH_ID, A_B, B_A, EFFLUX_RATIO, CELL_TYPES, PCT_RECOVERY_AB, 
--created_date
experiment_date
from FT_PERMEABILITY_VW where COMPOUND_ID = 'FT009591' 
ORDER BY 
experiment_date
--created_date 
DESC;

-- protein binding 0.053 s
select SPECIES, MATRIX, PCT_UNBOUND, 
--created_date 
experiment_date
from FT_PPB_VW 
where COMPOUND_ID = 'FT009591' 
ORDER BY 
experiment_date
--created_date 
DESC;

-- solubility 0.04 s
select condition, result, 
--created_date 
experiment_date
from FT_SOLUBILITY_VW where COMPOUND_ID = 'FT009591' 
ORDER BY 
experiment_date
--created_date 
DESC;

--stability 0.054 s
select matrix, species, RESULT_TYPE_1, result_1, experiment_date
from METABOLIC_STABILITY_VW where COMPOUND_ID = 'FT009731' ORDER BY experiment_date DESC;


-- calc props all 2
select C_13, C_10, C_12 from PIV_1ELJMAEV_T_V_0 where compound_id = 'FT007615' ;


-- ,T1.CREATED_DATE CREATED_DATE
select t2.compound_id from
(SELECT formatted_id, MOLFILE
FROM C$PINPOINT.REG_DATA WHERE formatted_id = 'FT007615') t1
INNER JOIN (
    SELECT compound_id, assay_type, target, variant, cofactors, geo_nm, n_of_m
    FROM su_biochem_drc_stats WHERE compound_id = 'FT007615'
) t2 ON t1.formatted_id = t2.compound_id
WHERE t1.formatted_id = 'FT007615';

SELECT BATCH_ID, A_B, B_A, EFFLUX_RATIO, CELL_TYPES, PCT_RECOVERY_AB, CREATED_DATE, CASE WHEN created_date >= TO_DATE('2022-01-15', 'YYYY-MM-DD') THEN 1 ELSE 0 END DATE_HIGHLIGHT FROM FT_PERMEABILITY_VW WHERE COMPOUND_ID = 'FT002787' ORDER BY created_date DESC
;

SELECT BATCH_ID, BATCH_REGISTERED_PROJECT, net_weight_mg, SUPPLIER, REGISTERED_DATE, CASE WHEN registered_date >= TO_DATE('2022-05-17',
                'MM-DD-YYYY') AND registered_date <= TO_DATE('2023-05-17',
                'MM-DD-YYYY')  THEN 1 ELSE 0 END DATE_HIGHLIGHT FROM COMPOUND_BATCH WHERE compound_id = 'FT007615' ORDER BY registered_date DESC

;


SELECT formatted_id
FROM   (
    SELECT *
    FROM   C$PINPOINT.REG_DATA
    ORDER BY DBMS_RANDOM.RANDOM)
WHERE  rownum < 21

;



select DISTINCT COMPOUND_ID, PROJECT, CREATED_DATE from su_cellular_growth_drc where PROJECT = 'KIN-08' ORDER BY CREATED_DATE DESC, COMPOUND_ID ;

SELECT t.COMPOUND_ID, t.PROJECT, t.CREATED_DATE
FROM (
  SELECT COMPOUND_ID, PROJECT, MAX(CREATED_DATE) AS CREATED_DATE
  FROM su_cellular_growth_drc
  WHERE PROJECT = 'KIN-08' AND COMPOUND_ID LIKE 'FT%'
  GROUP BY COMPOUND_ID, PROJECT
)  t
ORDER BY t.COMPOUND_ID DESC, t.CREATED_DATE DESC;



select compound_id from LIST_SPENCERTRINH_225251;


SELECT resource_name, limit
FROM dba_profiles
WHERE resource_type = 'KERNEL'
  AND profile = (SELECT profile FROM dba_users WHERE username = 'DS3_USERDATA');
