ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "TOTAL_AMT"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "TOTAL_CURR"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "DISBURSED_AMT"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "DISBURSED_CURR"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "COSTPRICE_AMT"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "COSTPRICE_CURR"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "DLR_CLAIM_AMT"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "DLR_CLAIM_CURR"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "TOTAL_DLR_CLAIM_AMT"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "TOTAL_DLR_CLAIM_CURR"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "DISPLAY_AMT"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "DISPLAY_CURR"
/
ALTER TABLE LINE_ITEM_GROUP 
DROP COLUMN "PERCENTAGE_ACCEPTANCE_FOR_CP"
/
ALTER TABLE PAYMENT 
DROP COLUMN "PREVIOUS_PAID_AMOUNT_AMT"
/
ALTER TABLE PAYMENT 
DROP COLUMN "PREVIOUS_PAID__AMOUNT_CURR"
/
ALTER TABLE PAYMENT 
DROP COLUMN "CLAIMED_TOTAL_AMT"
/
ALTER TABLE PAYMENT 
DROP COLUMN "CLAIMED_TOTAL_CURR"
/
drop table "PAYMENT_PREVIOUS_CREDIT_MEMOS" cascade constraints
/
drop table "PREVIOUS_PART_INFO" cascade constraints
/
drop table "LINE_ITEM_GROUP_AUDIT" cascade constraints
/
drop table "PAYMENT_COMPONENT" cascade constraints
/
drop table "PAYMENT_AUDIT" cascade constraints
/
drop table Temp_Labor_Split_Details
/