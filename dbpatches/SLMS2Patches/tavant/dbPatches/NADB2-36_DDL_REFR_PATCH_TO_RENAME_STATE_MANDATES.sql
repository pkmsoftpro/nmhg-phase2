--Purpose    : DDL for NMHGSLMS-425 -Renaming OEM_PARTS to OEM_PARTS_PERCENT in State_Mandates
--Author     : Arpitha Nadig AR
--Created On : 14-JAN-2013
ALTER TABLE STATE_MANDATES RENAME COLUMN OEM_PARTS TO OEM_PARTS_PERCENT
/