-- PURPOSE    : PATCH TO ADD CONFIG PARAM FOR REJECTED PARTS COLLECTION WINDOW PERIOD FOR DEALER
-- AUTHOR     : Deepak Patel.
-- CREATED ON : 9-May-2013

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
    'Window period for allowing dealer to collect part back for denied claims',
    'Window period for allowing dealer to collect part back for denied claims :',
    'CLAIMS',
    1,
    'waitingForDealerToCollectParts',
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
        45,
        (SELECT id FROM config_param cp WHERE cp.description='Window period for allowing dealer to collect part back for denied claims'),
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
commit
/