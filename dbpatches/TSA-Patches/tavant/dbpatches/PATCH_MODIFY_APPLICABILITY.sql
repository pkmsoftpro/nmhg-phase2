ALTER TABLE CUST_REPORT_APP_PART 
DROP COLUMN APPLICABILITY
/
CREATE TABLE APPLICABILITY
  (
    TYPE    VARCHAR2(255 CHAR) NOT NULL ENABLE PRIMARY KEY,
    VERSION NUMBER(10,0) NOT NULL ENABLE,
    D_CREATED_ON DATE,
    D_INTERNAL_COMMENTS VARCHAR2(255 CHAR),
    D_UPDATED_ON DATE,
    D_LAST_UPDATED_BY NUMBER(19,0) REFERENCES ORG_USER(ID),
    D_CREATED_TIME TIMESTAMP (6),
    D_UPDATED_TIME TIMESTAMP (6),
    D_ACTIVE NUMBER(1,0) DEFAULT 1
    )
/
INSERT into applicability
VALUES('Causal Part',1,sysdate,'Data Set Up',sysdate,null,cast( sysdate as TIMESTAMP),cast(sysdate as TIMESTAMP),1)
/
INSERT into applicability
VALUES('Removed Part',1,sysdate,'Data Set Up',sysdate,null,cast( sysdate as TIMESTAMP),cast(sysdate as TIMESTAMP),1)
/
INSERT into applicability
VALUES('Installed Part',1,sysdate,'Data Set Up',sysdate,null,cast( sysdate as TIMESTAMP),cast(sysdate as TIMESTAMP),1)
/
CREATE TABLE applicability_types_in_part
  (
    cust_rep_app_part  NUMBER(19,0) NOT NULL ENABLE REFERENCES CUST_REPORT_APP_PART(ID),
    applicability VARCHAR2(255 BYTE) NOT NULL ENABLE
  )
/
 CREATE SEQUENCE CUST_REPORT_INSTRUCTION  MINVALUE 20 MAXVALUE 999999999999999999999999999  
 INCREMENT BY 20 START WITH 20   CACHE 20   NOORDER NOCYCLE 
/
ALTER table REPORT_FORM_ANSWER_OPTION drop constraint SYS_C0012221
/
COMMIT
/
