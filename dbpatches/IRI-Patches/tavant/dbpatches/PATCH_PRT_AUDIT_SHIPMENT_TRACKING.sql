--PURPOSE    : PATCH FOR MAINTAING PART RETURN AUDIT IN ORDER AND ADDING SHIPMENT_ID AND TRACKING NUMBER IN PART_RETURN_ACTION
--AUTHOR     : PRADYOT ROUT
--CREATED ON : 14-MAR-09

ALTER TABLE PART_RETURN_AUDIT ADD LIST_INDEX NUMBER(19)
/
ALTER TABLE PART_RETURN_ACTION ADD SHIPMENT_ID VARCHAR(255)
/
ALTER TABLE PART_RETURN_ACTION ADD TRACKING_NUMBER VARCHAR(255)
/
COMMIT
/