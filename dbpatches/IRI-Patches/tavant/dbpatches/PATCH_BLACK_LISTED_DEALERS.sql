--PURPOSE    : PATCH FOR IMPLEMENTING EXTENDED WARRANTY PURCHASE FOR BLACK LISTED SERVICE PROVIDERS
--AUTHOR     : PRADYOT ROUT
--CREATED ON : 17-JUL-09

CREATE TABLE policy_not_for_providers (policy_defn NUMBER(19,0) NOT NULL, 
for_service_provider NUMBER(19,0) NOT NULL)
/
ALTER TABLE policy_not_for_providers ADD CONSTRAINT PLC_NOT_FOR_SVC_PRD_POLICY_FK FOREIGN 
KEY (policy_defn) REFERENCES POLICY_DEFINITION
/
ALTER TABLE policy_not_for_providers ADD CONSTRAINT PLC_NOT_FOR_SVC_PROVIDER_FK 
FOREIGN KEY (for_service_provider ) REFERENCES SERVICE_PROVIDER
/
COMMIT
/