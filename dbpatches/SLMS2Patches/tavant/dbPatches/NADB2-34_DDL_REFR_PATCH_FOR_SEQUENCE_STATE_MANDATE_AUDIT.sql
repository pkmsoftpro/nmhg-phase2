-- PURPOSE    : PATCH TO Create Sequence for STATE_MANDATE_AUDIT TABLE
-- AUTHOR     : Arpitha Nadig AR
-- CREATED ON : 14-JAN-2013

CREATE SEQUENCE state_mandate_audit_seq
  MINVALUE 1000
  MAXVALUE 9999999999999999999999999999
  INCREMENT BY 20
  NOCYCLE
  NOORDER
  CACHE 20
/