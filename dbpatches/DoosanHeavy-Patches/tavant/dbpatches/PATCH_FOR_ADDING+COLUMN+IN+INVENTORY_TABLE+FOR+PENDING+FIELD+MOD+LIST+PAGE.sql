 --PURPOSE    : PATCH TO CREATE CAMPAIGN_AUDIT TABLE FOR CAMPAIGN ACTION HISTORY
--AUTHOR     : RAVIKUMAR.Y
--CREATED ON : 29-JUNE-12

ALTER TABLE INVENTORY_ITEM ADD (FIELD_MOD_INV_STATUS NUMBER(19,0))
/
ALTER TABLE INVENTORY_ITEM ADD CONSTRAINT INV_ITEM_FieldMODINVSTATUS_FK FOREIGN KEY (FIELD_MOD_INV_STATUS) REFERENCES LIST_OF_VALUES (ID) ENABLE
/