CREATE OR REPLACE TRIGGER UPDATE_USER_EMAIL
AFTER INSERT OR UPDATE
ON ADDRESS
FOR EACH ROW	

DECLARE
v_id	NUMBER;
BEGIN

UPDATE ORG_USER 
SET EMAIL = :NEW.EMAIL
WHERE 
ADDRESS = :NEW.ID;

EXCEPTION
WHEN OTHERS
THEN
	NULL;
END;

