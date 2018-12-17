--PURPOSE    :CREATION OF NEW TABLES AND ALTERED WARRANTY TABLE FOR DR MANUAL APPROVAL FLOW
--AUTHOR     : PRADYOT.ROUT
--CREATED ON : 5-SEP-08

CREATE TABLE WARRANTY_AUDIT (ID NUMBER(19,0) NOT NULL, 
D_CREATED_ON DATE, 
D_INTERNAL_COMMENTS VARCHAR2(255 CHAR),
D_UPDATED_ON DATE, 
EXTERNAL_COMMENTS VARCHAR2(255 CHAR), 
INTERNAL_COMMENTS VARCHAR2(255 CHAR), 
STATUS VARCHAR2(255 CHAR), 
D_LAST_UPDATED_BY NUMBER(19,0), 
FOR_WARRANTY NUMBER(19,0) NOT NULL,
LIST_INDEX NUMBER(19,0),
VERSION NUMBER(19,0),
D_CREATED_TIME DATE,
D_UPDATED_TIME DATE,
CONSTRAINT WARRANTY_AUDIT_PK PRIMARY KEY(ID))
/
CREATE TABLE WARRANTY_TASK_INSTANCE (ID NUMBER(19,0) NOT NULL,
ACTIVE NUMBER(1,0),
D_CREATED_ON DATE,
D_INTERNAL_COMMENTS VARCHAR2(255 CHAR),
D_UPDATED_ON DATE,
STATUS VARCHAR2(255 CHAR),
VERSION NUMBER(10,0) NOT NULL,
FOR_ITEM NUMBER(19,0) NOT NULL,
ASSIGNED_TO NUMBER(19,0),
D_LAST_UPDATED_BY NUMBER(19,0),
D_CREATED_TIME DATE,
D_UPDATED_TIME DATE,
WARRANTY_AUDIT NUMBER(19,0) NOT NULL,
CONSTRAINT WARRANTY_TASK_INSTANCE_PK PRIMARY KEY(ID), CONSTRAINT WNTY_TASK_WNTY_AUDIT_UNIQUE UNIQUE (WARRANTY_AUDIT))
/
ALTER TABLE WARRANTY_AUDIT ADD CONSTRAINT WNTY_AUDIT_UPDATED_BY_FK FOREIGN KEY (D_LAST_UPDATED_BY) REFERENCES ORG_USER
/
ALTER TABLE WARRANTY_AUDIT ADD CONSTRAINT WNTY_AUDIT_FOR_WNTY_FK FOREIGN KEY (FOR_WARRANTY) REFERENCES WARRANTY
/
ALTER TABLE WARRANTY_TASK_INSTANCE ADD CONSTRAINT WNTY_TASK_INST_WNTY_AUDIT_FK FOREIGN KEY (WARRANTY_AUDIT) REFERENCES WARRANTY_AUDIT
/
ALTER TABLE WARRANTY_TASK_INSTANCE ADD CONSTRAINT WNTY_TASK_INST_UPDATED_BY_FK FOREIGN KEY (D_LAST_UPDATED_BY) REFERENCES ORG_USER
/
ALTER TABLE WARRANTY_TASK_INSTANCE ADD CONSTRAINT WNTY_TASK_INST_FOR_ITEM_FK FOREIGN KEY (FOR_ITEM) REFERENCES INVENTORY_ITEM
/
ALTER TABLE WARRANTY_TASK_INSTANCE ADD CONSTRAINT WNTY_TASK_INST_ASSIGN_TO_FK FOREIGN KEY (ASSIGNED_TO) REFERENCES ORG_USER
/
CREATE SEQUENCE WARRANTY_TASK_INSTANCE_SEQ
  START WITH 1000
  INCREMENT BY 20
  MAXVALUE 999999999999999999999999999
  MINVALUE 1000
  NOCYCLE
  CACHE 20
  NOORDER
/
CREATE SEQUENCE WARRANTY_AUDIT_SEQ
  START WITH 1000
  INCREMENT BY 20
  MAXVALUE 999999999999999999999999999
  MINVALUE 1000
  NOCYCLE
  CACHE 20
  NOORDER
/
ALTER TABLE WARRANTY ADD TRANSACTION_TYPE NUMBER(19,0)
/
ALTER TABLE WARRANTY ADD CONSTRAINT WNTY_TRANS_TYPE_FK FOREIGN KEY (TRANSACTION_TYPE) REFERENCES INVENTORY_TRANSACTION_TYPE
/
INSERT INTO ROLE (ID,NAME,DISPLAY_NAME,VERSION)
VALUES ((SELECT MAX(ID)+1 FROM ROLE),'warrantyProcessor','Warranty Processor',1)
/
update  warranty set status='SUBMITTED' where status='SUBMITED'
/
update  warranty set status='ACCEPTED' where status='SUBMITTED'
/
COMMIT
/