--Purpose    : tables created for the supplier recovery flow
--Author     : Kaustubhshobhan Basu
--Created On : 01/05/09
--Kuldeep : As per discussion with Sudaksh, recovery can't be claimed on Installed parts so this column is not needed and should be dropped later.
--alter table recoverable_part drop column part
--/
--alter table recoverable_part add(OEM_PART NUMBER(19))
--/
--alter table recoverable_part add(INSTALLED_PART NUMBER(19))
--/
--ALTER TABLE recoverable_part ADD (
--	CONSTRAINT FK_REC_OEM_PART
--	FOREIGN KEY (OEM_PART) 
--	REFERENCES oem_part_replaced (ID)
--)
--/
--ALTER TABLE recoverable_part ADD (
--	CONSTRAINT FK_REC_INSTALLED_PART
--	FOREIGN KEY (INSTALLED_PART) 
--	REFERENCES installed_parts (ID)
--)
--/
COMMIT
/