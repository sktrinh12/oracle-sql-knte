WITH cte1 AS (
    SELECT
        experiment_id,
        protocol_id
    FROM
        ds3_userdata.tm_experiments
    WHERE
            nvl(deleted, 'N') = 'N'
        AND completed_date IS NOT NULL
        AND protocol_id IN ( 541, 481 )
), cte2 AS (
    SELECT
        id,
        doc,
        file_name,
        extension
    FROM
        ds3_userdata.tm_template_dict
    WHERE
        extension IN ( 'pptx', 'ppt', 'xlsx' )
), cte3 AS (
    SELECT
        experiment_id,
        cro,
        assay_type
    FROM
        tm_protocol_props_pivot
    WHERE
        assay_type IN (
            SELECT
                prop_value
            FROM
                ds3_userdata.tm_protocol_prop_lookup
            WHERE
                    prop_type = 'ASSAY_TYPE'
                AND prop_group = 'CELLULAR'
        )
), cte4 AS (
    SELECT
        experiment_id,
        batch_id
    FROM
        ft_in_vitro_files
), cte5 AS (
    SELECT DISTINCT
        batch_id,
        experiment_id
    FROM
        ds3_userdata.su_cellular_combo
)
SELECT
    cte1.experiment_id,
    CASE
        WHEN cte4.batch_id IS NULL THEN
            substr(cte5.batch_id, 0, 8)
        ELSE
            substr(cte4.batch_id, 0, 8)
    END compound_id,
    cte2.file_name,
    cte2.extension,
    cte2.doc,
    CASE
        WHEN cte4.batch_id IS NULL THEN
            cte5.batch_id
        ELSE
            cte4.batch_id
    END batch_id,
    cte3.cro,
    cte3.assay_type,
    CASE
        WHEN cte1.protocol_id = 541 THEN
            'FT_IN_VITRO_FILES'
        WHEN cte1.protocol_id = 481 THEN
            'COMBO'
        ELSE
            'NA'
    END source_type
FROM
         cte1
    INNER JOIN cte2 ON cte1.experiment_id = cte2.id
    INNER JOIN cte3 ON cte1.experiment_id = cte3.experiment_id
    FULL JOIN cte4 ON cte1.experiment_id = cte4.experiment_id
    LEFT JOIN cte5 ON cte1.experiment_id = cte5.experiment_id
WHERE
cte1.EXPERIMENT_ID = 211153
;


SELECT * FROM (
WITH cte1 AS (
    SELECT
        experiment_id,
        protocol_id
    FROM
        ds3_userdata.tm_experiments
    WHERE
            nvl(deleted, 'N') = 'N'
        AND completed_date IS NOT NULL
        AND protocol_id = 481
), cte2 AS (
    SELECT
        id,
        doc,
        file_name,
        extension
    FROM
        ds3_userdata.tm_template_dict
    WHERE
        extension IN ( 'pptx', 'ppt', 'xlsx' )
), cte3 AS (
    SELECT
        experiment_id,
        cro,
        assay_type
    FROM
        tm_protocol_props_pivot
    WHERE
        assay_type IN (
            SELECT
                prop_value
            FROM
                ds3_userdata.tm_protocol_prop_lookup
            WHERE
                    prop_type = 'ASSAY_TYPE'
                AND prop_group = 'CELLULAR'
        )
), cte4 AS (
    SELECT
        experiment_id,
        batch_id
    FROM
        ft_in_vitro_files
), cte5 AS (
    SELECT DISTINCT
        batch_id,
        experiment_id
    FROM
        ds3_userdata.su_cellular_combo
)
SELECT
    cte1.experiment_id,
    CASE
        WHEN cte4.batch_id IS NULL THEN
            substr(cte5.batch_id, 0, 8)
        ELSE
            substr(cte4.batch_id, 0, 8)
    END compound_id,
    cte2.file_name,
    cte2.extension,
    cte2.doc,
    CASE
        WHEN cte4.batch_id IS NULL THEN
            cte5.batch_id
        ELSE
            cte4.batch_id
    END batch_id,
    cte3.cro,
    cte3.assay_type
FROM
         cte1
    INNER JOIN cte2 ON cte1.experiment_id = cte2.id
    INNER JOIN cte3 ON cte1.experiment_id = cte3.experiment_id
    FULL JOIN cte4 ON cte1.experiment_id = cte4.experiment_id
    LEFT JOIN cte5 ON cte1.experiment_id = cte5.experiment_id
    )
WHERE
COMPOUND_ID = 'FT002787'
;