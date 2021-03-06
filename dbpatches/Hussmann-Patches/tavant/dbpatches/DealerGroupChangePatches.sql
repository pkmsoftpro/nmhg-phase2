--purpose : PATCH FOR Changes to Dealer Group Changes
--Author: Priyaank Gupta
--Created On: Date 20 Oct 2008
CREATE TABLE SERVICE_PROVIDER ( ID NUMBER(19) NOT NULL)
/
CREATE UNIQUE INDEX SERVICE_PROVIDER_PK ON SERVICE_PROVIDER (ID) 
/
ALTER TABLE SERVICE_PROVIDER ADD ( CONSTRAINT SERVICE_PROVIDER_PK PRIMARY KEY (ID))
/
ALTER TABLE DEALERSHIP DROP CONSTRAINT DEALERSHIP_ID_FK
/
ALTER TABLE DEALERS_IN_GROUP DROP CONSTRAINT DEALERSINGROUP_DEALER_FK
/
ALTER TABLE THIRD_PARTY DROP CONSTRAINT THIRDPARTY_ID_FK
/
INSERT INTO SERVICE_PROVIDER(SELECT DISTINCT ID FROM DEALERSHIP)
/
INSERT INTO SERVICE_PROVIDER(SELECT DISTINCT ID FROM THIRD_PARTY)
/
INSERT INTO SERVICE_PROVIDER(SELECT DISTINCT ID FROM NATIONAL_ACCOUNT)
/
INSERT INTO SERVICE_PROVIDER(SELECT DISTINCT ID FROM DIRECT_CUSTOMER)
/
INSERT INTO SERVICE_PROVIDER(SELECT DISTINCT ID FROM ORIGINAL_EQUIP_MANUFACTURER)
/
INSERT INTO SERVICE_PROVIDER(SELECT DISTINCT ID FROM INTER_COMPANY)
/
ALTER TABLE DEALERSHIP ADD CONSTRAINT DEALERSHIP_ID_FK FOREIGN KEY (ID) REFERENCES SERVICE_PROVIDER (ID)
/
ALTER TABLE DEALERS_IN_GROUP ADD CONSTRAINT DEALERSINGROUP_DEALER_FK FOREIGN KEY (DEALER) REFERENCES SERVICE_PROVIDER (ID)
/
ALTER TABLE THIRD_PARTY ADD CONSTRAINT THIRDPARTY_ID_FK FOREIGN KEY (ID) REFERENCES SERVICE_PROVIDER (ID)
/
ALTER TABLE SERVICE_PROVIDER ADD (SERVICE_PROVIDER_NUMBER VARCHAR(255))
/
UPDATE SERVICE_PROVIDER SP SET SERVICE_PROVIDER_NUMBER = (SELECT THIRD_PARTY_NUMBER FROM THIRD_PARTY TP WHERE TP.ID = SP.ID) WHERE SP.ID IN (SELECT DISTINCT ID FROM THIRD_PARTY)
/
UPDATE SERVICE_PROVIDER SP SET SERVICE_PROVIDER_NUMBER = (SELECT DEALER_NUMBER FROM DEALERSHIP D WHERE D.ID = SP.ID) WHERE SP.ID IN (SELECT DISTINCT ID FROM DEALERSHIP)
/
UPDATE SERVICE_PROVIDER SP SET SERVICE_PROVIDER_NUMBER = (SELECT NATIONAL_ACCOUNT_NUMBER FROM NATIONAL_ACCOUNT NA WHERE NA.ID = SP.ID) WHERE SP.ID IN (SELECT DISTINCT ID FROM NATIONAL_ACCOUNT)
/
UPDATE SERVICE_PROVIDER SP SET SERVICE_PROVIDER_NUMBER = (SELECT ORG_EQUIP_MANUF_NUMBER FROM ORIGINAL_EQUIP_MANUFACTURER OEM WHERE OEM.ID = SP.ID) WHERE SP.ID IN (SELECT DISTINCT ID FROM ORIGINAL_EQUIP_MANUFACTURER)
/
UPDATE SERVICE_PROVIDER SP SET SERVICE_PROVIDER_NUMBER = (SELECT DIRECT_CUSTOMER_NUMBER FROM DIRECT_CUSTOMER DC WHERE DC.ID = SP.ID) WHERE SP.ID IN (SELECT DISTINCT ID FROM DIRECT_CUSTOMER)
/
UPDATE SERVICE_PROVIDER SP SET SERVICE_PROVIDER_NUMBER = (SELECT INTER_COMPANY_NUMBER FROM INTER_COMPANY IC WHERE IC.ID = SP.ID) WHERE SP.ID IN (SELECT DISTINCT ID FROM INTER_COMPANY)
/
