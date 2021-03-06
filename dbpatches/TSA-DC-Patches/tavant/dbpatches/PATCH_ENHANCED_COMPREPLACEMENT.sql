--Purpose    : Config param for replacing BU part with non BU part
--Author     : ramalakshmi.p	
--Created On : 08-Feb-2010

ALTER TABLE installed_parts add (serial_number varchar2(255))
/
ALTER TABLE SERIALIZED_ITEM_REPLACEMENT ADD (FOR_COMPOSITION NUMBER(19))
/
ALTER TABLE SERIALIZED_ITEM_REPLACEMENT
  ADD CONSTRAINT SLZED_ITEM_REP_ITEMCOMP_FK FOREIGN KEY (FOR_COMPOSITION) 
  REFERENCES inventory_item_composition (ID)
/
ALTER TABLE SERIALIZED_ITEM_REPLACEMENT ADD (NEW_PART NUMBER(19))
/
ALTER TABLE SERIALIZED_ITEM_REPLACEMENT
  ADD CONSTRAINT SLZED_ITEM_REP_INVITEM_FK FOREIGN KEY (NEW_PART) 
  REFERENCES inventory_item (ID)
/
COMMIT
/