--Purpose    : Adding columns to stg_draft_claim
--Author     : Bharath kumar
--Created On : 17/05/2010
--Impact     : None

alter table stg_draft_claim add REPLACED_IR_PARTS_SERIAL_NUM VARCHAR2(4000 BYTE)
/
alter table stg_draft_claim add INSTALLED_IR_PARTS VARCHAR2(4000 BYTE)
/
alter table stg_draft_claim add INSTALLED_IR_PARTS_QUANTITY VARCHAR2(4000 BYTE)
/
alter table stg_draft_claim add INSTALLED_IR_PARTS_SERIAL_NUM VARCHAR2(4000 BYTE)
/
commit
/



