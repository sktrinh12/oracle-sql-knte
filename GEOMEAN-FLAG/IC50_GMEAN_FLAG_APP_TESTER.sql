select 
                t3.PID,
                t3.CRO,
                t3.ASSAY_TYPE,
                t3.COMPOUND_ID,
                t3.EXPERIMENT_ID,
                t3.BATCH_ID,
                t3.TARGET,
                t3.VARIANT,
                t3.COFACTORS,
                t3.ATP_CONC_UM,
                t3.MODIFIER,
                BASE64ENCODE(t3.GRAPH) as GRAPH,
                ROUND(t3.ic50_nm,2) as IC50_NM,
                t3.flag,
             ROUND( POWER(10,
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
                )) * TO_NUMBER('1.0e+09'), 1) AS GEOMEAN
                FROM (
              SELECT t1.CRO,
                     t1.ASSAY_TYPE,
                     t1.experiment_id,
                     t1.COMPOUND_ID,
                     t1.BATCH_ID,
                     t1.TARGET,
                     t1.VARIANT,
                     t1.COFACTORS,
                     t1.ATP_CONC_UM,
                     t1.MODIFIER,
                     t1.GRAPH,
                     t2.flag,
                     t1.ic50,
                     t1.ic50_nm,
                     t1.PID
               FROM DS3_USERDATA.ENZYME_INHIBITION_VW t1
              INNER JOIN DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS t2
                 ON t1.pid = t2.pid
              ) t3
              WHERE t3.COMPOUND_ID = 'FT000953' AND t3.CRO = 'Pharmaron'
                      AND t3.MODIFIER IS NULL
                      AND t3.ATP_CONC_UM = 3.0
                      AND t3.ASSAY_TYPE = 'ADP-GLO'
                      AND t3.TARGET = 'BRAF'
                      AND t3.VARIANT IS NULL
                      AND t3.COFACTORS IS NULL

;


select * from DS3_USERDATA.CELLULAR_GROWTH_DRC;