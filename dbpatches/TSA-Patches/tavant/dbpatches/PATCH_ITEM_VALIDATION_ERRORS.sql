INSERT INTO UPLOAD_ERROR(ID,CODE,UPLOAD_FIELD) VALUES(UPLOAD_ERROR_SEQ.NEXTVAL,'IT020','SERVICE PART')
/
INSERT INTO UPLOAD_MGT_UPLOAD_ERRORS VALUES((SELECT ID FROM UPLOAD_MGT WHERE NAME_OF_TEMPLATE = 'itemUpload'), (SELECT ID FROM UPLOAD_ERROR WHERE CODE = 'IT020'))
/
INSERT INTO I18NUPLOAD_ERROR_TEXT VALUES(I18N_UPLOAD_ERROR_SEQ.NEXTVAL,'en_US','Invalid Service Part value', (SELECT ID FROM UPLOAD_ERROR WHERE CODE = 'IT020'))
/
commit
/
