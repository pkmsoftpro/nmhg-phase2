-- Author: Jitesh Jain
-- Date : 1st October,2008
-- Reason: Selected items type will be allowed in claim entry as causal part.
ALTER TABLE CONFIG_VALUE MODIFY (VALUE NULL)
/
INSERT INTO CONFIG_PARAM
   (ID, DESCRIPTION, DISPLAY_NAME, NAME, TYPE, D_CREATED_ON, D_INTERNAL_COMMENTS, D_UPDATED_ON, D_LAST_UPDATED_BY, D_CREATED_TIME, D_UPDATED_TIME, LOGICAL_GROUP, PARAM_DISPLAY_TYPE, LOGICAL_GROUP_ORDER, SECTIONS, SECTIONS_ORDER, PARAM_ORDER)
 VALUES
   (config_param_seq.NEXTVAL, 'Selected items type will be allowed in claim entry as causal part.', 'Causal Items On Claim Configuration', 'causalItemsOnClaimConfiguration', 'java.lang.String', 
    TO_DATE('09/24/2008 15:38:14', 'MM/DD/YYYY HH24:MI:SS'), 'Configuration', TO_DATE('09/24/2008 15:38:14', 'MM/DD/YYYY HH24:MI:SS'), NULL, NULL, 
    NULL, NULL, 'multiselect', NULL, NULL, 
    NULL, NULL)
/
INSERT INTO CONFIG_PARAM_OPTION VALUES (config_param_option_seq.NEXTVAL, 'Kit', 'Kit')
/
INSERT INTO CONFIG_PARAM_OPTION VALUES (config_param_option_seq.NEXTVAL, 'Attachment', 'Attachment')
/
INSERT INTO CONFIG_PARAM_OPTION VALUES (config_param_option_seq.NEXTVAL, 'Option', 'Option')	
/
INSERT INTO CONFIG_PARAM_OPTION VALUES (config_param_option_seq.NEXTVAL, 'Parts', 'Parts')	
/
INSERT INTO CONFIG_PARAM_OPTIONS_MAPPING SELECT  CFG_PARAM_OPTNS_MAPPING_SEQ.NEXTVAL, cp.ID, cpo.ID  FROM CONFIG_PARAM cp, CONFIG_PARAM_OPTION cpo WHERE cp.NAME = 'causalItemsOnClaimConfiguration' AND cpo.VALUE = 'Parts'
/
INSERT INTO CONFIG_PARAM_OPTIONS_MAPPING SELECT  CFG_PARAM_OPTNS_MAPPING_SEQ.NEXTVAL, cp.ID, cpo.ID  FROM CONFIG_PARAM cp, CONFIG_PARAM_OPTION cpo WHERE cp.NAME = 'causalItemsOnClaimConfiguration' AND cpo.VALUE = 'Option'
/
INSERT INTO CONFIG_PARAM_OPTIONS_MAPPING SELECT  CFG_PARAM_OPTNS_MAPPING_SEQ.NEXTVAL, cp.ID, cpo.ID  FROM CONFIG_PARAM cp, CONFIG_PARAM_OPTION cpo WHERE cp.NAME = 'causalItemsOnClaimConfiguration' AND cpo.VALUE = 'Attachment'
/
INSERT INTO CONFIG_PARAM_OPTIONS_MAPPING SELECT  CFG_PARAM_OPTNS_MAPPING_SEQ.NEXTVAL, cp.ID, cpo.ID  FROM CONFIG_PARAM cp, CONFIG_PARAM_OPTION cpo WHERE cp.NAME = 'causalItemsOnClaimConfiguration' AND cpo.VALUE = 'Kit'
/
COMMIT
/