create or replace
PROCEDURE              "UPLOAD_COST_PRICE_UPLOAD" AS

CURSOR all_rec IS
    SELECT *
    FROM stg_cost_price
    WHERE NVL(error_status, 'N') = 'Y'
    AND error_code IS NULL
    AND NVL(upload_status, 'N')  = 'N'
    ORDER BY id;

v_cp_in_usd NUMBER(19,2);
v_cp_in_supplier_usd NUMBER(19,2);
v_cp_in_dealer_curr NUMBER(19,2);
v_cp_in_supplier_curr  NUMBER(19,2);
v_count NUMBER;
v_error_code VARCHAR2(100);
v_upload_error VARCHAR2(4000) := NULL;
v_mapping_fraction NUMBER;
v_recoverable_part_id number;

v_oemparts_lig NUMBER;
v_claimamount_lig NUMBER;
v_oemparts_cp NUMBER(19,2);

v_bu_name VARCHAR2(255);
v_cp_config VARCHAR2(255);
v_supplier_currency VARCHAR2(20);

BEGIN

FOR each_rec IN all_rec LOOP
BEGIN
    v_cp_in_usd := NULL;
	  v_cp_in_supplier_usd:=null;
    v_cp_in_dealer_curr := NULL;
	  v_cp_in_supplier_curr := NULL;
    v_error_code := NULL;
    v_mapping_fraction := 1;
    v_recoverable_part_id:=null;
	  v_supplier_currency:=null;

    IF v_bu_name IS NULL THEN
        SELECT business_unit_info INTO v_bu_name
        FROM file_upload_mgt WHERE id=each_rec.file_upload_mgt_id AND ROWNUM=1;

        SELECT o.value INTO v_cp_config
        FROM config_param c,config_value v,config_param_option o
        WHERE c.name='costPriceConfiguration' AND c.id=v.config_param
            AND c.d_active=1 AND v.business_unit_info=v_bu_name
            AND v.d_active=1 AND v.config_param_option=o.id
            AND ROWNUM=1;
    END IF;

    IF each_rec.currency = 'USD' OR each_rec.currency = each_rec.dealer_currency THEN
        SELECT CAST(each_rec.cost_price AS NUMBER(19,2)) INTO v_cp_in_usd FROM DUAL;
    ELSE
        BEGIN
            SELECT CAST(factor * CAST(each_rec.cost_price AS NUMBER(19,2)) AS NUMBER(19,2)) INTO v_cp_in_usd
            FROM currency_conversion_factor WHERE parent = ( SELECT id FROM currency_exchange_rate 
              WHERE from_currency = each_rec.currency AND to_currency = 'USD') 
              AND (SELECT repair_date FROM claim WHERE id = (SELECT claim FROM recovery_claim WHERE UPPER(recovery_claim_number)=UPPER(each_rec.claim_number))) 
                BETWEEN from_date AND till_date   AND ROWNUM=1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_error_code := common_utils.addErrorMessage(v_error_code, 'CP015');
        END;
    END IF;

    IF v_error_code IS NULL THEN
        IF each_rec.dealer_currency = 'USD' OR each_rec.currency = each_rec.dealer_currency THEN
            v_cp_in_dealer_curr := v_cp_in_usd;
        ELSE
            BEGIN
                SELECT CAST(factor * v_cp_in_usd AS NUMBER(19,2)) INTO v_cp_in_dealer_curr
                FROM currency_conversion_factor WHERE parent = (
                  SELECT id FROM currency_exchange_rate 
                  WHERE from_currency = 'USD' AND to_currency = each_rec.dealer_currency
                ) AND (SELECT repair_date FROM claim WHERE id = (SELECT claim FROM recovery_claim WHERE UPPER(recovery_claim_number)=UPPER(each_rec.claim_number)))  
                    BETWEEN from_date AND till_date 
                AND ROWNUM=1;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'CP016');
            END;
        END IF;
    END IF;

    BEGIN
        SELECT uom.mapping_fraction INTO v_mapping_fraction
        FROM oem_part_replaced opr,uom_mappings uom
        WHERE opr.id=each_rec.oem_part_replaced AND opr.uom_mapping IS NOT NULL
            AND opr.uom_mapping=uom.id;
        
        v_cp_in_dealer_curr := (v_cp_in_dealer_curr * v_mapping_fraction);
    EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
        v_mapping_fraction := 1;
    END;

    IF v_error_code IS NULL AND NVL(UPPER(each_rec.override),'N') = 'N' THEN
        IF LOWER(v_cp_config) = 'materialcost' THEN
            SELECT COUNT(*) INTO v_count FROM oem_part_replaced 
            WHERE id=each_rec.oem_part_replaced
                AND (material_cost_amt IS NULL OR (material_cost_amt = v_cp_in_dealer_curr
                    AND material_cost_curr = each_rec.dealer_currency));
        ELSE
            SELECT COUNT(*) INTO v_count FROM oem_part_replaced 
            WHERE id=each_rec.oem_part_replaced
                AND (cost_price_per_unit_amt IS NULL OR (cost_price_per_unit_amt = v_cp_in_dealer_curr
                    AND cost_price_per_unit_curr = each_rec.dealer_currency));
        END IF;
        IF v_count = 0 THEN
            v_error_code := common_utils.addErrorMessage(v_error_code, 'CP014');
        END IF;
            END IF;

