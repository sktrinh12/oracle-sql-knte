select dbms_stats.get_stats_history_retention from dual;

select * from SYS.wri$_adv_asa_reco_data;

SELECT OCCUPANT_NAME,SPACE_USAGE_KBYTES FROM SYSAUX_OCCUPANTS ORDER BY SPACE_USAGE_KBYTES DESC;

SELECT * FROM (SELECT SEGMENT_NAME,OWNER,TABLESPACE_NAME,BYTES/1024/1024 "SIZE(MB)",SEGMENT_TYPE FROM SYS.DBA_SEGMENTS WHERE TABLESPACE_NAME='SYSAUX' ORDER BY BYTES DESC) WHERE ROWNUM<=10;


select * from SYS.wri$_heatmap_topn_dep1;


SELECT       
    t1.pid                                                                                                AS pid,   
    0                                                                                                    AS flag
FROM
    ds3_userdata.SU_CELLULAR_GROWTH_DRC T1
    LEFT JOIN DS3_USERDATA.CELLULAR_IC50_FLAGS T2 ON T1.pid = T2.pid
    WHERE T2.pid IS NULL;
    
    
SELECT
    T1.REG_ID AS REG_ID
   , T1.FORMATTED_ID AS COMPOUND_ID
--    ,T1.PROJECT_ID AS PROJECT_ID
    ,substr(T2.PROJECT_NAME, 0, 3) || lpad(to_char(T1.REG_ID), 6, '0') AS project_compound_id
    ,T2.PROJECT_NAME AS PROJECT
    ,t2.peyn_comment AS project_target
--    ,T1.SUPPLIER AS SUPPLIER
--    ,T1.SUPPLIER_REF AS SUPPLIER_REF
--    ,T1.USER_NAME AS USER_NAME
--    ,T1.LABBOOK_ID AS LABBOOK_ID
--    ,T1.PAGE_ID AS PAGE_ID
--    ,T1.STRUCTURE_ID AS STRUCTURE_ID
    ,T1.SMILES AS SMILES
--    ,T1.MW AS MW
    ,T1.STRUCTURE_NAME AS STRUCTURE_NAME
    ,T1.ADDITIONAL_COMMENTS AS STEREO_COMMENTS
    ,T1.CAS_NUMBER AS CAS_NUMBER
    ,T1.ALIAS AS ALIAS
    ,T1.REG_DATE AS REG_DATE
--    ,T1.MODIFIED_DATE AS MODIFIED_DATE
    ,T1.COMMENTS AS COMMENTS
  FROM
     C$PINPOINT.REG_DATA T1
     INNER JOIN C$PINPOINT.REG_PROJECTS T2 ON T1.PROJECT_ID = T2.ID
    -- INNER JOIN ds3_userdata.ft_project_target t3 ON t2.id = t3.reg_projects_id
  WHERE
    T1.REG_ID>0
AND T2.PROJECT_NAME LIKE 'KIN-%';


select * from C$PINPOINT.REG_DATA where FORMATTED_ID = 'FT008785';


update C$PINPOINT.REG_DATA set alias = 'Pamiparib' where FORMATTED_ID = 'FT008785';