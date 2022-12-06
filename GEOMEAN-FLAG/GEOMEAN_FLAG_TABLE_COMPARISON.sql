-- cross check row count of biochem ic50 flags for uniquness
SELECT
    COUNT(*) AS row_count
FROM
         ds3_userdata.test_biochem_ic50_flags
    UNION ALL
     (
        SELECT
            COUNT(DISTINCT(experiment_id
                           || batch_id
                           || target
                           || nvl(variant, '-')
                           || flag
                           || prop1 )) AS row_count
                           --|| cofactor_1
                           --|| cofactor_1
                           --|| assay_type
                           --|| CRO
                           --|| ATP_CONC_UM
                           --|| MODIFIER
                           --|| IC50_NM)) AS row_count
        FROM
            ds3_userdata.test_biochem_ic50_flags 
    );

SELECT
    t1.concat_values as concat_values, 
    COUNT(t1.concat_values), 
    t1.experiment_id,
    t1.batch_id,
    t1.target,
    t1.variant,
    t1.flag,
    t1.prop1 ,
    t1.cofactor_1,
    t1.cofactor_1,
    t1.assay_type,
    t1.CRO,
    t1.ATP_CONC_UM,
    t1.MODIFIER,
    t1.IC50_NM
FROM
    (
        SELECT
            t0.experiment_id
            || t0.batch_id
               || t0.target
                  || nvl(t0.variant, '-')
                     || t0.flag
                        || t0.prop1
                           || t0.cofactor_1
                              || t0.cofactor_1
                                 || t0.assay_type
                                    || t0.cro
                                       || t0.atp_conc_um
                                          || t0.modifier
                                             || t0.ic50_nm        AS concat_values,
            t0.experiment_id as experiment_id,
            t0.batch_id as batch_id,
            t0.target as target,
            nvl(t0.variant, '-') AS variant,
            t0.flag as flag,
            t0.prop1 as prop1,
            t0.cofactor_1 as cofactor_1,
            t0.cofactor_1 as cofactor_2,
            t0.assay_type as assay_type,
            t0.cro as cro,
            t0.atp_conc_um as atp_conc_um,
            t0.modifier as modifier,
            t0.ic50_nm as ic50_nm
        FROM
            ds3_userdata.test_biochem_ic50_flags t0 
    ) t1
GROUP BY t1.experiment_id,
    t1.batch_id,
    t1.target,
    t1.variant,
    t1.flag,
    t1.prop1 ,
    t1.cofactor_1,
    t1.cofactor_1,
    t1.assay_type,
    t1.CRO,
    t1.ATP_CONC_UM,
    t1.MODIFIER,
    t1.IC50_NM,
    t1.concat_values
HAVING COUNT(t1.concat_values) > 1;

select * from test_biochem_ic50_flags 
where EXPERIMENT_ID = '138824' 
AND BATCH_ID = 'FT001223-01' 
AND TARGET = 'FGFR2' 
and PROP1 = 1 
and ASSAY_TYPE='radiometric'
and CRO='ReactionBio' 
and ATP_CONC_UM = 5 
AND IC50_NM = 28.192349;






--CREAT BIOCHEM IC50 FLAGS TABLE        
CREATE TABLE DS3_USERDATA.TEST_BIOCHEM_IC50_FLAGS AS (        
SELECT       
    MAX(t1.experiment_id)                                                                            AS experiment_id,
    MAX(t1.id)                                                                                       AS batch_id,
    SUBSTR(t1.id, 1,8) AS COMPOUND_ID,
    t5.target                                                                                        AS target,  
    t5.variant                                                                                       AS variant,
    substr(nvl2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
           || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), 3)                                   AS cofactors,
    MAX(0)                                                                                           AS FLAG,
    MAX(t1.prop1)                                                                                    AS PROP1
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
    --INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 181
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
GROUP BY
    t1.experiment_id,
    SUBSTR(t1.id, 1, 8), 
    t5.TARGET,
    t5.VARIANT,
    substr(nvl2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
           || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), 3)    
);



