--Purpose    : Alter DCAP tables following change in AuditableColEntity
--Author     : rashmi.malik
--Created On : 4-Sep-08

ALTER TABLE DCAP_CLAIM_AUDIT ADD D_CREATED_TIME DATE
/

ALTER TABLE DCAP_CLAIM_AUDIT ADD D_UPDATED_TIME DATE
/

ALTER TABLE DCAP_DETAIL_HISTORY ADD D_CREATED_TIME DATE
/

ALTER TABLE DCAP_DETAIL_HISTORY ADD D_UPDATED_TIME DATE
/

COMMIT
/