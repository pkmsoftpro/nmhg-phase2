--Purpose    : Changes Made for Inventory Item Composition , Inventory item and Serialized Item Replacement for Inventory Item Composition Registration 
--Author     : Lavin Hawes
--Created On : 18-Dec-09



ALTER TABLE INVENTORY_ITEM_COMPOSITION DROP COLUMN BASED_ON
/

ALTER TABLE INVENTORY_ITEM_COMPOSITION ADD SOURCE_OF_PART VARCHAR2(255 CHAR)
/

ALTER TABLE INVENTORY_ITEM ADD INSTALLATION_DATE DATE
/

ALTER TABLE INVENTORY_ITEM ADD INVENTORY_ITEM_TYPE VARCHAR2(255 BYTE)
/

ALTER TABLE SERIALIZED_ITEM_REPLACEMENT ADD OLD_SERIAL_NUMBER VARCHAR2(255 BYTE)
/

ALTER TABLE SERIALIZED_ITEM_REPLACEMENT DROP COLUMN FOR_COMPOSITION
/

ALTER TABLE SERIALIZED_ITEM_REPLACEMENT DROP COLUMN NEW_PART
/
Alter table service_Provider add certified Number(1,0) DEFAULT 0
/
COMMIT