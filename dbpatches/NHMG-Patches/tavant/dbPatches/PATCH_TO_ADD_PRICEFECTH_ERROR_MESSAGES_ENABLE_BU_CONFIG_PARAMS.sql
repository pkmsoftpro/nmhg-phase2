INSERT
INTO config_param
  (
    id,
    description,
    display_name,
    logical_group,
    logical_group_order,
    name,
    param_display_type,
    param_order,
    sections,
    sections_order,
    type,
    d_active,
    d_created_on,
    d_created_time,
    d_internal_comments,
    d_last_updated_by,
    d_updated_on,
    d_updated_time
  )
  VALUES
  (
    config_param_seq.nextval,
    'Is dealer is allowed take action on claim during EPO is down?',
    'Is dealer is allowed take action on claim during EPO is down?',
    'CLAIMS',
    1,
    'dealerAllowedTakeActionOnClaimsDuringEPOIsDown',
    'radio',
    1,
    'CLAIM_INPUT_PARAMETERS',
    1,
    'boolean',
    1,
    sysdate,
    systimestamp,
    'Nacco Configuration',
    1,
    sysdate,
    systimestamp
  )
/
INSERT
INTO config_param_options_mapping
  (
    id,
    param_id,
    option_id
  )
  VALUES
  (
    cfg_param_optns_mapping_seq.nextval,
    (SELECT id
    FROM config_param cp
    WHERE cp.description='Is dealer is allowed take action on claim during EPO is down?'
    ),
    (SELECT id from config_param_option cpo where cpo.value='true')
  )
/
INSERT
INTO config_param_options_mapping
  (
    id,
    param_id,
    option_id
  )
  VALUES
  (
    cfg_param_optns_mapping_seq.nextval,
    (SELECT id
    FROM config_param cp
    WHERE cp.description='Is dealer is allowed take action on claim during EPO is down?'
    ),
    (SELECT id from config_param_option cpo where cpo.value='false')
  )
/
Insert into 
config_value 
(ID,
ACTIVE,
VALUE,
CONFIG_PARAM,
D_CREATED_ON,
D_INTERNAL_COMMENTS,
D_UPDATED_ON,
D_LAST_UPDATED_BY,
D_CREATED_TIME,
D_UPDATED_TIME,
D_ACTIVE,
BUSINESS_UNIT_INFO,
CONFIG_PARAM_OPTION) 
values (CONFIG_VALUE_SEQ.nextval,
1,
null,
(SELECT id FROM config_param WHERE NAME='dealerAllowedTakeActionOnClaimsDuringEPOIsDown'),
sysdate,
null,
sysdate,
null,
sysdate,
sysdate,
1,
'EMEA',
(SELECT id FROM config_param_option WHERE DISPLAY_VALUE ='No'))
/
commit
/