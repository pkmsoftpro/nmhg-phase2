create or replace
PROCEDURE "ITEM_UPLOAD"
AS
  CURSOR ALL_REC
  IS
    SELECT *
    FROM ITEM_STAGING
    WHERE ERROR_STATUS         = 'Y'
    AND NVL(UPLOAD_STATUS,'N') = 'N'
    ORDER BY ID ASC;
  v_upload_error    VARCHAR2(4000) := NULL;
  v_parent_group_id VARCHAR2(255)  := NULL;
  v_supp_name       VARCHAR2(255)  := NULL;
  v_make_name       VARCHAR2(255)  := NULL;
  v_owner_id        VARCHAR2(255)  := NULL;
  v_oem_id          VARCHAR2(255)  := NULL;
  v_prod_id         VARCHAR2(255)  := NULL;
  v_item_id         NUMBER;
  v_item_type       VARCHAR2(255)  := NULL;
  v_bu              VARCHAR2(4000) := NULL;
  v_item_number     VARCHAR2(4000) := NULL;
  v_need_to_INSERT  NUMBER;
  v_service_part    NUMBER;
BEGIN
  FOR EACH_REC IN ALL_REC
  LOOP
    BEGIN
      v_parent_group_id := 0;
      v_prod_id         := NULL;
      v_make_name       := NULL;
      v_owner_id        := NULL;
      v_item_type       := NULL;
      v_item_number     := NULL;
      v_need_to_INSERT  := 0;
      v_service_part    := 1;
      SELECT NAME
      INTO v_bu
      FROM BUSINESS_UNIT
      WHERE UPPER(NAME) = UPPER(EACH_REC.BUSINESS_UNIT);
      SELECT EACH_REC.ITEM_NUMBER
        || DECODE(EACH_REC.PART_MANUFACTURING_CODE, '', '', '#'
        ||EACH_REC.PART_MANUFACTURING_CODE)
      INTO v_item_number
      FROM dual;
      SELECT ID
      INTO v_parent_group_id
      FROM ITEM_GROUP
      WHERE UPPER(GROUP_CODE)    = UPPER(EACH_REC.ITEM_GROUP_CODE)
      AND BUSINESS_UNIT_INFO     = v_bu
      AND UPPER(ITEM_GROUP_TYPE) = 'MODEL';

      BEGIN
        SELECT DECODE(EACH_REC.ITEM_GROUP_CODE, 'PART', NULL , a.ID )
            INTO v_prod_id
            FROM
          (SELECT id,
            ITEM_GROUP_TYPE
          FROM ITEM_GROUP
          START WITH ID = v_parent_group_id
          CONNECT BY ID = PRIOR IS_PART_OF
            ) A
        WHERE A.ITEM_GROUP_TYPE = 'PRODUCT';
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN
            v_prod_id := NULL;
      END;
      IF EACH_REC.OWNER      IS NOT NULL THEN
        BEGIN
          SELECT P.NAME,
            P.ID
          INTO v_make_name,
            v_owner_id
          FROM SUPPLIER S,
            PARTY P
          WHERE upper(S.SUPPLIER_NUMBER) = upper(EACH_REC.OWNER)
          AND S.ID                       = P.ID
          AND ROWNUM                     = 1;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_make_name:=NULL;
          v_owner_id := NULL;
        END;
      ELSE
        SELECT DECODE(P.NAME,'OEM',v_bu,P.NAME) ,
          P.ID
        INTO v_make_name,
          v_owner_id
        FROM PARTY P,
          ORGANIZATION O
        WHERE UPPER(P.NAME) = 'OEM'
        AND P.ID            = O.ID;
      END IF;
      IF NVL(EACH_REC.UPDATES,'N') = 'Y' THEN
        BEGIN
          SELECT ID
          INTO v_item_id
          FROM ITEM
          WHERE ITEM_NUMBER      = v_item_number
          AND BUSINESS_UNIT_INFO = V_BU;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_need_to_INSERT := 1;
        END;
      ELSE
        v_need_to_INSERT := 1;
      END IF;
      IF v_need_to_INSERT = 1 THEN
        SELECT ITEM_SEQ.NEXTVAL INTO v_item_id FROM DUAL;
      END IF;
      SELECT DECODE(EACH_REC.ITEM_GROUP_CODE,'PART','PART','MACHINE')
      INTO v_item_type
      FROM DUAL;

      SELECT DECODE(UPPER(EACH_REC.SERVICE_PART), NULL, 1, 'Y', 1, 0)
      INTO v_service_part
      FROM DUAL;

      IF v_need_to_INSERT = 0 THEN
        UPDATE ITEM
        SET DESCRIPTION        = EACH_REC.ITEM_DESC,
          MAKE                 = v_make_name,
          NAME                 = EACH_REC.ITEM_DESC,
          ITEM_NUMBER          = v_item_number,
          SERIALIZED           = DECODE(EACH_REC.IS_SERIALIZED,'Y',1,0),
          USAGE_METER          = USAGE_METER,
          OWNED_BY             = v_owner_id,
          MODEL                = v_parent_group_id, --MODEL,
          PRODUCT              = v_prod_id,         --PRODUCT
          ITEM_TYPE            = v_item_type,
          Business_unit_info   = V_BU,
          status               =EACH_REC.ITEM_STATUS,
          UOM                  = EACH_REC.UNIT_OF_MEASURE,
          D_ACTIVE             = DECODE(UPPER(EACH_REC.ITEM_STATUS),'INACTIVE',0,1)
        WHERE ID               = v_item_id
        AND BUSINESS_UNIT_INFO = v_bu;
        UPDATE ITEMS_IN_GROUP
        SET ITEM_GROUP = v_parent_group_id
        WHERE ITEM     = v_item_id;
        UPDATE I18NITEM_TEXT
        SET DESCRIPTION = EACH_REC.ITEM_DESC
        WHERE ITEM      = v_item_id;
      ELSE
        INSERT
        INTO ITEM
          (
            ID,
            COST_AMT,
            COST_CURR,
            DESCRIPTION,
            MAKE,
            NAME,
            ITEM_NUMBER,
            SERIALIZED,
            USAGE_METER,
            VERSION,
            ITEM_YEAR,
            OWNED_BY,
            MODEL,
            PRODUCT,
            ITEM_TYPE,
            Business_unit_info,
            status,
            UOM,
            duplicate_alternate_number,
            alternate_item_number,
            D_ACTIVE,
            service_part
          )
          VALUES
          (
            v_item_id,
            NULL,
            NULL,
            EACH_REC.ITEM_DESC,
            v_make_name,
            EACH_REC.ITEM_DESC,
            v_item_number, --EACH_REC.ITEM_NUMBER,
            DECODE(EACH_REC.IS_SERIALIZED,'Y',1,0),
            DECODE(EACH_REC.HAS_HOUR_METER,'Y',1,0), --for hussmann, this should be zero by default   --DECODE(EACH_REC.HAS_HOUR_METER,'Y',1,0),    --need to ask
            0,
            NULL,
            v_owner_id,
            v_parent_group_id, --MODEL,
            v_prod_id,         --PRODUCT
            v_item_type,
            v_bu, --'Hussmann'
            EACH_REC.ITEM_STATUS,
            EACH_REC.UNIT_OF_MEASURE,
            1,
            v_item_number,
            1,
            v_service_part
          );
        INSERT
        INTO ITEMS_IN_GROUP
          (
            ITEM_GROUP,
            ITEM
          )
          VALUES
          (
            v_parent_group_id,
            v_item_id
          );
        DECLARE
        type v_Array IS varray
        (
          5
        )
        OF VARCHAR2
        (
          20
        )
        ;
        VA v_Array;
      BEGIN
        VA := v_Array
        (
          'en_EN', 'fr_FR', 'de_DE', 'en_US'
        )
        ;
        FOR i IN 1..4
        LOOP
          BEGIN
            INSERT
            INTO I18NITEM_TEXT
              (
                ID,
                LOCALE,
                DESCRIPTION,
                ITEM
              )
              VALUES
              (
                I18N_ITEM_TEXT_SEQ.NEXTVAL,
                VA(i),
                EACH_REC.ITEM_DESC,
                v_item_id
              );
          END;
        END LOOP;
      END;
    END IF;
    UPDATE ITEM_STAGING
    SET UPLOAD_STATUS = 'Y',
      UPLOAD_DATE     = SYSDATE,
      UPLOAD_ERROR    = NULL
    WHERE ID          = EACH_REC.ID;
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_upload_error := SUBSTR(SQLERRM,0,3500);
    UPDATE ITEM_STAGING
    SET UPLOAD_STATUS = 'N',
      UPLOAD_DATE     = SYSDATE,
      UPLOAD_ERROR    = v_upload_error
    WHERE ID          = EACH_REC.ID;
    COMMIT;
  END;
END LOOP;
END;
