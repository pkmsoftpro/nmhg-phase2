-- PURPOSE    : PATCH TO Create Sequence for State Mandates
-- AUTHOR     : Arpitha Nadig AR.
-- CREATED ON : 13-DEC-2013

CREATE SEQUENCE state_mandates_seq
  MINVALUE 1000
  MAXVALUE 9999999999999999999999999999
  INCREMENT BY 20
  NOCYCLE
  NOORDER
  CACHE 20
/
CREATE SEQUENCE state_mndte_cost_ctgy_seq
  MINVALUE 1000
  MAXVALUE 9999999999999999999999999999
  INCREMENT BY 20
  NOCYCLE
  NOORDER
  CACHE 20
/