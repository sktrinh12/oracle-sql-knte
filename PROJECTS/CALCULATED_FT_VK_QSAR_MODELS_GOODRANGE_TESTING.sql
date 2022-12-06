select distinct goodrange from FOUNT.calculated_ft_vk_qsar_models;

select distinct transform from FOUNT.calculated_ft_vk_qsar_models;


SELECT * FROM FOUNT.calculated_ft_vk_qsar_models FETCH NEXT 10 ROWS ONLY;


select qsar_model, goodrange, map_goodrange(goodrange, qsar_model) from FOUNT.calculated_ft_vk_qsar_models;



select goodrange, count(goodrange) from calculated_ft_vk_qsar_models group by goodrange;



SELECT 
 REGNO,
 PROJECT_NAME,
 PEYN_COMMENT,
 SMILES,
 QSAR_MODEL,
 OBSERVED,
 HOLD_OUT,
 GOODRANGE,
 MAP_GOODRANGE(GOODRANGE, qsar_model) GOORANGE_MAPPING,
 TIER,
 MODEL,
 KINNATE_ALIAS,
 TRANSFORM,
 CLOSESTSMILES as CLOSEST_SMILES,
 CLOSESTNAMES as CLOSEST_NAMES,
 TANIMOTO,
 BESTSIMILARITY as BEST_SIMILARITY,
 NO_PROD_SIM
FROM
FOUNT.CALCULATED_FT_VK_QSAR_MODELS
;