DELETE FROM ds3_userdata.TEST_BIOCHEM_IC50_FLAGS WHERE EXPERIMENT_ID = '172724' AND BATCH_ID = 'FT002787-17' and TARGET = 'BRAF' AND PROP1 = 5;
DELETE FROM ds3_userdata.TEST_BIOCHEM_IC50_FLAGS WHERE EXPERIMENT_ID = '172744' AND BATCH_ID = 'FT002787-17' and TARGET = 'RAF1' AND PROP1 = 5;

insert into ds3_userdata.TEST_BIOCHEM_IC50_FLAGS values ('172724', 'FT002787-17', 'BRAF', NULL, 0, 5);
insert into ds3_userdata.TEST_BIOCHEM_IC50_FLAGS values ('172744', 'FT002787-17', 'RAF1', NULL, 0, 5);

-- get the differential, the 'left' table will grow as data is fed in; the 'right' table won't and so must add these to the IC50_FLAGS table
INSERT INTO Ds3_userdata.TEST_BIOCHEM_IC50_FLAGS 
(
 EXPERIMENT_ID, BATCH_ID, TARGET, VARIANT, FLAG, PROP1
)
SELECT       
    to_char(t1.experiment_id)                                                                            AS experiment_id,
    t1.id                                                                                                AS batch_id,   
    t5.target                                                                                            AS target,  
    t5.variant                                                                                           AS variant,
    0                                                                                                    AS flag,
    t1.prop1
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
    INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
    LEFT JOIN DS3_USERDATA.TEST_BIOCHEM_IC50_FLAGS T6 ON T1.EXPERIMENT_ID = T6.EXPERIMENT_ID
                                                            AND T1.id = T6.BATCH_ID
                                                            AND T1.prop1 = T6.prop1
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 181
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
    AND t6.batch_id IS NULL;

drop table ds3_userdata.TEST_BIOCHEM_IC50_FLAGS;


--delete from ds3_userdata.TEST_BIOCHEM_IC50_FLAGS;  


INSERT INTO Ds3_userdata.TEST2_BIOCHEM_IC50_FLAGS 
(
 PID, FLAG
)
SELECT       
    t1.pid                                                                                                AS pid,   
    0                                                                                                    AS flag
FROM
    ds3_userdata.ENZYME_INHIBITION_VW T1
    LEFT JOIN DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS T6 ON T1.pid = T6.pid
    WHERE T6.pid IS NULL
;


DELETE FROM ds3_userdata.TEST2_BIOCHEM_IC50_FLAGS WHERE PID IN ( 'BIO2018-1', 'BIO2018-2', 'BIO2018-3', 'BIO2018-4');




