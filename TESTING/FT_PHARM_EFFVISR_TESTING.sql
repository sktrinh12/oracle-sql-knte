SELECT DISTINCT
    experiment_id
FROM
    ft_pharm_efficacy_raw;

SELECT
    MAX(t3.tv_mm_3)       tv_mm_3,
    MAX(t3.bw_g)          bw_g,
    MAX(t0.group_id)      group_id,
    MAX(t0.route)         route,
    MAX(t0.frequency)     frequency,
    MAX(t0.n_dosing)      n_dosing,
    MAX(t0.subject_type)  subject_type,
    MAX(t0.subject_id)    subject_id,
    MAX(t0.dose_id)       dose_id,
    MAX(t0.dose)          dose,
    MAX(t0.dose_unit)     dose_unit,
    MAX(t0.dosing_site)   dosing_site,
    MAX(t3.sample_id)     sample_id,
    MAX(t3.animal_id)     animal_id,
    MAX(t3.sampling_time) sampling_time
FROM
         ft_pharm_group t0
--    INNER JOIN ft_pharm_dosing       t1 ON t0.experiment_id = t1.experiment_id
--                                     AND t0.subject_id = t1.subject_id
    --inner join FT_PHARM_ANIMAL t2 ON t0.experiment_id = t2.experiment_id --and t0.group_id = t2.animal_id
    INNER JOIN ft_pharm_efficacy_raw t3 ON t0.experiment_id = t3.experiment_id
                                           AND t0.subject_id = t3.animal_id
WHERE
    t0.experiment_id = 196044
GROUP BY
    animal_id --,t3.SAMPLE_ID
    ;

SELECT
    *
FROM
         ft_pharm_group t0
     INNER JOIN ft_pharm_dosing       t1 ON t0.experiment_id = t1.experiment_id
                             AND t0.subject_id = t1.subject_id
    INNER JOIN ft_pharm_efficacy_raw t3 ON t0.experiment_id = t3.experiment_id
                                           AND t0.subject_id = t3.animal_id
WHERE
    t0.experiment_id = 208769;

SELECT
    t0.group_id,
    t0.route,
    t0.frequency,
    t0.n_dosing,
    t0.subject_id,
    t0.subject_type,
    t0.dose_id,
    t0.dose,
    t0.dose_unit,
    t0.dosing_site,
    t0.is_fed,
    t0.experiment_id,
    t3.sample_id,
    t3.animal_id,
    t3.sampling_time,
    t4.batch_id,
    t4.dose_id,
    t4.formulation_id,
    t4.concentration,
    t4.concentration_unit,
    t4.treatment,
    t3.bw_g,
    t3.l_mm,
    t3.w_mm,
    t3.tv_mm_3
FROM
         ft_pharm_group t0
    INNER JOIN ft_pharm_efficacy_raw t3 ON t0.experiment_id = t3.experiment_id
                                           AND t0.subject_id = t3.animal_id
    LEFT JOIN ft_pharm_dose t4 ON t0.experiment_id = t4.experiment_id 
                                            AND t0.DOSE_ID = t4.DOSE_ID
WHERE
    t0.experiment_id = 208769
;

SELECT
    *
FROM
    ft_pharm_animal
WHERE
    experiment_id = 208769;

SELECT DISTINCT
    experiment_id
FROM
    ft_pharm_animal;

SELECT DISTINCT
    experiment_id
FROM
    ft_pharm_study;

SELECT
    *
FROM
    ft_pharm_study;

SELECT DISTINCT
    experiment_id
FROM
    ft_pharm_efficacy_raw; -- 208769 196044

SELECT
    *
FROM
    ft_pharm_group
WHERE
    experiment_id = 208769;

SELECT
    *
FROM
    ft_pharm_dosing
WHERE
    experiment_id = 208769;

SELECT
    *
FROM
    ft_pharm_animal
WHERE
    experiment_id = 208769;

SELECT
    *
FROM
    ft_pharm_efficacy_raw
WHERE
    experiment_id = 208769--196044
    ;

SELECT
    *
FROM
    ft_pharm_study
WHERE
    experiment_id = 208769;