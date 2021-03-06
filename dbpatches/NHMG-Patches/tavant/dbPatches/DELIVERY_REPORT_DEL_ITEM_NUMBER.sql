update upload_mgt set columns_to_capture=24 where name_of_template='warrantyRegistrations'
/
create or replace
PROCEDURE UPLOAD_WARRANTY_REG_VALIDATION
AS
  CURSOR ALL_REC
  IS
    SELECT * FROM STG_WARRANTY_REGISTRATIONS WHERE ERROR_STATUS IS NULL;
  CURSOR ALL_ELIGIBLE_POLICY_PLANS(P_PRODUCT VARCHAR2, P_MODEL VARCHAR2, P_BU VARCHAR2, P_DEL_DATE DATE, P_HRS_ON_SERVICE NUMBER, P_CONDITION VARCHAR2, P_CERT_STATUS VARCHAR2, P_INSTALL_DEALER NUMBER)
  IS
    SELECT PD.*
    FROM POLICY_DEFINITION PD,
      POLICY_FOR_ITEMCONDITIONS PFI,
      (
      (SELECT PDG.POLICY_DEFN
      FROM POLICY_FOR_DEALER_GROUPS PDG,
        DEALERS_IN_GROUP DIG
      WHERE PDG.FOR_DEALER_GROUPS = DIG.DEALER_GROUP
      AND DIG.DEALER              = P_INSTALL_DEALER
      )
  UNION
    (SELECT PSP.POLICY_DEFN
    FROM POLICY_FOR_SERVICEPROVIDERS PSP
    WHERE PSP.FOR_SERVICE_PROVIDER = P_INSTALL_DEALER
    ) ) DLR_FILTER
    WHERE PD.ID IN
      (SELECT POLICY_DEFN
      FROM POLICY_FOR_PRODUCTS
      WHERE FOR_PRODUCT IN (P_PRODUCT, P_MODEL)
      )
    AND PD.ACTIVE_FROM                                           <= P_DEL_DATE
    AND PD.ACTIVE_TILL                                           >= P_DEL_DATE
    AND P_HRS_ON_SERVICE                                         <= PD.SERVICE_HRS_COVERED
    AND PD.BUSINESS_UNIT_INFO                                     = P_BU
    AND UPPER(PD.WARRANTY_TYPE)                                   = 'STANDARD'
    AND (DECODE(PD.CERTIFICATION_STATUS, 'NOTCERTIFIED', 'N', 'Y')= P_CERT_STATUS
    OR PD.CERTIFICATION_STATUS                                    = 'ANY')
    AND PD.ID                                                     = PFI.POLICY_DEFN
    AND PFI.FOR_ITEMCONDITION                                     = P_CONDITION
    AND PD.AVAILABILITY_OWNERSHIP_STATE                           = 1 --HARDCODED BECAUSE IT IS 1 FOR DATA MIGRATION
    AND PD.ID                                                     = DLR_FILTER.POLICY_DEFN(+)
    AND PD.D_ACTIVE                                               = 1
    AND NOT EXISTS
      (SELECT 1
      FROM POLICY_FEES
      WHERE POLICY        = PD.id
      AND is_transferable = 0
      AND amount          > 0
      );
    V_ERROR_CODE             VARCHAR2(4000):=NULL;
    V_ALLOW_OTHER_DLRS_STOCK VARCHAR2(10);
    V_UNIT_OWNER_TYPE        VARCHAR(50);
    V_CAP_INST_DLR_DATE      VARCHAR2(10);
    V_ADD_INFO_APPLICABLE    VARCHAR2(10);
    V_COMP_PART_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_COMP_INSTALL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_COMP_SERIAL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_POL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_COMP_PART_COUNT    NUMBER := 0;
    V_COMP_INSTALL_COUNT NUMBER := 0;
    V_COMP_SERIAL_COUNT  NUMBER := 0;
    V_POL_COUNT          NUMBER;
    V_COMMIT_COUNT       NUMBER;
    V_VAR                NUMBER;
    V_FILING_PARTY       NUMBER;
    V_SHIP_DATE DATE;
    V_HOURS_ON_SERV      NUMBER(19) := 0;
    V_FILE_UPLOAD_MGT_ID NUMBER     := 0;
    V_SUCCESS_COUNT      NUMBER     := 0;
    V_ERROR_COUNT        NUMBER     := 0;
    V_COUNT              NUMBER     := 0;
    V_SERIAL_ID          NUMBER(19) := 0;
    V_CURR_OWNER_ID      NUMBER(19) := 0;
    V_COMPONENT_ID       NUMBER(19) := 0;
    V_PENDING_WR         NUMBER     := 0;
    V_BUILD_DATE DATE               := NULL;
    V_PRODUCT           NUMBER(19)            := 0;
    V_MODEL             NUMBER(19)            := 0;
    V_INSTALL_DEALER_ID NUMBER(19)            := NULL;
    V_CERT_STATUS       VARCHAR2(1)           := NULL;
    V_CONDITION         VARCHAR2(255)         :=NULL;
    V_CONTRACT_CODE     VARCHAR2(255)         :=NULL;
    V_MAINTENANCE_CONTRACT  VARCHAR2(255)     :=NULL;
    V_INDUSTRY_CODE     VARCHAR2(255)         :=NULL;
	V_BU				VARCHAR2(255) 		  :=NULL;
  BEGIN
	SELECT FUM.BUSINESS_UNIT_INFO INTO V_BU
	FROM FILE_UPLOAD_MGT FUM WHERE ID=(SELECT DISTINCT FILE_UPLOAD_MGT_ID 
		FROM STG_WARRANTY_REGISTRATIONS WHERE ERROR_STATUS IS NULL);
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR047', ';WR047'),
      ERROR_STATUS            = 'N'
    WHERE BUSINESS_UNIT_INFO IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR048', ';WR048'),
      ERROR_STATUS                                = 'N'
    WHERE INSTR(NVL(TAV.ERROR_CODE,'X'), 'WR047') = 0
    AND NOT EXISTS
      ( SELECT 1 FROM BUSINESS_UNIT WHERE NAME = TAV.BUSINESS_UNIT_INFO
      )
    AND TAV.BUSINESS_UNIT_INFO IS NOT NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE       = 'WR001',
      ERROR_STATUS       = 'N'
    WHERE DEALER_NUMBER IS NULL;
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
      )
    AND TAV.DEALER_NUMBER IS NOT NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR003', ';WR003'),
      ERROR_STATUS       = 'N'
    WHERE CUSTOMER_TYPE IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR004', ';WR004'),
      ERROR_STATUS                      = 'N'
    WHERE upper(TAV.CUSTOMER_TYPE) NOT IN
      (SELECT upper(CFO.VALUE)
      FROM CONFIG_PARAM_OPTION CFO,
        CONFIG_VALUE CV,
        CONFIG_PARAM CP
      WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
      AND CV.CONFIG_PARAM       = CP.ID
      AND CP.NAME               = 'customersFilingDR'
      AND CV.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      )
    AND TAV.CUSTOMER_TYPE IS NOT NULL;
    COMMIT;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR005', ';WR005'),
      ERROR_STATUS         = 'N'
    WHERE CUSTOMER_NUMBER IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR006', ';WR006'),
      ERROR_STATUS = 'N'
    WHERE NOT EXISTS
      (SELECT C.CUSTOMER_ID
      FROM CUSTOMER C
      WHERE C.CUSTOMER_ID = TAV.CUSTOMER_NUMBER
      )
    AND TAV.CUSTOMER_NUMBER IS NOT NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR007', ';WR007'),
      ERROR_STATUS = 'N'
    WHERE NOT EXISTS
      (SELECT 1
      FROM ADDRESS_BOOK AB,
        SERVICE_PROVIDER SP
      WHERE SP.SERVICE_PROVIDER_NUMBER = TAV.DEALER_NUMBER
      AND SP.ID                        = AB.BELONGS_TO
      AND upper(AB.TYPE)               = upper(TAV.CUSTOMER_TYPE)
      )
    AND TAV.DEALER_NUMBER IS NOT NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR008', ';WR008'),
      ERROR_STATUS                            = 'N'
    WHERE INSTR(NVL(ERROR_CODE,'X'), 'WR007') = 0
    AND INSTR(NVL(ERROR_CODE,'X'), 'WR004')   = 0
    AND NOT EXISTS
      (SELECT 1
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
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR012', ';WR012'),
      ERROR_STATUS       = 'N'
    WHERE SERIAL_NUMBER IS NULL;
    SELECT DISTINCT OU.BELONGS_TO_ORGANIZATION
    INTO V_FILING_PARTY
    FROM FILE_UPLOAD_MGT FUM,
      ORG_USER OU,
      STG_WARRANTY_REGISTRATIONS TAV
    WHERE TAV.FILE_UPLOAD_MGT_ID = FUM.ID
    AND FUM.UPLOADED_BY          = OU.ID;
    COMMIT;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR014', ';WR014'),
      ERROR_STATUS       = 'N'
    WHERE DELIVERY_DATE IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR015', ';WR015'),
      ERROR_STATUS          = 'N'
    WHERE HOURS_ON_TRUCK IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR050', ';WR050'),
      ERROR_STATUS             = 'N'
    WHERE TAV.OPERATOR_NUMBER IS NOT NULL
    AND TAV.OPERATOR_TYPE     IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR051', ';WR051'),
      ERROR_STATUS             = 'N'
    WHERE TAV.OPERATOR_NUMBER IS NULL
    AND TAV.OPERATOR_TYPE     IS NOT NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR016', ';WR016'),
      ERROR_STATUS                    = 'N'
    WHERE TAV.OPERATOR_TYPE          IS NOT NULL
    AND upper(TAV.OPERATOR_TYPE) NOT IN
      (SELECT upper(CFO.VALUE)
      FROM CONFIG_PARAM_OPTION CFO,
        CONFIG_VALUE CV,
        CONFIG_PARAM CP
      WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
      AND CV.CONFIG_PARAM       = CP.ID
      AND CP.NAME               = 'customersFilingDR'
      AND CV.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      );
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR049', ';WR049'),
      ERROR_STATUS                            = 'N'
    WHERE INSTR(NVL(ERROR_CODE,'X'), 'WR016') = 0
    AND TAV.OPERATOR_NUMBER                  IS NOT NULL
    AND TAV.OPERATOR_TYPE                    IS NOT NULL
    AND NOT EXISTS
      (SELECT 1
      FROM CUSTOMER C,
        CUSTOMER_ADDRESSES CA,
        SERVICE_PROVIDER SP,
        ADDRESS_BOOK AB,
        ADDRESS_BOOK_ADDRESS_MAPPING ABAM
      WHERE ABAM.ADDRESS_BOOK_ID     = AB.ID
      AND upper(AB.TYPE)             = UPPER(TAV.OPERATOR_TYPE)
      AND AB.BELONGS_TO              = SP.ID
      AND CA.CUSTOMER                = C.ID
      AND ABAM.ADDRESS_ID           IN (CA.ADDRESSES)
      AND C.CUSTOMER_ID              = TAV.OPERATOR_NUMBER
      AND SP.SERVICE_PROVIDER_NUMBER = TAV.DEALER_NUMBER
      );
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR053', ';WR053'),
      ERROR_STATUS = 'N'
    WHERE TAV.OEM IS NOT NULL
    AND NOT EXISTS
      (SELECT 1
      FROM LIST_OF_VALUES
      WHERE TYPE             = 'OEM'
      AND DESCRIPTION        = TAV.OEM
      AND BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      );
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR020', ';WR020'),
      ERROR_STATUS                     = 'N'
    WHERE TAV.COMPONENT_SERIAL_NUMBER IS NOT NULL
    AND TAV.COMPONENT_PART_NUMBER     IS NULL;
	UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR059', ';WR059'),
      ERROR_STATUS           = 'N'
    WHERE TAV.SERIAL_NUMBER IS NOT NULL
    AND EXISTS
      (SELECT 1
      FROM INVENTORY_ITEM II,
        ITEM I
      WHERE II.SERIAL_NUMBER    = TAV.SERIAL_NUMBER
      AND II.SERIALIZED_PART    = 0
      AND II.D_ACTIVE           = 1
      AND II.OF_TYPE            = I.ID
      AND II.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      AND I.BUSINESS_UNIT_INFO  = TAV.BUSINESS_UNIT_INFO
      AND II.CONDITION_TYPE     = 'SCRAP'
	  AND I.ITEM_TYPE            = 'MACHINE'
      AND I.OWNED_BY             = 1
      AND I.D_ACTIVE             = 1
      );
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR060', ';WR0060'),
      ERROR_STATUS           = 'N'
    WHERE TAV.SERIAL_NUMBER IS NOT NULL
    AND EXISTS
      (SELECT 1
      FROM INVENTORY_ITEM II,
        ITEM I
      WHERE II.SERIAL_NUMBER    = TAV.SERIAL_NUMBER
      AND II.SERIALIZED_PART    = 0
      AND II.D_ACTIVE           = 1
      AND II.OF_TYPE            = I.ID
      AND II.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      AND I.BUSINESS_UNIT_INFO  = TAV.BUSINESS_UNIT_INFO
      AND II.TYPE               = 'RETAIL'
	  AND I.ITEM_TYPE            = 'MACHINE'
      AND I.OWNED_BY             = 1
      AND I.D_ACTIVE             = 1
      );
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR061', ';WR061'),
      ERROR_STATUS          = 'N'
    WHERE CONTRACT_CODE IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR062', ';WR062'),
      ERROR_STATUS                      = 'N'
    WHERE upper(TAV.CONTRACT_CODE) NOT IN
      (SELECT upper(CC.CONTRACT_CODE)
      FROM CONTRACT_CODE CC       
      WHERE
      CC.CONTRACT_CODE = TAV.CONTRACT_CODE
      AND CC.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      )
    AND TAV.CONTRACT_CODE IS NOT NULL;
    COMMIT;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR063', ';WR063'),
      ERROR_STATUS          = 'N'
    WHERE MAINTENANCE_CONTRACT IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR064', ';WR064'),
      ERROR_STATUS                      = 'N'
    WHERE upper(TAV.MAINTENANCE_CONTRACT) NOT IN
      (SELECT upper(MC.MAINTENANCE_CONTRACT)
      FROM MAINTENANCE_CONTRACT MC       
      WHERE
      MC.MAINTENANCE_CONTRACT = TAV.MAINTENANCE_CONTRACT
      AND MC.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      )
    AND TAV.MAINTENANCE_CONTRACT IS NOT NULL;
    COMMIT;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR065', ';WR065'),
      ERROR_STATUS          = 'N'
    WHERE INDUSTRY_CODE IS NULL;
    UPDATE STG_WARRANTY_REGISTRATIONS TAV
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR066', ';WR066'),
      ERROR_STATUS                      = 'N'
    WHERE upper(TAV.INDUSTRY_CODE) NOT IN
      (SELECT upper(IC.INDUSTRY_CODE)
      FROM INDUSTRY_CODE IC       
      WHERE
      IC.INDUSTRY_CODE = TAV.INDUSTRY_CODE
      AND IC.BUSINESS_UNIT_INFO = TAV.BUSINESS_UNIT_INFO
      )
    AND TAV.INDUSTRY_CODE IS NOT NULL;
    COMMIT;
    UPDATE STG_WARRANTY_REGISTRATIONS
    SET ERROR_CODE = ERROR_CODE
      || DECODE(ERROR_CODE, NULL, 'WR021', ';WR021'),
      ERROR_STATUS                   = 'N'
    WHERE COMPONENT_PART_NUMBER     IS NOT NULL
    AND COMPONENT_INSTALLATION_DATE IS NULL;
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
    WHERE BUSINESS_UNIT_INFO = V_BU
    )
    LOOP
      V_POL_CODES(EACH_POL.CODE) := EACH_POL.CODE;
    END LOOP;
    FOR EACH_REC IN ALL_REC
    LOOP
      BEGIN
        V_ERROR_CODE      := NULL;
        V_INSTALL_DEALER_ID := NULL;
        V_COMMIT_COUNT    := V_COMMIT_COUNT + 1;
        V_VAR             := 0;
        V_UNIT_OWNER_TYPE := 'DEALER';
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_ALLOW_OTHER_DLRS_STOCK
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'allowWntyRegOnOthersStock'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_ALLOW_OTHER_DLRS_STOCK := 'FALSE';
        END;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_CAP_INST_DLR_DATE
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'enableDealerAndInstallationDate'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_CAP_INST_DLR_DATE := 'FALSE';
        END;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_ADD_INFO_APPLICABLE
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'additionalInformationDetailsApplicable'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_ADD_INFO_APPLICABLE := 'FALSE';
        END;
        BEGIN
          SELECT II.id,
            II.PENDING_WARRANTY,
            II.SHIPMENT_DATE,
            II.BUILT_ON,
            II.CURRENT_OWNER,
            II.HOURS_ON_MACHINE,
            II.CONDITION_TYPE,
			I.PRODUCT,
			I.MODEL
          INTO V_SERIAL_ID,
            V_PENDING_WR,
            V_SHIP_DATE,
            V_BUILD_DATE,
            V_CURR_OWNER_ID,
            V_HOURS_ON_SERV,
            V_CONDITION,
			V_PRODUCT,
			V_MODEL
          FROM INVENTORY_ITEM II,
            ITEM I
          WHERE II.OF_TYPE          = I.ID
          AND II.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
          AND I.BUSINESS_UNIT_INFO  = EACH_REC.BUSINESS_UNIT_INFO
          AND II.SERIAL_NUMBER      = EACH_REC.SERIAL_NUMBER
          AND II.SERIALIZED_PART    = 0
          AND II.D_ACTIVE           = 1
          AND II.TYPE               = 'STOCK'
		  AND I.ITEM_TYPE            = 'MACHINE'
		  AND I.OWNED_BY             = 1
		  AND I.D_ACTIVE             = 1;
          SELECT upper(SP.SERVICE_PROVIDER_TYPE)
          INTO V_UNIT_OWNER_TYPE
          FROM SERVICE_PROVIDER SP
          WHERE SP.id = V_CURR_OWNER_ID;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_UNIT_OWNER_TYPE := 'DEALER';
          V_ERROR_CODE      := common_utils.addErrorMessage(V_ERROR_CODE, 'WR013');
        END;
        IF NOT(V_ALLOW_OTHER_DLRS_STOCK = 'TRUE' OR V_FILING_PARTY = 1 OR V_UNIT_OWNER_TYPE = 'OEM') AND V_FILING_PARTY > 1 AND V_FILING_PARTY <> V_CURR_OWNER_ID THEN
          V_ERROR_CODE                 := common_utils.addErrorMessage(V_ERROR_CODE, 'WR013');
        END IF;
        IF V_PENDING_WR = 1 THEN
          V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR009');
        END IF;
        IF EACH_REC.DELIVERY_DATE                         IS NOT NULL AND NOT (COMMON_UTILS.ISVALIDDATE(EACH_REC.DELIVERY_DATE)) THEN
          V_ERROR_CODE                                    := common_utils.addErrorMessage(V_ERROR_CODE, 'WR034');
        ELSIF TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD') >= SYSDATE THEN
          V_ERROR_CODE                                    := common_utils.addErrorMessage(V_ERROR_CODE, 'WR035');
        ELSIF TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD')  < V_BUILD_DATE THEN
          V_ERROR_CODE                                    := common_utils.addErrorMessage(V_ERROR_CODE, 'WR056');
        ELSIF TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD')  < V_SHIP_DATE THEN
          V_ERROR_CODE                                    := common_utils.addErrorMessage(V_ERROR_CODE, 'WR036');
        END IF;
        IF UPPER(V_CAP_INST_DLR_DATE)           = 'TRUE' THEN
          IF EACH_REC.INSTALLING_DEALER_NUMBER IS NULL THEN
            V_ERROR_CODE                       := common_utils.addErrorMessage(V_ERROR_CODE, 'WR017');
          ELSE
            BEGIN
              SELECT SP.id
              INTO V_INSTALL_DEALER_ID
              FROM SERVICE_PROVIDER SP,
                BU_ORG_MAPPING BOM
              WHERE SP.ID                            = BOM.ORG
              AND BOM.BU                             = EACH_REC.BUSINESS_UNIT_INFO
              AND SP.SERVICE_PROVIDER_NUMBER         = EACH_REC.INSTALLING_DEALER_NUMBER
              AND EACH_REC.INSTALLING_DEALER_NUMBER IS NOT NULL;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR018');
            END;
          END IF;
          IF EACH_REC.DATE_OF_INSTALLATION IS NULL THEN
            V_ERROR_CODE                   := common_utils.addErrorMessage(V_ERROR_CODE, 'WR019');
          ELSIF NOT (COMMON_UTILS.ISVALIDDATE(EACH_REC.DATE_OF_INSTALLATION)) THEN
            V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR037');
          ELSIF TO_DATE(EACH_REC.DATE_OF_INSTALLATION, 'YYYYMMDD') >= SYSDATE THEN
            V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR039');
          ELSIF TO_DATE(EACH_REC.DATE_OF_INSTALLATION, 'YYYYMMDD')  < V_BUILD_DATE THEN
            V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR058');
          ELSIF TO_DATE(EACH_REC.DATE_OF_INSTALLATION, 'YYYYMMDD')  < V_SHIP_DATE THEN
            V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR057');
          ELSIF EACH_REC.DELIVERY_DATE                             IS NOT NULL AND COMMON_UTILS.ISVALIDDATE(EACH_REC.DELIVERY_DATE) AND TO_DATE(EACH_REC.DATE_OF_INSTALLATION, 'YYYYMMDD') > TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD') THEN
            V_ERROR_CODE                                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR038');
          END IF;
        END IF;
        IF EACH_REC.HOURS_ON_TRUCK IS NOT NULL AND NOT(COMMON_UTILS.ISNUMBER(EACH_REC.HOURS_ON_TRUCK)) THEN
          V_ERROR_CODE               := common_utils.addErrorMessage(V_ERROR_CODE, 'WR033');
        END IF;
        IF EACH_REC.COMPONENT_PART_NUMBER IS NOT NULL THEN
          COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_PART_NUMBER,'#$#',V_COMP_PART_ARRAY ,V_COMP_PART_COUNT);
          IF EACH_REC.COMPONENT_SERIAL_NUMBER IS NOT NULL THEN
            COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_SERIAL_NUMBER,'#$#',V_COMP_SERIAL_ARRAY ,V_COMP_SERIAL_COUNT);
            IF EACH_REC.COMPONENT_INSTALLATION_DATE IS NOT NULL THEN
              COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_INSTALLATION_DATE,'#$#',V_COMP_INSTALL_ARRAY ,V_COMP_INSTALL_COUNT);
              IF V_COMP_PART_COUNT <> V_COMP_SERIAL_COUNT THEN
                V_ERROR_CODE       := common_utils.addErrorMessage(V_ERROR_CODE, 'WR040');
              END IF;
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
                WHEN INSTR(NVL(V_ERROR_CODE,'X'), 'WR042') > 0;
                END;
              END LOOP;
              IF INSTR(NVL(V_ERROR_CODE,'X'), 'WR040') = 0 AND INSTR(NVL(V_ERROR_CODE,'X'), 'WR041') = 0 AND INSTR(NVL(V_ERROR_CODE,'X'), 'WR042') = 0 THEN
                FOR N                                 IN 1..V_COMP_PART_COUNT
                LOOP
                  BEGIN
                    SELECT II.id
                    INTO V_COMPONENT_ID
                    FROM ITEM I,
                      INVENTORY_ITEM II
                    WHERE I.ITEM_TYPE        = 'PART'
                    AND I.ITEM_NUMBER        = V_COMP_PART_ARRAY(N)
                    AND I.OWNED_BY           = 1
                    AND I.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
                    AND II.OF_TYPE           = I.ID
                    AND II.SERIAL_NUMBER     = V_COMP_SERIAL_ARRAY(N)
                    AND II.SERIALIZED_PART   = 1
                    AND II.D_ACTIVE          = 1;
                    SELECT common_utils.addErrorMessage(V_ERROR_CODE, 'WR054')
                    INTO V_ERROR_CODE
                    FROM inventory_item_composition iic,
                      inventory_item ii
                    WHERE iic.PART_OF = ii.id
                    AND iic.PART      = V_COMPONENT_ID
                    AND iic.D_ACTIVE  = 1
                    AND ii.id        <> V_SERIAL_ID
                    AND II.D_ACTIVE   = 1;
                    EXIT
                  WHEN INSTR(NVL(V_ERROR_CODE,'X'), 'WR054') > 0;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_COMPONENT_ID := 0;
                  END;
                END LOOP;
              END IF;
              FOR I IN 1..V_COMP_INSTALL_COUNT
              LOOP
                IF NOT COMMON_UTILS.ISVALIDDATE(V_COMP_INSTALL_ARRAY(I)) OR TO_DATE(V_COMP_INSTALL_ARRAY(I), 'YYYYMMDD') < V_BUILD_DATE THEN
                  V_ERROR_CODE                                                                                          := common_utils.addErrorMessage(V_ERROR_CODE, 'WR043');
                  EXIT
                WHEN INSTR(NVL(V_ERROR_CODE,'X'), 'WR043') > 0;
                END IF;
              END LOOP;
            END IF;
          END IF;
        END IF;
    IF (V_INSTALL_DEALER_ID IS NOT NULL ) 
		THEN 
        SELECT  DECODE(SP.CERTIFIED, 0, 'N', 1, 'Y')
        INTO    V_CERT_STATUS
        FROM SERVICE_PROVIDER SP,
          BU_ORG_MAPPING BOM
        WHERE SP.SERVICE_PROVIDER_NUMBER = EACH_REC.INSTALLING_DEALER_NUMBER
        AND SP.ID                        = BOM.ORG
        AND BOM.BU                       = EACH_REC.BUSINESS_UNIT_INFO;		
		END IF;
