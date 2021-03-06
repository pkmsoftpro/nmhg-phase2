--Purpose    : WR Upload - coverage upload procedure
--Author     : Rahul Katariya
--Created On : 09/07/2010
--Impact     : WR Upload

CREATE OR REPLACE
PROCEDURE UPLOAD_WARRANTY_COVERAGE(
    P_POL_DEFN_ID   IN NUMBER,
    P_WARRANTY_ID   IN NUMBER,
    P_SERIAL_ID     IN NUMBER,
    P_SHIP_DATE     IN DATE,
    P_DELIVERY_DATE IN DATE,
    P_BU_INFO       IN VARCHAR2,
    P_UPDATED_BY    IN NUMBER,
    P_IS_RED_CVG OUT VARCHAR2)
AS
  V_POLICY_ID           NUMBER(19) := 0;
  V_POLICY_AUDIT_ID     NUMBER(19) := 0;
  V_MONTHS_FRM_SHIPMENT NUMBER     := 0;
  V_MONTHS_FRM_DELIVERY NUMBER     := 0;
  V_HOURS_COVERED       NUMBER     := 0;
  V_POLICY_TYPE         VARCHAR2(20);
  V_SHIP_COVERAGE_TILL_DATE DATE;
  V_DEL_COVERAGE_TILL_DATE DATE;
  V_COVERAGE_END_DATE DATE;
BEGIN
  P_IS_RED_CVG := 'FALSE';
  BEGIN
    SELECT NVL(ID, 0)
    INTO V_POLICY_ID
    FROM POLICY p
    WHERE WARRANTY        = P_WARRANTY_ID
    AND POLICY_DEFINITION = P_POL_DEFN_ID;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    V_POLICY_ID := 0;
  END;
  IF V_POLICY_ID = 0 THEN
    BEGIN
      SELECT WARRANTY_TYPE
      INTO V_POLICY_TYPE
      FROM POLICY_DEFINITION
      WHERE id = P_POL_DEFN_ID;
      SELECT MONTHS_FRM_SHIPMENT,
        MONTHS_FRM_DELIVERY,
        SERVICE_HRS_COVERED
      INTO V_MONTHS_FRM_SHIPMENT,
        V_MONTHS_FRM_DELIVERY,
        V_HOURS_COVERED
      FROM POLICY_DEFINITION
      WHERE ID               = P_POL_DEFN_ID
      AND BUSINESS_UNIT_INFO = P_BU_INFO;
      SELECT (ADD_MONTHS(P_SHIP_DATE, V_MONTHS_FRM_SHIPMENT)-1)
      INTO V_SHIP_COVERAGE_TILL_DATE
      FROM DUAL;
      SELECT (ADD_MONTHS(P_DELIVERY_DATE, V_MONTHS_FRM_DELIVERY)-1)
      INTO V_DEL_COVERAGE_TILL_DATE
      FROM DUAL;
      IF V_SHIP_COVERAGE_TILL_DATE < V_DEL_COVERAGE_TILL_DATE THEN
        V_COVERAGE_END_DATE       := V_SHIP_COVERAGE_TILL_DATE;
        IF upper(V_POLICY_TYPE)    = 'GOODWILL' THEN
          P_IS_RED_CVG            := 'FALSE';
        ELSE
          P_IS_RED_CVG := 'TRUE';
        END IF;
      ELSE
        V_COVERAGE_END_DATE := V_DEL_COVERAGE_TILL_DATE;
        P_IS_RED_CVG        := 'FALSE';
      END IF;
      IF V_COVERAGE_END_DATE < P_DELIVERY_DATE THEN
        V_COVERAGE_END_DATE := P_DELIVERY_DATE;
      END IF;
      SELECT POLICY_SEQ.NEXTVAL INTO V_POLICY_ID FROM DUAL;
      SELECT POLICY_AUDIT_SEQ.NEXTVAL INTO V_POLICY_AUDIT_ID FROM DUAL;
      INSERT
      INTO POLICY
        (
          ID,
          AMOUNT,
          CURRENCY,
          POLICY_DEFINITION,
          WARRANTY,
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
          V_POLICY_ID,
          0,    --HARD CODED AND HAVE TO GET THE CLARIFICATION
          'USD',--HARD CODED AND HAVE TO GET THE CLARIFICATION
          P_POL_DEFN_ID,
          P_WARRANTY_ID,
          SYSDATE,
          P_BU_INFO
          || '-Upload',
          1,
          SYSDATE,
          P_UPDATED_BY,
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        );
      INSERT
      INTO POLICY_AUDIT
        (
          ID,
          STATUS,
          FROM_DATE,
          TILL_DATE,
          FOR_POLICY,
          CREATED_ON,
          COMMENTS,
          SERVICE_HOURS_COVERED,
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
          V_POLICY_AUDIT_ID,
          'Active',
          P_DELIVERY_DATE,
          V_COVERAGE_END_DATE,
          V_POLICY_ID,
          (SYSDATE-TO_DATE(19700101,'YYYYMMDD'))*86400,
          'Uploaded',
          V_HOURS_COVERED,
          SYSDATE,
          P_BU_INFO
          || '-Upload',
          1,
          SYSDATE,
          P_UPDATED_BY,
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        );
      UPDATE EXTENDED_WARRANTY_NOTIFICATION
      SET NOTIFICATION_TYPE  = 'Completed'
      WHERE POLICY           = P_POL_DEFN_ID
      AND FOR_UNIT           = P_SERIAL_ID
      AND BUSINESS_UNIT_INFO = P_BU_INFO;
    END;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;
/
commit
/