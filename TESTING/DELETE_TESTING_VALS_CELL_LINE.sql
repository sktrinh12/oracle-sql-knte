select * from FOUNT.cell_line;

select * from FOUNT.protocol_cell_line_vw;


select distinct protocol_id from fount.protocol_list;

DELETE
FROM
    fount.cell_line
WHERE
    NAME in ('Bob', 'Janet', 'yort', 'bob', 'meg', 'janet', 'michelle', 'kevin', 'meg', 'MImika_test');
    
    
select * from fount.cell_line where name = 'Bob';