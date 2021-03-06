--Purpose    : Scripts for adding LOA tables, changes made as a part of 4.3 upgrade 
--Created On : 11-Oct-2010
--Created By : Kuldeep Patil
--Impact     : None

CREATE TABLE LIMIT_OF_AUTHORITY_SCHEME 
	(ID NUMBER(19,0) NOT NULL, 
	NAME VARCHAR2(255 CHAR) NOT NULL, 
	DESCRIPTION VARCHAR2(255 CHAR), 	
	VERSION NUMBER(10,0), 
	D_CREATED_ON DATE, 
	D_INTERNAL_COMMENTS VARCHAR2(255 CHAR), 
	D_UPDATED_ON DATE, 
	D_LAST_UPDATED_BY NUMBER(19,0), 
	D_CREATED_TIME TIMESTAMP (6), 
	D_UPDATED_TIME TIMESTAMP (6), 
	D_ACTIVE NUMBER(1,0) DEFAULT 1, 
	CODE VARCHAR2(255 CHAR),
	BUSINESS_UNIT_INFO VARCHAR2(255 CHAR),
	CONSTRAINT "LIMIT_OF_AUTHORITY_SCHEME_PK" PRIMARY KEY ("ID"))
/
CREATE SEQUENCE LOA_SCHEME_SEQ MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 20 START WITH 1000 NOCACHE NOORDER NOCYCLE
/
CREATE TABLE LIMIT_OF_AUTHORITY_LEVEL 
	(ID NUMBER(19,0) NOT NULL, 
	NAME VARCHAR2(255 CHAR) NOT NULL, 
	LOA_LEVEL NUMBER(10,0), 
	LOA_SCHEME NUMBER(19,0),
	LOA_USER NUMBER(19,0), 
	VERSION NUMBER(10,0), 
	D_CREATED_ON DATE, 
	D_INTERNAL_COMMENTS VARCHAR2(255 CHAR), 
	D_UPDATED_ON DATE, 
	D_LAST_UPDATED_BY NUMBER(19,0), 
	D_CREATED_TIME TIMESTAMP (6), 
	D_UPDATED_TIME TIMESTAMP (6), 
	D_ACTIVE NUMBER(1,0) DEFAULT 1, 
	CONSTRAINT "LIMIT_OF_AUTHORITY_LEVEL_PK" PRIMARY KEY ("ID"))
/
CREATE SEQUENCE LOA_LEVEL_SEQ MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 20 START WITH 1000 NOCACHE NOORDER NOCYCLE
/
ALTER TABLE LIMIT_OF_AUTHORITY_LEVEL 
	ADD CONSTRAINT LOA_LEVEL_SCHEME_FK 
	FOREIGN KEY (LOA_SCHEME) 
	REFERENCES "LIMIT_OF_AUTHORITY_SCHEME" ("ID")
/
ALTER TABLE LIMIT_OF_AUTHORITY_LEVEL 
	ADD CONSTRAINT LOA_LEVEL_USER_FK 
	FOREIGN KEY (LOA_USER) 
	REFERENCES "ORG_USER" ("ID")
/
CREATE INDEX LOA_AUTHORITY_SCHEME_IDX ON LIMIT_OF_AUTHORITY_LEVEL(LOA_SCHEME)
/
--ALTER TABLE DOMAIN_RULE_ACTION ADD LOA_SCHEME NUMBER(19,0)
--/
--ALTER TABLE DOMAIN_RULE_ACTION 
--	ADD 
-- CONSTRAINT "DOMAIN_RULE_ACTION_LOASCHME_FK" FOREIGN KEY ("LOA_SCHEME")
--    REFERENCES "LIMIT_OF_AUTHORITY_SCHEME" ("ID")
--/
--Kuldeep - Removed this part as this has been dropped in PATCH_ADD_COL_ASSIGNMENT_RULE_ACTION.sql patch, Also removed the drop statement from PATCH_ADD_COL_ASSIGNMENT_RULE_ACTION.sql
COMMIT
/
