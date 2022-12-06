DROP TABLE "DS3_USERDATA"."FT_PHARM_STUDY";
 
--------------------------------------------------------
--  DDL for Table FT_PHARM_STUDY
--------------------------------------------------------

  CREATE TABLE "DS3_USERDATA"."FT_PHARM_STUDY" 
   (
    "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE ,	
    "STUDY_ID" VARCHAR2(20 BYTE), 
    "REQUESTOR" VARCHAR2(20 BYTE), 
    "STUDY_DIRECTOR" VARCHAR2(20 BYTE), 
    "TEAM_ID" VARCHAR2(20 BYTE), 
    "PROTOCOL_ID" VARCHAR2(20 BYTE), 
    "REQUEST_DATE" DATE,
    "IN_LIFE_DATE" DATE,
    "REPORT_DATE" DATE,
	"NOTES" VARCHAR2(50 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
    COMMENT ON COLUMN "DS3_USERDATA"."FT_PHARM_STUDY"."STUDY_ID" IS 'sequential ID';
-----------------------------------------------

DROP TABLE "DS3_USERDATA"."FT_PHARM_GROUP";  

--------------------------------------------------------
--  DDL for Table FT_PHARM_GROUP
--------------------------------------------------------

  CREATE TABLE "DS3_USERDATA"."FT_PHARM_GROUP" 
   (	
    "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE ,	
    "GROUP_ID" VARCHAR2(20 BYTE), 
	"ROUTE" VARCHAR2(20 BYTE), 
    "ANIMAL_TYPE" VARCHAR2(20 BYTE),
    "ANIMAL_ID" VARCHAR2(20 BYTE), 
    "DOSE_ID" VARCHAR2(20 BYTE), 
	"DOSE" NUMBER, 
    "DOSE_UNIT" VARCHAR2(20 BYTE),
    "DOSING_SITE" VARCHAR2(20 BYTE),
    "IS_FED" VARCHAR2(20 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
    COMMENT ON COLUMN "DS3_USERDATA"."FT_PHARM_GROUP"."isFED" IS '1 for Fed, 0 for fast';



DROP TABLE "DS3_USERDATA"."FT_PHARM_ANIMAL";

 --------------------------------------------------------
--  DDL for Table FT_PHARM_ANIMAL
--------------------------------------------------------

  CREATE TABLE "DS3_USERDATA"."FT_PHARM_ANIMAL" 
   (	
    "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE ,	
    "ANIMAL_ID" VARCHAR2(20 BYTE),
    "RESULT_TIME" NUMBER,
    "TIME_UNIT" VARCHAR2(20 BYTE),
    "RESULT_TYPE" VARCHAR2(20 BYTE), 
    "RESULT" NUMBER,
    "RESULT_UNIT" VARCHAR2(20 BYTE),
  	"OBSERVATION" VARCHAR2(50 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;



DROP TABLE "DS3_USERDATA"."FT_PHARM_DOSING";

--------------------------------------------------------
--  DDL for Table FT_PHARM_DOSING
--------------------------------------------------------

  CREATE TABLE "DS3_USERDATA"."FT_PHARM_DOSING" 
   (	
    "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE ,	
    "DOSING_ID" VARCHAR2(20 BYTE), 
    "ANIMAL_ID" VARCHAR2(20 BYTE),
	"ROUTE" VARCHAR2(20 BYTE), 
	"AMOUNT" NUMBER, 
	"AMOUNT_UNIT" VARCHAR2(20 BYTE), 
    "DOSING_TIME" NUMBER,
    "DOSING_TIME_UNIT" VARCHAR2(20 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
    COMMENT ON COLUMN "DS3_USERDATA"."FT_PHARM_DOSING"."DOSING_TIME" IS 'actual DOSING time';
  

-----------------------------------------------

DROP TABLE "DS3_USERDATA"."FT_PHARM_DOSE";

--------------------------------------------------------
--  DDL for Table FT_PHARM_DOSING
--------------------------------------------------------

  CREATE TABLE "DS3_USERDATA"."FT_PHARM_DOSE" 
   (	
    "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE ,	
    "DOSE_ID" VARCHAR2(20 BYTE),
	"BATCH_ID" VARCHAR2(20 BYTE),
	"FORMULATION_ID" VARCHAR2(20 BYTE),
 	"FORMULATION" VARCHAR2(100 BYTE),
	"CONCENTRATION" NUMBER,
    "CONCENTRATION_UNIT" VARCHAR2(20 BYTE),
    "TREATMENT" VARCHAR2(100 BYTE),
    "APPEARANCE" VARCHAR2(100 BYTE),
    "COMMENTS" VARCHAR2(50 BYTE),
    "MEAN_CONC" NUMBER, 
    "ACCURACY_PCT" NUMBER,
    "SD" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
  COMMENT ON COLUMN "DS3_USERDATA"."FT_PHARM_DOSE"."TREATMENT" IS 'a list of all treatments to prepare formulation';

--------------------------------------------------------

DROP TABLE "DS3_USERDATA"."FT_PHARM_RAW";

--------------------------------------------------------
--  DDL for Table FT_PHARM_RAW
--------------------------------------------------------

  CREATE TABLE "DS3_USERDATA"."FT_PHARM_RAW" 
   (	
    "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE NOT NULL ENABLE,
    "RAWVALUE_ID" VARCHAR2(20 BYTE),
    "ANIMAL_ID" VARCHAR2(20 BYTE),
    "RAWVALUE_TYPE" VARCHAR2(20 BYTE),
    "SAMPLING_TIME" NUMBER,
    "TIME_UNIT" VARCHAR2(20 BYTE), 
    "RESULT" VARCHAR2(20 BYTE), 
    "RESULT_UNIT" VARCHAR2(20 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
  NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;

   COMMENT ON COLUMN "DS3_USERDATA"."FT_PHARM_RAW"."RAWVALUE_TYPE" IS 'SAMPLE type';
   
   
DROP TABLE "DS3_USERDATA"."FT_PHARM_SAMPLING";