--testing of all columns join
-- no aggregate equivalent
SELECT
   t0.CRO AS CRO,
   t0.ASSAY_TYPE AS assay_type,
   t0.COMPOUND_ID AS compound_id,
   t0.TARGET AS target,
   t0.VARIANT AS variant,
   t0.COFACTORS AS cofactors,
   t0.FLAG AS FLAG,
   t0.PROP1,
   t0.graph,
   t0.ATP_CONC_UM AS atp_conc_uM,
   t0.ic50_nm,
   t0.GEOMEAN_NM AS geo_nM
    FROM 
    (
    SELECT  
        t3.CRO,  
        t3.ASSAY_TYPE,  
        t3.COMPOUND_ID,  
        t3.BATCH_ID,  
        t3.TARGET,  
        t3.VARIANT,  
        t3.COFACTORS,  
        t3.ATP_CONC_UM,  
        t3.MODIFIER,
        t3.ic50_nm,
        t3.flag,
        t3.prop1,
        t3.graph,
        ROUND(POWER(10, 
        AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
        t3.CRO,  
        t3.ASSAY_TYPE,  
        t3.COMPOUND_ID,  
        t3.TARGET,  
        t3.VARIANT,  
        t3.COFACTORS,  
        t3.ATP_CONC_UM,  
        t3.MODIFIER,
        t3.flag
        )) * TO_NUMBER('1.0e+09'), 1) AS geomean_nM
        FROM 
        (
          SELECT  
          t1.CRO,  
          t1.ASSAY_TYPE,
          t1.experiment_id,
          t1.COMPOUND_ID,  
          t1.BATCH_ID,  
          t1.TARGET,  
          t1.VARIANT,  
          t1.COFACTORS,  
          t1.ATP_CONC_UM,  
          t1.MODIFIER,
          t2.flag,
          t2.prop1,
          t1.ic50,
          t1.graph,
          t1.ic50_nm
          FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1 
          INNER JOIN DS3_USERDATA.TEST_BIOCHEM_IC50_FLAGS t2 
          ON t1.experiment_id = t2.experiment_id
          AND t1.batch_id = t2.batch_id
          AND nvl(t1.target,'-') = nvl(t2.target, '-')        
          AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
          WHERE
                t1.ASSAY_INTENT = 'Screening'
            AND t1.VALIDATED = 'VALIDATED' 
            AND t1.COMPOUND_ID = 'FT000194' 
        ) t3 
        ) t0;
        
--        AND t2.PROP1 = 66            
--            AND t2.TARGET = 'CDK12'
--            AND t2.VARIANT = 'C1039S'
--            AND t1.COFACTORS = 'CCNK'



SELECT       
    to_char(t1.experiment_id)                                                                            AS experiment_id,
    t1.id                                                                                                AS batch_id,
    t5.cell_line                                                                                         AS cell_line,  
    t5.variant                                                                                           AS variant,
    --t5.cell_incubation_hr as cell_incubation_hr,
    --t5.washout as washout,
    --t5.pct_serum as pct_serum,
    --t4.day_0_norm as day_0_norm,
    --t5.passage_number,
    t1.prop1
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
    --INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T4 ON T1.EXPERIMENT_ID = T4.EXPERIMENT_ID
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' );
    --AND t1.EXPERIMENT_ID = '142906';
    --AND t1.ID = 'FT001051';

                    

--- DELETE IC50 FLAGS
DROP TABLE DS3_USERDATA.TEST_CELLULAR_IC50_FLAGS;
--- CELLULAR IC50 FLAGS
CREATE TABLE DS3_USERDATA.TEST_CELLULAR_IC50_FLAGS AS (
SELECT
    MAX(t1.experiment_id)                                                                                     AS experiment_id,
    MAX(t1.id)                                                                                                AS batch_id,
    MAX(SUBSTR(t1.id, 1, 8))                                                                                  AS COMPOUND_ID,
    MAX(t5.cell_line)                                                                                         AS cell_line,  
    MAX(t5.variant)                                                                                           AS variant,
    MAX(0)                                                                                                    AS FLAG,
    --COUNT(*),
    MAX(t1.prop1) AS PROP1
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
GROUP BY
  t1.experiment_id,
   SUBSTR(t1.id, 1, 8), 
    t5.CELL_LINE,
    t5.VARIANT
    )
;


DROP TABLE DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS;
CREATE TABLE DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS AS (
SELECT       
    to_char(t1.experiment_id)                                                                            AS experiment_id,
    t1.id                                                                                                AS batch_id,
    t5.target                                                                                            AS target,  
    t5.variant                                                                                           AS variant,
    0 as FLAG,
    t1.prop1
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 181
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
);


SELECT
    COUNT(*) AS row_count
