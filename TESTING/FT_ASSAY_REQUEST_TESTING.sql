SELECT
    T4.EXPERIMENT_ID,
    T4.DESCR
    ,T1.STUDY_ID AS STUDY_ID
    ,T1.REPORT_NUMBER AS REPORT_NUMBER
    ,T1.PO_NUMBER AS PO_NUMBER
    ,T1.INVOICE_NUMBER AS INVOICE_NUMBER
    ,T1.REQUESTER AS REQUESTER
    ,T1.REQUEST_DATE AS REQUEST_DATE
    ,T1.COMPLETION_DATE AS COMPLETION_DATE
    ,T1.STATUS AS STATUS
    ,T1.FOUNT_CODE AS FOUNT_CODE
    ,TRIM(T1.COMPOUND_ID) AS COMPOUND_ID
    ,T1.BATCH_ID AS BATCH_ID
    ,T1.CRO AS CRO
    ,T1.ASSAY AS ASSAY
    ,T1.NOTES AS NOTES
    ,T2.MW AS MW
    ,T2.MW_EXACT AS MW_EXACT
    ,T3.COST AS COST
  FROM
     DS3_USERDATA.FT_ASSAY_REQUESTS T1
     INNER JOIN DS3_USERDATA.REG_DATA_PROPS T2 ON T1.COMPOUND_ID = T2.CP_ID
     INNER JOIN DS3_USERDATA.FT_ASSAY_MENU T3 ON T1.CRO = T3.CRO AND T1.ASSAY = T3.ASSAY
     LEFT OUTER JOIN DS3_USERDATA.TM_EXPERIMENTS T4 ON T1.STUDY_ID = trim(translate(T4.DESCR, chr(10) || chr(13), '  ')) AND T4.COMPLETED_DATE IS NOT NULL;
     
     
-- ASSAY MENU VIEW
  SELECT
     '1' AS ID
     ,T1.CRO AS CRO
    ,T1.ASSAY AS ASSAY
    ,T1.COST AS COST
    ,T1.ASSAY_ID AS ASSAY_ID
    ,T1.CATEGORY AS CATEGORY
  FROM
     DS3_USERDATA.FT_ASSAY_MENU T1
ORDER BY
    LOWER(T1.ASSAY)
    ,T1.CRO;