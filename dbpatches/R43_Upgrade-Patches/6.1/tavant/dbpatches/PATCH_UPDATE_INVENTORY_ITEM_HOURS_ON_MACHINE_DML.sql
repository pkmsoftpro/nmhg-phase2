--PURPOSE    : PATCH FOR UPDATING HOURS_ON_MACHINE
--AUTHOR     : GHANASHYAM DAS
--CREATED ON : 21-NOV-11

ALTER TABLE INVENTORY_ITEM ADD (HOURS_ON_MACHINE_NEW NUMBER(19,0))
/
ALTER TRIGGER WARRANTY_COVERAGE_TRIGGER DISABLE
/
UPDATE INVENTORY_ITEM SET HOURS_ON_MACHINE_NEW = HOURS_ON_MACHINE
/
ALTER TRIGGER WARRANTY_COVERAGE_TRIGGER ENABLE
/
ALTER TABLE INVENTORY_ITEM DROP COLUMN HOURS_ON_MACHINE
/
ALTER TABLE INVENTORY_ITEM RENAME COLUMN HOURS_ON_MACHINE_NEW TO HOURS_ON_MACHINE
/
COMMIT
/