BEGIN
  SELECT d.id  INTO v_recoverable_part_id  FROM RECOVERY_CLAIM_INFO b, REC_CLAIM_INFO_REC_PARTS c, RECOVERABLE_PART d
  WHERE b.recovery_claim =each_rec.recovery_claim
  AND b.id               = c.Recovery_Claim_Info
  AND c.recoverable_parts=d.id
  AND d.oem_part         =each_rec.oem_part_replaced;
EXCEPTION
WHEN OTHERS THEN
v_error_code := common_utils.addErrorMessage(v_error_code, 'CP014');
END;

-- This is for supplier's currency conversion
	BEGIN
	SELECT b.preferred_currency into v_supplier_currency FROM SUPPLIER A, ORGANIZATION B WHERE A.ID=B.ID AND a.supplier_number=each_Rec.supplier_number;
	EXCEPTION WHEN OTHERS
	THEN
	v_supplier_currency:=each_rec.dealer_currency;
	END;

	IF v_supplier_currency = each_rec.dealer_currency
	THEN
	v_cp_in_supplier_curr:=v_cp_in_dealer_curr;
	ELSE
	BEGIN
    IF each_rec.currency = 'USD' OR each_rec.currency = v_supplier_currency THEN
        SELECT CAST(each_rec.cost_price AS NUMBER(19,2)) INTO v_cp_in_supplier_usd FROM DUAL;
    ELSE
        BEGIN
            SELECT CAST(factor * CAST(each_rec.cost_price AS NUMBER(19,2)) AS NUMBER(19,2)) INTO v_cp_in_supplier_usd
            FROM currency_conversion_factor WHERE parent = ( SELECT id FROM currency_exchange_rate 
              WHERE from_currency = each_rec.currency AND to_currency = 'USD') 
              AND (SELECT repair_date FROM claim WHERE id = (SELECT claim FROM recovery_claim WHERE UPPER(recovery_claim_number)=UPPER(each_rec.claim_number))) 
                BETWEEN from_date AND till_date   AND ROWNUM=1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_error_code := common_utils.addErrorMessage(v_error_code, 'CP015');
        END;
		 
    END IF;

    IF v_error_code IS NULL THEN
        IF v_supplier_currency = 'USD' OR each_rec.currency = v_supplier_currency THEN
            v_cp_in_supplier_curr := v_cp_in_supplier_usd;
        ELSE
            BEGIN
                SELECT CAST(factor * v_cp_in_supplier_usd AS NUMBER(19,2)) INTO v_cp_in_supplier_curr
                FROM currency_conversion_factor WHERE parent = (
                  SELECT id FROM currency_exchange_rate 
                  WHERE from_currency = 'USD' AND to_currency = v_supplier_currency
                ) AND (SELECT repair_date FROM claim WHERE id = (SELECT claim FROM recovery_claim WHERE UPPER(recovery_claim_number)=UPPER(each_rec.claim_number)))  
                    BETWEEN from_date AND till_date 
                AND ROWNUM=1;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                v_error_code := common_utils.addErrorMessage(v_error_code, 'CP016');
            END;
        END IF;
    END IF;
    END;
	v_cp_in_supplier_curr := (v_cp_in_supplier_curr * v_mapping_fraction);
 END IF;
 
    IF v_error_code IS NULL THEN
        IF LOWER(v_cp_config) = 'materialcost' THEN
            UPDATE oem_part_replaced SET
                material_cost_amt = (v_cp_in_dealer_curr),
                material_cost_curr = each_rec.dealer_currency
            WHERE id = each_rec.oem_part_replaced;
            if v_recoverable_part_id is not null then
            UPDATE recoverable_part SET material_cost_amt=v_cp_in_supplier_curr,  material_cost_curr =v_supplier_currency
            WHERE id=v_recoverable_part_id;
            end if;
        ELSE
            UPDATE oem_part_replaced SET
                cost_price_per_unit_amt = (v_cp_in_dealer_curr),
                cost_price_per_unit_curr = each_rec.dealer_currency
            WHERE id = each_rec.oem_part_replaced;
if v_recoverable_part_id is not null then
           UPDATE recoverable_part SET cost_price_per_unit_amt =v_cp_in_supplier_curr,  cost_price_per_unit_curr  = v_supplier_currency
           WHERE id=v_recoverable_part_id;
end if;
        END IF;
    END IF;

    IF v_error_code IS NULL THEN
        UPDATE stg_cost_price SET 
            upload_status = 'Y',
            upload_error = NULL
        WHERE id = each_rec.id;
    ELSE
        UPDATE stg_cost_price SET 
            error_status = 'N',
            error_code = v_error_code
        WHERE id = each_rec.id;
        UPDATE file_upload_mgt SET 
            success_records = success_records-1,
            error_records = error_records+1
        WHERE id = each_rec.file_upload_mgt_id;
    END IF;

EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    v_upload_error := SUBSTR(SQLERRM,0,3500);
    UPDATE stg_cost_price SET 
        upload_status = 'N',
        upload_error = v_upload_error
    WHERE id = each_rec.id;
END;

COMMIT;
END LOOP;
COMMIT;

END;