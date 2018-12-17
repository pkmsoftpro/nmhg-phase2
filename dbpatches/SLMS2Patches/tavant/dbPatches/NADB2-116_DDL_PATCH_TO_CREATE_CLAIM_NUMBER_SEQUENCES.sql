-- PURPOSE    : PATCH TO Create Claim Number Sequences for EMEA and AMER
-- AUTHOR     : ParthaSarathy R
-- CREATED ON : 27-Mar-2013

CREATE SEQUENCE EMEA_CLAIM_NUMBER_SEQ
  MINVALUE 0
  MAXVALUE 9999999999999999999999999999
  INCREMENT BY 1
  NOCYCLE
  NOORDER
  NOCACHE
/
CREATE SEQUENCE AMER_CLAIM_NUMBER_SEQ
  MINVALUE 0
  MAXVALUE 9999999999999999999999999999
  INCREMENT BY 1
  NOCYCLE
  NOORDER
  NOCACHE
/