--PURPOSE    : To create a error code
--AUTHOR     : Nibedita
--CREATED ON : 14-Mar-2012

INSERT INTO UPLOAD_ERROR VALUES(UPLOAD_ERROR_SEQ.NEXTVAL,'IT024','ITEM GROUP CODE')
/
INSERT INTO UPLOAD_MGT_UPLOAD_ERRORS VALUES((SELECT ID FROM UPLOAD_MGT WHERE NAME_OF_TEMPLATE = 'itemUpload'),(SELECT ID FROM UPLOAD_ERROR where code = 'IT024' and upload_field='ITEM GROUP CODE'))
/
INSERT INTO i18nupload_error_text VALUES(I18N_UPLOAD_ERROR_SEQ.NEXTVAL,'en_US','Item Group Code can not be updated for an existing item',(select id from UPLOAD_ERROR where code = 'IT024' and upload_field='ITEM GROUP CODE'))
/
COMMIT
/