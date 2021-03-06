--Purpose    : WR Validation procedure
--Author     : Rahul Katariya
--Created On : 08/07/2010
--Impact     : WR Upload

CREATE OR REPLACE
PROCEDURE UPLOAD_WARRANTY_REG_VALIDATION
AS
  CURSOR ALL_REC
  IS
    SELECT * FROM STG_WARRANTY_REGISTRATIONS WHERE ERROR_STATUS IS NULL;
  V_ERROR_CODE             VARCHAR2(4000):=NULL;
  V_ALLOW_OTHER_DLRS_STOCK VARCHAR2(10);
  V_ADD_INFO_APPLICABLE    VARCHAR2(10);
  V_COMP_PART_ARRAY DBMS_UTILITY.UNCL_ARRAY;
  V_COMP_INSTALL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
  V_COMP_SERIAL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
  V_POL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
  V_COMP_PART_COUNT    NUMBER;
  V_COMP_INSTALL_COUNT NUMBER;
  V_COMP_SERIAL_COUNT  NUMBER;
  V_POL_COUNT          NUMBER;
  V_COMMIT_COUNT       NUMBER;
  V_VAR                NUMBER;
  V_LOGGED_IN_DEALER   NUMBER;
  V_SHIP_DATE DATE;
  V_FILE_UPLOAD_MGT_ID NUMBER := 0;
  V_SUCCESS_COUNT      NUMBER := 0;
  V_ERROR_COUNT        NUMBER := 0;
  V_COUNT              NUMBER := 0;
