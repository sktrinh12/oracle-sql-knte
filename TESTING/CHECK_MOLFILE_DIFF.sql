select molfile from DS3_USERDATA.FT_VIR_DESIGN where experiment_id = 203844 and VIR_ID = 'VK004727';


select t0.smiles, t1.reg_smiles from ft_vir_design t0 inner join reg_reagents_vw t1 
on t0.VIR_ID = t1.VIR_ID
where t0.experiment_id = 203844 and t0.VIR_id = 'VK004727';



select * from DS3_USERDATA.FT_VIR_DESIGN fetch next 1 rows only;



select MOLfile from c$pinpoint.REG_DATA where formatted_id = 'FT008642'; --fetch next 100 rows only;



SELECT
    reg.MOLfile AS reg_molfile,
    vir.molfile AS vir_molfile,
     CASE
        WHEN DBMS_LOB.COMPARE(reg.MOLfile, vir.molfile) = 0 THEN 'Exact Match'
        ELSE 'Not Exact Match'
    END AS comparison_result
FROM
    c$pinpoint.REG_DATA reg
JOIN
    DS3_USERDATA.FT_VIR_DESIGN vir
ON
    reg.formatted_id = 'FT008642'
    AND vir.experiment_id = 203844
    AND vir.VIR_ID = 'VK004727';
