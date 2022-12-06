--CELLULAR-------
SELECT
    'CELL'
    || to_char(YEAR)
    || '-'
--    || cell_id_seq.NEXTVAL AS pid
    || TO_CHAR(ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY YEAR)) AS PID
    ,q.*
FROM
    (
        SELECT
            to_char(t1.experiment_id)                                                                            AS experiment_id,
            substr(t1.id, 1, 8)                                                                                  AS compound_id,
            t1.id                                                                                                AS batch_id,
            t4.project                                                                                           AS project,
            t4.cro                                                                                               AS cro,
            t3.descr                                                                                             AS descr,
            t1.analysis_name                                                                                     AS analysis_name,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric))              AS ic50,
            - log(10, to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)))   AS pic50,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            substr(t1.result_alpha, 1, 1)                                                                        AS modifier,
            t1.validated                                                                                         AS validated,
            to_number(t1.param1)                                                                                 AS minimum,
            to_number(t1.param2)                                                                                 AS maximum,
            to_number(t1.param3)                                                                                 AS slope,
            to_number(t1.param6)                                                                                 AS r2,
            to_number(t1.err)                                                                                    AS err,
            t2.file_blob                                                                                         AS graph,
            t5.cell_line                                                                                         AS cell_line,
            t5.cell_variant                                                                                      AS variant,
            t5.passage_number                                                                                    AS passage_number,
            nvl(t5.washout, 'N')                                                                                 AS washout,
            nvl(t5.pct_serum, 10)                                                                                AS pct_serum,
            nvl(t4.day_0_norm, 'N')                                                                              AS day_0_norm,
            t4.assay_type                                                                                        AS assay_type,
            t4.assay_intent                                                                                      AS assay_intent,
            t4.threed                                                                                            AS threed,
            t5.compound_incubation_hr                                                                            AS compound_incubation_hr,
            t5.cell_incubation_hr                                                                                AS cell_incubation_hr,
            t4.assay_type
            || ' '
            || t5.cell_incubation_hr                                                                             AS assay_cell_incubation,
            t5.treatment                                                                                         AS treatment,
            t5.treatment_conc_um                                                                                 AS treatment_conc_um,
            t4.donor                                                                                             AS donor,
            t4.acceptor                                                                                          AS acceptor,
            t3.created_date                                                                                      AS created_date,
            EXTRACT(YEAR FROM t3.CREATED_DATE)                                                                   AS year,
            t3.isid                                                                                              AS scientist
        FROM
                 ds3_userdata.tm_experiments t3
            INNER JOIN ds3_userdata.tm_conclusions           t1 ON t3.experiment_id = t1.experiment_id
            INNER JOIN ds3_userdata.tm_graphs                t2 ON t1.id = t2.id
                                                    AND t1.experiment_id = t2.experiment_id
                                                    AND t1.prop1 = t2.prop1
            INNER JOIN ds3_userdata.tm_protocol_props_pivot  t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                                   AND t1.id = t5.batch_id
                                                                   AND t1.prop1 = t5.prop1
        WHERE
            t3.completed_date IS NOT NULL
            AND t1.protocol_id = 201
            AND ( t3.deleted IS NULL
                  OR t3.deleted = 'N' )
        ORDER BY
            t1.id,
            t5.cell_line
    ) q
    ORDER BY q.YEAR, q.batch_id, q.cell_line
    ;
    

DROP SEQUENCE ds3_userdata.cell_id_seq;

CREATE SEQUENCE ds3_userdata.cell_id_seq INCREMENT BY 1 START WITH 1 MINVALUE 1 MAXVALUE 1000000 CYCLE CACHE 2;

SELECT
    cell_id_seq.NEXTVAL
FROM
    dual;

SELECT
    cell_id_seq.CURRVAL
FROM
    dual;

SELECT
    *
FROM
    ds3_userdata.cellular_growth_drc;

drop table DS3_USERDATA.TEST2_CELLULAR_IC50_FLAGS;

CREATE TABLE ds3_userdata.test2_cellular_ic50_flags
    AS
        ( SELECT
            pid,
            0 AS flag
        FROM
            ds3_userdata.cellular_growth_drc
        );