BEGIN
  -- VALIDATE THE BUSINESS UNIT INFO FOR NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR047', ';WR047'),
    ERROR_STATUS            = 'N'
  WHERE BUSINESS_UNIT_INFO IS NULL;
  -- VALIDATE THE BUSINESS UNIT INFO IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR048', ';WR048'),
    ERROR_STATUS = 'N'
  WHERE NOT EXISTS
    ( SELECT 1 FROM BUSINESS_UNIT WHERE NAME = TAV.BUSINESS_UNIT_INFO
    );
  --ERROR CODES: DEALER_NUMBER_NULL
  --VALIDATE THAT DEALER NUMBER IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE       = 'WR001',
    ERROR_STATUS       = 'N'
  WHERE DEALER_NUMBER IS NULL;
  --ERROR CODE: DEALER_NUMBER_INVALID
  --VALIDATE THAT DEALER NUMBER IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR002', ';WR002'),
    ERROR_STATUS = 'N'
  WHERE NOT EXISTS
    (SELECT 1
    FROM SERVICE_PROVIDER SP,
      BU_ORG_MAPPING BOM
    WHERE SP.ID                    = BOM.ORG
    AND BOM.BU                     = TAV.BUSINESS_UNIT_INFO
    AND SP.SERVICE_PROVIDER_NUMBER = TAV.DEALER_NUMBER
    );
  --ERROR CODES: CUSTOMER_TYPE_NULL
  --VALIDATE THAT CUSTOMER TYPE IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR003', ';WR003'),
    ERROR_STATUS       = 'N'
  WHERE CUSTOMER_TYPE IS NULL;
  --ERROR CODES: CUSTOMER_TYPE_INVALID
  --VALIDATE THAT CUSTOMER TYPE IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR004', ';WR004'),
    ERROR_STATUS           = 'N'
  WHERE CUSTOMER_TYPE NOT IN
    (SELECT CFO.VALUE
    FROM CONFIG_PARAM_OPTION CFO,
      CONFIG_VALUE CV,
      CONFIG_PARAM CP
    WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
    AND CV.CONFIG_PARAM       = CP.ID
    AND CP.NAME               = 'customersFilingDR'
    AND CV.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
    );
  COMMIT;
  --ERROR CODE: CUSTOMER_NUMBER_NULL
  --VALIDATE THAT CUSTOMER NUMBER IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR005', ';WR005'),
    ERROR_STATUS         = 'N'
  WHERE CUSTOMER_NUMBER IS NULL;
  --ERROR CODE: CUSTOMER_NUMBER_INVALID
  --VALIDATE THAT CUSTOMER_NUMBER IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR006', ';WR006'),
    ERROR_STATUS = 'N'
  WHERE NOT EXISTS
    (SELECT C.CUSTOMER_ID
    FROM CUSTOMER C
    WHERE C.CUSTOMER_ID = TAV.CUSTOMER_NUMBER
    );
  --ERROR CODE: END_CUST_ADD_BOOK_DOES_NOT_EXIST
  --VALIDATE THAT END CUSTOMER ADDRESS BOOK EXISTS FOR DEALER
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR007', ';WR007'),
    ERROR_STATUS = 'N'
  WHERE NOT EXISTS
    ( SELECT DISTINCT SP.SERVICE_PROVIDER_NUMBER
    FROM ADDRESS_BOOK AB,
      SERVICE_PROVIDER SP
    WHERE SP.SERVICE_PROVIDER_NUMBER = TAV.DEALER_NUMBER
    AND SP.ID                        = AB.BELONGS_TO
    AND AB.TYPE                      = 'ENDCUSTOMER'
    );
  --ERROR CODE: END_CUST_NOT_MAPPED_TO_DLR
  --VALIDATE THAT END CUSTOMER EXISTS IN THE DEALER'S ENDCUSTOMER ADDRESS BOOK
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR008', ';WR008'),
    ERROR_STATUS                            = 'N'
  WHERE INSTR(NVL(ERROR_CODE,'X'), 'WR007') = 0
  AND NOT EXISTS
    ( SELECT DISTINCT C.CUSTOMER_ID,
      SP.SERVICE_PROVIDER_NUMBER
    FROM CUSTOMER C,
      CUSTOMER_ADDRESSES CA,
      SERVICE_PROVIDER SP,
      ADDRESS_BOOK AB,
      ADDRESS_BOOK_ADDRESS_MAPPING ABAM
    WHERE ABAM.ADDRESS_BOOK_ID     = AB.ID
    AND AB.TYPE                    = UPPER(TAV.CUSTOMER_TYPE)
    AND AB.BELONGS_TO              = SP.ID
    AND CA.CUSTOMER                = C.ID
    AND ABAM.ADDRESS_ID           IN (CA.ADDRESSES)
    AND C.CUSTOMER_ID              = TAV.CUSTOMER_NUMBER
    AND SP.SERVICE_PROVIDER_NUMBER = TAV.DEALER_NUMBER
    );
  COMMIT;
  --ERROR CODES: ITEM_NUMBER_NULL
  --VALIDATE THAT ITEM NUMBER IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR010', ';WR010'),
    ERROR_STATUS     = 'N'
  WHERE ITEM_NUMBER IS NULL;
  --ERROR CODE: ITEM_NUMBER_INVALID
  --VALIDATE THAT ITEM NUMBER IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR011', ';WR011'),
    ERROR_STATUS = 'N'
  WHERE NOT EXISTS
    (SELECT I.ID
    FROM ITEM I
    WHERE I.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
    AND I.ITEM_TYPE            = 'MACHINE'
    AND I.OWNED_BY             = 1
    AND I.ITEM_NUMBER          = TAV.ITEM_NUMBER
    );
  COMMIT;
  --ERROR CODES: SERIAL_NUMBER_NULL
  --VALIDATE THAT SERIAL NUMBER IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR012', ';WR012'),
    ERROR_STATUS       = 'N'
  WHERE SERIAL_NUMBER IS NULL;
  BEGIN
    SELECT UPPER(CFO.VALUE)
    INTO V_ALLOW_OTHER_DLRS_STOCK
    FROM CONFIG_PARAM_OPTION CFO,
      CONFIG_VALUE CV,
      CONFIG_PARAM CP
    WHERE CFO.ID        = CV.CONFIG_PARAM_OPTION
    AND CV.CONFIG_PARAM = CP.ID
    AND CP.NAME         = 'allowWntyRegOnOthersStock';
    --AND CP.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO;  -- TODO : CHECK IT WITH RASHMI
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    V_ALLOW_OTHER_DLRS_STOCK := 'FALSE';
  END;
  --ERROR CODE: SERIAL_NUMBER_INVALID
  --VALIDATE THAT THE SERIAL NUMBER IS VALID
  IF V_ALLOW_OTHER_DLRS_STOCK = 'TRUE' THEN
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR013', ';WR013'),
      ERROR_STATUS = 'N'
    WHERE NOT EXISTS
      (SELECT 1
      FROM INVENTORY_ITEM II,
        ITEM I
      WHERE II.OF_TYPE          = I.ID
      AND II.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      AND I.BUSINESS_UNIT_INFO  = TAV.BUSINESS_UNIT_INFO
      AND II.SERIAL_NUMBER      = TAV.SERIAL_NUMBER
      AND I.ITEM_NUMBER         = TAV.ITEM_NUMBER
      AND II.TYPE               = 'STOCK'
      );
  ELSE
    SELECT OU.BELONGS_TO_ORGANIZATION
    INTO V_LOGGED_IN_DEALER
    FROM FILE_UPLOAD_MGT FUM,
      ORG_USER OU,
      STG_WARRANTY_REGISTRATIONS TAV
    WHERE TAV.FILE_UPLOAD_MGT_ID = FUM.ID
    AND FUM.UPLOADED_BY          = OU.ID;
    --IF THE USER IS NOT AN ADMIN, THEN CHECK IF THE LOGGED IN USER OWNS THE INVENTORY
    IF V_LOGGED_IN_DEALER > 1 THEN
      UPDATE STG_WARRANTY_REGISTRATIONS TAV
      SET ERROR_CODE = ERROR_CODE
        || DECODE(ERROR_CODE, NULL, 'WR013', ';WR013'),
        ERROR_STATUS = 'N'
      WHERE NOT EXISTS
        (SELECT 1
        FROM INVENTORY_ITEM II,
          ITEM I,
          INVENTORY_TRANSACTION IT
        WHERE II.OF_TYPE            = I.ID
        AND II.BUSINESS_UNIT_INFO   = TAV.BUSINESS_UNIT_INFO
        AND I.BUSINESS_UNIT_INFO    = TAV.BUSINESS_UNIT_INFO
        AND II.SERIAL_NUMBER        = TAV.SERIAL_NUMBER
        AND I.ITEM_NUMBER           = TAV.ITEM_NUMBER
        AND II.TYPE                 = 'STOCK'
        AND II.ID                   = IT.TRANSACTED_ITEM
        AND IT.INV_TRANSACTION_TYPE = 1
        AND IT.BUYER                = V_LOGGED_IN_DEALER
        );
    END IF;
  END IF;
  COMMIT;
  --ERROR CODES: DELIVERY_DATE_NULL
  --VALIDATE THAT DELIVERY DATE IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR014', ';WR014'),
    ERROR_STATUS       = 'N'
  WHERE DELIVERY_DATE IS NULL;
  --ERROR CODES: HOURS_ON_MACHINE_NULL
  --VALIDATE THAT HOURS ON MACHINE IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR015', ';WR015'),
    ERROR_STATUS          = 'N'
  WHERE HOURS_ON_MACHINE IS NULL;
  --COMMIT;
  --ERROR CODES: OPERATOR_TYPE_INVALID
  --VALIDATE THAT OPERATOR TYPE IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR016', ';WR016'),
    ERROR_STATUS             = 'N'
  WHERE TAV.OPERATOR_TYPE   IS NOT NULL
  AND TAV.OPERATOR_TYPE NOT IN
    (SELECT CFO.VALUE
    FROM CONFIG_PARAM_OPTION CFO,
      CONFIG_VALUE CV,
      CONFIG_PARAM CP
    WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
    AND CV.CONFIG_PARAM       = CP.ID
    AND CP.NAME               = 'customersFilingDR'
    AND CV.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
    );
  --ERROR CODE: OPERATOR_NOT_MAPPED_TO_DLR
  --VALIDATE THAT OPERATOR EXISTS IN THE DEALER'S ENDCUSTOMER ADDRESS BOOK
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR049', ';WR049'),
    ERROR_STATUS                            = 'N'
  WHERE INSTR(NVL(ERROR_CODE,'X'), 'WR016') = 0
  AND TAV.OPERATOR_NUMBER                  IS NOT NULL
  AND NOT EXISTS
    ( SELECT DISTINCT C.CUSTOMER_ID,
      SP.SERVICE_PROVIDER_NUMBER
    FROM CUSTOMER C,
      CUSTOMER_ADDRESSES CA,
      SERVICE_PROVIDER SP,
      ADDRESS_BOOK AB,
      ADDRESS_BOOK_ADDRESS_MAPPING ABAM
    WHERE ABAM.ADDRESS_BOOK_ID     = AB.ID
    AND AB.TYPE                    = UPPER(TAV.OPERATOR_TYPE)
    AND AB.BELONGS_TO              = SP.ID
    AND CA.CUSTOMER                = C.ID
    AND ABAM.ADDRESS_ID           IN (CA.ADDRESSES)
    AND C.CUSTOMER_ID              = TAV.OPERATOR_NUMBER
    AND SP.SERVICE_PROVIDER_NUMBER = TAV.DEALER_NUMBER
    );
  --ERROR CODES: INSTALL_DLR_NULL
  --VALIDATE THAT INSTALLING_DEALER IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR017', ';WR017'),
    ERROR_STATUS                      = 'N'
  WHERE TAV.INSTALLING_DEALER_NUMBER IS NULL;
  --ERROR CODE: INSTALL_DLR_INVALID
  --VALIDATE THAT INSTALLER NUMBER IS VALID
  UPDATE STG_WARRANTY_REGISTRATIONS TAV
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR018', ';WR018'),
    ERROR_STATUS = 'N'
  WHERE NOT EXISTS
    (SELECT 1
    FROM SERVICE_PROVIDER SP,
      BU_ORG_MAPPING BOM
    WHERE SP.ID                    = BOM.ORG
    AND BOM.BU                     = TAV.BUSINESS_UNIT_INFO
    AND SP.SERVICE_PROVIDER_NUMBER = TAV.INSTALLING_DEALER_NUMBER
    );
  --ERROR CODES: INSTALL_DATE_NULL
  --VALIDATE THAT INSTALL DATE IS NOT NULL
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR019', ';WR019'),
    ERROR_STATUS              = 'N'
  WHERE DATE_OF_INSTALLATION IS NULL;
  --ERROR CODES: COMP_PART_NUMBERS_NULL
  --VALIDATE THAT COMPONENT PART NUMBERS ARE PROVIDED IF COMPONENT SERIAL NUMBERS ARE PROVIDED
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR020', ';WR020'),
    ERROR_STATUS                 = 'N'
  WHERE COMPONENT_SERIAL_NUMBER IS NOT NULL
  AND COMPONENT_PART_NUMBER     IS NULL;
  --ERROR CODES: COMP_INSTALL_DATES_NULL
  --VALIDATE THAT COMPONENT INSTALL DATES ARE PROVIDED IF COMPONENT PART NUMBERS ARE PROVIDED
  UPDATE STG_WARRANTY_REGISTRATIONS
  SET ERROR_CODE = ERROR_CODE
    || DECODE(ERROR_CODE, NULL, 'WR021', ';WR021'),
    ERROR_STATUS                   = 'N'
  WHERE COMPONENT_PART_NUMBER     IS NOT NULL
  AND COMPONENT_INSTALLATION_DATE IS NULL;
  COMMIT;
  BEGIN
    SELECT UPPER(CFO.VALUE)
    INTO V_ADD_INFO_APPLICABLE
    FROM CONFIG_PARAM_OPTION CFO,
      CONFIG_VALUE CV,
      CONFIG_PARAM CP
    WHERE CFO.ID        = CV.CONFIG_PARAM_OPTION
    AND CV.CONFIG_PARAM = CP.ID
    AND CP.NAME         = 'additionalInformationDetailsApplicable';
    --AND CV.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO;  -- TODO : CHECK IT WITH RASHMI
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    V_ADD_INFO_APPLICABLE := 'FALSE';
  END;
  IF V_ADD_INFO_APPLICABLE = 'TRUE' THEN
    --ERROR CODES: TRANSACTION_TYPE_NULL
    --VALIDATE THAT TRANSACTION TYPE IS NOT NULL
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR022', ';WR022'),
      ERROR_STATUS          = 'N'
    WHERE TRANSACTION_TYPE IS NULL;
    --ERROR CODES: TRANSACTION_TYPE_INVALID
    --VALIDATE THAT TRANSACTION_TYPE IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR023', ';WR023'),
      ERROR_STATUS            = 'N'
    WHERE TRANSACTION_TYPE   IS NOT NULL
    AND TRANSACTION_TYPE NOT IN
      (SELECT TYPE FROM TRANSACTION_TYPE
      );
    --ERROR CODES: MARKET_TYPE_NULL
    --VALIDATE THAT MARKET TYPE IS NOT NULL
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR024', ';WR024'),
      ERROR_STATUS     = 'N'
    WHERE MARKET_TYPE IS NULL;
    --ERROR CODES: MARKET_TYPE_INVALID
    --VALIDATE THAT MARKET_TYPE IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR025', ';WR025'),
      ERROR_STATUS       = 'N'
    WHERE MARKET_TYPE   IS NOT NULL
    AND MARKET_TYPE NOT IN
      (SELECT TITLE FROM MARKET_TYPE
      ); --TODO : CHECK WHETHER CODE OT TITLE FROM MARKET TYPE TABLE
    --ERROR CODES: FIRST_TIME_OWNER_NULL
    --VALIDATE THAT FIRST TIME OWNER IS NOT NULL
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR026', ';WR026'),
      ERROR_STATUS          = 'N'
    WHERE FIRST_TIME_OWNER IS NULL;
    --ERROR CODES: FIRST_TIME_OWNER_INVALID
    --VALIDATE THAT FIRST_TIME_OWNER IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR027', ';WR027'),
      ERROR_STATUS            = 'N'
    WHERE FIRST_TIME_OWNER   IS NOT NULL
    AND FIRST_TIME_OWNER NOT IN ('YES', 'NO');
    --ERROR CODES: IF_PREVIOUS_OWNER_NULL
    --VALIDATE THAT IF_PREVIOUS_OWNER IS NOT NULL IF FIRST TIME OWNER IS YES
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR028', ';WR028'),
      ERROR_STATUS         = 'N'
    WHERE FIRST_TIME_OWNER = 'YES'
    AND IF_PREVIOUS_OWNER IS NULL;
    --ERROR CODES: IF_PREVIOUS_OWNER_INVALID
    --VALIDATE THAT IF_PREVIOUS_OWNER IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR029', ';WR029'),
      ERROR_STATUS             = 'N'
    WHERE IF_PREVIOUS_OWNER   IS NOT NULL
    AND IF_PREVIOUS_OWNER NOT IN ('Switching to Thermo King TSA', 'Continuing with Thermo King TSA', 'Unknown/Not Provided');
    --ERROR CODES: COMPETITION_TYPE_INVALID
    --VALIDATE THAT COMPETITION_TYPE IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR030', ';WR030'),
      ERROR_STATUS            = 'N'
    WHERE COMPETITION_TYPE   IS NOT NULL
    AND COMPETITION_TYPE NOT IN
      (SELECT TYPE FROM COMPETITION_TYPE
      );
    --ERROR CODES: COMPETITOR_MAKE_INVALID
    --VALIDATE THAT COMPETITOR_MAKE IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR031', ';WR031'),
      ERROR_STATUS           = 'N'
    WHERE COMPETITOR_MAKE   IS NOT NULL
    AND COMPETITOR_MAKE NOT IN
      (SELECT MAKE FROM COMPETITOR_MAKE
      );
    --ERROR CODES: MODEL_NUMBER_INVALID
    --VALIDATE THAT MODEL_NUMBER IS VALID
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR032', ';WR032'),
      ERROR_STATUS        = 'N'
    WHERE MODEL_NUMBER   IS NOT NULL
    AND MODEL_NUMBER NOT IN
      (SELECT IG.NAME
      FROM ITEM_GROUP IG,
        ITEM_SCHEME ISCH
      WHERE IG.ITEM_GROUP_TYPE    = 'MODEL'
      AND IG.SCHEME               = ISCH.ID
      AND IG.BUSINESS_UNIT_INFO   = TAV.BUSINESS_UNIT_INFO
      AND ISCH.NAME               = 'Prod Struct Scheme'
      AND ISCH.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      );
  END IF;
  COMMIT;
  DECLARE
  TYPE POL_TYPE
