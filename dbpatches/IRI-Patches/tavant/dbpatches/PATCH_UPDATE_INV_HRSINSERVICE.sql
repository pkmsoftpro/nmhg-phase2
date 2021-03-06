CREATE OR REPLACE TRIGGER "UPDATE_INV_HRSINSERVICE"
AFTER INSERT OR UPDATE
ON CLAIM
REFERENCING NEW AS newRow
FOR EACH ROW
DECLARE
  v_item_hrs INVENTORY_ITEM.HOURS_ON_MACHINE%TYPE;
  v_claimed_item_hrs CLAIMED_ITEM.HOURS_IN_SERVICE%TYPE;
CURSOR itemIds IS
            SELECT ITEM_REF_INV_ITEM  FROM CLAIMED_ITEM WHERE CLAIM= :newRow.id and item_ref_szed=1;

BEGIN
 IF(:newRow.STATE='ACCEPTED') THEN
BEGIN
	FOR REC IN itemIds LOOP
	SELECT HOURS_ON_MACHINE INTO v_item_hrs FROM INVENTORY_ITEM WHERE id=REC. ITEM_REF_INV_ITEM;
	SELECT  HOURS_IN_SERVICE  INTO v_claimed_item_hrs FROM CLAIMED_ITEM WHERE CLAIM=:newRow.id AND ITEM_REF_INV_ITEM=REC. ITEM_REF_INV_ITEM;
	IF(	v_claimed_item_hrs>v_item_hrs) THEN
	UPDATE INVENTORY_ITEM SET  HOURS_ON_MACHINE= v_claimed_item_hrs  WHERE id=REC. ITEM_REF_INV_ITEM;
	END IF ;
	END LOOP;
END;
END IF;
END;
/

