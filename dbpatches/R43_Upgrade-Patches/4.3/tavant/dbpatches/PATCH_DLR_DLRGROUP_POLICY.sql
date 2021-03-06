--Purpose    : Changes Made to include Dealer and Dealer Groups  to a Policy, changes made as a part of 4.3 upgrade 
--Created On : 11-Oct-2010
--Created By : Kuldeep Patil
--Impact     : None

CREATE TABLE POLICY_FOR_SERVICEPROVIDERS
(
POLICY_DEFN NUMBER(19), 
FOR_SERVICE_PROVIDER NUMBER(19)
)
/
COMMIT
/
ALTER TABLE POLICY_FOR_SERVICEPROVIDERS ADD (
	CONSTRAINT FK_POLICY_DEFNIT
	FOREIGN KEY (POLICY_DEFN)
	REFERENCES POLICY_DEFINITION (ID)
)
/
COMMIT
/
ALTER TABLE POLICY_FOR_SERVICEPROVIDERS ADD (
	CONSTRAINT FK_SERVICE_PROVIDER
	FOREIGN KEY (FOR_SERVICE_PROVIDER)
	REFERENCES SERVICE_PROVIDER (ID)
)
/
COMMIT
/
CREATE TABLE POLICY_FOR_DEALER_GROUPS
(
POLICY_DEFN NUMBER(19), 
FOR_DEALER_GROUPS NUMBER(19)
)
/
COMMIT
/
ALTER TABLE POLICY_FOR_DEALER_GROUPS ADD (
	CONSTRAINT FK_POLICY_DEFN_DEALER_GROUP
	FOREIGN KEY (POLICY_DEFN)
	REFERENCES POLICY_DEFINITION (ID)
)
/
COMMIT
/
ALTER TABLE POLICY_FOR_DEALER_GROUPS ADD (
	CONSTRAINT FK_DEALER_GROUP
	FOREIGN KEY (FOR_DEALER_GROUPS)
	REFERENCES DEALER_GROUP (ID)
)
/
COMMIT
/