--Purpose    : Patch for creating missing join tables related Market table
--Author     : Hari Krishna Y D
--Created On : 20-Jun-09

CREATE TABLE MARKET_DESC_I18N_TEXT
(
  MARKET     NUMBER(19)                         NOT NULL,
  I18N_TEXT  NUMBER(19)                         NOT NULL
)
/
ALTER TABLE MARKET_DESC_I18N_TEXT ADD (
  UNIQUE (I18N_TEXT))
/
ALTER TABLE MARKET_DESC_I18N_TEXT ADD (
  CONSTRAINT MARKET_DESC_FK 
 FOREIGN KEY (MARKET) 
 REFERENCES MARKET (ID))
/
ALTER TABLE MARKET_DESC_I18N_TEXT ADD (
  CONSTRAINT I18N_MARKET_DESC_FK 
 FOREIGN KEY (I18N_TEXT) 
 REFERENCES REPORTI18NTEXT (ID))
/
CREATE TABLE MARKET_I18N_TEXT
(
  MARKET     NUMBER(19)                         NOT NULL,
  I18N_TEXT  NUMBER(19)                         NOT NULL
)
/
ALTER TABLE MARKET_I18N_TEXT ADD (
  UNIQUE (I18N_TEXT))
/
ALTER TABLE MARKET_I18N_TEXT ADD (
  CONSTRAINT MARKET_FK 
 FOREIGN KEY (MARKET) 
 REFERENCES MARKET (ID))
/
ALTER TABLE MARKET_I18N_TEXT ADD (
  CONSTRAINT I18N_MARKET_FK 
 FOREIGN KEY (I18N_TEXT) 
 REFERENCES REPORTI18NTEXT (ID))
/
CREATE SEQUENCE MARKET_SEQ
  START WITH 1100000016400
  INCREMENT BY 20
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/
COMMIT
/