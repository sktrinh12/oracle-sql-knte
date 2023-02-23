select * from ds3_userdata.cellular_ic50_flag_m@dm_prod;


insert into ds3_userdata.cellular_ic50_flag_m
select * from ds3_userdata.cellular_ic50_flag_m@dm_prod;



CREATE DATABASE LINK dm_prod
CONNECT TO ds3_userdata
IDENTIFIED BY ds3_userdata
USING '
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dotoradb.fount)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORA_DM)
    )
  )
';


drop database link dm_prod;




CREATE DATABASE LINK dm_dev
CONNECT TO ds3_userdata
IDENTIFIED BY ds3_userdata
USING '
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dotoradb-2022-dev.fount)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORA_DM)
    )
  )
';


insert into ds3_userdata.cellular_ic50_flags
select * from ds3_userdata.cellular_ic50_flag_m@dm_dev;


select * from cellular_ic50_flags;


SELECT *
FROM   (
select PID from su_biochem_drc 
    ORDER BY DBMS_RANDOM.RANDOM)
WHERE  rownum < 21;