IS
  TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);
  V_POL_CODES POL_TYPE;
BEGIN
  FOR EACH_POL IN
  (SELECT CODE
  FROM POLICY_DEFINITION
  WHERE BUSINESS_UNIT_INFO = 'Thermo King TSA'
  )
  LOOP
    V_POL_CODES(EACH_POL.CODE) := EACH_POL.CODE;
  END LOOP;
  --MAIN LOOP TO ITERATE OVER ALL THE RECORDS AND VALIDATE INDIVIDUAL ELEMENTS
  FOR EACH_REC IN ALL_REC
  LOOP
    BEGIN
      --RESET THE VARIABLE
      V_ERROR_CODE   := NULL;
      V_COMMIT_COUNT := V_COMMIT_COUNT + 1;
      V_VAR          := 0;
      --ERROR CODE: HRS_ON_MACH_INVALID
      --VALIDATE THAT HOURS ON MACHINE IS VALID
      IF EACH_REC.HOURS_ON_MACHINE IS NOT NULL AND NOT(COMMON_UTILS.ISNUMBER(EACH_REC.HOURS_ON_MACHINE)) THEN
        V_ERROR_CODE               := common_utils.addErrorMessage(V_ERROR_CODE, 'WR033');
      END IF;
      --ERROR_CODE: DELIVERY_DATE_INVALID, DELIVERY_DATE_BEFORE_SHIP_DATE, DELIVERY_DATE_IN_FUTURE
      --VALIDATE THAT DELIVERY DATE IS IN VALID FORMAT AND IS ON OR AFTER SHIPMENT DATE
      IF EACH_REC.DELIVERY_DATE                         IS NOT NULL AND NOT (COMMON_UTILS.ISVALIDDATE(EACH_REC.DELIVERY_DATE)) THEN
        V_ERROR_CODE                                    := common_utils.addErrorMessage(V_ERROR_CODE, 'WR034');
      ELSIF TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD') >= SYSDATE THEN
        V_ERROR_CODE                                    := common_utils.addErrorMessage(V_ERROR_CODE, 'WR035');
      ELSE
        SELECT SHIPMENT_DATE
        INTO V_SHIP_DATE
        FROM INVENTORY_ITEM II,
          ITEM I,
          INVENTORY_TRANSACTION IT,
          STG_WARRANTY_REGISTRATIONS TAV,
          SERVICE_PROVIDER SP
        WHERE II.OF_TYPE                               = I.ID
        AND II.BUSINESS_UNIT_INFO                      = TAV.BUSINESS_UNIT_INFO
        AND I.BUSINESS_UNIT_INFO                       = TAV.BUSINESS_UNIT_INFO
        AND II.SERIAL_NUMBER                           = TAV.SERIAL_NUMBER
        AND I.ITEM_NUMBER                              = TAV.ITEM_NUMBER
        AND II.TYPE                                    = 'STOCK'
        AND II.ID                                      = IT.TRANSACTED_ITEM
        AND IT.INV_TRANSACTION_TYPE                    = 1
        AND IT.BUYER                                   = SP.ID
        AND SP.SERVICE_PROVIDER_NUMBER                 = TAV.DEALER_NUMBER;
        IF TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD') < V_SHIP_DATE THEN
          V_ERROR_CODE                                := common_utils.addErrorMessage(V_ERROR_CODE, 'WR036');
        END IF;
      END IF;
      --ERROR_CODE: INSTALL_DATE_INVALID, INSTALL_DATE_BEFORE_DEL_DATE, INSTALL_DATE_IN_FUTURE
      --VALIDATE THAT INSTALL DATE IS IN VALID FORMAT AND IS ON OR AFTER DELIVERY DATE
      IF EACH_REC.DATE_OF_INSTALLATION                         IS NOT NULL AND NOT (COMMON_UTILS.ISVALIDDATE(EACH_REC.DATE_OF_INSTALLATION)) THEN
        V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR037');
      ELSIF TO_DATE(EACH_REC.DATE_OF_INSTALLATION, 'YYYYMMDD')  < TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD') THEN
        V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR038');
      ELSIF TO_DATE(EACH_REC.DATE_OF_INSTALLATION, 'YYYYMMDD') >= SYSDATE THEN
        V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR039');
      END IF;
      --ERROR_CODE: COMP_PART_NO_AND_SERIAL_NO_MISMATCH
      --VALIDATE THAT COMPONENT PART AND SERIAL NUMBERS HAVE THE SAME COUNT
      IF EACH_REC.COMPONENT_SERIAL_NUMBER IS NOT NULL THEN
        COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_SERIAL_NUMBER,'#$#',V_COMP_SERIAL_ARRAY ,V_COMP_SERIAL_COUNT);
        IF V_COMP_PART_COUNT <> V_COMP_SERIAL_COUNT THEN
          V_ERROR_CODE       := common_utils.addErrorMessage(V_ERROR_CODE, 'WR040');
        END IF;
      END IF;
      --ERROR_CODE: COMP_PART_NO_AND_INSTALL_DATES_MISMATCH
      --VALIDATE THAT COMPONENT PART NUMBERS AND INSTALL DATES HAVE THE SAME COUNT
      IF EACH_REC.COMPONENT_PART_NUMBER IS NOT NULL THEN
        COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_PART_NUMBER,'#$#',V_COMP_PART_ARRAY ,V_COMP_PART_COUNT);
        COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_INSTALLATION_DATE,'#$#',V_COMP_INSTALL_ARRAY ,V_COMP_INSTALL_COUNT);
        IF V_COMP_PART_COUNT <> V_COMP_INSTALL_COUNT THEN
          V_ERROR_CODE       := common_utils.addErrorMessage(V_ERROR_CODE, 'WR041');
        END IF;
        FOR I IN 1..V_COMP_PART_COUNT
        LOOP
          BEGIN
            SELECT 1
            INTO V_VAR
            FROM ITEM
            WHERE ITEM_TYPE        = 'PART'
            AND ITEM_NUMBER        = V_COMP_PART_ARRAY(I)
            AND OWNED_BY           = 1
            AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR042');
            EXIT
          WHEN INSTR(V_ERROR_CODE, 'WR042') > 0;
          END;
        END LOOP;
      END IF;
      --ERROR_CODE: COMP_INSTALL_DATE_INVALID
      --VALIDATE THAT INSTALL DATES FOR MAJOR COMPONENTS IS A VALID DATE
      IF EACH_REC.COMPONENT_INSTALLATION_DATE IS NOT NULL THEN
        FOR I                                 IN 1..V_COMP_INSTALL_COUNT
        LOOP
          IF NOT COMMON_UTILS.ISVALIDDATE(V_COMP_INSTALL_ARRAY(I)) THEN
            V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR043');
            EXIT
          WHEN INSTR(V_ERROR_CODE, 'WR043') > 0;
          END IF;
        END LOOP;
      END IF;
      --ERROR_CODE: NUMBER_OF_MONTHS_INVALID
      --VALIDATE THAT NUMBER_OF_MONTHS IS A VALID NUMBER
      IF EACH_REC.NUMBER_OF_MONTHS IS NOT NULL AND NOT (COMMON_UTILS.ISNUMBER(EACH_REC.NUMBER_OF_MONTHS)) THEN
        V_ERROR_CODE               := common_utils.addErrorMessage(V_ERROR_CODE, 'WR044');
      END IF;
      --ERROR_CODE: NUMBER_OF_YEARS_INVALID
      --VALIDATE THAT NUMBER_OF_YEARS IS A VALID NUMBER
      IF EACH_REC.NUMBER_OF_YEARS IS NOT NULL AND NOT (COMMON_UTILS.ISNUMBER(EACH_REC.NUMBER_OF_YEARS)) THEN
        V_ERROR_CODE              := common_utils.addErrorMessage(V_ERROR_CODE, 'WR045');
      END IF;
      --ERROR_CODE: POLICY_INVALID_<POLICY CODE>
      --IF ADDITIONAL POLICIES ARE GIVEN, VALIDATE THAT THEY ARE VALID
      IF EACH_REC.ADDITIONAL_APPLICABLE_POLICIES IS NOT NULL THEN
        BEGIN
          --GET AN ARRAY OUT OF ALL THE COMMA SEPARATED ITEMS
          COMMON_UTILS.ParseAnySeperatorList(EACH_REC.ADDITIONAL_APPLICABLE_POLICIES,'#$#',V_POL_ARRAY ,V_POL_COUNT);
          FOR I IN 1..V_POL_COUNT
          LOOP
            IF NOT V_POL_CODES.EXISTS(V_POL_ARRAY(I)) THEN
              V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR046');
              EXIT
            WHEN INSTR(V_ERROR_CODE, 'WR046') > 0;
            END IF;
          END LOOP;
        END;
      END IF;
      IF V_ERROR_CODE IS NULL AND EACH_REC.ERROR_CODE IS NULL THEN
        --RECORD IS CLEAN AND IS SUCCESSFULLY VALIDATED
        UPDATE STG_WARRANTY_REGISTRATIONS
        SET ERROR_STATUS = 'Y',
          ERROR_CODE     = NULL
        WHERE ID         = EACH_REC.ID;
      ELSE
        --RECORD HAS ERRORS
        UPDATE STG_WARRANTY_REGISTRATIONS
        SET ERROR_STATUS = 'N',
          ERROR_CODE     = ERROR_CODE
          || DECODE (ERROR_CODE,NULL, V_ERROR_CODE,','
          || V_ERROR_CODE)
        WHERE ID = EACH_REC.ID;
      END IF;
      --DO A COMMIT FOR EACH RECORD
      IF V_COMMIT_COUNT > 100 THEN
        COMMIT;
        V_COMMIT_COUNT := 0;
      END IF;
    END;
  END LOOP;
  COMMIT;
