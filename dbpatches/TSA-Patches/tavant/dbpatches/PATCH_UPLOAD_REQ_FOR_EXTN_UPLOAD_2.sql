CREATE OR REPLACE
PROCEDURE UPLOAD_REQ_FOR_EXTN_UPLOAD
AS
  CURSOR ALL_REQUESTS
  IS
    SELECT SERIAL_NUMBER,
      ITEM_NUMBER,
      BUSINESS_UNIT_INFO,
      ACTION_PERFORMED,
      DEALER_NUMBER,
      FILE_UPLOAD_MGT_ID
    FROM STG_REQUESTS_FOR_EXTENSION
    WHERE NVL(ERROR_STATUS, 'Y') = 'Y'
    AND NVL(UPLOAD_STATUS, 'N')  = 'N'
    GROUP BY SERIAL_NUMBER,
      ITEM_NUMBER,
      BUSINESS_UNIT_INFO,
      ACTION_PERFORMED,
      DEALER_NUMBER,
      FILE_UPLOAD_MGT_ID;
  CURSOR POLICIES_FOR_VALID_REQUESTS (P_SERIAL_NO VARCHAR2 , P_ITEM_NO VARCHAR2, P_BU VARCHAR2)
  IS
    SELECT *
    FROM STG_REQUESTS_FOR_EXTENSION
    WHERE NVL(ERROR_STATUS, 'Y') = 'Y'
    AND NVL(UPLOAD_STATUS, 'N')  = 'N'
    AND SERIAL_NUMBER            = P_SERIAL_NO
    AND ITEM_NUMBER              = P_ITEM_NO
    AND BUSINESS_UNIT_INFO       = P_BU;
  V_WARRANTY_ID        NUMBER(19);
  V_GOODWILL_POLICY_ID NUMBER(19);
  V_DEALER_ID          NUMBER(19);
  V_LAST_UPDATED_BY    NUMBER(19);
  V_IS_RED_CVG         VARCHAR2(10)  := 'FALSE';
  V_ERROR_CODE         VARCHAR2(4000):=NULL;
  V_UPLOAD_ERROR       VARCHAR2(4000);
  V_REQUEST_CVG_ID     NUMBER(19);
  V_INV_ITEM_ID        NUMBER(19);
  V_HOURS_ON_MACHINE   NUMBER(19);
  V_SHIP_DATE DATE;
  V_WRTY_START_DATE DATE;
  V_WRTY_END_DATE DATE;
  V_ASSIGNED_TO NUMBER(19);
  V_COMMENTS    VARCHAR2(4000):=NULL;
