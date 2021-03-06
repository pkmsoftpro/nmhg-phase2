--Purpose    : Patch for Adding BU column in model category
--Author     : saya.sudha	
--Created On : 08-jan-2010

ALTER TABLE MODEL_CATEGORY ADD (business_unit_info VARCHAR2(255 BYTE))
/
ALTER TABLE MODEL_CATEGORY ADD 
(CONSTRAINT MODEL_CATEGORY_BU_FK FOREIGN KEY (BUSINESS_UNIT_INFO) REFERENCES BUSINESS_UNIT (NAME))
/
COMMIT
/