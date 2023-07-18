
SELECT
     T1.CP_ID AS FORMATTED_ID
    ,MAX(T1.CP_INPUT) AS INPUT_SMILES
    ,MAX(T1.SMILES) AS CANNONICAL_SMILES
    ,MAX(T1.MOLFORMULA) AS MOLFORMULA

    ,MAX(T1.MW) AS MW
    ,MAX(T1.MW_EXACT) AS MW_EXACT
    ,MAX(T1.TPSA_NO) AS TPSA_NO
    ,MAX(T1.TPSA_NOPS) AS TPSA_NOPS
    ,MAX(T1.FSP3) AS FSP3
    ,MAX(T1.HBA) AS HBA
    ,MAX(T1.HBD) AS HBD
    ,MAX(T1.HAC) AS HAC
    ,MAX(T1.XLOGP) AS XLOGP
    ,MAX(T1.ATOMCOUNT) AS ATOMCOUNT
    ,MAX(T1.BONDCOUNT) AS BONDCOUNT
    ,MAX(T1.ROTBONDS) AS ROTBONDS
    ,MAX(T1.POSCOUNT) AS POSCOUNT
    ,MAX(T1.NEGCOUNT) AS NEGCOUNT
    ,MAX(T1.ROTBONDCOUNT) AS ROTBONDCOUNT
    ,MAX(T1.HALOGENCOUNT) AS HALOGENCOUNT
    ,MAX(T1.SPIROCOUNT) AS SPIROCOUNT
    ,MAX(T1.RINGATOMS) AS RINGATOMS
    ,MAX(T1.RINGBONDS) AS RINGBONDS
    ,MAX(T1.LIPINSKI) AS LIPINSKI
    ,MAX(T1.LIPINSKI_COUNT) AS LIPINSKI_COUNT
    ,MAX(T1.RO3) AS RULE_OF_3
    ,MAX(T1.RO3_COUNT) AS RULE_OF_3_COUNT
    ,MAX(T1.COMPONENTCOUNT) AS COMPONENTCOUNT
    ,MAX(T1.SIMPLERINGCOUNT) AS SIMPLERINGCOUNT
    ,MAX(T1.AROMATICRINGCOUNT) AS AROMATICRINGCOUNT
    ,MAX(T1.RINGASSEMBLIES) AS RINGASSEMBLIES
    ,MAX(T1.LARGESTRINGASSEMBLY) AS LARGESTRINGASSEMBLY
    ,MAX(T1.SCAFFOLDMURCKOSMILES) AS SCAFFOLDMURCKOSMILES
    ,MAX(T1.SCAFFOLDRINGSONLYSMILES) AS SCAFFOLDRINGSONLYSMILES
    ,MAX(T1.SCAFFOLDRINGSLINKERSSMILES) AS SCAFFOLDRINGSLINKERSSMILES
  FROM
     DS3_USERDATA.REG_DATA_PROPS T1
    INNER JOIN C$PINPOINT.REG_DATA T2 ON  T1.CP_ID = T2.FORMATTED_ID
  WHERE
       T2.REG_ID > 0
       
GROUP BY
     T1.CP_ID
HAVING
     COUNT(*) = 1
     
;
       
      select * from ( 
select * from reg_data_props where substr( cp_input , 0, LENGTH(cp_input)-2) != 'r' and CP_ID = 'FT008905'
 
    ) t1 inner join (
select * from C$PINPOINT.REG_DATA where formatted_id = 'FT008905')
t2 on t1.cp_id = t2.formatted_id

;


select length(CP_INPUT) from reg_data_props where CP_ID = 'FT008905';


select * from reg_data_props order by CP_ID fetch next 100 rows only;
select * from reg_data_props where substr( cp_input , 0, LENGTH(cp_input)-2) != 'r';

select substr( cp_input , LENGTH(cp_input)-4, LENGTH(cp_input)) test from reg_data_props order by CP_ID fetch next 100 rows only;


