--Purpose    : Adding error codes for warranty claim upload
--Author     : Bharath kumar
--Created On : 26/04/2010
--Impact     : None

insert into upload_error values(1108,'DC036_MP','MISCELLANEOUS PARTS')
/
insert into upload_error values(1109,'DC036_RP','REPLACED IR PARTS')
/
insert into upload_error values(1110,'DC036_ALH','REASON FOR EXTRA LABOR HOURS')
/
insert into upload_error values(1111,'DC074','LABOUR HOURS')
/
insert into upload_mgt_upload_errors values(4,1108)
/
insert into upload_mgt_upload_errors values(4,1109)
/
insert into upload_mgt_upload_errors values(4,1110)
/
insert into upload_mgt_upload_errors values(4,1111)
/
insert into i18nupload_error_text values(1108,'en_US','Miscellaneous Parts  cost category is not allowed for this product',1108)
/
insert into i18nupload_error_text values(1109,'en_US','Thermo King TSA Parts cost category is not allowed for this product',1109)
/
insert into i18nupload_error_text values(1110,'en_US','This is user is not eligible to add extra labour hours',1110)
/
insert into i18nupload_error_text values(1111,'en_US','Labor hours cost category is not allowed for this product',1111)
/
commit
/


