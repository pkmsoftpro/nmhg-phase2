--Purpose    : Changes Made for validation
--Author     : Bharath kumar
--Created On : 2-8-2010


create or replace
PROCEDURE                 "UPLOAD_DRAFT_CLAIM_VALIDATION" AS
CURSOR ALL_REC IS
	SELECT * FROM STG_DRAFT_CLAIM
	WHERE NVL(ERROR_STATUS,'N') = 'N' -- AND
		 -- UPLOAD_STATUS IS NULL
		 ORDER BY ID ASC;

    v_loop_count            NUMBER         := 0;
    v_success_count         NUMBER         := 0;
    v_error_count           NUMBER         := 0;
    v_count                 NUMBER         := 0;
    v_count2                NUMBER         := 0;
    v_file_upload_mgt_id    NUMBER         := 0;
    v_number_temp           NUMBER         := 0;
    isFaultFoundValid       BOOLEAN        := FALSE;
    v_error                 VARCHAR2(4000) := NULL;
    v_error_code            VARCHAR2(4000) := NULL;
    v_model                 NUMBER := NULL;
    v_product               NUMBER := NULL;
    v_machine_serial_number VARCHAR2(4000) := NULL;
    v_replaced_part      NUMBER := NULL;
    v_flag                  BOOLEAN := FALSE;
    v_valid_bu              BOOLEAN;
    v_valid_repair_date     BOOLEAN := FALSE;
    v_valid_failure_date    BOOLEAN := FALSE;
    v_valid_fault_found     BOOLEAN := FALSE;
    v_valid_campaign_code   BOOLEAN := FALSE;
    v_user_locale           VARCHAR2(255) := NULL;
    v_dealer                VARCHAR2(255) := NULL;
    v_dealer_id             NUMBER := NULL;
    v_bu_name               VARCHAR2(255) := NULL;
    v_smr_reason_id         VARCHAR2(255) := NULL;
    v_service_provider      NUMBER := NULL;
    v_delimiter             VARCHAR2(10) := '#$#';
    v_fault_code            VARCHAR2(255);
    v_job_code              VARCHAR2(255);
    v_fault_found           VARCHAR2(255);    
    v_item_number           VARCHAR2(255) := NULL;   
    v_competitor_model_id   NUMBER := NULL;
    v_ac_input      		    NUMBER         := 0;
    v_id                    NUMBER := NULL;    
