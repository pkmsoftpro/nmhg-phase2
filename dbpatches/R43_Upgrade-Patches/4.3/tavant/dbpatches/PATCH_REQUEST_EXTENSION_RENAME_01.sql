--Purpose    : Correcting staging table name
--Author     : Kuldeep Patil
--Created On : 17/08/2010

--UPDATE UPLOAD_MGT SET STAGING_TABLE = 'STG_REQUESTS_FOR_EXTENSION', validation_procedure = 'UPLOAD_REQ_FOR_EXTN_VALIDATION', upload_procedure = 'UPLOAD_REQ_FOR_EXTN_UPLOAD' where --name_of_template = 'requestForExtension'
--/
-- Kuldeep - Moved this part to PATCH_REQ_EXT_UPLOAD_UC08.sql DB patch so this patch is not needed.
commit
/