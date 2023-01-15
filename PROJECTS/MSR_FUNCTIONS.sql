CREATE OR REPLACE TYPE t_compound_id_type AS OBJECT
  (
  pid VARCHAR2(285),
  compound_id VARCHAR2(32),
  created_date DATE
);
/

CREATE OR REPLACE TYPE t_gmean_tbl_type AS OBJECT
  (
BATCH_ID VARCHAR2(100),
GRAPH BLOB,
IC50_NM NUMBER,
GEO_NM VARCHAR2(500),
AGG_STATS VARCHAR2(800),
PROPERTIES VARCHAR2(1000)
);
/

CREATE OR REPLACE TYPE t_msr_tbl_type AS OBJECT
  (
  compound_id VARCHAR2(32),
  msr number
);
/

drop type t_gmean_tbl_type_table;
--drop type t_compound_id_type;
--drop type t_compound_id_type_table;
--drop function most_recent_ft_nbrs;
--drop function calc_msr;

CREATE OR REPLACE TYPE t_compound_id_type_table AS TABLE OF t_compound_id_type;
/

CREATE OR REPLACE TYPE t_gmean_tbl_type_table AS TABLE OF t_gmean_tbl_type;
/

CREATE OR REPLACE TYPE t_msr_tbl_type_table AS TABLE OF t_msr_tbl_type;
/

CREATE OR REPLACE FUNCTION most_recent_ft_nbrs( v_cro VARCHAR2, 
                                        v_assay_type varchar2, 
                                        v_cell_line varchar2, 
                                        v_variant varchar2, 
                                        v_cell_incub number, 
                                        v_pct_serum number) 
                                        RETURN t_compound_id_type_table
AS
 v_compids t_compound_id_type_table; 
BEGIN
    SELECT
    t_compound_id_type(pid, compound_id, created_date) bulk collect into v_compids
FROM
    (
        SELECT
            pid,
            compound_id,
            created_date--,
--            cro,
--            assay_type,
--            cell_line
        FROM
            ds3_userdata.su_cellular_growth_drc
        WHERE
                cro = v_cro
            AND assay_type = v_assay_type
            AND cell_line = v_cell_line
            AND nvl2(variant, variant, '-') = nvl2(v_variant, v_variant, '-')
            AND pct_serum = v_pct_serum
            AND cell_incubation_hr = v_cell_incub
            AND compound_id != 'BLANK'
        ORDER BY
            created_date DESC
    )
;
--DBMS_OUTPUT.PUT_LINE('COMPOUND_IS: ' || v_compids);
RETURN v_compids;
END;
/


CREATE OR REPLACE FUNCTION most_recent_ft_nbrs2(i_cro VARCHAR2, 
                                        i_assay_type varchar2, 
                                        i_param1 varchar2,                                         
                                        i_param2 varchar2, 
                                        i_param3 varchar2,
                                        i_dsname varchar2) 
                                        RETURN t_compound_id_type_table
AS
 v_compids t_compound_id_type_table; 
 v_sqlquery VARCHAR2(1000);
 v_dsname VARCHAR2(50);
 v_sqltemplate VARCHAR2(1000) := 
 q'[SELECT
    t_compound_id_type(pid, compound_id, created_date)
    FROM (
        SELECT
            pid,
            compound_id,
            created_date
        FROM
            ds3_userdata.%s
        WHERE
                cro = '%s'
            AND assay_type = '%s'
            AND %s 
            AND %s
            AND %s
            AND compound_id != 'BLANK'
        ORDER BY
            created_date DESC
    )]';
    
BEGIN
    IF regexp_count(i_dsname, 'BIO', 1, 'i') > 0 THEN
        v_dsname := 'su_biochem_drc';
    ELSE
        v_dsname := i_dsname;
    END IF;
    v_sqlquery := utl_lms.format_message(v_sqltemplate, v_dsname, i_cro, i_assay_type, i_param1, i_param2, i_param3);
    --dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    bulk collect into v_compids;
RETURN v_compids;
END;
/            
            
            
CREATE OR REPLACE FUNCTION calc_msr(v_cro VARCHAR2, 
                                        v_assay_type varchar2, 
                                        v_cell_line varchar2, 
                                        v_variant varchar2, 
                                        v_cell_incub number, 
                                        v_pct_serum number,
                                        v_nbr_of_cmpds number)
return number
as
  n_MSR NUMBER;
