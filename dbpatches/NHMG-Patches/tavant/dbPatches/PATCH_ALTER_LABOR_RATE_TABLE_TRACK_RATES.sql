--PURPOSE    :TO CHANGE LABOR-RATE TO TRACK CERTIFIED AND UNCERTIFIED TECHNICIAN RATES
--AUTHOR     :SANTI SWAROOP.K
--CREATED ON :11-SEPT-2012

ALTER TABLE LABOR_RATE ADD (CERTIFIED_LABOR_PERCENTAGE NUMBER(19,2),UNCERTIFIED_LABOR_PERCENTAGE NUMBER(19,2))
/