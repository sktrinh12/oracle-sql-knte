select * from FOUNT.protocol_cell_line_vw;


select * from FOUNT.protocol_target_list_vw;


select * from FOUNT.protocol_list;


select * from FOUNT.hgnc_protein_coding;




SELECT 
    A.PROTOCOL_ID,
    A.CATEGORY,
    A.STATUS,
    B.SYMBOL
FROM 
    PROTOCOL_LIST A
    INNER JOIN HGNC_PROTEIN_CODING B ON A.FK_ID = B.HGNC_ID;