DBMS_OUTPUT.PUT_LINE(V_PRODUCT || V_MODEL || EACH_REC.BUSINESS_UNIT_INFO || TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD')|| TO_NUMBER(V_HOURS_ON_SERV) || V_CONDITION || V_CERT_STATUS|| V_INSTALL_DEALER_ID);
        OPEN ALL_ELIGIBLE_POLICY_PLANS(V_PRODUCT, V_MODEL, EACH_REC.BUSINESS_UNIT_INFO, TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD'), TO_NUMBER(V_HOURS_ON_SERV), V_CONDITION, V_CERT_STATUS, V_INSTALL_DEALER_ID);

        IF ALL_ELIGIBLE_POLICY_PLANS%NOTFOUND THEN
          V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR055');
        END IF;
        CLOSE ALL_ELIGIBLE_POLICY_PLANS;

        IF EACH_REC.ADDITIONAL_APPLICABLE_POLICIES IS NOT NULL THEN
          BEGIN
            COMMON_UTILS.ParseAnySeperatorList(EACH_REC.ADDITIONAL_APPLICABLE_POLICIES,'#$#',V_POL_ARRAY ,V_POL_COUNT);
            FOR I IN 1..V_POL_COUNT
            LOOP
              IF NOT V_POL_CODES.EXISTS(V_POL_ARRAY(I)) THEN
                V_ERROR_CODE := common_utils.addErrorMessage(V_ERROR_CODE, 'WR046');
                EXIT
              WHEN INSTR(NVL(V_ERROR_CODE,'X'), 'WR046') > 0;
              END IF;
            END LOOP;
          END;
        END IF;
        IF EACH_REC.REQUEST_FOR_EXTENSION          IS NOT NULL THEN
          IF upper(EACH_REC.REQUEST_FOR_EXTENSION) <> 'YES' AND upper(EACH_REC.REQUEST_FOR_EXTENSION) <> 'NO' THEN
            V_ERROR_CODE                           := common_utils.addErrorMessage(V_ERROR_CODE, 'WR052');
          END IF;
        END IF;
        IF V_ERROR_CODE IS NULL AND EACH_REC.ERROR_CODE IS NULL THEN
          UPDATE STG_WARRANTY_REGISTRATIONS
          SET ERROR_STATUS = 'Y',
            ERROR_CODE     = NULL
          WHERE ID         = EACH_REC.ID;
        ELSE
          UPDATE STG_WARRANTY_REGISTRATIONS
          SET ERROR_STATUS = 'N',
            ERROR_CODE     = ERROR_CODE
            || DECODE (ERROR_CODE,NULL, V_ERROR_CODE,','
            || V_ERROR_CODE)
          WHERE ID = EACH_REC.ID;
        END IF;
        COMMIT;
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
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END UPLOAD_WARRANTY_REG_VALIDATION;
/
create or replace
PROCEDURE UPLOAD_WARRANTY_REG_UPLOAD
AS
 CURSOR ALL_REC
  IS
    SELECT *
    FROM STG_WARRANTY_REGISTRATIONS
    WHERE ERROR_STATUS          = 'Y'
    AND NVL(UPLOAD_STATUS, 'N') = 'N';
  CURSOR ALL_ELIGIBLE_POLICY_PLANS(P_PRODUCT VARCHAR2, P_MODEL VARCHAR2, P_BU VARCHAR2, P_DEL_DATE DATE, P_HRS_ON_SERVICE NUMBER, P_CONDITION VARCHAR2, P_CERT_STATUS VARCHAR2, P_INSTALL_DEALER NUMBER)
  IS
   SELECT PD.*
    FROM POLICY_DEFINITION PD,
      POLICY_FOR_ITEMCONDITIONS PFI
    WHERE PD.ID IN
      (SELECT POLICY_DEFN
      FROM POLICY_FOR_PRODUCTS
      WHERE FOR_PRODUCT IN (P_PRODUCT, P_MODEL)
      )
    AND PD.ACTIVE_FROM                                           <= P_DEL_DATE
    AND PD.ACTIVE_TILL                                           >= P_DEL_DATE
    AND P_HRS_ON_SERVICE                                         <= PD.SERVICE_HRS_COVERED
    AND PD.BUSINESS_UNIT_INFO                                     = P_BU
    AND UPPER(PD.WARRANTY_TYPE)                                   = 'STANDARD'
    AND (DECODE(PD.CERTIFICATION_STATUS, 'NOTCERTIFIED', 'N', 'Y')= P_CERT_STATUS
    OR PD.CERTIFICATION_STATUS                                    = 'ANY')
    AND PD.ID                                                     = PFI.POLICY_DEFN
    AND PFI.FOR_ITEMCONDITION                                     = P_CONDITION


    And  (
            P_INSTALL_DEALER in (
                select
                    applicable7_.for_service_provider 
                from
                    policy_for_serviceproviders applicable7_ 
                where
                    PD.id=applicable7_.policy_defn
            ) 
            or exists (
                select
                    dealergrou8_.id 
                from
                    dealer_group dealergrou8_ cross 
                join
                    dealer_group dealergrou9_ 
                inner join
                    dealers_in_group includedde10_ 
                        on dealergrou9_.id=includedde10_.dealer_group 
                inner join
                    service_provider servicepro11_ 
                        on includedde10_.dealer=servicepro11_.id 
                inner join
                    organization servicepro11_1_ 
                        on servicepro11_.id=servicepro11_1_.id 
                inner join
                    party servicepro11_2_ 
                        on servicepro11_.id=servicepro11_2_.id 
                where
                    dealergrou8_.business_unit_info in (
                       P_BU
                    ) 
                    and dealergrou8_.d_active = 1 
                    and dealergrou9_.business_unit_info in (
                        P_BU
                    ) 
                    and dealergrou9_.d_active = 1 
                    and P_INSTALL_DEALER=servicepro11_.id 
                    and dealergrou8_.tree_id=dealergrou9_.tree_id 
                    and dealergrou8_.lft<=dealergrou9_.lft 
                    and dealergrou9_.rgt<=dealergrou8_.rgt 
                    and (
                        dealergrou8_.id in (
                            select
                                applicable12_.for_dealer_groups 
                            from
                                policy_for_dealer_groups applicable12_ 
                            where
                                PD.id=applicable12_.policy_defn
                        )
                    )
                ) 
                or  not (exists (select
                    servicepro14_.id 
                from
                    policy_for_serviceproviders applicable13_,
                    service_provider servicepro14_ 
                inner join
                    organization servicepro14_1_ 
                        on servicepro14_.id=servicepro14_1_.id 
                inner join
                    party servicepro14_2_ 
                        on servicepro14_.id=servicepro14_2_.id 
                where
                    PD.id=applicable13_.policy_defn 
                    and applicable13_.for_service_provider=servicepro14_.id)) 
                and  not (exists (select
                    dealergrou16_.id 
                from
                    policy_for_dealer_groups applicable15_,
                    dealer_group dealergrou16_ 
                where
                    PD.id=applicable15_.policy_defn 
                    and applicable15_.for_dealer_groups=dealergrou16_.id))
            ) 
    AND PD.D_ACTIVE = 1
    AND NOT EXISTS
      (SELECT 1
      FROM POLICY_FEES
      WHERE POLICY        = PD.id
      AND is_transferable = 0
      AND amount          > 0
      );
    CURSOR ALL_EXTENDED_POLICIES(P_BUSINESS_UNIT_INFO VARCHAR2, P_SERIAL_ID NUMBER)
    IS
      SELECT POLICY
      FROM EXTENDED_WARRANTY_NOTIFICATION we
      WHERE NOTIFICATION_TYPE  <> 'Completed'
      AND WE.FOR_UNIT           = P_SERIAL_ID
      AND WE.BUSINESS_UNIT_INFO = P_BUSINESS_UNIT_INFO;
    V_UPLOAD_ERROR        VARCHAR2(4000);
    V_ADMIN_APPRV_IND     VARCHAR2(10);
    V_PERFORM_D2D         VARCHAR2(10);
    V_ALLOW_OTR_DLRS_STK  VARCHAR2(10);
    V_KICK_OFF_CVRGS      BOOLEAN;
    V_TYPE_OF             NUMBER(19);
    V_PRODUCT             VARCHAR2(255);
    V_MODEL               VARCHAR2(255);
    V_OEM_ID              NUMBER(19);
    V_PARTY_OEM_ID        NUMBER(19);
    V_WARRANTY_ID         NUMBER(19);
    V_MARK_INFO_ID        NUMBER(19);
    V_SALESMAN_ID         NUMBER(19);
    V_MARKET_ID           NUMBER(19);
    V_COMPETITION_TYPE_ID NUMBER(19);
    V_TRANSACTION_TYPE_ID NUMBER(19);
    V_COMPETITOR_MODEL_ID NUMBER(19);
    V_COMPETITOR_MAKE_ID  NUMBER(19);
    V_MAX_COUNT           NUMBER(19);
    V_INV_TYPE            VARCHAR2(255);
    V_TRANS_TYPE          VARCHAR2(255);
    V_SELLER_ID           NUMBER(19);
    V_BUYER_ID            NUMBER(19);
    V_BUILD_DATE DATE;
    V_MFG_ID            NUMBER(19);
    V_INV_ID            NUMBER(19);
    V_INSTALL_DEALER_ID NUMBER(19);
    V_CUST_ADD_ID       VARCHAR2(255);
    V_ADDRESS_TRANS_ID  NUMBER(19);
    V_MULTIDRETRNUMBER  NUMBER(19);
    V_OPERATOR_ID       NUMBER(19);
    V_WARRANTY_AUDIT_ID NUMBER(19);
    V_OF_TYPE_ID        NUMBER(19);
    V_SERIAL_ID         NUMBER(19);
    V_INV_ITEM_COMP_ID  NUMBER(19);
    V_HOURS_ON_SERV     NUMBER(19);
    V_BUILT_ON DATE;
    V_INSTALL_DATE DATE;
    V_SHIP_DATE DATE;
    V_CONDITION       VARCHAR2(255);
    V_TYPE            VARCHAR2(255);
    V_OWNERSHIP_STATE VARCHAR2(255);
    V_CERT_STATUS     VARCHAR2(1);
    V_SHIP_COVERAGE_TILL_DATE DATE;
    V_COVERAGE_TILL_DATE DATE;
    V_MONTHS_FRM_DELIVERY NUMBER(19);
    V_MONTHS_FRM_SHIPMENT NUMBER(19);
    V_POLICY_DEFN_ID      NUMBER(19);
    V_POLICY_ID           NUMBER(19);
    V_POLICY_AUDIT_ID     NUMBER(19);
    V_ADDTNL_INFO_IND     VARCHAR2(10);
    V_CAP_INST_DLR_DATE   VARCHAR2(10);
    V_POL_COUNT           NUMBER(19);
    V_SERIAL_NUM_COUNT    NUMBER(19);
    V_PART_NUM_COUNT      NUMBER(19);
    V_INSTALL_DATE_COUNT  NUMBER(19);
    V_END_CUST_ID         NUMBER(19);
    V_ASSIGNED_TO         NUMBER(19);
    V_WARRANTY_STATUS     VARCHAR2(255);
    V_ASSIGN_COUNT        NUMBER(19);
    V_TRANS_ID            NUMBER(19);
    V_DEALER_ID           NUMBER(19);
    V_LAST_UPDATED_BY     NUMBER(19);
    V_TRANSACTION_ORDER   NUMBER;
    V_CURR_OWNER_TYPE     VARCHAR(50);
    V_INVOICE_DATE DATE;
    V_INVOICE_NUM              VARCHAR2(255);
    V_WARANTY_TASK_INSTANCE_ID NUMBER(19);
    V_COVERAGE_END_DATE DATE;
    V_COMP_INSTALL_DATE_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_COMP_SERIAL_NUMBER_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_COMP_PART_NUMBER_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_POL_ARRAY DBMS_UTILITY.UNCL_ARRAY;
    V_CUR_RECORD ALL_ELIGIBLE_POLICY_PLANS%ROWTYPE;
    V_IS_RED_CVG        VARCHAR(20);
    V_IS_REQ_EXTN       VARCHAR(20);
    V_WNTY_EXTN_REQ_ID  NUMBER(19);
    V_MAX_LIST_INDEX    NUMBER;
    V_OPR_ADDR_TRANS_ID NUMBER(19);
    V_OPR_ADDR_ID       NUMBER(19);
    V_CONTRACT_CODE_ID  NUMBER(19); 
    V_MAINTENANCE_CONTRACT_ID  NUMBER(19); 
    V_INDUSTRY_CODE_ID  NUMBER(19); 
    V_DEALER_REPRESENTATIVE VARCHAR2(255);
  BEGIN
    SELECT ID INTO V_PARTY_OEM_ID FROM PARTY WHERE NAME = 'OEM';
    FOR EACH_REC IN ALL_REC
    LOOP
      BEGIN
        V_UPLOAD_ERROR             := NULL;
        V_TYPE_OF                  := 0;
        V_PRODUCT                  := NULL;
        V_MODEL                    := NULL;
        V_WARRANTY_ID              := 0;
        V_MARK_INFO_ID             := NULL;
        V_SALESMAN_ID              := 0;
        V_MARKET_ID                := NULL;
        V_COMPETITION_TYPE_ID      := NULL;
        V_TRANSACTION_TYPE_ID      := NULL;
        V_COMPETITOR_MODEL_ID      := NULL;
        V_COMPETITOR_MAKE_ID       := NULL;
        V_TRANS_TYPE               := NULL;
        V_SELLER_ID                := 0;
        V_BUYER_ID                 := 0;
        V_INSTALL_DEALER_ID        := 0;
        V_CUST_ADD_ID              := NULL;
        V_ADDRESS_TRANS_ID         := 0;
        V_MULTIDRETRNUMBER         := 0;
        V_OPERATOR_ID              := NULL;
        V_WARRANTY_AUDIT_ID        := 0;
        V_OF_TYPE_ID               := 0;
        V_SERIAL_ID                := 0;
        V_INV_ITEM_COMP_ID         := 0;
        V_HOURS_ON_SERV            := 0;
        V_BUILT_ON                 :=NULL;
        V_INSTALL_DATE             :=NULL;
        V_SHIP_DATE                :=NULL;
        V_CONDITION                :=NULL;
        V_TYPE                     :=NULL;
        V_OWNERSHIP_STATE          :=NULL;
        V_CERT_STATUS              := NULL;
        V_SHIP_COVERAGE_TILL_DATE  := NULL;
        V_COVERAGE_TILL_DATE       := NULL;
        V_MONTHS_FRM_DELIVERY      := 0;
        V_MONTHS_FRM_SHIPMENT      := 0;
        V_POLICY_DEFN_ID           := 0;
        V_POLICY_ID                := 0;
        V_POLICY_AUDIT_ID          := 0;
        V_END_CUST_ID              := 0;
        V_ASSIGN_COUNT             := 0;
        V_TRANS_ID                 := NULL;
        V_DEALER_ID                := 0;
        V_SERIAL_NUM_COUNT         := 0;
        V_INVOICE_DATE             := NULL;
        V_INVOICE_NUM              := NULL;
        V_WARANTY_TASK_INSTANCE_ID := NULL;
        V_COVERAGE_END_DATE        := NULL;
        V_CURR_OWNER_TYPE          := NULL;
        V_ASSIGNED_TO              := NULL;
        V_IS_RED_CVG               := 'FALSE';
        V_IS_REQ_EXTN              := 'FALSE';
        V_MAX_LIST_INDEX           := 0;
        V_OPR_ADDR_ID              := NULL;
        V_OPR_ADDR_TRANS_ID        := NULL;
        V_CONTRACT_CODE_ID         := NULL;
        V_MAINTENANCE_CONTRACT_ID  := NULL; 
        V_INDUSTRY_CODE_ID         := NULL;
        SELECT UPLOADED_BY
        INTO V_LAST_UPDATED_BY
        FROM file_upload_mgt
        WHERE id = EACH_REC.FILE_UPLOAD_MGT_ID;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_ALLOW_OTR_DLRS_STK
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'allowWntyRegOnOthersStock'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_ALLOW_OTR_DLRS_STK := 'FALSE';
        END;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_CAP_INST_DLR_DATE
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'enableDealerAndInstallationDate'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_CAP_INST_DLR_DATE := 'FALSE';
        END;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_ADDTNL_INFO_IND
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'additionalInformationDetailsApplicable'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_ADDTNL_INFO_IND := 'FALSE';
        END;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_ADMIN_APPRV_IND
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'manualApprovalFlowForDR'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_ADMIN_APPRV_IND := 'FALSE';
        END;
        BEGIN
          SELECT UPPER(CFO.VALUE)
          INTO V_PERFORM_D2D
          FROM CONFIG_PARAM_OPTION CFO,
            CONFIG_VALUE CV,
            CONFIG_PARAM CP
          WHERE CFO.ID              = CV.CONFIG_PARAM_OPTION
          AND CV.CONFIG_PARAM       = CP.ID
          AND CP.NAME               = 'performD2DOnWR'
          AND CV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_PERFORM_D2D := 'FALSE';
        END;
        IF UPPER(V_ADMIN_APPRV_IND) = 'TRUE' THEN
          V_WARRANTY_STATUS        := 'SUBMITTED';
        ELSE
          V_WARRANTY_STATUS := 'ACCEPTED';
        END IF;
		BEGIN
        SELECT CUST.ID
        INTO V_END_CUST_ID
        FROM CUSTOMER CUST,
          CUSTOMER_ADDRESSES CUSTADDR,
          ADDRESS_BOOK ADDRBK,
          ADDRESS_BOOK_ADDRESS_MAPPING ADDRBKMPNG,
          SERVICE_PROVIDER SP
        WHERE CUST.ID                  = CUSTADDR.CUSTOMER
        AND CUSTADDR.ADDRESSES         = ADDRBKMPNG.ADDRESS_ID
        AND ADDRBKMPNG.ADDRESS_BOOK_ID = ADDRBK.ID
        AND ADDRBK.BELONGS_TO          = SP.ID
        AND UPPER(ADDRBK.TYPE)         = UPPER(EACH_REC.CUSTOMER_TYPE)
        AND CUST.CUSTOMER_ID           = EACH_REC.CUSTOMER_NUMBER
        AND SP.SERVICE_PROVIDER_NUMBER = EACH_REC.DEALER_NUMBER;
		EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_END_CUST_ID := 0;
        END;
		BEGIN
        SELECT ID
        INTO V_INSTALL_DEALER_ID
        FROM SERVICE_PROVIDER
        WHERE SERVICE_PROVIDER_NUMBER = EACH_REC.INSTALLING_DEALER_NUMBER;
		EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_INSTALL_DEALER_ID := 0;
        END;
        SELECT ID
        INTO V_DEALER_ID
        FROM SERVICE_PROVIDER
        WHERE SERVICE_PROVIDER_NUMBER = EACH_REC.DEALER_NUMBER;
        IF (EACH_REC.OPERATOR_NUMBER IS NOT NULL) THEN
          BEGIN
            SELECT CUST.ID
            INTO V_OPERATOR_ID
            FROM CUSTOMER CUST,
              CUSTOMER_ADDRESSES CUSTADDR,
              ADDRESS_BOOK ADDRBK,
              ADDRESS_BOOK_ADDRESS_MAPPING ADDRBKMPNG,
              SERVICE_PROVIDER SP
            WHERE CUST.ID                  = CUSTADDR.CUSTOMER
            AND CUSTADDR.ADDRESSES         = ADDRBKMPNG.ADDRESS_ID
            AND ADDRBKMPNG.ADDRESS_BOOK_ID = ADDRBK.ID
            AND ADDRBK.BELONGS_TO          = SP.ID
            AND UPPER(ADDRBK.TYPE)         = UPPER(EACH_REC.OPERATOR_TYPE)
            AND CUST.CUSTOMER_ID           = EACH_REC.OPERATOR_NUMBER
            AND SP.SERVICE_PROVIDER_NUMBER = EACH_REC.DEALER_NUMBER;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_OPERATOR_ID := NULL;
          END;
        END IF;
        IF V_END_CUST_ID > 0 THEN
          BEGIN
            IF (EACH_REC.COMPONENT_SERIAL_NUMBER IS NOT NULL AND EACH_REC.COMPONENT_PART_NUMBER IS NOT NULL AND EACH_REC.COMPONENT_INSTALLATION_DATE IS NOT NULL) THEN
              COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_SERIAL_NUMBER,'#$#',V_COMP_SERIAL_NUMBER_ARRAY , V_SERIAL_NUM_COUNT);
              COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_PART_NUMBER,'#$#',V_COMP_PART_NUMBER_ARRAY , V_PART_NUM_COUNT);
              COMMON_UTILS.ParseAnySeperatorList(EACH_REC.COMPONENT_INSTALLATION_DATE,'#$#',V_COMP_INSTALL_DATE_ARRAY , V_INSTALL_DATE_COUNT);
            END IF;
            SELECT II.ID,
              BUILT_ON,
              SHIPMENT_DATE,
              CONDITION_TYPE,
              TYPE,
              OWNERSHIP_STATE,
              INSTALLATION_DATE,
              II.CURRENT_OWNER,
			  I.PRODUCT,
			  I.MODEL,
			  I.ID
            INTO V_SERIAL_ID,
              V_BUILT_ON,
              V_SHIP_DATE,
              V_CONDITION,
              V_TYPE,
              V_OWNERSHIP_STATE,
              V_INSTALL_DATE,
              V_SELLER_ID,
			  V_PRODUCT,
			  V_MODEL,
			  V_TYPE_OF
            FROM INVENTORY_ITEM II,
              ITEM I
            WHERE II.SERIAL_NUMBER    = EACH_REC.SERIAL_NUMBER
            AND II.OF_TYPE            = I.ID
            AND II.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
            AND I.BUSINESS_UNIT_INFO  = EACH_REC.BUSINESS_UNIT_INFO
            AND II.SERIALIZED_PART    = 0
            AND II.D_ACTIVE           = 1
            AND II.TYPE               = 'STOCK'
			AND I.ITEM_TYPE            = 'MACHINE'
			AND I.OWNED_BY             = 1
			AND I.D_ACTIVE             = 1;
            V_HOURS_ON_SERV:=EACH_REC.HOURS_ON_TRUCK;
            SELECT upper(SP.COMPANY_TYPE)
            INTO V_CURR_OWNER_TYPE
            FROM SERVICE_PROVIDER SP
            WHERE SP.ID    = V_SELLER_ID;
            IF V_SERIAL_ID > 0 THEN
              FOR I       IN 1..V_SERIAL_NUM_COUNT
              LOOP
                BEGIN
                  SELECT ID
                  INTO V_OF_TYPE_ID
                  FROM ITEM
                  WHERE ITEM_NUMBER      = V_COMP_PART_NUMBER_ARRAY(I)
                  AND ITEM_TYPE          = 'PART'
                  AND OWNED_BY           = 1
                  AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
                  AND ROWNUM             = 1;
                  SELECT ID
                  INTO V_INV_ID
                  FROM INVENTORY_ITEM
                  WHERE SERIAL_NUMBER    = V_COMP_SERIAL_NUMBER_ARRAY(I)
                  AND OF_TYPE            = V_OF_TYPE_ID
                  AND serialized_part    = 1
                  AND D_ACTIVE           = 1
                  AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  SELECT INVENTORY_ITEM_SEQ.NEXTVAL INTO V_INV_ID FROM DUAL;
                  INSERT
                  INTO INVENTORY_ITEM
                    (
                      ID,
                      BUILT_ON,
                      DELIVERY_DATE,
                      HOURS_ON_MACHINE,
                      SERIAL_NUMBER,
                      SHIPMENT_DATE,
                      VERSION,
                      CONDITION_TYPE,
                      TYPE,
                      OF_TYPE,
                      OWNERSHIP_STATE,
                      BUSINESS_UNIT_INFO,
                      PENDING_WARRANTY,
                      D_CREATED_ON,
                      D_INTERNAL_COMMENTS,
                      D_ACTIVE,
                      D_UPDATED_ON,
                      D_LAST_UPDATED_BY,
                      D_CREATED_TIME,
                      D_UPDATED_TIME,
                      SERIALIZED_PART,
                      INSTALLATION_DATE,
                      SOURCE
                    )
                    VALUES
                    (
                      V_INV_ID,
                      V_BUILT_ON,
                      TO_DATE(EACH_REC.DELIVERY_DATE, 'YYYYMMDD'),
                      V_HOURS_ON_SERV,
                      V_COMP_SERIAL_NUMBER_ARRAY(I),
                      V_SHIP_DATE,
                      1,
                      V_CONDITION,
                      V_TYPE,
                      V_OF_TYPE_ID,
                      V_OWNERSHIP_STATE,
                      EACH_REC.BUSINESS_UNIT_INFO,
                      0,
                      SYSDATE,
                      EACH_REC.BUSINESS_UNIT_INFO
                      || '-Upload',
                      1,
                      SYSDATE,
                      V_LAST_UPDATED_BY,
                      CURRENT_TIMESTAMP,
                      CURRENT_TIMESTAMP,
                      1,
                      TO_DATE(V_COMP_INSTALL_DATE_ARRAY(I),'YYYYMMDD'),
                      'UNITREGISTRATION'
                    );
                  SELECT SEQ_INVENTORYITEMCOMPOSITION.NEXTVAL INTO V_INV_ITEM_COMP_ID FROM DUAL;
                  INSERT
                  INTO INVENTORY_ITEM_COMPOSITION
                    (
                      ID,
                      VERSION,
                      PART,
                      PART_OF,
                      D_CREATED_ON,
                      D_INTERNAL_COMMENTS,
                      D_ACTIVE,
                      D_UPDATED_ON,
                      D_LAST_UPDATED_BY,
                      D_CREATED_TIME,
                      D_UPDATED_TIME
                    )
                    VALUES
                    (
                      V_INV_ITEM_COMP_ID,
                      1,
                      V_INV_ID,
                      V_SERIAL_ID,
                      SYSDATE,
                      EACH_REC.BUSINESS_UNIT_INFO
                      || '-Upload',
                      1,
                      SYSDATE,
                      V_LAST_UPDATED_BY,
                      CURRENT_TIMESTAMP,
                      CURRENT_TIMESTAMP
                    );
                END;
              END LOOP;
              IF UPPER
                (
                  V_ADDTNL_INFO_IND
                )
                = 'TRUE' THEN
                BEGIN
                  SELECT MARKETING_INFORMATION_SEQ.NEXTVAL INTO V_MARK_INFO_ID FROM DUAL;
                  SELECT ID
                  INTO V_CONTRACT_CODE_ID
                  FROM CONTRACT_CODE
                  WHERE CONTRACT_CODE=EACH_REC.CONTRACT_CODE
                  AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
                  SELECT ID
                  INTO V_MAINTENANCE_CONTRACT_ID
                  FROM MAINTENANCE_CONTRACT
                  WHERE MAINTENANCE_CONTRACT=EACH_REC.MAINTENANCE_CONTRACT
                  AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
                  SELECT ID
                  INTO V_INDUSTRY_CODE_ID
                  FROM INDUSTRY_CODE
                  WHERE INDUSTRY_CODE=EACH_REC.INDUSTRY_CODE
                  AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
                  INSERT
                  INTO MARKETING_INFORMATION
                    (
                      ID,
                      VERSION,
                      D_CREATED_ON,
                      D_INTERNAL_COMMENTS,
                      D_ACTIVE,
                      D_UPDATED_ON,
                      D_LAST_UPDATED_BY,
                      D_CREATED_TIME,
                      D_UPDATED_TIME,
                      CONTRACT_CODE,
                      MAINTENANCE_CONTRACT,
                      INDUSTRY_CODE,
                      DEALER_REPRESENTATIVE
                    )
                    VALUES
                    (
                      V_MARK_INFO_ID,
                      1,
                      SYSDATE,
                      EACH_REC.BUSINESS_UNIT_INFO
                      || '-Upload',
                      1,
                      SYSDATE,
                      V_LAST_UPDATED_BY,
                      CURRENT_TIMESTAMP,
                      CURRENT_TIMESTAMP,
                      V_CONTRACT_CODE_ID, 
                      V_MAINTENANCE_CONTRACT_ID,
                      V_INDUSTRY_CODE_ID,
                      EACH_REC.DEALER_REPRESENTATIVE
                    );
                END;
              END IF;
              IF EACH_REC.OEM IS NOT NULL THEN
                SELECT ID
                INTO V_OEM_ID
                FROM LIST_OF_VALUES
                WHERE TYPE             = 'OEM'
                AND DESCRIPTION        = EACH_REC.OEM
                AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
              END IF;
              V_INV_TYPE := 'RETAIL';
              SELECT ID
              INTO V_TRANS_TYPE
              FROM INVENTORY_TRANSACTION_TYPE
              WHERE TRNX_TYPE_KEY = DECODE(V_INV_TYPE, 'STOCK', 'IB','RETAIL', 'DR');
              V_INVOICE_DATE     := NULL;
              V_INVOICE_NUM      := NULL;
              SELECT MAX(transaction_order)
              INTO V_TRANSACTION_ORDER
              FROM inventory_transaction it
              WHERE it.transacted_item = V_SERIAL_ID;

              IF upper(V_PERFORM_D2D) = 'TRUE' AND V_SELLER_ID <> V_DEALER_ID AND (upper(V_ALLOW_OTR_DLRS_STK) = 'TRUE' OR V_CURR_OWNER_TYPE = 'OEM') THEN
                V_TRANSACTION_ORDER  := V_TRANSACTION_ORDER + 1;
                INSERT
                INTO INVENTORY_TRANSACTION
                  (
                    ID,
                    INVOICE_DATE,
                    INVOICE_NUMBER,
                    TRANSACTION_DATE,
                    VERSION,
                    BUYER,
                    TRANSACTED_ITEM,
                    SELLER,
                    INV_TRANSACTION_TYPE,
                    OWNER_SHIP,
                    TRANSACTION_ORDER,
                    STATUS,
                    D_CREATED_ON,
                    D_INTERNAL_COMMENTS,
                    D_ACTIVE,
                    D_UPDATED_ON,
                    D_LAST_UPDATED_BY,
                    D_CREATED_TIME,
                    D_UPDATED_TIME
                  )
                  VALUES
                  (
                    INVENTORY_TRANSACTION_SEQ.NEXTVAL,
                    V_INVOICE_DATE,
                    V_INVOICE_NUM,
                    sysdate,
                    1,
                    V_DEALER_ID,
                    V_SERIAL_ID,
                    V_SELLER_ID,
                    10,
                    V_DEALER_ID,
                    V_TRANSACTION_ORDER,
                    'ACTIVE',
                    SYSDATE,
                    EACH_REC.BUSINESS_UNIT_INFO
                    || '-Upload',
                    1,
                    SYSDATE,
                    V_LAST_UPDATED_BY,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                  );
              END IF;
              V_SELLER_ID := V_DEALER_ID;
              V_BUYER_ID  := V_END_CUST_ID;
              IF upper
                (
                  V_ADMIN_APPRV_IND
                )
                = 'FALSE' THEN
                SELECT INVENTORY_TRANSACTION_SEQ.NEXTVAL INTO V_TRANS_ID FROM DUAL;
                V_TRANSACTION_ORDER := V_TRANSACTION_ORDER + 1;
                INSERT
                INTO INVENTORY_TRANSACTION
                  (
                    ID,
                    INVOICE_DATE,
                    INVOICE_NUMBER,
                    TRANSACTION_DATE,
                    VERSION,
                    BUYER,
                    TRANSACTED_ITEM,
                    SELLER,
                    INV_TRANSACTION_TYPE,
                    OWNER_SHIP,
                    TRANSACTION_ORDER,
                    STATUS,
                    D_CREATED_ON,
                    D_INTERNAL_COMMENTS,
                    D_ACTIVE,
                    D_UPDATED_ON,
                    D_LAST_UPDATED_BY,
                    D_CREATED_TIME,
                    D_UPDATED_TIME
                  )
                  VALUES
                  (
                    V_TRANS_ID,
                    V_INVOICE_DATE,
                    V_INVOICE_NUM,
                    sysdate,
                    1,
                    V_BUYER_ID,
                    V_SERIAL_ID,
                    V_SELLER_ID,
                    V_TRANS_TYPE,
                    V_SELLER_ID,
                    V_TRANSACTION_ORDER,
                    'ACTIVE',
                    SYSDATE,
                    EACH_REC.BUSINESS_UNIT_INFO
                    || '-Upload',
                    1,
                    SYSDATE,
                    V_LAST_UPDATED_BY,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                  );
              END IF;
              SELECT ADDRESS INTO V_CUST_ADD_ID FROM PARTY WHERE ID = V_BUYER_ID;
              SELECT ADDRESSFORTRANS_SEQ.NEXTVAL INTO V_ADDRESS_TRANS_ID FROM DUAL;
              INSERT
              INTO ADDRESS_FOR_TRANSFER
                (SELECT V_ADDRESS_TRANS_ID,
                    ADDRESS_LINE1,
                    CITY,
                    CONTACT_PERSON_NAME,
                    COUNTRY,
                    EMAIL,
                    PHONE,
                    SECONDARY_PHONE,
                    STATE,
                    'BILLING',
                    0,
                    ZIP_CODE,
                    SYSDATE,
                    EACH_REC.BUSINESS_UNIT_INFO
                    || '-Upload',
                    SYSDATE,
                    V_LAST_UPDATED_BY,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP,
                    1,
                    ADDRESS_LINE2,
                    ADDRESS_LINE3,
					COUNTY,
					SUB_COUNTY,
					FAX
                  FROM ADDRESS
                  WHERE ID = V_CUST_ADD_ID
                );
              IF V_OPERATOR_ID IS NOT NULL THEN
                SELECT ADDRESS INTO V_OPR_ADDR_ID FROM PARTY WHERE ID = V_OPERATOR_ID;
                SELECT ADDRESSFORTRANS_SEQ.NEXTVAL INTO V_OPR_ADDR_TRANS_ID FROM DUAL;
                INSERT
                INTO ADDRESS_FOR_TRANSFER
                  (SELECT V_OPR_ADDR_TRANS_ID,
                      ADDRESS_LINE1,
                      CITY,
                      CONTACT_PERSON_NAME,
                      COUNTRY,
                      EMAIL,
                      PHONE,
                      SECONDARY_PHONE,
                      STATE,
                      'SHIPPING',
                      0,
                      ZIP_CODE,
                      SYSDATE,
                      EACH_REC.BUSINESS_UNIT_INFO
                      || '-Upload',
                      SYSDATE,
                      V_LAST_UPDATED_BY,
                      CURRENT_TIMESTAMP,
                      CURRENT_TIMESTAMP,
                      1,
                      ADDRESS_LINE2,
                      ADDRESS_LINE3,
					  COUNTY,
					  SUB_COUNTY,
					  FAX
                    FROM ADDRESS
                    WHERE ID = V_OPR_ADDR_ID
                  );
              END IF;
              SELECT WARRANTY_TASK_INSTANCE_SEQ.NEXTVAL
              INTO V_WARANTY_TASK_INSTANCE_ID
              FROM DUAL;
              SELECT WARRANTY_MULTIDRETR_NUMBER_SEQ.NEXTVAL
              INTO V_MULTIDRETRNUMBER
              FROM DUAL;
              BEGIN
                SELECT NVL(MAX(LIST_INDEX), -1) + 1
                INTO V_MAX_LIST_INDEX
                FROM warranty
                WHERE for_item = V_SERIAL_ID;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_MAX_LIST_INDEX := 0;
              END;
              SELECT WARRANTY_SEQ.NEXTVAL INTO V_WARRANTY_ID FROM DUAL;
			  IF  V_INSTALL_DEALER_ID = 0 THEN
                  V_INSTALL_DEALER_ID := NULL;
              END IF;
              INSERT
              INTO WARRANTY
                (
                  ID,
                  DELIVERY_DATE,
                  DRAFT,
                  VERSION,
                  MARKETING_INFORMATION,
                  FOR_TRANSACTION,
                  CUSTOMER,
                  FOR_ITEM,
                  LIST_INDEX,
                  STATUS,
                  FOR_DEALER,
                  ADDRESS_FOR_TRANSFER,
                  TRANSACTION_TYPE,
                  MULTIDRETRNUMBER,
                  CUSTOMER_TYPE,
                  OPERATOR,
                  INSTALLING_DEALER,
                  OEM,
                  EQUIPMENT_VIN,
                  INSTALLATION_DATE,
                  D_CREATED_ON,
                  D_INTERNAL_COMMENTS,
                  D_ACTIVE,
                  D_UPDATED_ON,
                  D_LAST_UPDATED_BY,
                  D_CREATED_TIME,
                  D_UPDATED_TIME,
                  FLEET_NUMBER,
                  FILED_BY,
                  OPERATOR_ADDRESS_FOR_TRANSFER
                )
                VALUES
                (
                  V_WARRANTY_ID,
                  TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'),
                  0,
                  1,
                  V_MARK_INFO_ID,
                  V_TRANS_ID,
                  V_BUYER_ID,
                  V_SERIAL_ID,
                  V_MAX_LIST_INDEX,
                  V_WARRANTY_STATUS,
                  V_SELLER_ID,
                  V_ADDRESS_TRANS_ID,
                  V_TRANS_TYPE,
                  V_MULTIDRETRNUMBER,
                  EACH_REC.CUSTOMER_TYPE,
                  V_OPERATOR_ID,
                  V_INSTALL_DEALER_ID,
                  V_OEM_ID,
                  EACH_REC.EQUIPMENT_VIN_ID,
                  TO_DATE(EACH_REC.DATE_OF_INSTALLATION,'YYYYMMDD'),
                  SYSDATE,
                  EACH_REC.BUSINESS_UNIT_INFO
                  || '-Upload',
                  1,
                  SYSDATE,
                  V_LAST_UPDATED_BY,
                  CURRENT_TIMESTAMP,
                  CURRENT_TIMESTAMP,
                  EACH_REC.TRUCK_NUMBER,
                  V_LAST_UPDATED_BY,
                  V_OPR_ADDR_TRANS_ID
                );
              SELECT WARRANTY_AUDIT_SEQ.NEXTVAL INTO V_WARRANTY_AUDIT_ID FROM DUAL;
              INSERT
              INTO WARRANTY_AUDIT
                (
                  ID,
                  FOR_WARRANTY,
                  STATUS,
                  LIST_INDEX,
                  VERSION,
                  D_CREATED_ON,
                  D_INTERNAL_COMMENTS,
                  D_ACTIVE,
                  D_UPDATED_ON,
                  D_LAST_UPDATED_BY,
                  D_CREATED_TIME,
                  D_UPDATED_TIME
                )
                VALUES
                (
                  V_WARRANTY_AUDIT_ID,
                  V_WARRANTY_ID,
                  V_WARRANTY_STATUS,
                  0,
                  1,
                  SYSDATE,
                  EACH_REC.BUSINESS_UNIT_INFO
                  || '-Upload',
                  1,
                  SYSDATE,
                  V_LAST_UPDATED_BY,
                  CURRENT_TIMESTAMP,
                  CURRENT_TIMESTAMP
                );
              INSERT
              INTO WARRANTY_TASK_INSTANCE
                (
                  ID,
                  ACTIVE,
                  STATUS,
                  VERSION,
                  ASSIGNED_TO,
                  WARRANTY_AUDIT,
                  MULTIDRETRNUMBER,
                  BUSINESS_UNIT_INFO,
                  D_CREATED_ON,
                  D_INTERNAL_COMMENTS,
                  D_ACTIVE,
                  D_UPDATED_ON,
                  D_LAST_UPDATED_BY,
                  D_CREATED_TIME,
                  D_UPDATED_TIME
                )
                VALUES
                (
                  V_WARANTY_TASK_INSTANCE_ID,
                  1,
                  V_WARRANTY_STATUS,
                  1,
                  V_ASSIGNED_TO,
                  V_WARRANTY_AUDIT_ID,
                  V_MULTIDRETRNUMBER,
                  EACH_REC.BUSINESS_UNIT_INFO,
                  SYSDATE,
                  EACH_REC.BUSINESS_UNIT_INFO
                  || '-Upload',
                  1,
                  SYSDATE,
                  V_LAST_UPDATED_BY,
                  CURRENT_TIMESTAMP,
                  CURRENT_TIMESTAMP
                );
              INSERT
              INTO WARRANTY_TASK_INCLUDED_ITEMS
                (
                  WARRANTY_TASK,
                  INV_ITEM
                )
                VALUES
                (
                  V_WARANTY_TASK_INSTANCE_ID,
                  V_SERIAL_ID
                );
			  IF EACH_REC.INSTALLING_DEALER_NUMBER IS NOT NULL THEN 
              SELECT DECODE(SP.CERTIFIED, 0, 'N', 1, 'Y')
              INTO V_CERT_STATUS
              FROM SERVICE_PROVIDER SP,
                BU_ORG_MAPPING BOM
              WHERE SP.SERVICE_PROVIDER_NUMBER = EACH_REC.INSTALLING_DEALER_NUMBER
              AND SP.ID                        = BOM.ORG
              AND BOM.BU                       = EACH_REC.BUSINESS_UNIT_INFO;
			  END IF;
              OPEN ALL_ELIGIBLE_POLICY_PLANS(V_PRODUCT, V_MODEL, EACH_REC.BUSINESS_UNIT_INFO, TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'), TO_NUMBER(V_HOURS_ON_SERV), V_CONDITION, V_CERT_STATUS, V_INSTALL_DEALER_ID);
              FETCH ALL_ELIGIBLE_POLICY_PLANS INTO V_CUR_RECORD;
              CLOSE ALL_ELIGIBLE_POLICY_PLANS;
              FOR EACH_PLAN IN ALL_ELIGIBLE_POLICY_PLANS(V_PRODUCT, V_MODEL, EACH_REC.BUSINESS_UNIT_INFO, TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'), TO_NUMBER(V_HOURS_ON_SERV), V_CONDITION, V_CERT_STATUS, V_INSTALL_DEALER_ID)
              LOOP
                UPLOAD_WARRANTY_COVERAGE(EACH_PLAN.ID, V_WARRANTY_ID, V_SERIAL_ID, V_SHIP_DATE, TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'), EACH_REC.BUSINESS_UNIT_INFO, V_LAST_UPDATED_BY, NULL, 0, V_IS_RED_CVG);
                IF V_IS_RED_CVG  = 'TRUE' THEN
                  V_IS_REQ_EXTN := 'TRUE';
                END IF;
              END LOOP;
              IF EACH_REC.ADDITIONAL_APPLICABLE_POLICIES IS NOT NULL THEN
                BEGIN
                  COMMON_UTILS.ParseAnySeperatorList(EACH_REC.ADDITIONAL_APPLICABLE_POLICIES,'#$#',V_POL_ARRAY ,V_POL_COUNT);
                  FOR I IN 1..V_POL_COUNT
                  LOOP
                    SELECT ID
                    INTO V_POLICY_DEFN_ID
                    FROM POLICY_DEFINITION
                    WHERE UPPER(CODE)      = UPPER(V_POL_ARRAY(I))
                    AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
                    AND CURRENTLY_INACTIVE = 0
                    AND TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD') BETWEEN ACTIVE_FROM AND ACTIVE_TILL;
                    UPLOAD_WARRANTY_COVERAGE(V_POLICY_DEFN_ID, V_WARRANTY_ID, V_SERIAL_ID, V_SHIP_DATE, TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'), EACH_REC.BUSINESS_UNIT_INFO, V_LAST_UPDATED_BY, NULL, 0, V_IS_RED_CVG);
                    IF V_IS_RED_CVG  = 'TRUE' THEN
                      V_IS_REQ_EXTN := 'TRUE';
                    END IF;
                  END LOOP;
                END;
              END IF;
              FOR EACH_EXTND_POLICY IN ALL_EXTENDED_POLICIES(EACH_REC.BUSINESS_UNIT_INFO, V_SERIAL_ID)
              LOOP
                UPLOAD_WARRANTY_COVERAGE(EACH_EXTND_POLICY.POLICY, V_WARRANTY_ID, V_SERIAL_ID, V_SHIP_DATE, TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'), EACH_REC.BUSINESS_UNIT_INFO, V_LAST_UPDATED_BY, NULL, 0, V_IS_RED_CVG);
                IF V_IS_RED_CVG  = 'TRUE' THEN
                  V_IS_REQ_EXTN := 'TRUE';
                END IF;
              END LOOP;
              IF upper ( V_ADMIN_APPRV_IND ) = 'FALSE' THEN
                IF V_IS_REQ_EXTN             = 'TRUE' THEN
                  BEGIN
                    SELECT REQUEST_WNTY_CVG_SEQ.NEXTVAL INTO V_WNTY_EXTN_REQ_ID FROM dual;
                    INSERT
                    INTO request_wnty_cvg
                      (
                        ID,
                        INVENTORY_ITEM,
                        STATUS,
                        D_ACTIVE,
                        BUSINESS_UNIT_INFO,
                        ORDER_NUMBER,
                        D_INTERNAL_COMMENTS,
                        REQUESTED_BY,
                        UPDATED_ON_DATE
                      )
                      VALUES
                      (
                        V_WNTY_EXTN_REQ_ID,
                        V_SERIAL_ID,
                        DECODE(NVL(UPPER(EACH_REC.REQUEST_FOR_EXTENSION), 'NO'), 'YES','SUBMITTED', 'NO', 'EXTENSION_NOT_REQUESTED'),
                        1,
                        EACH_REC.BUSINESS_UNIT_INFO,
                        NULL,
                        'Uploaded',
                        V_SELLER_ID,
                        sysdate
                      );
                    INSERT
                    INTO request_wnty_cvg_audit
                      (
                        ID,
                        REQUEST_WNTY_CVG,
                        COMMENTS,
                        STATUS,
                        ASSIGNED_TO,
                        ASSIGNED_BY,
                        D_CREATED_ON,
                        D_UPDATED_ON,
                        D_CREATED_TIME,
                        D_UPDATED_TIME,
                        D_INTERNAL_COMMENTS,
                        D_LAST_UPDATED_BY,
                        D_ACTIVE
                      )
                      VALUES
                      (
                        REQUEST_WNTY_CVG_AUDIT_SEQ.nextval,
                        V_WNTY_EXTN_REQ_ID,
                        'INITIAL',
                        'WAITING_FOR_YOUR_RESPONSE',
                        V_LAST_UPDATED_BY,
                        NULL,
                        sysdate,
                        sysdate,
                        CURRENT_TIMESTAMP,
                        CURRENT_TIMESTAMP,
                        'Uploaded',
                        V_LAST_UPDATED_BY,
                        1
                      );
                    INSERT
                    INTO request_wnty_cvg_audit
                      (
                        ID,
                        REQUEST_WNTY_CVG,
                        COMMENTS,
                        STATUS,
                        ASSIGNED_TO,
                        ASSIGNED_BY,
                        D_CREATED_ON,
                        D_UPDATED_ON,
                        D_CREATED_TIME,
                        D_UPDATED_TIME,
                        D_INTERNAL_COMMENTS,
                        D_LAST_UPDATED_BY,
                        D_ACTIVE
                      )
                      VALUES
                      (
                        REQUEST_WNTY_CVG_AUDIT_SEQ.nextval,
                        V_WNTY_EXTN_REQ_ID,
                        'Uploaded',
                        DECODE(NVL(UPPER(EACH_REC.REQUEST_FOR_EXTENSION), 'NO'), 'YES','SUBMITTED', 'NO', 'EXTENSION_NOT_REQUESTED'),
                        NULL,
                        V_LAST_UPDATED_BY,
                        sysdate,
                        sysdate,
                        CURRENT_TIMESTAMP,
                        CURRENT_TIMESTAMP,
                        'Uploaded',
                        V_LAST_UPDATED_BY,
                        1
                      );
                  END;
                END IF;
                UPDATE INVENTORY_ITEM
                SET DELIVERY_DATE   = TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'),
                  CURRENT_OWNER     = V_SELLER_ID,
                  TYPE              = 'RETAIL',
                  VIN_NUMBER        = EACH_REC.EQUIPMENT_VIN_ID,
                  OEM               = V_OEM_ID,
                  INSTALLATION_DATE = TO_DATE(EACH_REC.DATE_OF_INSTALLATION,'YYYYMMDD'),
                  FLEET_NUMBER      = EACH_REC.TRUCK_NUMBER,
                  PENDING_WARRANTY  = 0,
                  REGISTRATION_DATE = sysdate,
                  LATEST_BUYER      = V_BUYER_ID,
                  INSTALLING_DEALER = V_INSTALL_DEALER_ID,
                  OPERATOR          = V_OPERATOR_ID,
                  HOURS_ON_MACHINE  = V_HOURS_ON_SERV,
                  WNTY_START_DATE   = TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'),
                  WNTY_END_DATE     =
                  (SELECT MAX(PA.TILL_DATE)
                  FROM POLICY_AUDIT PA,
                    POLICY P
                  WHERE P.WARRANTY = V_WARRANTY_ID
                  AND P.ID         = PA.FOR_POLICY
                  ),
                  D_INTERNAL_COMMENTS = D_INTERNAL_COMMENTS
                  || '-Upload',
                  D_UPDATED_ON      = sysdate,
                  D_LAST_UPDATED_BY = V_LAST_UPDATED_BY ,
                  D_UPDATED_TIME    = sysdate,
                  version           = version + 1
                WHERE ID            = V_SERIAL_ID;
              ELSE
                UPDATE INVENTORY_ITEM
                SET PENDING_WARRANTY  = 1,
                DELIVERY_DATE   = TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'),
                LATEST_WARRANTY = V_WARRANTY_ID,
                WNTY_START_DATE   = TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'),
                WNTY_END_DATE     = TO_DATE(EACH_REC.DELIVERY_DATE,'YYYYMMDD'),
                HOURS_ON_MACHINE  = V_HOURS_ON_SERV,
                  D_INTERNAL_COMMENTS = D_INTERNAL_COMMENTS
                  || '-Upload',
                  D_UPDATED_ON      = sysdate,
                  D_LAST_UPDATED_BY = V_LAST_UPDATED_BY,
                  D_UPDATED_TIME    = sysdate,
                  version           = version + 1
                WHERE ID            = V_SERIAL_ID;
              END IF ;
              UPDATE STG_WARRANTY_REGISTRATIONS
              SET UPLOAD_STATUS = 'Y',
                UPLOAD_ERROR    = NULL,
                UPLOAD_DATE     = SYSDATE
              WHERE ID          = EACH_REC.ID;
              COMMIT;

            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            V_UPLOAD_ERROR := SUBSTR(SQLERRM, 1, 3500);
            UPDATE STG_WARRANTY_REGISTRATIONS
            SET UPLOAD_STATUS = 'N',
              UPLOAD_ERROR    = V_UPLOAD_ERROR,
              UPLOAD_DATE     = SYSDATE
            WHERE ID          = EACH_REC.ID;
            COMMIT;
            END;
        END IF;
      END;
    END LOOP;
  END UPLOAD_WARRANTY_REG_UPLOAD;
/