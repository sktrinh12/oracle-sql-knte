select COMPOUND_ID, IC50_NM, CREATED_DATE, ROW_COUNT, CNT, DIFF_IC50,AVG_IC50 from (
        select COMPOUND_ID, IC50_NM, CREATED_DATE, ROW_COUNT, CNT,
            SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) OVER (PARTITION BY COMPOUND_ID) DIFF_IC50,
            (SUM(IC50_LOG10) OVER (PARTITION BY COMPOUND_ID))/2 AVG_IC50
            FROM ( SELECT otbl.COMPOUND_ID, otbl.IC50_NM, otbl.CREATED_DATE, otbl.ROW_COUNT, otbl.cnt, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
--                select COMPOUND_ID, created_date, ic50_nm, ic50,
                        row_number () over ( partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
--                from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc')) t1
                from table(most_recent_ft_nbrs('Pharmaron', 'CellTiter-Glo', 'cell_line =''Ba/F3''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'variant = ''TPR-MET-wt''', 'su_cellular_growth_drc')) t1
                INNER JOIN (select PID, IC50_NM, IC50 from ds3_userdata.su_cellular_growth_drc WHERE VALIDATED != 'INVALIDATED' and assay_intent = 'Screening') t2 
                ON t1.PID = t2.PID
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl )
        )
       -- WHERE ROW_COUNT = 1
       --WHERE COMPOUND_ID = 'FT009067'
        ORDER BY CREATED_DATE DESC, ROW_COUNT, COMPOUND_ID
--        FETCH NEXT 20 ROWS ONLY        
;


with ranked_cmpids AS (
select COMPOUND_ID, IC50_NM, CREATED_DATE, ROW_COUNT, CNT, IC50_LOG10
           
            FROM ( SELECT otbl.COMPOUND_ID, otbl.IC50_NM, otbl.CREATED_DATE, otbl.ROW_COUNT, otbl.cnt, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
--                select COMPOUND_ID, created_date, ic50_nm, ic50,
                        row_number () over ( partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
--                from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc')) t1
                from table(most_recent_ft_nbrs('Pharmaron', 'CellTiter-Glo', 'cell_line =''Ba/F3''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'variant = ''TPR-MET-wt''', 'su_cellular_growth_drc')) t1
                INNER JOIN (select PID, IC50_NM, IC50 from ds3_userdata.su_cellular_growth_drc WHERE VALIDATED != 'INVALIDATED' and assay_intent = 'Screening') t2 
                ON t1.PID = t2.PID
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        ) otbl )
        )
--     SELECT  t_msr_data_type(COMPOUND_ID, CREATED_DATE, ROW_COUNT, AVG_IC50, DIFF_IC50) FROM (
    SELECT tbl1.COMPOUND_ID,  --tbl2.CREATED_DATE, tbl1.ROW_COUNT, (tbl1.IC50_LOG10+tbl2.IC50_LOG10)/2 AVG_IC50, tbl1.IC50_LOG10-tbl2.IC50_LOG10 DIFF_IC50 
--            tbl1.ROW_COUNT,
            tbl1.CREATED_DATE, 
            tbl2.CREATED_DATE, 
--            tbl1.ROW_COUNT, 
--            tbl2.ROW_COUNT, 
--            tbl1.CNT, 
            tbl1.IC50_NM, 
            tbl2.IC50_NM, 
--            tbl1.IC50_LOG10, 
--            tbl2.IC50_LOG10, 
            (tbl1.IC50_LOG10+tbl2.IC50_LOG10)/2 AVG_IC50, 
            tbl1.IC50_LOG10-tbl2.IC50_LOG10 DIFF_IC50 
    from ranked_cmpids tbl1
    INNER JOIN ranked_cmpids tbl2
    ON tbl1.row_count = tbl2.row_count+1 and tbl1.compound_id = tbl2.compound_id
    ORDER BY tbl1.CREATED_DATE DESC, tbl2.CREATED_DATE DESC, tbl1.COMPOUND_ID
--)    
    FETCH NEXT 20 ROWS ONLY
    
        ;
      
     




select * from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'Ba/F3', '72', '10', 'TPR-MET-wt', 'su_cellular_growth_drc'))
order by CREATED_DATE DESC, COMPOUND_ID; --where compound_id = 'FT008741';

select * from su_cellular_growth_drc where compound_id = 'FT008741' and created_date between TO_DATE('01-NOV-22', 'DD-MON-YY') and TO_DATE('05-NOV-22', 'DD-MON-YY');
cro = 'Pharmaron' and assay_type = 'CellTiter-Glo'
and cell_line = 'Ba/F3'
and cell_incubation_hr = '72'
and pct_serum = '10'
and variant = 'TPR-MET-wt'
order by created_date DESC
;


