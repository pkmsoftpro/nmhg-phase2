--Purpose    : Created an entity to hold the root causes
--Author     : Jhulfikar Ali. A
--Created On : 21-Jan-09

CREATE TABLE FAILURE_ROOT_CAUSE_DEFINITION (
ID NUMBER NOT NULL, 
CODE VARCHAR2(255 CHAR), 
DESCRIPTION VARCHAR2(255 CHAR), 
NAME VARCHAR2(255 CHAR), 
VERSION NUMBER NOT NULL, 
D_CREATED_ON DATE, 
D_INTERNAL_COMMENTS VARCHAR2(255 CHAR), 
D_UPDATED_ON DATE, 
D_LAST_UPDATED_BY NUMBER, 
D_CREATED_TIME TIMESTAMP (6), 
D_UPDATED_TIME TIMESTAMP (6), 
D_ACTIVE NUMBER DEFAULT 1, 
CONSTRAINT FLR_ROOT_CAUSE_DEFINITION_PK PRIMARY KEY (ID), 
CONSTRAINT FLR_RT_CAUS_DEF_LST_UPDT_BY_FK FOREIGN KEY 
(D_LAST_UPDATED_BY) REFERENCES ORG_USER (ID) 
)
/
CREATE SEQUENCE  FAILURE_ROOT_CAUSE_DEFN_SEQ  
MINVALUE 1 MAXVALUE 999999999999999999999999999 
INCREMENT BY 20 
START WITH 2203297 
NOCACHE  NOORDER  NOCYCLE
/
CREATE TABLE I18NFLR_ROOT_CAUSE_DEFINITION (	
ID NUMBER NOT NULL, 
LOCALE VARCHAR2(255 CHAR), 
NAME VARCHAR2(255 CHAR), 
FAILURE_ROOT_CAUSE_DEFINITION NUMBER NOT NULL, 
CONSTRAINT I18NFLR_RT_CAUSE_DEF_PK PRIMARY KEY (ID), 
CONSTRAINT I18NFLR_RT_CAUSE_FK FOREIGN KEY (FAILURE_ROOT_CAUSE_DEFINITION)
	  REFERENCES FAILURE_ROOT_CAUSE_DEFINITION (ID) 
)
/
CREATE SEQUENCE  I18N_Flr_Root_Cause_Def_SEQ 
MINVALUE 1 MAXVALUE 999999999999999999999999999 
INCREMENT BY 20 START WITH 5800 
CACHE 20 NOORDER  NOCYCLE
/
CREATE TABLE FAILURE_ROOT_CAUSE (
ID NUMBER NOT NULL, 
VERSION NUMBER NOT NULL, 
FAILURE_TYPE_ID NUMBER, 
DEFINITION_ID NUMBER, 
D_CREATED_ON DATE, 
D_INTERNAL_COMMENTS VARCHAR2(255 CHAR), 
D_UPDATED_ON DATE, 
D_LAST_UPDATED_BY NUMBER, 
D_CREATED_TIME TIMESTAMP (6), 
D_UPDATED_TIME TIMESTAMP (6), 
D_ACTIVE NUMBER DEFAULT 1, 
CONSTRAINT FAILURE_ROOT_CAUSE_PK PRIMARY KEY (ID), 
CONSTRAINT FLRROOTCAUSE_DEFINITIONID_FK FOREIGN KEY (DEFINITION_ID)
	  REFERENCES FAILURE_ROOT_CAUSE_DEFINITION (ID), 
CONSTRAINT FLRROOTCAUSE_FAILURETYPEID_FK FOREIGN KEY (FAILURE_TYPE_ID)
	  REFERENCES FAILURE_TYPE (ID), 
CONSTRAINT FLR_ROOT_CAUSE_LST_UPDT_BY_FK FOREIGN KEY (D_LAST_UPDATED_BY)
	  REFERENCES ORG_USER (ID));
/
CREATE INDEX FLRROOTCAUSE_DEFINITIONID_IX ON FAILURE_ROOT_CAUSE (DEFINITION_ID) 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 1048576 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "TW_DATA"
/
CREATE INDEX FLRROOTCAUSE_FAILURETYPEID_IX ON FAILURE_ROOT_CAUSE (FAILURE_TYPE_ID) 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 1048576 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "TW_DATA"
/
CREATE SEQUENCE FAILURE_ROOT_CAUSE_SEQ  
MINVALUE 1 MAXVALUE 999999999999999999999999999 
INCREMENT BY 20 START WITH 2203297 
NOCACHE  NOORDER  NOCYCLE
/
ALTER TABLE item_group ADD machine_url VARCHAR2(4000)
/
ALTER TABLE service_information ADD root_cause NUMBER
/
ALTER TABLE service_information ADD CONSTRAINT service_information_rt_fk 
FOREIGN KEY  (root_cause) REFERENCES FAILURE_ROOT_CAUSE_DEFINITION(ID)
/
COMMIT
/