-- PURPOSE    : PATCH TO ADD COLUMN CUSTOMER_REPRESENTATIVE IN MARKETING_INFORMATION --TABLE
-- AUTHOR     : PAllavi
-- CREATED ON : 26-April-2013

alter table MARKETING_INFORMATION add (CUSTOMER_REPRESENTATIVE VARCHAR2(255))
/