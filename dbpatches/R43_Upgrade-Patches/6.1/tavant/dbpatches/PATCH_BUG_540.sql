--PURPOSE    : PATCH FOR MAKING RULENUMBER 100005 WITH D_ACTIVE=0 (because this record is no longer useful for users)
--AUTHOR     : shilpi.singh
--CREATED ON : 2-MAY-11
--IMPACT     : MAKING INACTIVE RULENUMBER 100005
UPDATE DOMAIN_RULE SET D_ACTIVE = 0 
WHERE CONTEXT='DcapValidationRules' 
AND BUSINESS_UNIT_INFO='Thermo King TSA' 
AND RULE_NUMBER='100005' 
AND OGNL_EXPRESSION like '(isClaimingDealerSameAsRetailingDealer%'
/
COMMIT
/