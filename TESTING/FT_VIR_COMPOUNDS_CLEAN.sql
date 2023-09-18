select molfile from ds3_userdata.ft_vir_design where VIR_ID = 'VK000255';


select EXPERIMENT_ID, VIR_ID, ID, MOLFILE from ds3_userdata.ft_vir_design where molfile IS NOT NULL fetch next 100 rows only;



CREATE TABLE FT_VIR_CHIRAL_CLEAN (
    VIR_ID VARCHAR2(10),
    MOLFILE CLOB
);


select count(*) from ft_vir_design;


select * from FT_VIR_CHIRAL_CLEAN;

delete FROM FT_VIR_CHIRAL_CLEAN;

--drop table FT_VIR_CHIRAL_CLEAN;