SELECT
    *
FROM
    ds3_userdata.test2_cellular_ic50_flags;

SELECT
    t3.pid,
    t3.cro,
    t3.assay_type,
    t3.compound_id,
    t3.experiment_id,
    t3.batch_id,
    t3.cell_line,
    t3.variant,
    t3.pct_serum,
    t3.passage_number,
    t3.washout,
    t3.cell_incubation_hr,
    base64encode(t3.graph)                                                                                   AS graph,
    round(t3.ic50_nm, 2)                                                                                     AS ic50_nm,
    t3.flag,
    round(power(10, AVG(log(10, t3.ic50))
                    OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.cell_line, t3.variant,
                                      t3.pct_serum, t3.washout, t3.passage_number, t3.cell_incubation_hr, t3.flag)) * to_number('1.0e+09'),
                                      2) AS geomean
FROM
    (
        SELECT
            t1.pid,
            t1.cro,
            t1.assay_type,
            t1.experiment_id,
            t1.compound_id,
            t1.batch_id,
            t1.cell_line,
            t1.variant,
            t1.pct_serum,
            t1.washout,
            t1.passage_number,
            t1.cell_incubation_hr,
            t1.graph,
            t2.flag,
            t1.ic50,
            t1.ic50_nm
        FROM
                 ds3_userdata.cellular_growth_drc t1
            INNER JOIN ds3_userdata.test2_cellular_ic50_flags t2 ON t1.pid = t2.pid
    ) t3
WHERE
        t3.compound_id = 'FT002787'
    AND t3.cell_line = 'WM3629'
    AND t3.pct_serum = 2
    AND t3.assay_type = 'HTRF'
    AND t3.cell_incubation_hr = '24'
    AND t3.variant IS NULL
    AND t3.washout = 'N'
    AND t3.passage_number = '15';

SELECT
    t3.pid,
    t3.cro,
    t3.assay_type,
    t3.compound_id,
    t3.experiment_id,
    t3.batch_id,
    t3.cell_line,
    t3.variant,
    t3.pct_serum,
    t3.passage_number,
    t3.washout,
    t3.cell_incubation_hr,
    base64encode(t3.graph)                                                                                   AS graph,
    round(t3.ic50_nm, 2)                                                                                     AS ic50_nm,
    t3.flag,
    round(power(10, AVG(log(10, t3.ic50))
                    OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.cell_line, t3.variant,
                                      t3.pct_serum, t3.washout, t3.passage_number, t3.cell_incubation_hr, t3.flag)) * to_number('1.0e+09'),
                                      2) AS geomean
FROM
    (
        SELECT
            t1.cro,
            t1.assay_type,
            t1.experiment_id,
            t1.compound_id,
            t1.batch_id,
            t1.cell_line,
            t1.variant,
            t1.pct_serum,
            t1.washout,
            t1.passage_number,
            t1.cell_incubation_hr,
            t1.graph,
            t2.flag,
            t1.ic50,
            t1.pid,
            t1.ic50_nm
        FROM
                 ds3_userdata.cellular_growth_drc t1
            INNER JOIN ds3_userdata.test2_cellular_ic50_flags t2 ON t1.pid = t2.pid
    ) t3
WHERE
    t3.compound_id = 'FT000086';

SELECT
    *
FROM
    ds3_userdata.cellular_growth_drc
WHERE
    compound_id = 'FT000086';

--BIOCHEM-----
DROP SEQUENCE ds3_userdata.bio_id_seq;

CREATE SEQUENCE ds3_userdata.bio_id_seq INCREMENT BY 1 START WITH 1 MINVALUE 1 MAXVALUE 1000000 CYCLE CACHE 2;

SELECT
    q.*,
    'BIO'
    || to_char(YEAR)
    || '-'
