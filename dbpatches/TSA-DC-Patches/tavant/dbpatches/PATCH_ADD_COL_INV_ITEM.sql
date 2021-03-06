ALTER TABLE inventory_item ADD FLEET_NUMBER VARCHAR2(255 BYTE)
/
ALTER TABLE inventory_item ADD OEM NUMBER(19,0)
/
ALTER TABLE inventory_item ADD OPERATOR NUMBER(19,0)
/
ALTER TABLE inventory_item ADD INSTALLING_DEALER NUMBER(19,0)
/
ALTER TABLE inventory_item ADD (
  CONSTRAINT INV_ITEM_OPERATOR_FK 
 FOREIGN KEY (OPERATOR) 
 REFERENCES CUSTOMER (ID))
/
ALTER TABLE inventory_item ADD (
  CONSTRAINT INV_ITEM_INSTALLING_DLR_FK
 FOREIGN KEY (INSTALLING_DEALER) 
 REFERENCES PARTY (ID))
/
