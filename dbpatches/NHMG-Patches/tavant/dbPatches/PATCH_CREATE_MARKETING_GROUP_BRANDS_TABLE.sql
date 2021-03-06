CREATE TABLE MARKETING_GROUP
  (
    ID      NUMBER(19,0)  NOT NULL ENABLE,
	CONSTRAINT MKT_GRP_ID_PK PRIMARY KEY (ID) ENABLE,
    MKT_GRP_CODE    VARCHAR2(255 CHAR) NOT NULL ENABLE,
    MKT_GRP_NAME    VARCHAR2(255 CHAR) NOT NULL ENABLE
   
  )
/
 CREATE SEQUENCE MARKETING_GROUP_SEQ MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 20 START WITH 110000000000440 CACHE 20 NOORDER NOCYCLE
/
 CREATE TABLE BRAND
  (
    ID      NUMBER(19,0)  NOT NULL ENABLE,
	CONSTRAINT BRAND_ID_PK PRIMARY KEY (ID) ENABLE,
    BRAND_CODE    VARCHAR2(255 CHAR) NOT NULL ENABLE,
    BRAND_NAME    VARCHAR2(255 CHAR) NOT NULL ENABLE
   
  )  
/
  CREATE SEQUENCE BRAND_SEQ MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 20 START WITH 110000000000440 CACHE 20 NOORDER NOCYCLE
/
   CREATE TABLE DEALER_MKG_GROUPS
  (
    dealership NUMBER(19,0),
    marketing_groups NUMBER(19,0),
    CONSTRAINT DMG_DLR_FK FOREIGN KEY (dealership) REFERENCES DEALERSHIP (ID) ENABLE,
    CONSTRAINT DMG_MKT_GRP_ID_FK FOREIGN KEY (marketing_groups) REFERENCES MARKETING_GROUP (ID) ENABLE
  )
/
   CREATE TABLE DEALER_BRANDS
  (

    dealership NUMBER(19,0),
    brands NUMBER(19,0),
    CONSTRAINT DLR_BRD_DLR_FK FOREIGN KEY (dealership) REFERENCES DEALERSHIP (ID) ENABLE,
    CONSTRAINT DLR_BRD_FK FOREIGN KEY (brands) REFERENCES BRAND (ID) ENABLE
  )
/