BEGIN
  select POWER(10, 2*STDDEV(DIFF_IC50)) into n_msr FROM (
select COMPOUND_ID, SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) DIFF_IC50
FROM (
select t1.COMPOUND_ID, t1.ROW_COUNT, LOG(10, t2.IC50) IC50_LOG10 FROM (
select t.* from 
(
select PID, COMPOUND_ID, created_date,
row_number () over (
         partition by compound_id
         order by created_date desc
       ) row_count,
count(*) over (PARTITION BY compound_id) cnt
from table(most_recent_ft_nbrs(v_cro, v_assay_type, v_cell_line, v_variant, v_cell_incub, v_pct_serum))
ORDER BY
    compound_id,
    created_date DESC
    ) t
WHERE t.row_count <=2
AND t.cnt >1
FETCH NEXT v_nbr_of_cmpds*2 ROWS ONLY
) t1
INNER JOIN ds3_userdata.su_cellular_growth_drc t2 
ON t1.PID = t2.PID
WHERE t2.IC50_NM <9000
ORDER BY t1.row_count, t1.compound_id 
)
GROUP BY COMPOUND_ID
ORDER BY COMPOUND_ID
);
return n_MSR;
END;
/


CREATE OR REPLACE FUNCTION calc_msr2(i_cro VARCHAR2, 
                                     i_assay_type varchar2,                                       
                                     i_param1 varchar2, 
                                     i_param2 varchar2,
                                     i_param3 varchar2,
                                     i_dsname varchar2,
                                     i_nbr_cmpds number)
return number
as
  n_MSR NUMBER;
  v_sqlquery VARCHAR2(2000);
  v_sqltemplate VARCHAR2(2000) := q'[select POWER(10, 2*STDDEV(DIFF_IC50))
    FROM (
        select COMPOUND_ID, SUM(IC50_LOG10 * case when row_count =1 then 1 else -1 end) DIFF_IC50
        FROM (
        SELECT otbl.COMPOUND_ID, otbl.ROW_COUNT, LOG(10, otbl.IC50) IC50_LOG10 FROM (
            select t.* from (
                select t1.PID, t1.COMPOUND_ID, t1.created_date, t2.ic50_nm, t2.ic50,
                        row_number () over (
                         partition by t1.compound_id
                         order by t1.created_date desc
                       ) row_count,
                count(*) over (PARTITION BY t1.compound_id) cnt
                from table(most_recent_ft_nbrs2('%s', '%s', '%s', '%s', '%s', '%s')) t1
                INNER JOIN ds3_userdata.%s t2 
                ON t1.PID = t2.PID
                ORDER BY
                    t1.compound_id,
                    t1.created_date DESC
                ) t
        WHERE t.cnt >1
        AND t.row_count <=2
        FETCH NEXT %s *2 ROWS ONLY
        ) otbl )
         GROUP BY COMPOUND_ID
         ORDER BY COMPOUND_ID
         )]';
BEGIN
    v_sqlquery := utl_lms.format_message(v_sqltemplate, i_cro, i_assay_type, i_param1, i_param2, i_param3, i_dsname, i_dsname, to_char(i_nbr_cmpds));
    dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    into n_msr;
return n_MSR;
END;
/



CREATE OR REPLACE FUNCTION GEN_GEOMEAN_CURVE_TBL(i_experiment_id NUMBER, i_nbr_cmpds number)
return t_gmean_tbl_type_table
as
  tbl_gmean t_gmean_tbl_type_table;
  v_msr number;
  v_cro VARCHAR2(100);
  v_assay_type varchar2(100) ;
  v_param1 varchar2(120);
  v_param2 varchar2(120);
  v_param3 varchar2(120);
  v_dstype VARCHAR2(32);
  v_dsname VARCHAR2(32) := 'SU_CELLULAR_GROWTH_DRC';
  v_sqlquery VARCHAR2(500);
  v_sqltemplate VARCHAR2(500) := 'select cro,
        assay_type,
        %s, 
        %s,
        %s
    from ds3_userdata.%s where experiment_id = I_EXPERIMENT_ID fetch next 1 rows only;';
BEGIN
    select t2.protocol into v_dstype from ds3_userdata.tm_experiments t1 
    inner join ds3_userdata.tm_protocols t2 on t2.protocol_id = t1.protocol_id
    where t1.experiment_id  = I_EXPERIMENT_ID;
    IF regexp_count(v_dstype, 'BIO', 1, 'i') > 0 THEN
        v_dsname := 'SU_BIOCHEM_DRC';
        v_param1 := 'target = ' || q'['v_param1']';
        v_param2 := 'atp_conc_um = ' || v_param2;
        v_param3 := 'cofactors = ' || q'['v_param3']';
    ELSE
      v_param1 := 'cell_line = ' || q'['v_param1']';
      v_param2 := 'cell_incubation_hr = ' || v_param2;
      v_param3 := 'pct_serum = ' || v_param3;
    END IF;
    v_sqlquery := utl_lms.format_message(v_sqltemplate, v_param1, v_param2, v_param3, v_dsname);
    dbms_output.put_line('query: ' || v_sqlquery);
    execute immediate v_sqlquery
    into v_cro, v_assay_type, v_param1, v_param2, v_param3;
    v_msr := calc_msr2(i_cro => v_cro, 
                       i_assay_type => v_assay_type, 
                       i_param1 => v_param1, 
                       i_param2 => v_param2, 
                       i_param3 => v_param3, 
                       i_dsname => v_dsname, 
                       i_nbr_cmpds => i_nbr_cmpds);
    DBMS_OUTPUT.PUT_LINE('v_msr: ' || v_msr);
