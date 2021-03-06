--Purpose    :  added columns to support soft deletion of rule groups
--Author     : vaibhav.fouzdar
--Created On : 06-04-2009
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_ACTIVE NUMBER)
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_CREATED_ON DATE)
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_CREATED_TIME TIMESTAMP(6))
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_INTERNAL_COMMENTS VARCHAR2(255 CHAR))
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_LAST_UPDATED_BY NUMBER(19))
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_UPDATED_ON DATE)
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (D_UPDATED_TIME TIMESTAMP(6))
/
ALTER TABLE DOMAIN_RULE_GROUP ADD (status VARCHAR2(255 CHAR))
/