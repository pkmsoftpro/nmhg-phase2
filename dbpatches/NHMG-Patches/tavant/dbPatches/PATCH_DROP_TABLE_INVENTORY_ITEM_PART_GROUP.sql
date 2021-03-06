--PURPOSE    : Patch for drop table INVENTORY_ITEM_PART_GROUP , as part of NMHG TWMS implementation
--AUTHOR     : Pracher Pancholi
--CREATED ON : 2-Nov-2012

DROP TABLE INVENTORY_ITEM_PART_GROUP
/

CREATE TABLE INVENTORY_ITEM_PART_GROUPS
(
    inventory_item NUMBER(19,0),
    part_groups NUMBER(19,0),
    CONSTRAINT INV_PRT_INV_FK FOREIGN KEY (inventory_item) REFERENCES INVENTORY_ITEM (ID) ENABLE,
    CONSTRAINT INV_PRT_GRP_FK FOREIGN KEY (part_groups) REFERENCES PART_GROUP (ID) ENABLE
)
/