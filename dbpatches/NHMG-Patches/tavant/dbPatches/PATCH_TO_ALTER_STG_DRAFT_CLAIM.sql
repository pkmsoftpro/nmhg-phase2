--Purpose    : Patch for renaming columns.
--Author     : ROHIT MEHROTRA
--Created On : 15-MAY-2013

ALTER TABLE STG_DRAFT_CLAIM RENAME column REPLACED_OEM_PARTS TO REMOVED_OEM_PARTS
/
ALTER TABLE STG_DRAFT_CLAIM RENAME column REPLACED_OEM_PARTS_QUANTITY TO REMOVED_OEM_PARTS_QUANTITY
/