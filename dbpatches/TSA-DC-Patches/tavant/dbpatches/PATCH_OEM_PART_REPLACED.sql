--Purpose    : domain changes on OEM_PART_REPLACED
--Created On : 09-APR-2010
--Created By : Sudaksh Chohan

ALTER TABLE OEM_PART_REPLACED DROP COLUMN SUPPLIER_PART_RETURN
/
ALTER TABLE OEM_PART_REPLACED DROP COLUMN SUPPLIER_SHIPMENT
/
ALTER TABLE OEM_PART_REPLACED DROP COLUMN SUPPLIER_ITEM
/
ALTER TABLE OEM_PART_REPLACED DROP COLUMN SUPPLIER_RETURN_NEEDED
/
COMMIT
/