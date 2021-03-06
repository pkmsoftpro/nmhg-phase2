CREATE OR REPLACE PROCEDURE GEN_CAMPAIGN_NOTIFICATION_ALL (v_campaign_id NUMBER)
AS
   CURSOR c1
   IS
      SELECT DISTINCT items
                 FROM CAMPAIGN_COVERAGE_ITEMS camcovitems, CAMPAIGN cam
                WHERE camcovitems.CAMPAIGN_COVERAGE = cam.CAMPAIGN_COVERAGE
                  AND cam.ID = v_campaign_id;

   v_campaign_coverage_id   NUMBER := 0;
   v_dealership_id          NUMBER := 0;
   v_dealer_id              NUMBER := 0;
   v_seq_id                 NUMBER := 0;
   v_temp_id                NUMBER := 0;
BEGIN
   DELETE FROM CAMPAIGN_NOTIFICATION
         WHERE CAMPAIGN = v_campaign_id
           AND CLAIM = NULL
           AND NVL (notification_status, 'PENDING') = 'PENDING';

   COMMIT;

   BEGIN
      SELECT MAX (ID)
        INTO v_seq_id
        FROM CAMPAIGN_NOTIFICATION;

      IF v_seq_id IS NULL
      THEN
         v_seq_id := 0;
      END IF;
   END;

   FOR c1_rec IN c1
   LOOP

      BEGIN
         SELECT owner_ship
           INTO v_dealership_id
           FROM (SELECT   *
                     FROM INVENTORY_TRANSACTION
                    WHERE transacted_item = c1_rec.items
                 ORDER BY transaction_order  DESC) inv_transaction,
                Service_Provider dealer
          WHERE inv_transaction.owner_ship = dealer.ID AND ROWNUM = 1;

         BEGIN
            SELECT 1
              INTO v_temp_id
              FROM CAMPAIGN_NOTIFICATION campnoti
             WHERE campnoti.CAMPAIGN = v_campaign_id
               AND campnoti.ITEM = c1_rec.items
               AND campnoti.DEALERSHIP = v_dealership_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_seq_id := v_seq_id + 1;

               INSERT INTO CAMPAIGN_NOTIFICATION
                           (ID, notification_status, VERSION, DEALERSHIP,
                            ITEM, CAMPAIGN, CLAIM, D_CREATED_ON, D_CREATED_TIME,
                            D_UPDATED_ON, D_UPDATED_TIME, D_ACTIVE
                           )
                    VALUES (v_seq_id, 'PENDING', 0, v_dealership_id,
                            c1_rec.items, v_campaign_id, NULL, 
                            SYSDATE, CAST( SYSDATE AS TIMESTAMP),
                            SYSDATE, CAST( SYSDATE AS TIMESTAMP), 1
                           );
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      COMMIT;
   END LOOP;

   UPDATE CAMPAIGN
      SET notifications_generated = 1
    WHERE ID = v_campaign_id;

   COMMIT;
END;