CREATE TABLE LABOR_SPLIT_DETAIL_AUDIT
(
  ID                   NUMBER(19),  
  LABOR_TYPE           NUMBER(19),
  LABOR_HRS            NUMBER(19,2),
  NAME                 VARCHAR2(255 BYTE),
  labor_Rate_amt       NUMBER(19,2),
  labor_Rate_curr      VARCHAR2 (765),
  MULTIPLICATION_VALUE NUMBER(19,2),
  VERSION              NUMBER(10),
  D_CREATED_ON         DATE,
  D_UPDATED_ON         DATE,
  D_INTERNAL_COMMENTS  VARCHAR2(255 BYTE),
  D_LAST_UPDATED_BY    NUMBER(19),
  D_CREATED_TIME       TIMESTAMP(6),
  D_UPDATED_TIME       TIMESTAMP(6),
  LIST_INDEX           NUMBER(10)
)
/
CREATE UNIQUE INDEX LABOR_SPLIT_DETAIL_AUDIT_PK ON LABOR_SPLIT_DETAIL_AUDIT(ID)
/
ALTER TABLE LABOR_SPLIT_DETAIL_AUDIT ADD (
  CONSTRAINT LABOR_SPLIT_DETAIL_AUDIT_PK
 PRIMARY KEY
 (ID))
/
ALTER TABLE LABOR_SPLIT_DETAIL_AUDIT ADD CONSTRAINT split_detail_labor_type_fk FOREIGN KEY(
    labor_type
)
REFERENCES labor_split_type(
    id
)
/
CREATE SEQUENCE  LABOR_SPLIT_DETAIL_AUDIT_SEQ
  START WITH 3800
  INCREMENT BY 20
  MAXVALUE 999999999999999999999999999
  MINVALUE 1000
  NOCYCLE
  CACHE 20
  NOORDER;
/
CREATE TABLE line_itm_grp_audit_slt_dtl
(
 line_itm_grp_audit NUMBER(19),
 split_dtl_audit    NUMBER(19)
)
/
ALTER TABLE line_itm_grp_audit_slt_dtl ADD CONSTRAINT grp_audit_slt_dtl_fk FOREIGN KEY(
    line_itm_grp_audit
)
REFERENCES Line_Item_Group_Audit(
    id
)
/
ALTER TABLE line_itm_grp_audit_slt_dtl ADD CONSTRAINT slt_dtl_grp_audit_fk FOREIGN KEY(
    split_dtl_audit
)
REFERENCES LABOR_SPLIT_DETAIL_AUDIT(
    id
)
/
commit