END;
BEGIN
  SELECT file_upload_mgt_id
  INTO v_file_upload_mgt_id
  FROM STG_WARRANTY_REGISTRATIONS
  WHERE ROWNUM = 1;
  BEGIN
    SELECT COUNT(*)
    INTO v_success_count
    FROM STG_WARRANTY_REGISTRATIONS
    WHERE file_upload_mgt_id = v_file_upload_mgt_id
    AND ERROR_STATUS         = 'Y';
  EXCEPTION
  WHEN OTHERS THEN
    v_success_count := 0;
  END;
  BEGIN
    SELECT COUNT(*)
    INTO v_error_count
    FROM STG_WARRANTY_REGISTRATIONS
    WHERE file_upload_mgt_id = v_file_upload_mgt_id
    AND ERROR_STATUS         = 'N';
  EXCEPTION
  WHEN OTHERS THEN
    v_error_count := 0;
  END;
  SELECT COUNT(*)
  INTO v_count
  FROM STG_WARRANTY_REGISTRATIONS
  WHERE file_upload_mgt_id = v_file_upload_mgt_id;
  UPDATE file_upload_mgt
  SET success_records= v_success_count,
    error_records    = v_error_count,
    total_records    = v_count
  WHERE id           = v_file_upload_mgt_id;
EXCEPTION
WHEN OTHERS THEN
  v_error_code := SUBSTR(SQLERRM, 1, 4000);
  UPDATE file_upload_mgt
  SET error_message = v_error_code
  WHERE id          = v_file_upload_mgt_id;
END;
COMMIT;
--COMMON_UTILS.ENDTIME (V_TIME_ID, 'STG_WARRANTY_REGISTRATIONS');
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;
/
commit
/