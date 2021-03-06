--PURPOSE    : PATCH FOR Internationalization of MISC ITEM
--AUTHOR     : PRADYOT ROUT
--CREATED ON : 16-FEB-09

CREATE TABLE MISC_I18N_TEXT (
MISC_ITEM NUMBER(19,0) NOT NULL, 
I18N_TEXT NUMBER(19,0) NOT NULL,
UNIQUE (I18N_TEXT))
/
ALTER TABLE MISC_I18N_TEXT ADD CONSTRAINT MISC_ITEM_FK FOREIGN KEY (MISC_ITEM) 
REFERENCES MISC_ITEM
/
ALTER TABLE MISC_I18N_TEXT ADD CONSTRAINT I18N_MISC_ITEM_FK FOREIGN KEY (I18N_TEXT) 
REFERENCES reporti18ntext 
/