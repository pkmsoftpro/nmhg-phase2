--PURPOSE    : PATCH FOR ADDING BUSINESS_UNIT_INFO in WARRANTY_TASK_INSTANCE table
--AUTHOR     : PRADYOT ROUT
--CREATED ON : 04-FEB-09

ALTER TABLE WARRANTY_TASK_INSTANCE ADD BUSINESS_UNIT_INFO   VARCHAR2(255 CHAR)
/ 
ALTER TABLE WARRANTY_TASK_INSTANCE ADD (
CONSTRAINT WNTY_TASK_INST_BU_FK FOREIGN KEY (BUSINESS_UNIT_INFO) REFERENCES BUSINESS_UNIT (NAME)) 
/
COMMIT
/