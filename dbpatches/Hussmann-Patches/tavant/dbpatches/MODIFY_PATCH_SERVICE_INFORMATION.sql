--purpose : PATCH FOR ADDING THE THIRD PARTY LABOR RATE COLUMN
--Author: P Shraddha Nanda
--Created On: Date 13 JAN 2009

ALTER TABLE SERVICE_INFORMATION
ADD 
(THIRD_PARTY_LABOR_RATE_AMT NUMBER(19,2))
/
ALTER TABLE SERVICE_INFORMATION
ADD 
(THIRD_PARTY_LABOR_RATE_CURR VARCHAR2(255))
/