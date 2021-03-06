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
    'Generate WPRA on the date (monthly)',
    'Generate WPRA on the date (monthly)',
    'CLAIMS',
    1,
    'generateWpraDate',
    'textbox',
    1,
    'CLAIM_RETURN_PART',
    1,
    'number',
    1,
    sysdate,
    systimestamp,
    'Nacco Configuration',
    1,
    sysdate,
    systimestamp
  )
/
INSERT INTO CONFIG_VALUE
      (
        ID,
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
        CONFIG_PARAM_OPTION
      )
      VALUES
      (
        CONFIG_VALUE_SEQ.nextval,
        1,
        25,
        (SELECT id FROM config_param cp WHERE cp.description='Generate WPRA on the date (monthly)'),
        sysdate,
        'Nacco Configuration',
        sysdate,
        1,
        systimestamp,
        systimestamp,
        1,
        'EMEA',
        NULL
      )
/