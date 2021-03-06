--PURPOSE    : PATCH FOR adding create date column in NOTIFICATION_EVENT and NOTIFICATION_MESSAGE TABLE
--AUTHOR     : PRADYOT ROUT
--CREATED ON : 02-JAN-10

ALTER TABLE NOTIFICATION_EVENT add
(
  D_CREATED_ON         DATE,
  D_CREATED_TIME       TIMESTAMP(6),
  D_INTERNAL_COMMENTS  VARCHAR2(255 CHAR),
  D_UPDATED_ON         DATE,
  D_UPDATED_TIME       TIMESTAMP(6),
  D_LAST_UPDATED_BY    NUMBER(19),
  D_ACTIVE             NUMBER(1)
)
/
ALTER TABLE NOTIFICATION_EVENT  ADD (CONSTRAINT EVENT_UPDATED_BY_FK FOREIGN KEY (D_LAST_UPDATED_BY) REFERENCES ORG_USER (ID))
/
alter table abstract_notification_message add (exception varchar2(255))
/
COMMIT
/