-- PURPOSE    : PATCH TO ADD COLUMN DEALER_REPRESENTATIVE IN MARKETING_INFORMATION TABLE
-- AUTHOR     : PRACHER
-- CREATED ON : 02-April-2013

alter table MARKETING_INFORMATION add (DEALER_REPRESENTATIVE VARCHAR2(255))
/