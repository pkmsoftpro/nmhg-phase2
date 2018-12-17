--Purpose    :INSERT TRANSITION FOR CREATING RECOVERY CLAIMS AS A SUPPORT TASK
--Author     : Smita Kadle
--Created On : 06-Nov-09


INSERT INTO JBPM_TRANSITION (ID_,NAME_,PROCESSDEFINITION_,FROM_,TO_,FROMINDEX_)
VALUES (HIBERNATE_SEQUENCE.nextval,'ProcessRecovery',(SELECT ID_ FROM JBPM_PROCESSDEFINITION WHERE NAME_ = 'ClaimSubmission'),
	(SELECT ID_ FROM JBPM_NODE WHERE NAME_='Close' AND PROCESSDEFINITION_= (SELECT ID_ FROM JBPM_PROCESSDEFINITION WHERE NAME_ = 'ClaimSubmission')),
	(SELECT ID_ FROM JBPM_NODE WHERE NAME_='CheckSupplierRecovery' AND PROCESSDEFINITION_= (SELECT ID_ FROM JBPM_PROCESSDEFINITION WHERE NAME_ = 'ClaimSubmission')),
(SELECT MAX(FROMINDEX_)+1 FROM JBPM_TRANSITION WHERE FROM_=(SELECT ID_ FROM JBPM_NODE WHERE NAME_='Close' AND PROCESSDEFINITION_= (SELECT ID_ FROM JBPM_PROCESSDEFINITION WHERE NAME_ = 'ClaimSubmission'))))
/
COMMIT
/