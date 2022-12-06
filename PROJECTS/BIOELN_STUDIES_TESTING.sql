select * from studies_ELN_SUMMARY_VW t1
inner join eln_note_pages t2 
    on t1.experiment_id = t2.id
    
;

select * from eln_note_pages

;


select a.page,a.experiment_id,a.EXPERIMENT_ID link, a.EXPERIMENT_NAME, a.CREATED_DATE created, a.COMPLETED_DATE completed, a.ISID, a.COUNTERSIGNER
from ds3_userdata.tm_experiments a
where a.BOOK=8
order by a.PAGE desc
;


select book from tm_experiments;

