
select t1.ASsay_type, t1.batch_id, t1.cell_incubation_hr, t1.cell_line, t1.compound_id, t1.created_date, t1.cro, t1.IC50_NM, t1.passage_number, t1.pct_serum  from su_cellular_growth_drc t1
inner join (
--select * from table(most_recent_ft_nbrs2('Pharmaron', 'HTRF', 'cell_line = ''DBTRG-05MG''', 'cell_incubation_hr = 1', 'pct_serum = 10', 'su_cellular_growth_drc')) 
select * from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'cell_line = ''Ba/F3''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'su_cellular_growth_drc'))
) t2
ON t1.pid = t2.pid 
order by t1.compound_id, t1.CREATED_DATE DESC;

select * from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'cell_line = ''Ba/F3''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'su_cellular_growth_drc'));


select * from table(most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'target = ''MET''', 'ATP_CONC_UM = 100', 'cofactors is null', 'su_test_biochem_drc'));


select calc_msr2('Pharmaron', 'Caliper', 'target = ''''MET''''', 'ATP_CONC_UM = 100', 'cofactors is null', 'TEST_SU_BIOCHEM_DRC_LESS_10000', 20) MSR from dual;

select calc_msr2('Pharmaron', 'Caliper', 'target = ''''MET''''', 'ATP_CONC_UM = 100', 'cofactors is null', 'SU_BIOCHEM_DRC', 20) MSR from dual;

select calc_msr2('Pharmaron', 'HTRF', 'cell_line = ''''DBTRG-05MG''''', 'cell_incubation_hr = 1', 'pct_serum = 10', 'su_cellular_growth_drc', 20) MSR from dual;
select calc_msr2('Pharmaron', 'CellTiter-Glo', 'cell_line = ''''Ba/F3''''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'su_cellular_growth_drc', 20) MSR from dual;
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211215, 20);
select * from ds3_userdata.GEN_GEOMEAN_CURVE_TBL(211253, 20) ;

select power(10, DIFF_IC50) MSR from (
 select COMPOUND_ID, SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) DIFF_IC50
        FROM (
        SELECT otbl.COMPOUND_ID, otbl.created_date, otbl.ROW_COUNT, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
                        row_number () over (
                         partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs2('Pharmaron', 'CellTiter-Glo', 'cell_line = ''Ba/F3''', 'cell_incubation_hr = 72', 'pct_serum = 10', 'su_cellular_growth_drc')) t1
                --'Pharmaron', 'HTRF', 'cell_line = ''DBTRG-05MG''', 'cell_incubation_hr = 1', 'pct_serum = 10', 'su_cellular_growth_drc')) t1
                INNER JOIN (select PID, IC50_NM, IC50 from ds3_userdata.su_cellular_growth_drc WHERE VALIDATED != 'INVALIDATED') t2 
                ON t1.PID = t2.PID
                WHERE t2.IC50_NM < 10000
                ORDER BY                    
                    t1.created_date DESC
                    --t1.compound_id
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        FETCH NEXT 20 *2 ROWS ONLY
        ) otbl )
         GROUP BY COMPOUND_ID
         )
         --ORDER BY COMPOUND_ID, created_date desc
         ;


select /*+ RESULT_CACHE */ ot.*  from (
--select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
select t2.ic50_nm, t2.ic50, t2.COMPOUND_ID, t1.created_date,
                        row_number () over (
                         partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'target = ''MET''', 'ATP_CONC_UM = 100', 'cofactors is null', 'su_biochem_drc')) t1
                INNER JOIN (select PID, COMPOUND_ID, IC50_NM, IC50 from ds3_userdata.SU_BIOCHEM_DRC where VALIDATED != 'INVALIDATED') t2 
                ON t1.PID = t2.PID
                ORDER BY
                    --t1.compound_id,
                    t1.created_date DESC
                    ) ot
where ot.IC50_NM < 10000
and ot.cnt >1
        AND ot.row_count <=2
        --FETCH NEXT %s *2 ROWS ONLY
        order by ot.created_date DESC, ot.compound_id
;


select PID, COMPOUND_ID, IC50_NM, IC50 from ds3_userdata.SU_BIOCHEM_DRC where IC50_NM IS NOT NULL;

select count(*) from ds3_userdata.SU_BIOCHEM_DRC where IC50_NM IS NOT NULL;

with test_case as (
    select '1' as num_field from dual 
    union all
    select '2' from dual 
    union all
    select 'string' from dual
    )
    select num_field,
    validate_conversion(num_field as number) is_number,
    cast(num_field as number default 0 on conversion error) conversion_return
    from test_case;
    
