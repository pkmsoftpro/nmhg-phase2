--Purpose    : PATCH FOR STORING BUSINESS UNIT INFO IN DEALER GROUP
--Author     : Jitesh Jain
--Created On : 07-Nov-08

ALTER TABLE DEALER_GROUP ADD (business_unit_info VARCHAR2(255 BYTE))
/
ALTER TABLE DEALER_GROUP ADD (CONSTRAINT DEALER_GROUP_BU_FK FOREIGN KEY (BUSINESS_UNIT_INFO) REFERENCES BUSINESS_UNIT (NAME))
/
COMMIT
/
