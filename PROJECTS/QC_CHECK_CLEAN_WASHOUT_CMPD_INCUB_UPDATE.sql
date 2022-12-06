 -- subquery to view data as is [before and after update]
 SELECT
        A.PROTOCOL_ID,
        A.EXPERIMENT_ID,
        A.PROP1,
        A.SAMPLE_ID,
        A.PROPERTY_NAME AS WASHOUT,
        A.PROPERTY_VALUE AS YN,
        B.PROPERTY_NAME AS CMPD_INC,
        B.PROPERTY_VALUE AS HRS
    FROM
    (
        select * from ds3_userdata.tm_pes_fields_values
--        select * from ds3_userdata.copy_tm_pes_fields_values
        where property_name = 'Washout'
        and property_value = 'N'
        and sample_id != 'BLANK'
    ) A
    LEFT OUTER JOIN
    (
        select * from ds3_userdata.tm_pes_fields_values
--        select * from ds3_userdata.copy_tm_pes_fields_values
        where property_name = 'Compound Incubation (hr)'
        --and property_value != '0' -- only uncomment before making changes to the table
        and sample_id != 'BLANK'
    ) B ON A.PROTOCOL_ID = B.PROTOCOL_ID 
        AND A.EXPERIMENT_ID = B.EXPERIMENT_ID 
        AND A.SAMPLE_ID = B.SAMPLE_ID 
        AND A.PROP1 = B.PROP1
    WHERE a.experiment_id in (
            SELECT DISTINCT Experiment_id 
            FROM ds3_userdata.tm_prot_exp_fields_values 
            WHERE property_value != 'HTRF'
        ) 
        -- AND B.property_value is null -- only to check which one's have null in the hours column (378)
        order by experiment_id, sample_id;
        
 -- #####################################################################       
 -- QC check to ensure hours = 0 for those values from the subquery above
 
 SELECT
        A.PROTOCOL_ID,
        A.EXPERIMENT_ID,
        A.PROP1,
        A.SAMPLE_ID,
        A.PROPERTY_NAME AS WASHOUT,
        C.PROPERTY_NAME as washout_real,
        A.PROPERTY_VALUE AS YN,
        C.PROPERTY_VALUE as YN_real,
        B.PROPERTY_NAME AS CMPD_INC,
        D.PROPERTY_NAME AS CMPD_INC_REAL,
        B.PROPERTY_VALUE AS HRS,
        D.PROPERTY_VALUE as hrs_real
    FROM
    (
        select * from ds3_userdata.tm_pes_fields_values
--        select * from ds3_userdata.copy_tm_pes_fields_values
        where property_name = 'Washout'
        and property_value = 'N'
        and sample_id != 'BLANK'
    ) A
    LEFT OUTER JOIN
    (
        select * from ds3_userdata.tm_pes_fields_values
--        select * from ds3_userdata.copy_tm_pes_fields_values
        where property_name = 'Compound Incubation (hr)'
        and sample_id != 'BLANK'
    ) B 
     ON A.PROTOCOL_ID = B.PROTOCOL_ID 
        AND A.EXPERIMENT_ID = B.EXPERIMENT_ID 
        AND A.SAMPLE_ID = B.SAMPLE_ID 
        AND A.PROP1 = B.PROP1
    LEFT OUTER JOIN
    (
        select * from ds3_userdata.tm_pes_fields_values
        where property_name = 'Washout'
        and property_value = 'N'
        and sample_id != 'BLANK'
    ) C
     ON A.PROTOCOL_ID = C.PROTOCOL_ID 
        AND A.EXPERIMENT_ID = C.EXPERIMENT_ID 
        AND A.SAMPLE_ID = C.SAMPLE_ID 
        AND A.PROP1 = C.PROP1
    LEFT OUTER JOIN
    (
        select * from ds3_userdata.tm_pes_fields_values
        where property_name = 'Compound Incubation (hr)'
        and sample_id != 'BLANK'         
    ) D
    ON A.PROTOCOL_ID = D.PROTOCOL_ID 
        AND A.EXPERIMENT_ID = D.EXPERIMENT_ID 
        AND A.SAMPLE_ID = D.SAMPLE_ID 
        AND A.PROP1 = D.PROP1    WHERE a.experiment_id in (
            SELECT DISTINCT Experiment_id 
            FROM ds3_userdata.tm_prot_exp_fields_values 
            WHERE property_value != 'HTRF'
        )       ;
      
      
-- #####################################################################       
-- ensure that hrs = 0 for cmpd-incub when washout = 'n'
select a.protocol_id, 
       a.experiment_id, 
       a.prop1, 
       a.property_name as CMPD_INCUB,
       b.property_name as washout,
       a.property_value as hrs,
       b.property_value as YN,
       CASE WHEN a.property_value = '0' AND b.property_value = 'N' THEN 'OK' 
       ELSE 'NOT-EQUAL'
       END as QC_CHECK 
       from (        
select * from tm_pes_fields_values 
--select * from copy_tm_pes_fields_values 
where property_name = 'Compound Incubation (hr)') A
left outer join
(
select * from tm_pes_fields_values 
--select * from copy_tm_pes_fields_values 
where property_name = 'Washout' AND property_value = 'N' 
) B ON A.Protocol_ID = B.protocol_id 
    and A.experiment_id = B.experiment_id 
    ANd a.prop1 = b.prop1
    and a.sample_id = b.sample_id
    WHERE A.sample_id != 'BLANK';
    
    
select 'qc3' as query_type,
    a.protocol_id, 
       a.experiment_id, 
       a.prop1, 
       a.sample_id,
       a.property_name as CMPD_INCUB,
       b.property_name as washout,
       a.property_value as hrs,
       b.property_value as YN,
       CASE WHEN a.property_value = '0' AND b.property_value = 'N' THEN 'OK' 
       ELSE 'NOT-EQUAL'
       END as QC_CHECK 
       from (        
select * from tm_pes_fields_values 
--select * from copy_tm_pes_fields_values 
where property_name = 'Compound Incubation (hr)') A
left outer join
(
select * from tm_pes_fields_values 
--select * from copy_tm_pes_fields_values 
where property_name = 'Washout' AND property_value = 'N' 
) B ON A.Protocol_ID = B.protocol_id 
    and A.experiment_id = B.experiment_id 
    ANd a.prop1 = b.prop1
    and a.sample_id = b.sample_id
    WHERE A.sample_id != 'BLANK'
    AND a.experiment_id in ('139556',
'139569',
'139866', 
'139945', 
'140286',
'143404',
'143444') order by experiment_id, sample_id;