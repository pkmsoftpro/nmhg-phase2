--PURPOSE    : PATCH FOR CREATING CAMPAIGN_FOR_NATIONALACCOUNTS TABLE FOR ADDING NATIONAL ACCOUNTS TO FIELD MOD CAMPAIGN
--AUTHOR     : RAVIKUMAR.Y
--CREATED ON : 18-JULY-12

CREATE TABLE CAMPAIGN_FOR_NATIONALACCOUNTS
  (
    CAMPAIGN NUMBER(19,0) NOT NULL ENABLE,
    FOR_NATIONAL_ACCOUNTS NUMBER(19,0) NOT NULL ENABLE,
    CONSTRAINT CAMPFOR_NAT_CAMP_FK FOREIGN KEY (CAMPAIGN) REFERENCES CAMPAIGN (ID) ENABLE,
    CONSTRAINT CAMPFOR_NAT_FORNAT_FK FOREIGN KEY (FOR_NATIONAL_ACCOUNTS) REFERENCES NATIONAL_ACCOUNT (ID) ENABLE
  )
/