BEGIN
  FOR EACH_REC IN ALL_REQUESTS
  LOOP
    BEGIN
      V_WARRANTY_ID        := NULL;
      V_GOODWILL_POLICY_ID := NULL;
      V_DEALER_ID          := NULL;
      V_LAST_UPDATED_BY    := NULL;
      V_IS_RED_CVG         := NULL;
      V_REQUEST_CVG_ID     := 0;
      V_INV_ITEM_ID        := NULL;
      V_HOURS_ON_MACHINE   := NULL;
      V_SHIP_DATE          := NULL;
      V_WRTY_START_DATE    := NULL;
      V_WRTY_END_DATE      := NULL;
      V_ASSIGNED_TO        := NULL;
      BEGIN
        SELECT DISTINCT II.ID,
          II.HOURS_ON_MACHINE,
          II.SHIPMENT_DATE,
          REQ.ID,
          WNTY.ID
        INTO V_INV_ITEM_ID,
          V_HOURS_ON_MACHINE,
          V_SHIP_DATE,
          V_REQUEST_CVG_ID,
          V_WARRANTY_ID
        FROM INVENTORY_ITEM II,
          ITEM I,
          REQUEST_WNTY_CVG REQ,
          WARRANTY WNTY
        WHERE II.SERIAL_NUMBER     = EACH_REC.SERIAL_NUMBER
        AND I.ITEM_NUMBER          = EACH_REC.ITEM_NUMBER
        AND II.OF_TYPE             = I.ID
        AND II.BUSINESS_UNIT_INFO  = EACH_REC.BUSINESS_UNIT_INFO
        AND I.BUSINESS_UNIT_INFO   = EACH_REC.BUSINESS_UNIT_INFO
        AND II.D_ACTIVE            = 1
        AND II.TYPE                = 'RETAIL'
        AND II.ID                  = REQ.INVENTORY_ITEM
        AND REQ.STATUS            IN ('SUBMITTED', 'REPLIED')
        AND REQ.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
        AND II.ID                  = WNTY.FOR_ITEM
        AND WNTY.STATUS            = 'ACCEPTED'
        AND WNTY.LIST_INDEX        =
          (SELECT MAX(LIST_INDEX)
          FROM WARRANTY
          WHERE FOR_ITEM = II.ID
          AND STATUS     = 'ACCEPTED'
          );
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_REQUEST_CVG_ID := 0;
      END;
      IF V_REQUEST_CVG_ID > 0 THEN
        SELECT ID
        INTO V_DEALER_ID
        FROM SERVICE_PROVIDER
        WHERE SERVICE_PROVIDER_NUMBER = EACH_REC.DEALER_NUMBER;
        SELECT UPLOADED_BY
        INTO V_LAST_UPDATED_BY
        FROM FILE_UPLOAD_MGT
        WHERE ID                            = EACH_REC.FILE_UPLOAD_MGT_ID;
        IF UPPER(EACH_REC.ACTION_PERFORMED) = 'APPROVED' THEN
          FOR EACH_POL                     IN POLICIES_FOR_VALID_REQUESTS(EACH_REC.SERIAL_NUMBER, EACH_REC.ITEM_NUMBER, EACH_REC.BUSINESS_UNIT_INFO)
          LOOP
            BEGIN
              IF (EACH_POL.GOODWILL_POLICY_CODE IS NOT NULL) THEN
                V_COMMENTS                      := EACH_POL.COMMENTS;
                SELECT DISTINCT ID
                INTO V_GOODWILL_POLICY_ID
                FROM POLICY_DEFINITION
                WHERE CODE   = EACH_POL.GOODWILL_POLICY_CODE
                AND D_ACTIVE = 1;
                UPLOAD_WARRANTY_COVERAGE(V_GOODWILL_POLICY_ID, V_WARRANTY_ID, V_INV_ITEM_ID, V_SHIP_DATE, TO_DATE(EACH_POL.DELIVERY_DATE,'YYYYMMDD'),EACH_POL.BUSINESS_UNIT_INFO, V_LAST_UPDATED_BY, TO_DATE(EACH_POL.GOODWILL_POLICY_END_DATE,'YYYYMMDD'), EACH_POL.HOURS_COVERED, V_IS_RED_CVG);
              END IF;
            END;
          END LOOP;
          SELECT MIN(PA.FROM_DATE)
          INTO V_WRTY_START_DATE
          FROM POLICY_AUDIT PA,
            WARRANTY W,
            POLICY P
          WHERE PA.FOR_POLICY = P.ID
          AND P.WARRANTY      = W.ID
          AND P.D_ACTIVE      = 1
          AND W.ID            = V_WARRANTY_ID;
          SELECT MAX(PA.TILL_DATE)
          INTO V_WRTY_END_DATE
          FROM POLICY_AUDIT PA,
            WARRANTY W,
            POLICY P
          WHERE PA.FOR_POLICY = P.ID
          AND P.WARRANTY      = W.ID
          AND P.D_ACTIVE      = 1
          AND W.ID            = V_WARRANTY_ID;
          UPDATE INVENTORY_ITEM
          SET WNTY_START_DATE = V_WRTY_START_DATE,
            WNTY_END_DATE     = V_WRTY_END_DATE
          WHERE ID            = V_INV_ITEM_ID;
        ELSE
          SELECT TAV.COMMENTS
          INTO V_COMMENTS
          FROM STG_REQUESTS_FOR_EXTENSION TAV
          WHERE TAV.SERIAL_NUMBER    = EACH_REC.SERIAL_NUMBER
          AND TAV.ITEM_NUMBER        = EACH_REC.ITEM_NUMBER
          AND TAV.BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO
          AND TAV.COMMENTS          IS NOT NULL
          AND ROWNUM                 = 1;
        END IF;
        UPDATE REQUEST_WNTY_CVG
        SET STATUS            = EACH_REC.ACTION_PERFORMED,
          UPDATED_ON_DATE     = SYSDATE,
          D_INTERNAL_COMMENTS = 'Uploaded'
        WHERE ID              = V_REQUEST_CVG_ID;
        SELECT ASSIGNED_BY
        INTO V_ASSIGNED_TO
        FROM REQUEST_WNTY_CVG_AUDIT
        WHERE REQUEST_WNTY_CVG = V_REQUEST_CVG_ID
        AND STATUS             = 'SUBMITTED';
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
            V_REQUEST_CVG_ID,
            V_COMMENTS, -- COMMENT FROM TEMPLATE
            EACH_REC.ACTION_PERFORMED,
            V_ASSIGNED_TO, -- ASSIGNED TO USER FROM AUDIT WITH STATUS SUBMITTED
            V_LAST_UPDATED_BY,
            sysdate,
            sysdate,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            'Uploaded',
            V_LAST_UPDATED_BY,
            1
          );
        UPDATE STG_REQUESTS_FOR_EXTENSION
        SET UPLOAD_STATUS      = 'Y',
          UPLOAD_ERROR         = NULL,
          UPLOAD_DATE          = SYSDATE
        WHERE SERIAL_NUMBER    = EACH_REC.SERIAL_NUMBER
        AND ITEM_NUMBER        = EACH_REC.ITEM_NUMBER
        AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      V_UPLOAD_ERROR := SUBSTR(SQLERRM, 1, 3500);
      UPDATE STG_REQUESTS_FOR_EXTENSION
      SET UPLOAD_STATUS      = 'N',
        UPLOAD_ERROR         = V_UPLOAD_ERROR,
        UPLOAD_DATE          = SYSDATE
      WHERE SERIAL_NUMBER    = EACH_REC.SERIAL_NUMBER
      AND ITEM_NUMBER        = EACH_REC.ITEM_NUMBER
      AND BUSINESS_UNIT_INFO = EACH_REC.BUSINESS_UNIT_INFO;
      COMMIT;
    END;
  END LOOP;
END;