--CREATE TABLE COPY_tm_pes_fields_values AS select * from ds3_userdata.tm_pes_fields_values; 

--CREATE TABLE COPY_tm_prot_exp_fields_values  AS select * from ds3_userdata.tm_prot_exp_fields_values;
--DROP TABLE copy_tm_prot_exp_fields_values;

SET SERVEROUTPUT ON;

--CREATE TABLE COPY_KINASE_PANEL AS SELECT * FROM FT_KINASE_PANEL; 
--DROP TABLE COPY_KINASE_PANEL;

DECLARE 
    TMP_PROP_NAME VARCHAR2(255);
    CURSOR c_cursor
    IS 
    --SUBQUERY START
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
        select * from ds3_userdata.copy_tm_pes_fields_values
        where property_name = 'Washout'
        and property_value = 'N'
        and sample_id != 'BLANK'
    ) A
    LEFT OUTER JOIN
    (
        select * from ds3_userdata.copy_tm_pes_fields_values
        where property_name = 'Compound Incubation (hr)'
        and property_value != '0'
        and sample_id != 'BLANK'
    ) B ON A.PROTOCOL_ID = B.PROTOCOL_ID 
        AND A.EXPERIMENT_ID = B.EXPERIMENT_ID 
        AND A.SAMPLE_ID = B.SAMPLE_ID 
        AND A.PROP1 = B.PROP1
    WHERE a.experiment_id in (
            SELECT DISTINCT Experiment_id 
            FROM ds3_userdata.copy_tm_prot_exp_fields_values 
            WHERE property_value != 'HTRF'
        )       
    --SUBQUERY END
    FOR UPDATE;
BEGIN
    --dbms_output.put_line('Program started.');
    FOR r_val IN c_cursor
    LOOP        
        --DBMS_OUTPUT.PUT_LINE('cmpd_inc: ' || r_val.CMPD_INC );
        UPDATE copy_tm_pes_fields_values
           SET PROPERTY_NAME = 'Compound Incubation (hr)', PROPERTY_VALUE = 0
         WHERE PROPERTY_NAME IS NULL;
         --AND CURRENT OF c_cursor;
    END LOOP;
END;
/