select * from tm_experiments where experiment_id in (208697,
208836,
209788,
209788,
210948);


SELECT
                    experiment_id,
                    nvl(variant_1, '-') AS variant,
                    plate_set
                   
                FROM
                    su_plate_prop_pivot
                where experiment_id = 208697
                    ;
                    
                    
select * from tm_experiments where experiment_id = 208697
;

SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id =208697
                        ;

SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = 208697
                    AND property_name = 'Assay Type'
                    ;
                    
                    
select * from (
 SELECT        
            to_char(T4.EXPERIMENT_ID) experiment_id,           
            SUBSTR(T3.DISPLAY_NAME, 1, 8)  COMPOUND_ID,
            T8.PROJECT ,                    
            T8.CRO ,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC))              AS IC50,
            TO_NUMBER(NVL(REGEXP_REPLACE(T1.REPORTED_RESULT, '[A-DF-Za-z\<\>~= ]'), T1.RESULT_NUMERIC)) * 1000000000 AS IC50_NM,            
               CASE T1.STATUS
                    WHEN 1 THEN  'VALIDATED'                    
                    ELSE         'INVALIDATED'
                END VALIDATION,
            T9.CELL_LINE ,
            T9.VARIANT_1 variant,
            NVL(T9.PCT_SERUM, 10) PCT_SERUM,          
            T9.CELL_INCUBATION_HR,
            T8.ASSAY_TYPE,       
            T4.CREATED_DATE 
        FROM
                 DS3_USERDATA.SU_ANALYSIS_RESULTS T1
            INNER JOIN DS3_USERDATA.SU_GROUPINGS            T2 ON T1.GROUP_ID = T2.ID
            INNER JOIN DS3_USERDATA.SU_SAMPLES              T3 ON T2.SAMPLE_ID = T3.ID
            INNER JOIN DS3_USERDATA.TM_EXPERIMENTS          T4 ON T2.EXPERIMENT_ID = T4.EXPERIMENT_ID and t4.protocol_id = 441
            INNER JOIN DS3_USERDATA.TM_PROTOCOL_PROPS_PIVOT T8 ON T8.EXPERIMENT_ID = T2.EXPERIMENT_ID 
            RIGHT OUTER JOIN DS3_USERDATA.SU_PLATE_PROP_PIVOT     T9 ON T9.EXPERIMENT_ID = T2.EXPERIMENT_ID
                                                                    AND T9.PLATE_SET = T2.PLATE_SET
        WHERE
            T4.COMPLETED_DATE IS NOT NULL
            AND T1.STATUS = 1
            AND nvl(T4.DELETED,'N')='N'
            )
            WHERE
            compound_id  = 'FT006719'
             AND VALIDATION = 'VALIDATED'
            AND cro = 'Pharmaron'
            AND assay_type = 'CellTiter-Glo'
            AND cell_line = 'Ba/F3'
            AND cell_incubation_hr = 72
            AND pct_serum = 10
            and variant = 'TPR-MET-wt'
            ;
            
            
select COMPOUND_ID, CREATED_DATE, IC50_NM from SU_CELLULAR_GROWTH_DRC where COMPOUND_ID IN (
'FT008613',
'FT008622',
'FT008639',
'FT008694',
'FT008718',
'FT008740',
'FT008741',
'FT008798',
'FT008821',
'FT008868',
'FT008869',
'FT008870',
'FT008893',
'FT008894',
'FT008923',
'FT008944',
'FT008945',
'FT008947',
'FT008980',
'FT009007'
)
AND cro = 'Pharmaron'
AND assay_type = 'CellTiter-Glo'
AND cell_line = 'Ba/F3'
AND cell_incubation_hr = 72
AND pct_serum = 10
and variant = 'TPR-MET-wt'
AND ASSAY_INTENT = 'Screening'
ORDER BY CREATED_DATE DESC, COMPOUND_ID
;


select 
COMPOUND_ID, CREATED_DATE, IC50_NM from SU_CELLULAR_GROWTH_DRC where COMPOUND_ID ='FT008740'
AND cro = 'Pharmaron'
AND assay_type = 'CellTiter-Glo'
AND cell_line = 'Ba/F3'
AND cell_incubation_hr = 72
AND pct_serum = 10
and variant = 'TPR-MET-wt'
AND ASSAY_INTENT = 'Screening'
ORDER BY CREATED_DATE DESC, COMPOUND_ID