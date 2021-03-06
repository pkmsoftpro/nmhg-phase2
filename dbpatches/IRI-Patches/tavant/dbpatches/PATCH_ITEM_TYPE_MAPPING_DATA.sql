--PURPOSE    : PATCH FOR ITEM_TYPE_MAPPING TABLE DATA
--AUTHOR     : BHASKARA K
--CREATED ON : 20-APR-09

DELETE FROM ITEM_TYPE_MAPPING
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'PARTS', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'MACHINE', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'ATTACHMENT', 'ATTACHMENT')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'EXTENDED WARRANTY', 'EXTENDED WARRANTY')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'KIT', 'KIT')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'OPTIONS', 'OPTION')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'SECONDHAND', 'SECONDHAND')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'COMPLETE MACHINES NOT PLANNED', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'ATTACHMENTS', 'ATTACHMENT')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'WIP KITTING', 'WIP KITTING')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'WIP CONFIGURATIONS', 'WIP CONFIGURATIONS')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'COMPLETE-CARS-PLANNED', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'COMPLETE-OTHERS', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'COMPLETE', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'TK MINMAX PARTS', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'TK MPS ASSEMBLIES', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'TK MPS PARTS', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'TK TELE SERV', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'TK TELEMATICS', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'PART', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'ACCESSORY', 'PART')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'COMPLETE MACHINES', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'CONFIGURATIONS', 'MACHINE')
/
INSERT INTO ITEM_TYPE_MAPPING ( ID, EXTERNAL_ITEM_TYPE, ITEM_TYPE ) VALUES (ITEM_TYPE_MAPPING_SEQ.NEXTVAL, 'TOOLS', 'MACHINE')
/
COMMIT
/