--    || bio_id_seq.NEXTVAL AS pid
    || TO_CHAR(ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY YEAR)) AS PID
    FROM 
    (
        SELECT
            to_char(t1.experiment_id)                                                                            AS experiment_id,
            substr(t1.id, 1, 8)                                                                                  AS compound_id,
            t1.id                                                                                                AS batch_id,
            t4.project                                                                                           AS project,
            t4.cro                                                                                               AS cro,
            t3.descr                                                                                             AS descr,
            t4.assay_type                                                                                        AS assay_type,
            t4.assay_intent                                                                                      AS assay_intent,
            t1.analysis_name                                                                                     AS analysis_name,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric))              AS ic50,
            - log(10, to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)))   AS pic50,
            to_number(nvl(regexp_replace(t1.result_alpha, '[A-DF-Za-z\<\>~=]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            substr(t1.result_alpha, 1, 1)                                                                        AS modifier,
            t1.validated                                                                                         AS validated,
            to_number(t1.param1)                                                                                 AS minimum,
            to_number(t1.param2)                                                                                 AS maximum,
            to_number(t1.param3)                                                                                 AS slope,
            t1.param6                                                                                            AS r2,
            to_number(t1.err)                                                                                    AS err,
            CASE
                WHEN t1.result_numeric > 0 THEN
                    power(10,(log(10, t1.result_numeric) - t1.result_delta))
                ELSE
                    NULL
            END                                                                                                  AS ic50_min_confidence,
            CASE
                WHEN ( t1.result_numeric > 0
                       AND t1.result_delta < 100 ) THEN
                    power(10,(log(10, t1.result_numeric) + t1.result_delta))
                ELSE
                    NULL
            END                                                                                                  AS ic50_max_confidence,
            CASE
                WHEN t1.result_numeric > 0 THEN
                    - log(10, t1.result_numeric) - t1.result_delta
                ELSE
                    NULL
            END                                                                                                  AS pic50_min_confidence,
            CASE
                WHEN ( t1.result_numeric > 0
                       AND t1.result_delta < 100 ) THEN
                    - log(10, t1.result_numeric) + t1.result_delta
                ELSE
                    NULL
            END                                                                                                  AS pic50_max_confidence,
            t2.file_blob                                                                                         AS graph,
            t5.target                                                                                            AS target,
            t5.variant                                                                                           AS variant,
            t5.target
            || nvl2(t5.variant, ' ' || t5.variant, NULL)                                                         AS target_variant,
            t5.cofactor_1                                                                                        AS cofactor_1,
            t5.cofactor_2                                                                                        AS cofactor_2,
            substr(nvl2(t5.cofactor_1, ', ' || t5.cofactor_1, NULL)
                   || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), 3)                                              AS cofactors,
            t5.target
            || nvl2(substr(nvl2(t5.cofactor_1, ', /' || t5.cofactor_1, NULL)
                           || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2, NULL), 3), substr(nvl2(t5.cofactor_1, ', /' || t5.cofactor_1,
                           NULL)
                                                                                           || nvl2(t5.cofactor_2, ', ' || t5.cofactor_2,
                                                                                           NULL), 3), NULL)                                       AS
                                                                                           target_cofactors,
            t4.thiol_free                                                                                        AS thiol_free,
            nvl(t4.atp_conc_um, t5.atp_conc_um)                                                                  AS atp_conc_um,
            t5.substrate_incubation_min                                                                          AS substrate_incubation_min,
            t3.created_date                                                                                      AS created_date,
            EXTRACT(YEAR FROM t3.CREATED_DATE)                                                                   AS year,
            t3.isid                                                                                              AS scientist
        FROM
                 ds3_userdata.tm_conclusions t1
            INNER JOIN ds3_userdata.tm_graphs                t2 ON t1.id = t2.id
                                                    AND t1.experiment_id = t2.experiment_id
                                                    AND t1.prop1 = t2.prop1
            INNER JOIN ds3_userdata.tm_experiments           t3 ON t1.experiment_id = t3.experiment_id
            INNER JOIN ds3_userdata.tm_protocol_props_pivot  t4 ON t1.experiment_id = t4.experiment_id
            INNER JOIN ds3_userdata.tm_sample_property_pivot t5 ON t1.experiment_id = t5.experiment_id
                                                                   AND t1.id = t5.batch_id
                                                                   AND t1.prop1 = t5.prop1
        WHERE
            t3.completed_date IS NOT NULL
            AND t1.protocol_id = 181
            AND ( t3.deleted IS NULL
                  OR t3.deleted = 'N' )
        ORDER BY
            t1.id,
            t5.target,
            t5.variant
    ) q
