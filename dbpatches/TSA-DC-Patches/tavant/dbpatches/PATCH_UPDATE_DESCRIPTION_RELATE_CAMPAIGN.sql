--Purpose    : updating the data type of column DESCRIPTION
--Author     : Mayank Vikram
--Created On : 15/04/2010
--Impact     : None

ALTER TABLE RELATE_CAMPAIGN MODIFY DESCRIPTION VARCHAR2(4000 BYTE)
/
commit
/


