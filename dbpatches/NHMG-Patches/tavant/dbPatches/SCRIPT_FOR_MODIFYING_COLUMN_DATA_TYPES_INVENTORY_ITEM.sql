--Purpose    : PATCH FOR MODIFYING THE COLUMN DATATYPES IN INVENTORY_ITEM ,OPTION_INFO TABLE
--Author     : kalyani	
--Created On : 24-APR-2013

ALTER TABLE INVENTORY_ITEM MODIFY(DISCOUNT_PERCENT  NUMBER(21,4))
/
ALTER TABLE OPTION_INFO MODIFY(OPTION_DISCOUNT_PERCENT  NUMBER(21,4))
/