ORDER BY q.YEAR, q.batch_id, q.target, q.variant
;

drop table DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS;

CREATE TABLE ds3_userdata.test2_biochem_ic50_flags
    AS
        ( SELECT
            pid,
            0 AS flag
        FROM
            ds3_userdata.enzyme_inhibition_vw
        );


SELECT
    t3.pid,
    t3.cro,
    t3.assay_type,
    t3.compound_id,
    t3.experiment_id,
    t3.batch_id,
    t3.target,
    t3.variant,
    t3.cofactors,
    t3.atp_conc_um,
    t3.modifier,
    base64encode(t3.graph)                                                          AS graph,
    round(t3.ic50_nm, 2)                                                            AS ic50_nm,
    t3.flag,
    round(power(10, AVG(log(10, t3.ic50))
                    OVER(PARTITION BY t3.cro, t3.assay_type, t3.compound_id, t3.target, t3.variant,
                                      t3.cofactors, t3.atp_conc_um, t3.modifier, t3.flag)) * to_number('1.0e+09'), 1) AS geomean_nm
FROM
    (
        SELECT
            t1.cro,
            t1.assay_type,
            t1.experiment_id,
            t1.compound_id,
            t1.batch_id,
            t1.target,
            t1.variant,
            t1.cofactors,
            t1.atp_conc_um,
            t1.modifier,
            t1.graph,
            t2.flag,
            t1.pid,
            t1.ic50,
            t1.ic50_nm
        FROM
                 ds3_userdata.enzyme_inhibition_vw t1
            INNER JOIN ds3_userdata.test2_biochem_ic50_flags t2 ON t1.pid = t2.pid                                                                 
    ) t3
WHERE
    t3.compound_id = 'FT000086';
    
    
    
    
    SELECT
                t3.PID,
                t3.CRO,
                t3.ASSAY_TYPE,
                t3.COMPOUND_ID,
                t3.EXPERIMENT_ID,
                t3.BATCH_ID,
                t3.CELL_LINE,
                t3.VARIANT,
                t3.PCT_SERUM,
                t3.PASSAGE_NUMBER,
                t3.WASHOUT,
                t3.CELL_INCUBATION_HR,
                BASE64ENCODE(t3.GRAPH) as GRAPH,
                ROUND(t3.ic50_nm,2) as IC50_NM,
                t3.flag,
                ROUND( POWER(10,
                   AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
                    t3.CRO,
                    t3.ASSAY_TYPE,
                    t3.COMPOUND_ID,
                    t3.CELL_LINE,
                    t3.VARIANT,
                    t3.PCT_SERUM,
                    t3.WASHOUT,
                    t3.PASSAGE_NUMBER,
                    t3.CELL_INCUBATION_HR,
                    t3.flag
                )) * TO_NUMBER('1.0e+09'), 2) AS GEOMEAN
                FROM (
              SELECT t1.CRO,
                     t1.ASSAY_TYPE,
                     t1.experiment_id,
                     t1.COMPOUND_ID,
                     t1.BATCH_ID,
                     t1.CELL_LINE,
                     t1.VARIANT,
                     t1.PCT_SERUM,
                     t1.WASHOUT,
                     t1.PASSAGE_NUMBER,
                     t1.CELL_INCUBATION_HR,
                     t1.GRAPH,
                     t2.flag,
                     t1.ic50,
                     t1.PID,
                     t1.ic50_nm
               FROM DS3_USERDATA.CELLULAR_GROWTH_DRC t1
              INNER JOIN DS3_USERDATA.TEST2_CELLULAR_IC50_FLAGS t2
                 ON t1.pid = t2.pid
              ) t3
              WHERE t3.COMPOUND_ID = 'FT000086'
;


select * from DS3_USERDATA.TEST2_CELLULAR_IC50_FLAGS order by PID DESC; --where PID in ('CELL2019-646674', 'CELL2019-646675', 'CELL2019-646676', 'CELL2019-646677');
select * from DS3_USERDATA.CELLULAR_GROWTH_DRC;

select * from DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS order by PID DESC;
select * from DS3_USERDATA.enzyme_inhibition_vw;