with test_ic50 as (
SELECT pid, to_number(ic50_nm) the_number, validate_conversion(ic50_nm as number) is_number,
    cast(ic50_nm as number default 0 on conversion error) conver_return
  FROM su_biochem_drc
  )
  select * from test_ic50 where is_number != 1 or conver_return = 0
;

--with test_val as (
  select PID, CASE WHEN REGEXP_COUNT(IC50_NM, '[[:alpha:]]', 1) > 1
  THEN '#PROBLEM#'
  ELSE '#OK#'
  END CHECK_VAL
  from su_biochem_drc 
--  )
--  select pid from test_val where check_val != '#OK#'
  ;
  
  select * from su_test_biochem_drc where regexp_count(trim(ic50_nm), ',') >1;

SELECT ic50_nm
                    FROM su_test_biochem_drc
                   WHERE REGEXP_LIKE (trim(ic50_nm)
                   , '[[:alpha:]]')
                   ;

                    
select 10000/1E9 from dual;
                    
select sum(to_number(ic50_nm)) from su_biochem_drc;
    
create table TEST_SU_BIOCHEM_DRC_LESS_1000 as (        
select PID, TO_NUMBER(IC50_NM) IC50_NM, TO_NUMBER(IC50) IC50 from su_biochem_drc where ic50_nm < 10000
);





SELECT pid, to_number(ic50_nm)
  FROM su_biochem_drc
 WHERE ic50_nm NOT IN (SELECT ic50_nm
                    FROM su_biochem_drc
                   WHERE REGEXP_LIKE (ic50_nm, '[[:alpha:]]'));
                   
                   
create table TEST_SU_BIOCHEM_DRC_LESS_10000 as (   
SELECT pid, ic50_nm, ic50 
               FROM TEMP_SU_BIOCHEM_DRC_LESS_10000 where ic50_nm < 10000
);


create table TEMP_SU_BIOCHEM_DRC_LESS_10000 (
 pid VARCHAR2(285),
IC50_NM NUMBER,
IC50 NUMBER
);

drop table TEST_SU_BIOCHEM_DRC_LESS_10000;
drop table TEMP_SU_BIOCHEM_DRC_LESS_10000;

select t1.PID from su_biochem_drc t1
left join TEST_SU_BIOCHEM_DRC_LESS_10000 t2
on t2.pid = t1.pid
WHERE t1.pid IS NULL
;

select count(*) from TEMP_SU_BIOCHEM_DRC_LESS_10000;
select count(*) from su_biochem_drc;

select * from TEST_SU_BIOCHEM_DRC_LESS_10000 fetch next 10 rows only;


BEGIN
   FOR c IN (SELECT PID, TO_NUMBER (IC50_NM) IC50_NM, TO_NUMBER(IC50) IC50
               FROM su_biochem_drc where NOT REGEXP_LIKE(ic50_nm, '[[:alpha:]]'))
   LOOP
    BEGIN
      savepoint s;
      insert into TEMP_SU_BIOCHEM_DRC_LESS_10000 values (c.pid, c.IC50_NM, c.IC50) ;
      commit;
   EXCEPTION
     WHEN OTHERS THEN
      rollback to savepoint s;
   END;
   END LOOP;
END;
/

select count(*) from temp_su_biochem_drc_less_10000;

select count(*) from su_biochem_drc;

select ot.PID, ot.IC50_NM from (
select t1.PID, t1.IC50_NM, t1.IC50 from su_biochem_drc t1 -- this shows there are nulls for the ic50 values?
left join TEMP_SU_BIOCHEM_DRC_LESS_10000 t2
on t2.pid = t1.pid
WHERE t2.pid IS NULL
) ot
ORDER BY IC50_NM
;

select PID, IC50_NM, IC50 from su_biochem_drc WHERE PID 
IN (
'BIO-15379-2',
'BIO-15512-3',
'BIO-15316-1',
'BIO-15534-5',
'BIO-15368-1',
'BIO-15490-1',
'BIO-15469-1',
'BIO-15330-2',
'BIO-15545-6',
'BIO-15523-4',
'BIO-15479-2',
'BIO-15390-3',
'BIO-15501-2',
'BIO-15344-3');

select * from su_biochem_drc where PID 
IN (
'BIO-15379-2',
'BIO-15512-3',
'BIO-15316-1',
'BIO-15534-5',
'BIO-15368-1',
'BIO-15490-1',
'BIO-15469-1',
'BIO-15330-2',
'BIO-15545-6',
'BIO-15523-4',
'BIO-15479-2',
'BIO-15390-3',
'BIO-15501-2',
'BIO-15344-3');
