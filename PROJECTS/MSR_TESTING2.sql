select * from table(most_recent_ft_nbrs2('Pharmaron', 'HTRF', 'cell_line = ''DBTRG-05MG''', 'cell_incubation_hr = 1', 'pct_serum = 10', 'su_cellular_growth_drc'));


select * from table(most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'target = ''MET''', 'ATP_CONC_UM = 100', 'cofactors is null', 'su_biochem_drc'));


select calc_msr2('Pharmaron', 'Caliper', 'target = ''''MET''''', 'ATP_CONC_UM = 100', 'cofactors is null', 'TEST_SU_BIOCHEM_DRC_LESS_10000', 20) MSR from dual;

select calc_msr2('Pharmaron', 'HTRF', 'cell_line = ''''DBTRG-05MG''''', 'cell_incubation_hr = 1', 'pct_serum = 10', 'su_cellular_growth_drc', 20) MSR from dual;


select ot.*  from (
--select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
select t2.ic50_nm, t2.ic50
--                        row_number () over (
--                         partition by t1.compound_id
--                         order by t1.created_date desc
--                       ) row_count,
--                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs2('Pharmaron', 'Caliper', 'target = ''MET''', 'ATP_CONC_UM = 100', 'cofactors is null', 'su_biochem_drc')) t1
                INNER JOIN (select PID, IC50_NM, IC50 from ds3_userdata.TEST_SU_BIOCHEM_DRC_LESS_10000) t2 
                ON t1.PID = t2.PID
--                WHERE to_number(regexp_substr(TRIM(t2.ic50_nm),'([[:digit:]])+')) < 10000
--where t2.ic50 < 0.00001
--where t2.ic50_nm < 10000
                ORDER BY
                    t1.compound_id,
                    t1.created_date DESC
                    ) ot
--                   WHERE REGEXP_LIKE(ot.ic50_nm, '^(\d+)(?:\.(\d{1,2}))?$')
where ot.ic50_nm < 10000
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
               FROM su_biochem_drc)
   LOOP
      insert into TEMP_SU_BIOCHEM_DRC_LESS_10000 values (c.pid, c.IC50_NM, c.IC50) ;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;