select * from DS3_USERDATA.enzyme_inhibition_vw where PID like 'BIO2018-%';


select t.*, 
MOD(t.rn, TO_NUMBER('1e+06'))
FROM
(
select 
rownum rn,
q.* 
from DS3_USERDATA.enzyme_inhibition_vw q
) t
;



SELECT
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
--               FROM DS3_USERDATA.COPY_ENZYME_INHIBITION_VW t1
--              INNER JOIN DS3_USERDATA.TEST2_BIOCHEM_IC50_FLAGS t2
--                 ON t1.pid = t2.pid
--              ) t3
FROM
                 ds3_userdata.enzyme_inhibition_vw t1
            INNER JOIN ds3_userdata.test2_biochem_ic50_flags t2 ON t1.pid = t2.pid                                                                 
    ) t3
WHERE
    t3.compound_id = 'FT000086'
             -- WHERE t3.COMPOUND_ID = 'FT000086'
               --t3.PID IN ('BIO2018-378','BIO2018-377','BIO2018-376','BIO2018-375')
;




SELECT
                t3.PID,
                t3.CRO,
                t3.ASSAY_TYPE,
                t3.COMPOUND_ID,
                t3.EXPERIMENT_ID,
                t3.BATCH_ID,
                t3.CELL_LINE,
                t3.VARIANT,
                t3.PCT_SERUM,
                t3.PASSAGE_NUMBER,
                t3.WASHOUT,
                t3.CELL_INCUBATION_HR,
                BASE64ENCODE(t3.GRAPH) as GRAPH,
                ROUND(t3.ic50_nm,2) as IC50_NM,
                t3.flag,
                ROUND( POWER(10,
                   AVG( LOG(10, t3.ic50) ) OVER(PARTITION BY
                    t3.CRO,
                    t3.ASSAY_TYPE,
                    t3.COMPOUND_ID,
                    t3.CELL_LINE,
                    t3.VARIANT,
                    t3.PCT_SERUM,
                    t3.WASHOUT,
                    t3.PASSAGE_NUMBER,
                    t3.CELL_INCUBATION_HR,
                    t3.flag
                )) * TO_NUMBER('1.0e+09'), 2) AS GEOMEAN
                FROM (
              SELECT t1.CRO,
                     t1.ASSAY_TYPE,
                     t1.experiment_id,
                     t1.COMPOUND_ID,
                     t1.BATCH_ID,
                     t1.CELL_LINE,
                     t1.VARIANT,
                     t1.PCT_SERUM,
                     t1.WASHOUT,
                     t1.PASSAGE_NUMBER,
                     t1.CELL_INCUBATION_HR,
                     t1.GRAPH,
                     t2.flag,
                     t1.ic50,
                     t1.PID,
                     t1.ic50_nm
               FROM DS3_USERDATA.CELLULAR_GROWTH_DRC t1
              INNER JOIN DS3_USERDATA.TEST2_CELLULAR_IC50_FLAGS t2
                 ON t1.pid = t2.pid
              ) t3
              WHERE t3.COMPOUND_ID = 'FT001051' AND t3.CRO = 'Pharmaron'
                  AND t3.CELL_LINE = 'HCC70'
                  AND t3.PCT_SERUM = 10
                  AND t3.ASSAY_TYPE = 'CellTiter-Glo'
                  AND t3.CELL_INCUBATION_HR = '72'
                  AND t3.VARIANT IS NULL
                  AND t3.WASHOUT = 'N'
                  AND t3.PASSAGE_NUMBER IS NULL
                  
;

select * FROM DS3_USERDATA.CELLULAR_GROWTH_DRC t3
where t3.COMPOUND_ID = 'FT001051' AND t3.CRO = 'Pharmaron'
                  AND t3.CELL_LINE = 'HCC70'
                  AND t3.PCT_SERUM = 10
                  AND t3.ASSAY_TYPE = 'CellTiter-Glo'
                  AND t3.CELL_INCUBATION_HR = '72'
                  AND t3.VARIANT IS NULL
                  AND t3.WASHOUT = 'N'
                  AND t3.PASSAGE_NUMBER IS NULL;
                  

       
       
       