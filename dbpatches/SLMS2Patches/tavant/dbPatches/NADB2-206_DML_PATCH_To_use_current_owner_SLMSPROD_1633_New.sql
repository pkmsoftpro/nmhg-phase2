-- PURPOSE    : PATCH_To_use_current_owner_instead_of_transaction_ownership_SLMSPROD-1633
-- AUTHOR     : P RAGHAVENDRA RAJU.
-- CREATED ON : 04-SEPT-2014



create or replace
PROCEDURE                "GEN_CAMPAIGN_NOTIFICATION_NEW" (v_campaign_id NUMBER)
AS
   CURSOR c1
   IS
      SELECT DISTINCT items
                 FROM CAMPAIGN_COVERAGE_ITEMS camcovitems, CAMPAIGN cam
                WHERE camcovitems.CAMPAIGN_COVERAGE = cam.CAMPAIGN_COVERAGE
                  AND cam.ID = v_campaign_id;

   v_campaign_coverage_id       NUMBER := 0;
   v_dealership_id              NUMBER := 0;
   v_dealer_id                  NUMBER := 0;
   v_seq_id                     NUMBER := 0;
   v_campaign_notification_id   NUMBER := 0;
BEGIN
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
         SELECT ID
           INTO v_campaign_notification_id
           FROM CAMPAIGN_NOTIFICATION
          WHERE CAMPAIGN = v_campaign_id AND ITEM = c1_rec.items;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN

               SELECT current_owner
                 INTO v_dealership_id
                 FROM (SELECT   *
                           FROM INVENTORY_ITEM
                          WHERE id = c1_rec.items) inv_item,
                      Service_provider dealer
                WHERE inv_item.current_owner = dealer.ID AND ROWNUM = 1;

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
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
      END;

      COMMIT;
   END LOOP;

   UPDATE CAMPAIGN
      SET notifications_generated = 1
    WHERE ID = v_campaign_id;

   COMMIT;
END;