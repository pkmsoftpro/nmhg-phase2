--PURPOSE    : Patch for change the unique logic to supplier number and name combination in the customer upload logic only for supplier 
--AUTHOR     : Saya Sudha
--CREATED ON : 02-FEB-2012

INSERT INTO UPLOAD_ERROR(ID,CODE,UPLOAD_FIELD) VALUES(UPLOAD_ERROR_SEQ.NEXTVAL,'CU0028','CUSTOMER NUMBER')
/
INSERT INTO UPLOAD_MGT_UPLOAD_ERRORS VALUES(
(SELECT ID FROM UPLOAD_MGT WHERE NAME_OF_TEMPLATE = 'customerUpload'), 
(SELECT ID FROM UPLOAD_ERROR where code = 'CU0028' and upload_field='CUSTOMER NUMBER'))
/
INSERT INTO i18nupload_error_text VALUES(I18N_UPLOAD_ERROR_SEQ.NEXTVAL,'en_US','Supplier with Number and Name combination does not exist',
(select id from UPLOAD_ERROR where code = 'CU0028' and upload_field='CUSTOMER NUMBER'))
/
COMMIT
/