--Purpose    : DDL for NMHGSLMS-Booking Installation
--Author     : Manohar Reddy
--Created On : 13-DEC-2013
--------------------------------------------------------
--  DDL for Table BOOKINGS_REPORT
--------------------------------------------------------
CREATE TABLE  BOOKINGS_REPORT
   (	
   ID NUMBER, 
	REPORTING_TIME TIMESTAMP (6), 
	NO_OF_DR NUMBER DEFAULT 0, 
	NO_OF_D2D NUMBER DEFAULT 0, 
	NO_OF_SIGNATURE_SHEET NUMBER DEFAULT 0,
	PRIMARY KEY (ID)
   ) 
/
CREATE SEQUENCE  BOOKING_REPORT_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 20 START WITH 1000 CACHE 20 NOORDER  NOCYCLE 
/

