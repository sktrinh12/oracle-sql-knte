select * from ft_analytical_chem_files where COMPOUND_ID = 'FT007843';


select * from tm_template_dict where ID = '198624';



SELECT
     to_char(t0.experiment_id) as experiment_id
    ,T0.DESCR AS EXPERIMENT_DESCRIPTION
    ,T1.COMPOUND_ID AS COMPOUND_ID
    ,T1.BATCH_ID AS BATCH_ID
,T2.DOC AS DOC
,T2.EXTENSION AS EXTENSION
    ,T1.FILENAME AS FILENAME
    ,T1.DOC_TYPE AS DOC_TYPE
    ,T2.DESCRIPTION AS DESCRIPTION   
    ,T2.ISID AS ISID
    ,T2.ADDED_DATE AS ADDED_DATE
    ,T2.MOD_DATE AS MOD_DATE
  FROM
       ds3_userdata.tm_experiments t0     
       INNER JOIN DS3_USERDATA.FT_ANALYTICAL_CHEM_FILES T1 ON t0.experiment_id = t1.experiment_id
       INNER JOIN DS3_USERDATA.TM_TEMPLATE_DICT T2 ON T1.EXPERIMENT_ID = T2.ID AND T1.FILENAME = T2.FILE_NAME
WHERE
    --(t0.deleted is null or t0.deleted = 'N')
    --AND t0.completed_date is not null
    --AND 
    COMPOUND_ID = 'FT007843';
