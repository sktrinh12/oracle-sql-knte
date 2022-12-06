-- create copy of the table
DELETE FROM copy_tm_pes_fields_values;
DROP TABLE copy_tm_pes_fields_values;
CREATE TABLE COPY_tm_pes_fields_values AS select * from ds3_userdata.tm_pes_fields_values; 

--select count(*) from tm_pes_fields_values; --1.15e6

MERGE INTO tm_pes_fields_values t0
USING (
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
        where property_name = 'Washout'
        and property_value = 'N'
        and sample_id != 'BLANK'
    ) A
    LEFT OUTER JOIN
    (
        select * from ds3_userdata.tm_pes_fields_values
        where property_name = 'Compound Incubation (hr)'
        and property_value != '0' 
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
        ) t1
    ON (t0.PROTOCOL_ID = t1.PROTOCOL_ID 
        AND t0.EXPERIMENT_ID = t1.EXPERIMENT_ID 
        AND t0.SAMPLE_ID = t1.SAMPLE_ID 
        AND t0.PROP1 = t1.PROP1
        AND t0.PROPERTY_NAME = t1.CMPD_INC
        )
        WHEN MATCHED THEN
        UPDATE SET t0.PROPERTY_VALUE = '0'; -- 27,237 rows merged