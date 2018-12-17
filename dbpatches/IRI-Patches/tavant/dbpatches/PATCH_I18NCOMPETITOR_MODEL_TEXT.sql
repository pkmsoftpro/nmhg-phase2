--Purpose    : Static Internationalization of the COMPETITOR_MODEL table
--Author     : shraddha.nanda
--Created On : 22-Aug-08


CREATE TABLE I18NCOMPETITOR_MODEL_TEXT
(
  ID                     NUMBER(19)             NOT NULL,
  LOCALE                 VARCHAR2(255 CHAR),
  MODEL                  VARCHAR2(255 CHAR),
  I18N_COMPETITOR_MODEL  NUMBER(19)             NOT NULL 
)
/
ALTER TABLE I18NCOMPETITOR_MODEL_TEXT ADD CONSTRAINT I18NCOMPETITOR_MODEL_TEXT_PK	PRIMARY KEY( 	ID	)
/
ALTER TABLE I18NCOMPETITOR_MODEL_TEXT ADD (
 CONSTRAINT COMPETITOR_MODEL_FK 
 FOREIGN KEY (I18N_COMPETITOR_MODEL) 
 REFERENCES COMPETITOR_MODEL(ID)
 )
/
CREATE SEQUENCE I18N_COMPETITOR_MODEL_TEXT_SEQ
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_US','UNKNOWN/NOT PROVIDED',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'UNKNOWN/NOT PROVIDED'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_UK','UNKNOWN/NOT PROVIDED',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'UNKNOWN/NOT PROVIDED'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'fr_FR','UNKNOWN/NOT PROVIDED',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'UNKNOWN/NOT PROVIDED'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'de_DE','UNKNOWN/NOT PROVIDED',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'UNKNOWN/NOT PROVIDED'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_US','DIESEL',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'DIESEL'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_UK','DIESEL',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'DIESEL'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'fr_FR','DIESEL',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'DIESEL'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'de_DE','DIESEL',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'DIESEL'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_US','ELECTRIC',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'ELECTRIC'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_UK','ELECTRIC',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'ELECTRIC'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'fr_FR','ELECTRIC',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'ELECTRIC'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'de_DE','ELECTRIC',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'ELECTRIC'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_US','GAS',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'GAS'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_UK','GAS',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'GAS'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'fr_FR','GAS',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'GAS'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'de_DE','GAS',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'GAS'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_US','OTHER',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'OTHER'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'en_UK','OTHER',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'OTHER'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'fr_FR','OTHER',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'OTHER'))
/
INSERT INTO I18NCOMPETITOR_MODEL_TEXT VALUES (I18N_COMPETITOR_MODEL_TEXT_SEQ.NEXTVAL,'de_DE','OTHER',(SELECT ID FROM COMPETITOR_MODEL WHERE MODEL = 'OTHER'))
/
COMMIT
/
  