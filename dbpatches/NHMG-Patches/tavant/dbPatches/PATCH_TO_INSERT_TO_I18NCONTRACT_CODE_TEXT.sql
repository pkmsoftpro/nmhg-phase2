--PURPOSE    : PATCH FOR NSERTING DATA INTO I18NCONTRACT_CODE_TEXT,I18NINDUSTRY_CODE_TEXT,I18NMAINTENANCE_CONTRACT_TEXT
--AUTHOR     : Jyoti Chauhan
--CREATED ON : 11-Dec-12

DECLARE
CURSOR ALL_CONTRACTS IS SELECT ID,CONTRACT_CODE FROM CONTRACT_CODE;
BEGIN
FOR EACH_CONTRACT IN ALL_CONTRACTS
LOOP
INSERT INTO I18NCONTRACT_CODE_TEXT VALUES(I18NCONTRACT_CODE_TEXT_SEQ.NEXTVAL,'en_US',EACH_CONTRACT.CONTRACT_CODE,EACH_CONTRACT.ID);
END LOOP;
commit;
END;
/
DECLARE
CURSOR ALL_CONTRACTS IS SELECT ID,CONTRACT_CODE FROM CONTRACT_CODE;
BEGIN
FOR EACH_CONTRACT IN ALL_CONTRACTS
LOOP
INSERT INTO I18NCONTRACT_CODE_TEXT VALUES(I18NCONTRACT_CODE_TEXT_SEQ.NEXTVAL,'en_GB',EACH_CONTRACT.CONTRACT_CODE,EACH_CONTRACT.ID);
END LOOP;
commit;
END;
/
DECLARE
CURSOR ALL_INDUSTRYS IS SELECT ID,INDUSTRY_CODE FROM INDUSTRY_CODE;
BEGIN
FOR EACH_INDUSTRY IN ALL_INDUSTRYS
LOOP
INSERT INTO I18NINDUSTRY_CODE_TEXT VALUES(I18NINDUSTRY_CODE_TEXT_SEQ.NEXTVAL,'en_US',EACH_INDUSTRY.INDUSTRY_CODE,EACH_INDUSTRY.ID);
END LOOP;
commit;
END;
/
DECLARE
CURSOR ALL_INDUSTRYS IS SELECT ID,INDUSTRY_CODE FROM INDUSTRY_CODE;
BEGIN
FOR EACH_INDUSTRY IN ALL_INDUSTRYS
LOOP
INSERT INTO I18NINDUSTRY_CODE_TEXT VALUES(I18NINDUSTRY_CODE_TEXT_SEQ.NEXTVAL,'en_GB',EACH_INDUSTRY.INDUSTRY_CODE,EACH_INDUSTRY.ID);
END LOOP;
commit;
END;
/
DECLARE
CURSOR ALL_MAINTENANCES IS SELECT ID,MAINTENANCE_CONTRACT FROM MAINTENANCE_CONTRACT;
BEGIN
FOR EACH_MAINTENANCE IN ALL_MAINTENANCES
LOOP
INSERT INTO I18NMAINTENANCE_CONTRACT_TEXT VALUES(I18NMAINTENANCE_CNTRT_TEXT_SEQ.NEXTVAL,'en_US',EACH_MAINTENANCE.MAINTENANCE_CONTRACT,EACH_MAINTENANCE.ID);
END LOOP;
commit;
END;
/
DECLARE
CURSOR ALL_MAINTENANCES IS SELECT ID,MAINTENANCE_CONTRACT FROM MAINTENANCE_CONTRACT;
BEGIN
FOR EACH_MAINTENANCE IN ALL_MAINTENANCES
LOOP
INSERT INTO I18NMAINTENANCE_CONTRACT_TEXT VALUES(I18NMAINTENANCE_CNTRT_TEXT_SEQ.NEXTVAL,'en_GB',EACH_MAINTENANCE.MAINTENANCE_CONTRACT,EACH_MAINTENANCE.ID);
END LOOP;
commit;
END;
/