BEGIN

    --Fetch the LoginId, Locale & BU of the user who had uploaded the claims
    BEGIN
        SELECT u.locale, u.login, f.business_unit_info, u.belongs_to_organization  INTO v_user_locale, v_dealer, v_bu_name, v_dealer_id
        FROM org_user u,file_upload_mgt f
        WHERE u.id = f.uploaded_by AND f.id = 
            (SELECT file_upload_mgt_id FROM stg_draft_claim WHERE rownum = 1);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            v_user_locale := 'en_US';
    END;

    --Fetch the Service Provider of the user who had uploaded the claims
    BEGIN
        SELECT p.id INTO v_service_provider
        FROM party p, service_provider sp, org_user_belongs_to_orgs orgs, org_user u
        WHERE p.id=sp.id AND 
            sp.id= orgs.belongs_to_organizations AND
            orgs.org_user = u.id AND u.login = v_dealer AND
            ROWNUM = 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

  FOR EACH_REC IN ALL_REC
  LOOP

    v_error_code := '';
    v_model := NULL;
    v_product := NULL;
    v_valid_bu := FALSE;
    v_valid_repair_date := FALSE;
    v_valid_failure_date := FALSE;
    v_valid_fault_found := FALSE;
    v_valid_campaign_code := FALSE;
    v_smr_reason_id := NULL;
    v_fault_code := NULL;
    v_job_code := NULL;
    v_fault_found := NULL;

	-- ERROR CODE: DC0001_BU
	-- VALIDATE THAT BUSINESS UNIT NAME IS NOT NULL AND BUSINESS UNIT NAME IS AN ALLOWED ONE IN TWMS
    BEGIN
        IF v_bu_name IS NULL OR lower(v_bu_name) != lower(each_rec.business_unit_name) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC001');
        ELSIF NOT (COMMON_VALIDATION_UTILS.isUserBelongsToBU(v_bu_name,v_dealer)) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC044');
        ELSE
            v_valid_bu := TRUE;
        END IF;
	END;

	-- ERROR CODE: DC0002_UI
	-- VALIDATE THAT UNIQUE IDENTIFIER IS NULL
	-- REASON FOR ERROR: UNIQUE IDENTIFIER IS NULL
	BEGIN
		 IF EACH_REC.UNIQUE_IDENTIFIER IS NULL
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC002');
		 END IF;
	END;

	-- VALIDATE THAT CLAIM TYPE IS NOT NULL AND AN ACCEPTED VALUE
	BEGIN
        IF each_rec.claim_type IS NULL OR UPPER(each_rec.claim_type) NOT IN 
            ('MACHINE SERIALIZED', 'MACHINE NON SERIALIZED', 'PARTS WITH HOST', 
            'PARTS WITHOUT HOST', 'FIELDMODIFICATION')
        THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC003');
        ELSIF v_valid_bu = TRUE AND NOT common_validation_utils.isClaimTypeAllowed(each_rec.claim_type, v_bu_name) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC066');
        END IF;
	END;

    -- VALIDATE CAMPAIGN CODE
    IF UPPER(each_rec.claim_type) IN ('FIELDMODIFICATION') THEN
        IF each_rec.campaign_code IS NULL THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC026');
        ELSIF NOT common_validation_utils.isValidCampaignCode(each_rec.campaign_code, v_service_provider, v_bu_name) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC065');
        ELSE
            v_valid_campaign_code := TRUE;
        END IF;
    END IF;

    -- ERROR CODE: DC0004_SN/ DC0005_SN
    -- VALIDATE THAT SERIAL NUMBER IS NOT NULL/ VALIDATE THAT SERIAL NUMBER IS NOT NULL AND A VALID INVENTORY
    -- REASON FOR ERROR: CLAIM TYPE IS NULL/ CLAIM TYPE IS NOT NULL AND NOT A VALID INVENTORY
    BEGIN
    IF UPPER(EACH_REC.CLAIM_TYPE) IN ('MACHINE SERIALIZED', 'FIELDMODIFICATION') OR (UPPER(EACH_REC.CLAIM_TYPE) IN ('PARTS WITH HOST') AND (EACH_REC.IS_SERIALIZED IS NULL OR UPPER(EACH_REC.IS_SERIALIZED) ='Y') ) THEN
        IF EACH_REC.SERIAL_NUMBER IS NULL THEN

			  IF EACH_REC.CONTAINER_NUMBER IS NULL THEN

              IF EACH_REC.IS_PART_INSTALLED IS NOT NULL AND EACH_REC.IS_PART_INSTALLED IN ('Y') AND (EACH_REC.IS_PART_INSTALLED_ON_TKTSA IS NULL OR EACH_REC.IS_PART_INSTALLED_ON_TKTSA IN ('N'))
              THEN      
                  v_competitor_model_id := common_validation_utils.getValidCompetitorModelId(EACH_REC.COMPETITOR_MODEL, v_user_locale, v_bu_name);
                  IF v_competitor_model_id IS NULL THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC071_CM');
                END IF;                      

               ELSE
               v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC004_CON'); 
               END IF; 
			  ELSIF NOT (COMMON_VALIDATION_UTILS.isValidInventoryWithConNum(EACH_REC.CONTAINER_NUMBER, v_bu_name)) THEN
					v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC005_CON');
				ELSIF UPPER(each_rec.claim_type) = 'FIELDMODIFICATION' AND v_valid_campaign_code = TRUE AND NOT
						common_validation_utils.isValidInventoryForFieldModWCN(each_rec.CONTAINER_NUMBER,each_rec.campaign_code,v_service_provider,v_bu_name) THEN
					v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC064_CON');
				ELSE
					SELECT COUNT(1) INTO v_count FROM inventory_item 
					WHERE business_unit_info = v_bu_name
					AND lower(VIN_NUMBER) = lower(each_rec.CONTAINER_NUMBER);

					IF v_count = 1 THEN
						SELECT model.id INTO v_model
						FROM ITEM_GROUP model, INVENTORY_ITEM ii, ITEM i
						WHERE ii.of_type = i.id AND I.model = MODEL.ID AND 
						lower(ii.VIN_NUMBER) = lower(trim(EACH_REC.CONTAINER_NUMBER)) AND 
						lower(ii.business_unit_info) = lower(trim(v_bu_name)) AND ROWNUM = 1; 

						SELECT product.id into v_product
						FROM ITEM_GROUP product, INVENTORY_ITEM ii, ITEM i
						WHERE ii.of_type = i.id AND I.product = product.ID AND 
						lower(ii.VIN_NUMBER) = lower(trim(EACH_REC.CONTAINER_NUMBER)) AND 
						lower(ii.business_unit_info) = lower(trim(v_bu_name)) AND ROWNUM = 1; 

					ELSIF v_count > 1 THEN
						IF EACH_REC.MODEL_NUMBER IS NULL THEN
							v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC006');
						ELSIF NOT (COMMON_VALIDATION_UTILS.isValidModel(EACH_REC.MODEL_NUMBER, v_bu_name)) THEN
							v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC007');
						ELSE
							SELECT m.id INTO v_model
							FROM inventory_item inv, item i, item_group m
							WHERE LOWER(inv.VIN_NUMBER) = LOWER(each_rec.CONTAINER_NUMBER)
							AND inv.of_type = i.id
							AND inv.business_unit_info = v_bu_name
							AND i.model = m.id AND m.item_group_type = 'MODEL'
							AND LOWER(m.name) = LOWER(each_rec.model_number)
							AND inv.d_active=1 AND i.d_active = 1 AND m.d_active = 1;

              SELECT m.id INTO v_product
							FROM inventory_item inv, item i, item_group m
							WHERE LOWER(inv.VIN_NUMBER) = LOWER(each_rec.CONTAINER_NUMBER)
							AND inv.of_type = i.id
							AND inv.business_unit_info = v_bu_name
							AND i.product = m.id AND m.item_group_type = 'PRODUCT'
							AND LOWER(m.name) = LOWER(each_rec.model_number)
							AND inv.d_active=1 AND i.d_active = 1 AND m.d_active = 1;

						END IF;
					END IF;
        END IF;


        ELSIF NOT (COMMON_VALIDATION_UTILS.isValidInventory(EACH_REC.SERIAL_NUMBER, v_bu_name)) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC005');
        ELSIF UPPER(each_rec.claim_type) = 'FIELDMODIFICATION' AND v_valid_campaign_code = TRUE AND NOT
                common_validation_utils.isValidInventoryForFieldMod(each_rec.serial_number,each_rec.campaign_code,v_service_provider,v_bu_name) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC064');
        ELSE
            SELECT COUNT(1) INTO v_count FROM inventory_item 
            WHERE business_unit_info = v_bu_name
            AND lower(serial_number) = lower(each_rec.serial_number);

            IF v_count = 1 THEN
                SELECT model.id INTO v_model
                FROM ITEM_GROUP model, INVENTORY_ITEM ii, ITEM i
                WHERE ii.of_type = i.id AND I.model = MODEL.ID AND 
                lower(ii.serial_number) = lower(trim(EACH_REC.SERIAL_NUMBER)) AND 
                lower(ii.business_unit_info) = lower(trim(v_bu_name)) AND ROWNUM = 1; 

                SELECT product.id into v_product
                FROM ITEM_GROUP product, INVENTORY_ITEM ii, ITEM i
                WHERE ii.of_type = i.id AND I.product = product.ID AND 
                lower(ii.serial_number) = lower(trim(EACH_REC.SERIAL_NUMBER)) AND 
                lower(ii.business_unit_info) = lower(trim(v_bu_name)) AND ROWNUM = 1; 

            ELSIF v_count > 1 THEN
                IF EACH_REC.MODEL_NUMBER IS NULL THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC006');
                ELSIF NOT (COMMON_VALIDATION_UTILS.isValidModel(EACH_REC.MODEL_NUMBER, v_bu_name)) THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC007');
                ELSE
                    SELECT m.id INTO v_model
                    FROM inventory_item inv, item i, item_group m
                    WHERE LOWER(inv.serial_number) = LOWER(each_rec.serial_number)
                    AND inv.of_type = i.id
                    AND inv.business_unit_info = v_bu_name
                    AND i.model = m.id AND m.item_group_type = 'MODEL'
                    AND LOWER(m.name) = LOWER(each_rec.model_number)
                    AND inv.d_active=1 AND i.d_active = 1 AND m.d_active = 1;

                    SELECT m.id INTO v_product
                    FROM inventory_item inv, item i, item_group m
                    WHERE LOWER(inv.VIN_NUMBER) = LOWER(each_rec.CONTAINER_NUMBER)
                    AND inv.of_type = i.id
                    AND inv.business_unit_info = v_bu_name
                    AND i.product = m.id AND m.item_group_type = 'PRODUCT'
                    AND LOWER(m.name) = LOWER(each_rec.model_number)
                    AND inv.d_active=1 AND i.d_active = 1 AND m.d_active = 1;
                END IF;
            END IF;
        END IF;
    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC008');
    END;





    -- ERROR CODE: DC0007_PN
    -- VALIDATE THAT PART ITEM NUMBER IS NOT NULL AND PART ITEM NUMBER IS A VALID ITEM
    -- REASON FOR ERROR: PART ITEM NUMBER IS NULL OR PART ITEM NUMBER IS NOT A VALID ITEM
    BEGIN
    IF UPPER(EACH_REC.CLAIM_TYPE) IN ('PARTS WITH HOST', 'PARTS WITHOUT HOST')  THEN
        IF EACH_REC.PART_ITEM_NUMBER IS NULL THEN
           -- v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC014');
           
            IF EACH_REC.PART_SERIAL_NUMBER IS NULL THEN
                 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC072_PS');
            ELSIF NOT (COMMON_VALIDATION_UTILS.isValidPartSerialNumber(EACH_REC.PART_SERIAL_NUMBER, v_bu_name)) THEN
                 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC073_PS');
            ELSE
                 SELECT model.id,i.item_number into v_model, v_item_number
                    FROM ITEM_GROUP model, inventory_ITEM inv,item i
                    WHERE inv.of_type = i.id AND 
                    i.model = model.id AND
                    lower(inv.serial_number) = lower(trim(EACH_REC.PART_SERIAL_NUMBER))AND 
                    lower(inv.business_unit_info) = lower(trim(v_bu_name)) AND inv.d_active = 1 AND ROWNUM = 1;

                  BEGIN 

                    --populating machine serial number.
                    select serial_number into v_machine_serial_number from inventory_item where id in ( select part_of from inventory_item_composition  where part in (select id from inventory_item  inv 
                    where lower(inv.serial_number) = lower(trim(EACH_REC.PART_SERIAL_NUMBER))AND 
                    lower(inv.business_unit_info) = lower(trim(v_bu_name)) AND inv.d_active = 1));
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;   
                    END;

                              IF EACH_REC.Is_Part_Installed IN ('Y') THEN
                                 IF v_machine_serial_number IS NOT null THEN
                                         IF EACH_REC.Is_Part_Installed_on_TKTSA IN ('Y') THEN
                                            IF EACH_REC.SERIAL_NUMBER IS NOT null AND lower(v_machine_serial_number) != lower(trim(EACH_REC.SERIAL_NUMBER)) THEN
                                               v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_90');
                                            END IF; 
                                            IF  EACH_REC.Model_Number IS NOT null THEN
                                                 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_91');
                                            ELSIF  EACH_REC.Competitor_Model IS NOT null THEN
                                                 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_92');     
                                            END IF;     
                                         END IF;

                                 ELSE
                                       IF EACH_REC.SERIAL_NUMBER IS NOT null THEN 
                                             v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_93');                                          
  
                                      END IF;

                                 END IF;
                              END IF;
            END IF; 
        ELSIF NOT (COMMON_VALIDATION_UTILS.isValidItemNumber(EACH_REC.PART_ITEM_NUMBER, v_bu_name)) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC015');
        ELSE
            SELECT model.id 
            INTO v_model
            FROM ITEM_GROUP model, ITEM i
            WHERE i.model = model.id AND 
            (lower(i.item_number) = lower(trim(EACH_REC.PART_ITEM_NUMBER)) OR 
            lower(i.alternate_item_number) = lower(trim(EACH_REC.PART_ITEM_NUMBER))) AND 
            lower(i.business_unit_info) = lower(trim(v_bu_name)) AND i.d_active = 1 AND ROWNUM = 1;

        END IF;
    END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC015');

    END;


     -- ERROR CODE: DC067_IAC
    -- VALIDATE THAT ALARM CODE IS NOT INVALID 
    -- REASON FOR ERROR: ALARM CODE IS INVALID 
     BEGIN
       IF EACH_REC.ALARM_CODES IS NOT NULL THEN          
            v_ac_input := Common_Utils.count_delimited_values(each_rec.ALARM_CODES, ',');
            FOR i IN 1 .. v_ac_input LOOP

                IF  v_product IS NOT NULL THEN       
                      IF NOT common_validation_utils.isValidAlarmCode(
                              common_utils.get_delimited_value(each_rec.ALARM_CODES, ',', i),v_product, v_bu_name)
                      THEN
                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC067_IAC');
                          EXIT;
                      END IF;
                ELSE 
                     select alarm_code.id into v_id from alarm_code where  lower(trim(code)) = lower(trim(common_utils.get_delimited_value(each_rec.ALARM_CODES, ',', i)));

                END IF;
            END LOOP;
        END IF; 
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC067_IAC');
     END;

	-- ERROR CODE: DC0008_HS
	-- VALIDATE THAT HOURS IN SERVICE IS NOT NULL
	-- REASON FOR ERROR: HOURS IN SERVICE IS NULL OR NOT IN RANGE OF 0-999999
  IF UPPER(EACH_REC.CLAIM_TYPE) IN ('MACHINE SERIALIZED', 'PARTS WITH HOST', 'FIELDMODIFICATION')
  THEN
    IF EACH_REC.HOURS_IN_SERVICE IS NULL
    THEN
      v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC016');
    END IF;

    IF EACH_REC.HOURS_IN_SERVICE IS NOT NULL AND (EACH_REC.HOURS_IN_SERVICE < 0 OR EACH_REC.HOURS_IN_SERVICE > 999999)
    THEN
      v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC017');
    END IF;
  END IF;

	-- ERROR CODE: DC0009_RD
	-- VALIDATE THAT REPAIR DATE IS NOT NULL AND VALID DATE
	-- REASON FOR ERROR: REPAIR DATE IS NULL OR NOT A VALID DATE
  IF EACH_REC.REPAIR_DATE IS NULL OR NOT (COMMON_VALIDATION_UTILS.isValidDate(EACH_REC.REPAIR_DATE, 'YYYYMMDD'))
  THEN
    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC018');
  ELSE
    v_valid_repair_date := TRUE;
  END IF;

	-- ERROR CODE: DC0010_FD
	-- VALIDATE THAT FAILURE DATE IS NOT NULL AND VALID DATE
	-- REASON FOR ERROR: FAILURE DATE IS NULL OR NOT A VALID DATE
  IF UPPER(EACH_REC.CLAIM_TYPE) NOT IN ('FIELDMODIFICATION') AND 
  ( EACH_REC.FAILURE_DATE IS NULL OR NOT (COMMON_VALIDATION_UTILS.isValidDate(EACH_REC.FAILURE_DATE, 'YYYYMMDD')) )
  THEN
    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC019');
  ELSE 
    v_valid_failure_date := TRUE;
  END IF;

	-- ERROR CODE: DC0011_FD
	-- VALIDATE THAT INSTALLATION DATE IS NOT NULL AND VALID DATE
	-- REASON FOR ERROR: INSTALLATION DATE IS NULL OR NOT A VALID DATE
  IF UPPER(EACH_REC.CLAIM_TYPE) IN ('MACHINE NON SERIALIZED', 'PARTS WITH HOST') AND 
  ( EACH_REC.INSTALLATION_DATE IS NULL OR NOT (COMMON_VALIDATION_UTILS.isValidDate(EACH_REC.INSTALLATION_DATE, 'YYYYMMDD')) )
  THEN
    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC020');
  END IF;

	-- ERROR CODE: DC0012_WN
	-- VALIDATE THAT WORK ORDER NUMBER IS NOT NULL
	-- REASON FOR ERROR: WORK ORDER NUMBER IS NULL
	BEGIN
		 IF EACH_REC.WORK_ORDER_NUMBER IS NULL
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC021');
		 END IF;
	END;

	-- ERROR CODE: DC0013_CF
	-- VALIDATE THAT CONDITION FOUND IS NOT NULL
	-- REASON FOR ERROR: CONDITION FOUND IS NULL
	BEGIN
		 IF EACH_REC.CONDITIONS_FOUND IS NULL
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC022');
		 END IF;
	END;

	-- ERROR CODE: DC0014_WP
	-- VALIDATE THAT WORK PERFORMED IS NOT NULL
	-- REASON FOR ERROR: WORK PERFORMED IS NULL
	BEGIN
		 IF EACH_REC.WORK_PERFORMED IS NULL
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC023');
		 END IF;
	END;

	-- ERROR CODE: DC0016_CP
	-- VALIDATE THAT CAUSAL PART IS NOT NULL
	-- REASON FOR ERROR: CAUSAL PART IS NULL
	BEGIN
		 IF UPPER(EACH_REC.CLAIM_TYPE) NOT IN ('PARTS WITHOUT HOST') AND 
     (EACH_REC.CAUSAL_PART IS NULL OR 
     NOT (COMMON_VALIDATION_UTILS.isValidItemNumber(EACH_REC.CAUSAL_PART, v_bu_name)))
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC025');
		 END IF;
	END;




	-- ERROR CODE: DC0018_RQ
	-- VALIDATE THAT REPLACED IR PARTS QUANTITY IS NOT NULL
	-- REASON FOR ERROR: REPLACED IR PARTS QUANTITY IS NULL
    IF UPPER(each_rec.claim_type) NOT IN ('PARTS WITHOUT HOST') AND 
            each_rec.replaced_ir_parts IS NOT NULL THEN

         IF  each_rec.INSTALLED_IR_PARTS IS NULL THEN            
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC045_ADD_INP');         
         END IF;    

        v_flag := TRUE;
        IF NOT common_validation_utils.isValidDelimitedValue(each_rec.replaced_ir_parts, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC045');
            v_flag := FALSE;
        ELSE
            v_count := Common_Utils.count_delimited_values(each_rec.replaced_ir_parts, v_delimiter);
             IF  each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL THEN            
                IF NOT common_validation_utils.isValidDelimitedValue(each_rec.REPLACED_IR_PARTS_SERIAL_NUM, v_delimiter) THEN
                  v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC045_SE');
                  v_flag := FALSE;
                ELSE
                  v_count2 := Common_Utils.count_delimited_values(each_rec.REPLACED_IR_PARTS_SERIAL_NUM, v_delimiter); 
                END IF; 
             END IF;
            IF v_flag = TRUE THEN
			
			  -- Checking duplicate serial and part numbers values
            IF UPPER(each_rec.claim_type) IN ('PARTS WITH HOST') AND common_validation_utils.hasDuplicateSerializedPart(each_rec.REPLACED_IR_PARTS_SERIAL_NUM,each_rec.replaced_ir_parts, v_delimiter) THEN
                  v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_98');          
            END IF;

            FOR i IN 1 .. v_count LOOP
                IF i <= v_count2 THEN
                IF UPPER(each_rec.claim_type) IN ('PARTS WITHOUT HOST') THEN
                               --serialized part
                            IF UPPER(each_rec.PART_SERIAL_NUMBER) IS NOT NULL THEN
                               IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NULL THEN   
                                        v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Removed part should be serialized replaced part');                                         
                               ELSE
                                                     IF each_rec.PART_SERIAL_NUMBER != each_rec.REPLACED_IR_PARTS_SERIAL_NUM THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Replaced part serial number should be same as part serial number');

                                                     ELSIF common_utils.get_delimited_value(each_rec.replaced_ir_parts_quantity, v_delimiter, i) !=1 THEN
                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Serialized replaced part quatity should be one');
                                                     END IF;

                               END IF;  
                            ELSIF UPPER(each_rec.Part_item_Number) IS NOT NULL THEN
                                 IF each_rec.Replaced_IR_Parts IS NOT NULL THEN
                                                  IF common_utils.get_delimited_value(each_rec.Replaced_IR_Parts, v_delimiter, i) != each_rec.Part_item_Number THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Please add correct replaced part');
                                                   END IF;
                                  END IF;                         
                                  IF UPPER(each_rec.REPLACED_IR_PARTS_QUANTITY) IS NOT NULL THEN
                                                  IF common_utils.get_delimited_value(each_rec.replaced_ir_parts_quantity, v_delimiter, i) !=1 THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Replaced part quantity should be one only');   
                                                   END IF;
                                  END IF;                 
                             END IF;
                END IF; 
                        IF UPPER(each_rec.claim_type) IN ('PARTS WITH HOST') THEN
                               --serialized part
                            IF UPPER(each_rec.PART_SERIAL_NUMBER) IS NOT NULL THEN
                                   IF common_utils.get_delimited_value(each_rec.replaced_ir_parts_quantity, v_delimiter, i) !=1 THEN
                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_79');
                                   END IF;
                                   
                                   IF each_rec.Is_Serialized in ('Y') THEN
                                          -- TKTSA host
                                          IF each_rec.Is_Part_Installed_on_TKTSA in ('Y') THEN                                         
                                              --replaced part
                                              IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL THEN
                                                    select count(*) into v_replaced_part from  Inventory_Item_Composition where part_of in (select id from inventory_item where serial_number = v_machine_serial_number ) and part in (select id from inventory_item where serial_number=common_utils.get_delimited_value(each_rec.REPLACED_IR_PARTS_SERIAL_NUM, v_delimiter, i) );   

                                                     IF v_replaced_part != 1 THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_78');                                                     
                                                     END IF;
                                               END IF;

                                                --installed part
                                               IF each_rec.Installed_IR_Parts_Serial_Num IS NOT NULL THEN
                                                    IF common_utils.get_delimited_value(each_rec.Installed_IR_Parts_Quantity, v_delimiter, i) !=1 THEN
                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_80');
                                                     END IF;
                                               END IF;
                                           -- competitor model
                                           ELSE 
                                              --replaced part
                                              IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL AND common_utils.get_delimited_value(each_rec.REPLACED_IR_PARTS_SERIAL_NUM, v_delimiter, i) != each_rec.Part_Serial_Number THEN
                                                v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_81');
                                              END IF;   
                                              --installed part
                                              IF each_rec.Installed_IR_Parts_Serial_Num IS NOT NULL AND common_utils.get_delimited_value(each_rec.Installed_IR_Parts_Quantity, v_delimiter, i) !=1 THEN

                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_80');

                                               END IF;
                                           END IF;
                                      --non serialized machine
                                    ELSE
                                             IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL AND common_utils.get_delimited_value(each_rec.REPLACED_IR_PARTS_SERIAL_NUM, v_delimiter, i) != each_rec.Part_Serial_Number THEN
                                                v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_81');
                                              END IF;    
                                              --installed part
                                              IF each_rec.Installed_IR_Parts_Serial_Num IS NOT NULL AND common_utils.get_delimited_value(each_rec.Installed_IR_Parts_Quantity, v_delimiter, i) !=1 THEN
                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_80');
                                               END IF;  
                                    END IF;

                            -- non serialized part
                            ELSIF UPPER(each_rec.Part_item_Number) IS NOT NULL THEN
                                      --serialized machine
                                      IF each_rec.Is_Serialized in ('Y') THEN    
                                            -- TKTSA host
                                            IF each_rec.Is_Part_Installed_on_TKTSA in ('Y') THEN
                                                  IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_82');
                                                   END IF;        
                                            -- competitor model
                                            ELSE
                                                  IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_82'); 
                                                  END IF;
                                                  IF each_rec.Replaced_IR_Parts IS NOT NULL AND UPPER(each_rec.Part_item_Number) != common_utils.get_delimited_value(each_rec.Replaced_IR_Parts, v_delimiter, 1) THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_85');
                                                   END IF;
                                                   IF Common_Utils.count_delimited_values(each_rec.Replaced_IR_Parts, v_delimiter)  !=1 THEN
                                                      v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Should not add more than one part');
                                                   END IF;

                                                   IF each_rec.Installed_IR_Parts_Serial_Num is NOT NULL THEN
                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_87');
                                                   END IF;  
                                             END IF;

                                       ELSE
                                              --non serialized
                                              IF each_rec.REPLACED_IR_PARTS_SERIAL_NUM IS NOT NULL THEN
                                                            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_84');
                                               END IF;

                                              IF each_rec.Replaced_IR_Parts IS NOT NULL AND UPPER(each_rec.Part_item_Number) != common_utils.get_delimited_value(each_rec.Replaced_IR_Parts, v_delimiter, i) THEN
                                                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_85');
                                              END IF;

                                              IF Common_Utils.count_delimited_values(each_rec.Replaced_IR_Parts, v_delimiter)  !=1 THEN
                                                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Should not add more than one part');
                                              END IF;

                                              IF each_rec.Installed_IR_Parts_Serial_Num is NOT NULL THEN
                                                         v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_87');
                                              END IF;  
                                       END IF;
                            END IF;   
                         END IF; 
                        IF NOT common_validation_utils.isValidReplacedIRPart(common_utils.get_delimited_value(each_rec.REPLACED_IR_PARTS_SERIAL_NUM, v_delimiter, i),
                              common_utils.get_delimited_value(each_rec.replaced_ir_parts, v_delimiter, i), v_bu_name)
                        THEN
                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC046');
                          EXIT;
                        END IF;

                ELSE          
                              
                              IF UPPER(each_rec.Part_item_Number) IS NOT NULL THEN
                                   IF each_rec.Is_Part_Installed_on_TKTSA in ('N') OR each_rec.Is_Serialized in ('N') THEN                                         
                                       
                                        IF each_rec.Replaced_IR_Parts IS NOT NULL AND UPPER(each_rec.Part_item_Number) != common_utils.get_delimited_value(each_rec.Replaced_IR_Parts, v_delimiter, i) THEN
                                                                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_88');
                                        END IF;

                                        IF Common_Utils.count_delimited_values(each_rec.Replaced_IR_Parts, v_delimiter)  !=1 THEN
                                               v_error_code := Common_Utils.addErrorMessage(v_error_code, 'Should not add more than one part');
                                        END IF;

                                        IF each_rec.Installed_IR_Parts_Serial_Num is NOT NULL THEN
                                                v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC_87');
                                        END IF;  
                                    END IF;
                              END IF;

                      IF NOT common_validation_utils.isValidReplacedIRPart(
                              common_utils.get_delimited_value(each_rec.replaced_ir_parts, v_delimiter, i), v_bu_name)
                      THEN
                          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC046');
                          EXIT;
                      END IF;
                END IF;     

            END LOOP;
            END IF;   
        END IF;

        IF each_rec.replaced_ir_parts_quantity IS NULL THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC027');
        ELSIF NOT common_validation_utils.isValidDelimitedValue(each_rec.replaced_ir_parts_quantity, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC047');
        ELSIF v_flag = TRUE AND v_count != Common_Utils.count_delimited_values(each_rec.replaced_ir_parts_quantity, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC048');
        ELSIF v_flag = TRUE THEN
            FOR i IN 1 .. v_count LOOP
                IF NOT common_utils.isPositiveInteger(
                        common_utils.get_delimited_value(each_rec.replaced_ir_parts_quantity, v_delimiter, i)) 
                THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC054');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END IF; 

    -- ERROR CODE: DC045_IN
	-- VALIDATE THAT INSTALLED IR PARTS QUANTITY IS NOT NULL
	-- REASON FOR ERROR: INSTALLED IR PARTS QUANTITY IS NULL
    IF UPPER(each_rec.claim_type) NOT IN ('PARTS WITHOUT HOST') AND 
            each_rec.INSTALLED_IR_PARTS IS NOT NULL THEN
        v_flag := TRUE;
        IF NOT common_validation_utils.isValidDelimitedValue(each_rec.INSTALLED_IR_PARTS, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC045_INP');
            v_flag := FALSE;
        ELSE            
              IF v_count != Common_Utils.count_delimited_values(each_rec.INSTALLED_IR_PARTS, v_delimiter) THEN
                 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC075');
              END IF;
            v_count := Common_Utils.count_delimited_values(each_rec.INSTALLED_IR_PARTS, v_delimiter);
            FOR i IN 1 .. v_count LOOP
                IF NOT common_validation_utils.isValidInstalledIRPart(
                        common_utils.get_delimited_value(each_rec.INSTALLED_IR_PARTS, v_delimiter, i), v_bu_name)
                THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC046_INP');
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF each_rec.INSTALLED_IR_PARTS_QUANTITY IS NULL THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC027_INP');
        ELSIF NOT common_validation_utils.isValidDelimitedValue(each_rec.INSTALLED_IR_PARTS_QUANTITY, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC047_INP');
        ELSIF v_flag = TRUE AND v_count != Common_Utils.count_delimited_values(each_rec.INSTALLED_IR_PARTS_QUANTITY, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC048_INP');
        ELSIF v_flag = TRUE THEN
            FOR i IN 1 .. v_count LOOP
                IF NOT common_utils.isPositiveInteger(
                        common_utils.get_delimited_value(each_rec.INSTALLED_IR_PARTS_QUANTITY, v_delimiter, i)) 
                THEN
                      v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC054_INP');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF each_rec.miscellaneous_parts IS NOT NULL THEN
        v_flag := TRUE;
        IF NOT common_validation_utils.isValidDelimitedValue(each_rec.miscellaneous_parts, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC049');
            v_flag := FALSE;
        ELSE
            v_count := Common_Utils.count_delimited_values(each_rec.miscellaneous_parts, v_delimiter);
            FOR i IN 1 .. v_count LOOP
                IF NOT common_validation_utils.isValidMiscPart(
                        common_utils.get_delimited_value(each_rec.miscellaneous_parts, v_delimiter, i), v_service_provider, v_bu_name)
                THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC050');
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF each_rec.misc_parts_quantity IS NULL THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC051');
        ELSIF NOT common_validation_utils.isValidDelimitedValue(each_rec.misc_parts_quantity, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC052');
        ELSIF v_flag = TRUE AND v_count != Common_Utils.count_delimited_values(each_rec.misc_parts_quantity, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC053');
        ELSIF v_flag = TRUE THEN
            FOR i IN 1 .. v_count LOOP
                IF NOT common_utils.isPositiveInteger(
                        common_utils.get_delimited_value(each_rec.misc_parts_quantity, v_delimiter, i)) 
                THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC055');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF UPPER(each_rec.claim_type) NOT IN ('PARTS WITHOUT HOST') AND 
            each_rec.replaced_non_ir_parts IS NOT NULL 
    THEN
        v_flag := TRUE;
        IF NOT common_validation_utils.isValidDelimitedValue(each_rec.replaced_non_ir_parts, v_delimiter) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC056');
            v_flag := FALSE;
        ELSE
            v_count := common_utils.count_delimited_values(each_rec.replaced_non_ir_parts, v_delimiter);
            IF each_rec.replaced_non_ir_parts_quantity IS NULL THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC028');
            ELSIF NOT common_validation_utils.isValidDelimitedValue(each_rec.replaced_non_ir_parts_quantity, v_delimiter) THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC057');
            ELSIF v_count != common_utils.count_delimited_values(each_rec.replaced_non_ir_parts_quantity, v_delimiter) THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC058');
            ELSE
                FOR i IN 1 .. v_count LOOP
                    IF NOT common_utils.isPositiveInteger(
                            common_utils.get_delimited_value(each_rec.replaced_non_ir_parts_quantity, v_delimiter, i)) 
                    THEN
                        v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC059');
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            IF each_rec.replaced_non_ir_parts_price IS NULL THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC029');
            ELSIF NOT common_validation_utils.isValidDelimitedValue(each_rec.replaced_non_ir_parts_price, v_delimiter) THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC060');
            ELSIF v_count != common_utils.count_delimited_values(each_rec.replaced_non_ir_parts_price, v_delimiter) THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC061');
            END IF;

            IF each_rec.replaced_non_ir_parts_desc IS NULL THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC030');
            ELSIF NOT common_validation_utils.isValidDelimitedValue(each_rec.replaced_non_ir_parts_desc, v_delimiter) THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC062');
            ELSIF v_count != common_utils.count_delimited_values(each_rec.replaced_non_ir_parts_desc, v_delimiter) THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'DC063');
            END IF;        
        END IF;
    END IF;

	-- ERROR CODE: DC0021_SR
	-- VALIDATE THAT SMR REQUEST IS NOT NULL AND AN ALLOWED VALUE OF 'Y'/'N'
	-- REASON FOR ERROR: SMR REQUEST IS NULL OR NOT AN ALLOWED VALUE OF 'Y'/'N'
	BEGIN
		 IF EACH_REC.SMR_CLAIM IS NOT NULL AND EACH_REC.SMR_CLAIM NOT IN ('Y', 'N')
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC031');
		 END IF;
	END;

  -- ERROR CODE: DC068_CP
	-- VALIDATE THAT COMMERCIAL POLICY IS NOT NULL AND AN ALLOWED VALUE OF 'Y'/'N'
	-- REASON FOR ERROR: COMMERCIAL POLICY IS NULL OR NOT AN ALLOWED VALUE OF 'Y'/'N'
	BEGIN
		 IF EACH_REC.COMMERCIAL_POLICY IS NOT NULL AND EACH_REC.COMMERCIAL_POLICY NOT IN ('Y', 'N')
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC068_CP');
		 END IF;
	END;

  -- ERROR CODE: DC069_IPI
	-- VALIDATE THAT IS PART INSTALLED IS NOT NULL AND AN ALLOWED VALUE OF 'Y'/'N'
	-- REASON FOR ERROR: IS PART INSTALLED IS NULL OR NOT AN ALLOWED VALUE OF 'Y'/'N'
	BEGIN
		 IF EACH_REC.IS_PART_INSTALLED IS NOT NULL AND EACH_REC.IS_PART_INSTALLED NOT IN ('Y', 'N')
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC069_IPI');
		 END IF;
	END;

  -- ERROR CODE: DC070_PITKTSA
	-- VALIDATE THAT IS_PART_INSTALLED_ON_TKTSA IS NOT NULL AND AN ALLOWED VALUE OF 'Y'/'N'
	-- REASON FOR ERROR: IS_PART_INSTALLED_ON_TKTSA IS NULL OR NOT AN ALLOWED VALUE OF 'Y'/'N'
	BEGIN
		 IF EACH_REC.IS_PART_INSTALLED_ON_TKTSA IS NOT NULL AND EACH_REC.IS_PART_INSTALLED_ON_TKTSA NOT IN ('Y', 'N')
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC070_PITKTSA');
		 END IF;
	END;

  -- ERROR CODE: DC071_CM
	-- VALIDATE THAT COMPETITOR_MODEL IS NOT NULL
	-- REASON FOR ERROR: COMPETITOR_MODEL
	BEGIN
		 IF EACH_REC.IS_PART_INSTALLED IS NOT NULL AND EACH_REC.IS_PART_INSTALLED IN ('Y') AND EACH_REC.IS_PART_INSTALLED_ON_TKTSA IN ('N')
		 THEN      
       v_competitor_model_id := common_validation_utils.getValidCompetitorModelId(EACH_REC.COMPETITOR_MODEL, v_user_locale, v_bu_name);
                IF v_competitor_model_id IS NULL THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC071_CM');
                END IF;      

      END IF;     

	END;


    -- ERROR CODE: DC0024_RE
	-- VALIDATE THAT REASON FOR SMR CLAIM IS NOT NULL
	-- REASON FOR ERROR: REASON FOR SMR CLAIM IS NULL
	BEGIN
		 IF EACH_REC.SMR_CLAIM IS NOT NULL AND each_rec.smr_claim = 'Y' THEN
            IF EACH_REC.REASON_FOR_SMR_CLAIM IS NULL THEN
			    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC032');
            ELSE
                v_smr_reason_id := common_validation_utils.getValidSMRReasonId(each_rec.reason_for_smr_claim, v_user_locale, v_bu_name);
                IF v_smr_reason_id IS NULL THEN
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC033');
                END IF;
            END IF;
		 END IF;
	END;


	-- ERROR CODE: DC0022_IN
	-- VALIDATE THAT INVOICE NUMBER IS NOT NULL
	-- REASON FOR ERROR: INVOICE NUMBER IS NULL
	BEGIN
		 IF COMMON_VALIDATION_UTILS.isConfigParamSet('invoiceNumberApplicable', v_bu_name) AND 
     EACH_REC.INVOICE_NUMBER IS NULL 
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC034');
		 END IF;
	END;

	-- ERROR CODE: DC0023_HP
	-- VALIDATE THAT HOURS ON PARTS IS NOT A NUMBER
	-- REASON FOR ERROR: HOURS ON PARTS IS NULL
	BEGIN
		 IF EACH_REC.HOURS_ON_PARTS IS NOT NULL  AND 
		 NOT (Common_Utils.isPositiveInteger(EACH_REC.HOURS_ON_PARTS) )
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC035');
		 END IF;
	END;

	-- ERROR CODE: DC036
	-- VALIDATE THAT REASON FOR EXTRA LABOR HOURS IS NOT NULL
	-- REASON FOR ERROR: REASON FOR EXTRA LABOR HOURS IS NULL
	
	BEGIN

		 IF UPPER(EACH_REC.CLAIM_TYPE) NOT IN ('PARTS WITHOUT HOST') AND 
		 EACH_REC.LABOUR_HOURS IS NOT NULL  
		 THEN
        IF EACH_REC.REASON_FOR_EXTRA_LABOR_HOURS IS NULL THEN 
        	 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC036');
        ELSE 
         select count(*) into v_id    from add_lbr_egl_service_providers where d_active = 1;          
           IF v_id =0 then
              null;               
            ELSE             
                select count(*) into v_id    from add_lbr_egl_service_providers where SERVICE_PROVIDERS = v_dealer_id and d_active = 1; 
                IF v_id = 0 then
                    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC036_ALH');
                END IF; 
            END IF; 
        END IF;  
		 END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC036_ALH');

	END;

IF v_product IS NOT NULL THEN     
  -- ERROR CODE: DC072
	-- VALIDATE COST CATEGORY(IR PARTS) 
	-- REASON FOR ERROR: IR PARTS ARE INVALID COST CATEGORY FOR THIS PRODUCT.
  
BEGIN
       IF UPPER(EACH_REC.LABOUR_HOURS)IS NOT NULL THEN 
               IF NOT common_validation_utils.isAllowedCostCategory('LABOR',v_product) THEN
                               v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC072');                                
               END IF;
        END IF;

        EXCEPTION 
          WHEN OTHERS THEN
          v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC072');
END;

  -- ERROR CODE: DC036_RP
	-- VALIDATE COST CATEGORY(IR PARTS) 
	-- REASON FOR ERROR: IR PARTS ARE INVALID COST CATEGORY FOR THIS PRODUCT.
BEGIN
       IF UPPER(EACH_REC.REPLACED_IR_PARTS)IS NOT NULL THEN 
               IF NOT common_validation_utils.isAllowedCostCategory('OEM_PARTS',v_product) THEN
                               v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC036_RP');                                
              END IF;
        END IF;

    EXCEPTION 
        WHEN OTHERS THEN
        v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC036_RP');
END;

  -- ERROR CODE: DC036_MP
	-- VALIDATE COST CATEGORY(MISC_PARTS) 
	-- REASON FOR ERROR: MISC_PARTS ARE INVALID COST CATEGORY FOR THIS PRODUCT.
  
BEGIN
       IF UPPER(EACH_REC.MISCELLANEOUS_PARTS)IS NOT NULL THEN 
            IF NOT common_validation_utils.isAllowedCostCategory('MISC_PARTS',v_product) THEN
                               v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC036_MP');                                
              END IF;
       END IF;
END;

END IF;

	-- ERROR CODE: DC0025_RE
	-- VALIDATE THAT REPAIR DATE IS NOT LESS THAN FAILURE DATE
	-- REASON FOR ERROR: REPAIR DATE IS LESS THAN FAILURE DATE
	BEGIN
		 IF v_valid_repair_date AND v_valid_failure_date AND 
            TO_DATE (EACH_REC.REPAIR_DATE, 'YYYYMMDD') < 
                TO_DATE (EACH_REC.FAILURE_DATE, 'YYYYMMDD') 
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC037');
		 END IF;
	END;


	-- ERROR CODE: DC0026_FC
	-- VALIDATE THAT FAULT CODE IS VALID
	-- REASON FOR ERROR: FAULT CODE IS NOT VALID
	BEGIN
        v_fault_code := common_utils.getValidFaultCode(EACH_REC.fault_location);
		 IF v_model IS NOT NULL  AND EACH_REC.fault_location IS NOT NULL AND 
     NOT COMMON_VALIDATION_UTILS.isValidFaultCodeForModelId(v_model, v_fault_code, v_bu_name)
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC038');
		 END IF;
	END;

	-- ERROR CODE: DC0027_JC
	-- VALIDATE THAT JOB CODE IS VALID
	-- REASON FOR ERROR: JOB CODE IS NOT VALID
	BEGIN
        v_job_code := common_utils.getValidJobCode(EACH_REC.JOB_CODE);
		 IF v_model IS NOT NULL  AND EACH_REC.JOB_CODE IS NOT NULL AND 
     NOT COMMON_VALIDATION_UTILS.isValidJobCodeForModelId(v_model, v_job_code, v_bu_name)
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC039');
		 END IF;
	END;

	-- ERROR CODE: DC0028_FF
	-- VALIDATE THAT FAULT FOUND IS VALID
	-- REASON FOR ERROR: FAULT FOUND IS NOT VALID
	BEGIN
		 IF v_model IS NOT NULL  AND EACH_REC.FAULT_FOUND IS NOT NULL THEN
            IF NOT COMMON_VALIDATION_UTILS.isValidFaultFoundForModelId(v_model, EACH_REC.FAULT_FOUND, v_bu_name)
		    THEN
			    v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC040');
            ELSE
                v_valid_fault_found := TRUE;
                SELECT ftd.name INTO v_fault_found
                FROM failure_type ft, 
                    i18nfailure_type_definition i18n_ftd,
                    failure_type_definition ftd
                where 
                    ft.definition_id = i18n_ftd.failure_type_definition
                    AND lower(i18n_ftd.name) = lower(ltrim(rtrim(each_rec.fault_found))) 
                    AND ft.for_item_group_id = v_model 
                    AND ft.d_active = 1
                    AND ftd.id = i18n_ftd.failure_type_definition
                    AND ROWNUM = 1;
            END IF;
		 END IF;
	END;


    -- ERROR CODE: DC0006_MN
    -- VALIDATE THAT MODEL NUMBER IS NOT NULL FOR MACHINE NON-SERIALIZED
    -- REASON FOR ERROR: SERIAL NUMBER IS NULL 
    BEGIN
    IF UPPER(EACH_REC.CLAIM_TYPE) IN ('MACHINE NON SERIALIZED') OR (UPPER(EACH_REC.CLAIM_TYPE) IN ('PARTS WITH HOST') AND UPPER(EACH_REC.IS_SERIALIZED) ='N' ) THEN
        v_flag := FALSE;
        IF EACH_REC.MODEL_NUMBER IS NULL THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC009');
        ELSIF NOT (COMMON_VALIDATION_UTILS.isValidModel(EACH_REC.MODEL_NUMBER, v_bu_name)) THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC010');
        ELSE
            v_flag := TRUE;
        END IF;

        IF v_flag THEN
             SELECT m.id INTO v_model
             FROM  item_group m,party p
             WHERE m.business_unit_info = v_bu_name            
                AND m.item_group_type = 'MODEL'
                AND lower(m.name) = lower(each_rec.model_number)
                AND m.d_active = 1 AND p.name = 'OEM' AND p.d_active = 1;                

          END IF;       


    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC013');
    END;

	-- ERROR CODE: DC0030_FF
	-- VALIDATE THAT ROOT CAUSE IS VALID
	-- REASON FOR ERROR: ROOT CAUSE IS NOT VALID
	BEGIN
		 IF v_valid_fault_found  AND EACH_REC.failure_detail IS NOT NULL AND 
     NOT COMMON_VALIDATION_UTILS.isValidRootCauseForModelId(v_model, EACH_REC.FAULT_FOUND, EACH_REC.failure_detail, v_bu_name)
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC042');
		 END IF;
	END;

    BEGIN
		 IF each_rec.technician_id IS NOT NULL AND 
            NOT COMMON_VALIDATION_UTILS.isValidTechnician(each_rec.technician_id, v_dealer, v_bu_name)
		 THEN
			 v_error_code := Common_Utils.addErrorMessage(v_error_code, 'DC043');
		 END IF;
	END;

	--UPDATE RECORDS RESPECTIVELY FOR EACH LOOP
	IF v_error_code IS NULL
	THEN
	   --RECORD IS CLEAN AND IS SUCCESSFULLY VALIDATED
	   UPDATE STG_DRAFT_CLAIM
	   SET
		  ERROR_STATUS = 'Y',
			ERROR_CODE = NULL,
            business_unit_name = v_bu_name,
            reason_for_smr_claim = v_smr_reason_id,
            competitor_model_id = v_competitor_model_id,
            fault_location = v_fault_code,
            job_code = v_job_code,
            fault_found = v_fault_found,
            part_number=  v_item_number
		WHERE
		  ID = EACH_REC.ID;
	ELSE
	   --RECORD HAS ERRORS
		UPDATE STG_DRAFT_CLAIM
	   SET
		  ERROR_STATUS = 'N',
		  ERROR_CODE = v_error_code
		WHERE
		  ID = EACH_REC.ID;
	END IF;

    v_loop_count := v_loop_count + 1;

    IF v_loop_count = 10 THEN
      --DO A COMMIT FOR 10 RECORDS
      COMMIT;
      v_loop_count := 0; -- Initialize the count size
    END IF;

  END LOOP;

    IF v_loop_count > 0 THEN
        COMMIT;
    END IF;

  BEGIN
    -- Update the status of validation
    
    -- In a given time there will be only one file for a given upload
    SELECT DISTINCT file_upload_mgt_id 
    INTO v_file_upload_mgt_id
    FROM STG_DRAFT_CLAIM 
    WHERE ROWNUM < 2;

    -- Success Count
    BEGIN
      SELECT count(*)
      INTO v_success_count
      FROM STG_DRAFT_CLAIM 
      where file_upload_mgt_id = v_file_upload_mgt_id and error_status = 'Y';
    EXCEPTION
    WHEN OTHERS THEN
      v_success_count := 0;
    END;

    -- Error Count
    BEGIN
      SELECT count(*)
      INTO v_error_count
      FROM STG_DRAFT_CLAIM 
      where file_upload_mgt_id = v_file_upload_mgt_id and error_status = 'N';
    EXCEPTION
    WHEN OTHERS THEN
      v_error_count := 0;
    END;

    -- Total Count
    SELECT count(*)
    INTO v_count
    FROM STG_DRAFT_CLAIM 
    where file_upload_mgt_id = v_file_upload_mgt_id ;

    UPDATE FILE_UPLOAD_MGT 
    SET 
      SUCCESS_RECORDS= v_success_count, 
      ERROR_RECORDS= v_error_count,
      TOTAL_RECORDS = v_count
    WHERE ID = v_file_upload_mgt_id;

  EXCEPTION
  WHEN OTHERS THEN
    -- Capture the error code into the table
    v_error := SUBSTR(SQLERRM, 1, 4000);
    UPDATE FILE_UPLOAD_MGT 
    SET 
      ERROR_MESSAGE = v_error
    WHERE ID = v_file_upload_mgt_id;

  END;

  COMMIT; -- Final Commit for the procedure

END UPLOAD_DRAFT_CLAIM_VALIDATION;
/
COMMIT
/