FROM
         ds3_userdata.test_cellular_ic50_flags
    UNION ALL
     (
        SELECT
            COUNT(DISTINCT(experiment_id
                           || batch_id
                           || nvl(cell_line, '-')
                           || nvl(variant, '-')
                           
                           || flag
                           || prop1 )) AS row_count                  
        FROM
            ds3_userdata.test_cellular_ic50_flags 
    )
    UNION ALL
    (
      SELECT
            COUNT(DISTINCT(experiment_id
                           || batch_id
                           || nvl(cell_line, '-')
                           || nvl(variant, '-')
                           
                           )) AS row_count                         
        FROM
            ds3_userdata.cellular_growth_drc
            );
            

--find difference in cellular ic50 flag table vs cellular growth drc
SELECT --*
 count(*) --4464
FROM
    ds3_userdata.cellular_growth_drc t1
    WHERE NOT EXISTS (
    SELECT 1 FROM DS3_USERDATA.TEST_CELLULAR_IC50_FLAGS T2 
  WHERE T1.EXPERIMENT_ID = T2.EXPERIMENT_ID
    AND T1.batch_id = T2.BATCH_ID
    AND nvl(t1.cell_line, '-') = nvl(t2.cell_line, '-')
    AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
    ) 
;
   
   
SELECT * FROM DS3_USERDATA.CELLULAR_GROWTH_DRC t0 INNER JOIN (
SELECT *
FROM
    ds3_userdata.cellular_growth_drc t1
    WHERE NOT EXISTS (
    SELECT 1 FROM DS3_USERDATA.TEST_CELLULAR_IC50_FLAGS T2 
  WHERE T1.EXPERIMENT_ID = T2.EXPERIMENT_ID
    AND T1.batch_id = T2.BATCH_ID
    AND nvl(t1.cell_line, '-') = nvl(t2.cell_line, '-')
    AND nvl(t1.pct_serum, '-') = nvl(t2.pct_serum, '-')
    AND nvl(t1.variant, '-') = nvl(t2.variant, '-')
    
    )
) t3 ON
    t0.experiment_id = t3.experiment_id
    AND t0.batch_id = t3.batch_id
    AND t0.cell_line = t3.cell_line
    AND t0.pct_serum = t3.pct_serum
    AND nvl(t0.variant, '-') = nvl(t0.variant, '-')
; 


select * from DS3_USERDATA.test_cellular_ic50_flags where
    cell_line = 'OVCAR-3'
    AND EXPERIMENT_ID = '142906'
    AND BATCH_ID = 'FT001051-02'
    
    ;
    
    
    
SELECT       
    t1.experiment_id                                                                            AS experiment_id,
    t1.id                                                                                                AS batch_id,
    SUBSTR(t1.id, 1, 8) AS COMPOUND_ID,
    t5.cell_line                                                                                         AS cell_line,  
    t5.variant                                                                                           AS variant,
    0 AS FLAG,
    substr(nvl2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
           || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), 3)                                AS cofactors,
    t1.prop1
FROM
    ds3_userdata.tm_conclusions t1
    INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                           AND t1.id = t5.batch_id
                                                           AND t1.prop1 = t5.prop1                                                                                                                                                                                                                              
    INNER JOIN DS3_USERDATA.TM_GRAPHS T2 ON T1.ID = T2.ID AND T1.EXPERIMENT_ID = T2.EXPERIMENT_ID AND T1.PROP1 = T2.PROP1
    INNER JOIN DS3_USERDATA.TM_EXPERIMENTS T3 ON T1.EXPERIMENT_ID = T3.EXPERIMENT_ID
WHERE
    t3.completed_date IS NOT NULL
    AND t1.protocol_id = 201
    AND ( t3.deleted IS NULL
          OR t3.deleted = 'N' )
    AND t1.EXPERIMENT_ID = '138744'
    AND CELL_LINE = 'IGR-OV1'
ORDER BY BATCH_ID, CELL_LINE, VARIANT, COFACTORS
;


--select * from tm_conclusions where experiment_id = '150864';
--select * from ds3_userdata.tm_sample_property_pivot
--where EXPERIMENT_ID = '150864';