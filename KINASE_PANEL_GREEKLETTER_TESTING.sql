
SELECT
    to_char(t1.experiment_id) AS experiment_id,
    t1.descr                  AS description,
    t4.project                AS project,
    t4.cro                    AS cro,
    t4.quote_number           AS quote_number,
    t2.order_number           AS order_number,
    substr(t2.batch_id, 0, 8) AS compound_id,
    t2.batch_id               AS batch_id,
    t2.conc                   AS conc,
    t2.atp                    AS atp,
    t2.kinase                 AS kinase,
    t2.technology             AS technology,
    t2.pct_inhibition_1       AS pct_inhibition_1,
    t2.pct_inhibition_2       AS pct_inhibition_2,
    t2.pct_inhibition_avg     AS pct_inhibition_avg,
    t2.difference             AS difference,
    t2.reaction_interference  AS reaction_interference,
    t2.donor_interference     AS donor_interference,
    t2.acceptor_interference  AS acceptor_interference,
    t2.z_prime                AS z_prime,
    t2.lot_number             AS lot_number,
    t3.file_name              AS file_name
FROM
         ds3_userdata.tm_experiments t1
    INNER JOIN ds3_userdata.ft_kinase_panel         t2 ON t1.experiment_id = t2.experiment_id
    INNER JOIN ds3_userdata.tm_template_dict        t3 ON t1.experiment_id = t3.id
                                                   AND t2.doc_id = t3.doc_id
    INNER JOIN ds3_userdata.tm_protocol_props_pivot t4 ON t1.experiment_id = t4.experiment_id
WHERE
    t1.completed_date IS NOT NULL
    AND ( t1.deleted IS NULL
          OR t1.deleted = 'N' )
ORDER BY
    t2.kinase;
    

select * from kinase_panel_vw where REGEXP_LIKE (compound_id, '^[^a-z]+$', 'i') ;

select count(*)  from kinase_panel_vw;

select compound_id, kinase from kinase_panel_vw where REGEXP_LIKE (kinase, '[^A-Za-z0-9_|-]', 'i') ;


select * from kinase_panel_vw where REGEXP_LIKE (kinase, '[^αγεβ]');