SELECT
t_gmean_tbl_type(
    t1.batch_id  ,
    t1.graph     ,
    t1.ic50_nm   ,
    round(t2.geo_nm - t3.MSR, 2)
    || '<br />'
    || t2.geo_nm
    || '<br />'
    || round(t2.geo_nm + t3.MSR, 2) ,
    '-3 stdev: '
    || round(t2.nm_minus_3_stdev, 1)
    || '<br />'
    || '+3 stdev: '
    || round(t2.nm_plus_3_stdev, 1)
    || '<br />'
    || 'n of m: '
    || t2.n_of_m
    || '<br />'
    || 'MSR: '
    || round(t3.MSR, 2) 
    ,
    'CRO: '
    || t1.cro
    || '<br />'
    || 'Assay Type: '
    || t1.assay_type
    || '<br />'
    || 'Cell Line: '
    || t1.cell_line
    || '<br />'
    || 'Variant: '
    || t1.variant
    || '<br />'
    || 'Inc(hr): '
    || t1.cell_incubation_hr
    || '<br />'
    || '% serum: '
    || t1.pct_serum
     
     ) bulk collect INTO tbl_gmean
FROM
    (
        SELECT
            substr(t3.display_name, 0, 8)                                                       AS compound_id,
            t3.display_name                                                                     AS batch_id,
            to_number(nvl(regexp_replace(t1.reported_result, '[A-DF-Za-z\<\>~= ]'), t1.result_numeric)) * 1000000000 AS ic50_nm,
            t4.data                                                              AS graph,
            t6.cro,
            t7.assay_type,
            cell_line,
            variant,
            cell_incubation_hr,
            pct_serum
        FROM
                 ds3_userdata.su_analysis_results t1
            INNER JOIN ds3_userdata.su_groupings            t2 ON t1.group_id = t2.id
            INNER JOIN ds3_userdata.su_samples              t3 ON t2.sample_id = t3.id
            INNER JOIN ds3_userdata.su_charts t4 ON t1.id = t4.result_id
            INNER JOIN (
                SELECT
                    experiment_id AS experiment_id,
                    cell_line AS cell_line,
                    nvl(variant_1, '-') AS variant,
                    cell_incubation_hr AS cell_incubation_hr,
                    pct_serum AS pct_serum,
                    plate_set AS plate_set
                FROM
                    su_plate_prop_pivot
            ) t5 ON t2.experiment_id = t5.experiment_id
            AND t5.PLATE_SET = t2.PLATE_SET
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS cro
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = I_EXPERIMENT_ID
                    AND property_name = 'CRO'
            )                      t6 ON t2.experiment_id = t6.experiment_id
            INNER JOIN (
                SELECT
                    experiment_id,
                    property_value AS assay_type
                FROM
                    ds3_userdata.tm_prot_exp_fields_values
                WHERE
                        experiment_id = I_EXPERIMENT_ID
                    AND property_name = 'Assay Type'
            )                      t7 ON t2.experiment_id = t7.experiment_id
        WHERE
            t2.experiment_id = I_EXPERIMENT_ID
            AND t3.display_name != 'BLANK'
    )                                  t1
    LEFT OUTER JOIN ds3_userdata.su_cellular_drc_stats t2 ON t1.compound_id = t2.compound_id
                                                             AND t1.cro = t2.cro
                                                             AND t1.assay_type = t2.assay_type
                                                             AND t1.cell_line = t2.cell
                                                             AND t1.variant = t2.variant
                                                             AND t1.cell_incubation_hr = t2.inc_hr
                                                             AND t1.pct_serum = t2.pct_serum   
     LEFT OUTER JOIN (select NULL compound_id, v_msr MSR from dual) t3
   ON t1.compound_id = t1.compound_id
   ORDER BY t1.COMPOUND_ID, t1.CELL_LINE, t1.VARIANT;
RETURN tbl_gmean;
END;
/

grant execute on calc_msr to DS3_APPDATA;
grant execute on most_recent_ft_nbrs to DS3_APPDATA; -- remember to prefix it with the schema name when calling it from  ds3_appdata!
grant execute on GEN_GEOMEAN_CURVE_TBL to DS3_APPDATA;
