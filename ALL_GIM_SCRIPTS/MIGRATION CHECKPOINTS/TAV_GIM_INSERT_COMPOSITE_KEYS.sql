/*-----------------------------------------------------------------------------
 * File Name	:	TAV_GIM_INSERT_COMPOSITE_KEYS.sql
 *
 * Purpose	:	This will populate all composite key table details in the given source database
 *                           
 * Revision History:
 *
 *  Date           Programmer              Description
 *  ------------   ---------------------   ------------------------------------
 *  Jan 15, 2011   Joseph                  Initial Write-Up
 *  Mar 28,2011	   Prabhu R		   Code Organization
 *-----------------------------------------------------------------------------
*/

Prompt Message: Inserting Composite key table...

Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ADD_LBR_EGL_SERVICE_PROVIDERS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ASSEMBLIES_INCLUDED','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('BU_ORG_MAPPING','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('CLAIM_RULE_FAILURES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('CLAIM_USER_PROCESS_COMMENTS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('CUSTOMER_ASSOCIATED_ORGS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('CUSTOMER_ROLES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('DEALERS_IN_GROUP','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('DEALER_CATEGORY_DEALERSHIP','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('DEALER_SCHEME_PURPOSES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('DOMAIN_PRED_REFERS_TO_PREDS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('EVAL_PRECEDENCE_PROPERTIES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('FAILURE_STRUCTURE_ASSEMBLIES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('FAULT_CODE_DEFINITION_LABELS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('FAULT_CODE_DEF_COMPS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('FAULT_CODE_PART_CLASS_ASSOC','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('INVENTORY_ITEM_LABELS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('INV_ITEM_ATTR_VALS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ITEMS_IN_GROUP','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ITEM_SCHEME_PURPOSES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('JBPM_BYTEBLOCK','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('JBPM_DECISIONCONDITIONS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('JBPM_FORM_NODES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('JBPM_TASKACTORPOOL','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('MIN_LBR_ROUND_UP_APP_PRODUCTS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ORG_USER_USER_GROUPS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('PAYMENT_PAYMENT_COMPONENTS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('POLICY_CATEGORY_POLICY','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('POLICY_DEFINITION_LABELS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('POLICY_DEF_APPLICABILITY_TERMS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('POLICY_FOR_PRODUCTS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('REPEATABLE_TRANSITION','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ROLES_IN_GROUP','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('ROLE_SCHEME_PURPOSES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('SECTIONS_IN_PYMT_DEFN','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('SECTION_COST_CATEGORIES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('SERVICE_PROCEDURE_DEF_LABELS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('SERVICE_PROC_DEF_COMPS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('SUPPLIER_LABELS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('TRANSITION_CONDITIONS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('USER_ATTR_VALS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('USER_CLUSTER_USER','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('USER_GROUP_ATTR_VALS','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('USER_ROLES','P',2);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('USER_SCHEME_PURPOSES','P',2);
-- Special Cases considered to be composite key tables to avoid creating OLD_43_ID and MIGRATE_FLAG
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('BU_USER_MAPPING','R',1);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('PRODUCT_LOCALE','N',0);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('EVENT_ROLE_MAPPING','F',0);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('UPLOAD_ROLES','F',0);
Insert into TAV_GIM_COMPOSITE_KEY_TABLES (TABLE_NAME,CONSTRAINT_TYPE,PK_COUNT) values ('UPLOAD_MGT_UPLOAD_ERRORS','F',0);

COMMIT;

/