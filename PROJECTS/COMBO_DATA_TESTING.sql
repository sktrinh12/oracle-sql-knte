SELECT
    *
FROM
         ds3_userdata.su_well_samples t1
    JOIN ds3_userdata.su_well_sample_properties t2 ON t2.well_sample_id = t1.id
    JOIN ds3_userdata.su_property_dictionary    t3 ON t2.property_dict_id = t3.id
                                                   AND t3.dictionary_type = 'Well Sample'

;

SELECT DISTINCT FORMATTED_ID 
FROM C$PINPOINT.REG_DATA 
WHERE FORMATTED_ID LIKE 'FT%' 
ORDER BY DBMS_RANDOM.value
;

SELECT
    wl.experiment_id,
    p.plate_number,
    p.name              plate_name,
    s.display_name,
    ws.conc,
    ws.conc_unit,
    wl.name             layer,
    wr.value            result,
    t1.*,
    chr(w.rowval + 65)
    || ( w.colval + 1 ) AS well_id,
    w.rowval,
    w.colval
FROM

    
         su_well_results wr
    JOIN su_well_layers                          wl ON wl.id = wr.layer_id
                              AND wl.name = 'Raw data'
                              AND wl.experiment_id = 211552
    JOIN su_wells                                w ON w.id = wr.well_id
    JOIN su_plates                               p ON p.id = w.plate_id
    
    JOIN su_well_samples                         ws ON ws.well_id = w.id
    JOIN su_samples                              s ON s.id = ws.sample_id
    JOIN su_groupings                            g on g.sample_id = s.id and g.experiment_id = 211552 and g.plate_set = p.plate_set
    join su_analysis_results                     ar on ar.group_id = g.id
    INNER JOIN ds3_userdata.su_well_sample_props_pivot t1 ON t1.group_id = ws.group_id
ORDER BY
    wl.name,
    p.plate_number,
    w.rowval,
    w.colval;
    
select * from su_well_layers where name = 'Raw data' and experiment_id = 211552;
select * from su_groupings where experiment_id = 211552; --sample_id = 1427;
select * from su_analysis_results;
select * from su_samples where display_name = 'FT000953-03';