select CP_ID,
MAX(CP_INPUT) AS CP_INPUT,
MAX(MW) AS MW,
MAX(XLOGP) AS XLOGP,
MAX(HBA) AS HBA,
MAX(HBD) AS HBD,
MAX(LIPINSKI) AS LIPINSKI,
MAX(RO3) AS RO3,
MAX(TPSA_NO) AS TPSA_NO,
MAX(TPSA_NOPS) AS TPSA_NOPS,
MAX(HAC) AS HAC,
MAX(ATOMCOUNT) AS ATOMCOUNT,
MAX(BONDCOUNT) AS BONDCOUNT,
MAX(MOLFORMULA) AS MOLFORMULA,
MAX(FSP3) AS FSP3,
MAX(MW_EXACT) AS MW_EXACT,
MAX(LIPINSKI_COUNT) AS LIPINSKI_COUNT,
MAX(RO3_COUNT) AS RO3_COUNT,
MAX(ROTBONDCOUNT) AS ROTBONDCOUNT,
MAX(HALOGENCOUNT) AS HALOGENCOUNT,
MAX(SPIROCOUNT) AS SPIROCOUNT,
MAX(POSCOUNT) AS POSCOUNT,
MAX(NEGCOUNT) AS NEGCOUNT,
MAX(SMILES) AS SMILES,
MAX(COMPONENTCOUNT) AS COMPONENTCOUNT,
MAX(SIMPLERINGCOUNT) AS SIMPLERINGCOUNT,
MAX(AROMATICRINGCOUNT) AS AROMATICRINGCOUNT,
MAX(RINGATOMS) AS RINGATOMS,
MAX(RINGBONDS) AS RINGBONDS,
MAX(RINGASSEMBLIES) AS RINGASSEMBLIES,
MAX(LARGESTRINGASSEMBLY) AS LARGESTRINGASSEMBLY,
MAX(SCAFFOLDMURCKOSMILES) AS SCAFFOLDMURCKOSMILES,
MAX(SCAFFOLDRINGSLINKERSSMILES) AS SCAFFOLDRINGSLINKERSSMILES,
MAX(SCAFFOLDRINGSONLYSMILES) AS SCAFFOLDRINGSONLYSMILES,
MAX(ROTBONDS) AS ROTBONDS
 from reg_data_props group by cp_ID HAVING COUNT(*) > 1;
 
 
 
 
 SELECT
    t1.reg_id                           AS reg_id,
    t1.formatted_id                     AS compound_id,
    substr(t2.project_name, 0, 3)
    || lpad(to_char(t1.reg_id), 6, '0') AS project_compound_id,
    t2.project_name                     AS project,
    t2.peyn_comment                     AS project_target,
    t1.smiles                           AS smiles,
    t1.structure_name                   AS structure_name,
    t1.additional_comments              AS stereo_comments,
    t1.cas_number                       AS cas_number,
    t1.alias                            AS alias,
    t1.reg_date                         AS reg_date,
    t1.comments                         AS comments
FROM
         c$pinpoint.reg_data t1
    INNER JOIN c$pinpoint.reg_projects t2 ON t1.project_id = t2.id
    -- INNER JOIN ds3_userdata.ft_project_target t3 ON t2.id = t3.reg_projects_id
WHERE
        t1.reg_id > 0
    AND t2.project_name LIKE 'KIN-%'
    AND t1.formatted_id = 'FT008905';

SELECT
    ROWNUM        row_index,
    "COMPOUND_ID" AS compound_id,
    'N'           exclude
FROM
    (
        ( ( SELECT DISTINCT
            dsp588."COMPOUND_ID"
        FROM
            ds3_userdata.compound_vw dsp588
        WHERE
            ( upper(dsp588."COMPOUND_ID") LIKE '%8905' )
        )
        )
        ORDER BY
            1 ASC
    )

;

select * from chemical_properties_vw where formatted_id = 'FT008905';