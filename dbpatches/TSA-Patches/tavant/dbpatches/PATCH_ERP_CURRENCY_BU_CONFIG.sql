--Purpose    : BU Config for Currency to be used for ERP Interactions
--Created On : 21-Jan-2010
--Created By : Rahul Katariya
--Impact     : None


INSERT INTO CONFIG_PARAM values (config_param_seq.nextval,'Currency to be used for ERP interactions','Currency to be used for ERP interactions','erpCurrency','java.lang.String',sysdate,'TSA-Migration | Added to boothstrap from DBPatch PATCH_ERP_CURRENCY_BU_CONFIG.sql',sysdate,56,CAST(sysdate AS TIMESTAMP),CAST(sysdate AS TIMESTAMP),1,'select',null,1,null,1,1)
/
Insert Into Config_Param_Option Values (Config_Param_Option_seq.nextval,'Dealers Currency','dealersCurrency')
/
Insert Into Config_Param_Option Values (Config_Param_Option_seq.nextval,'USD','usd')
/
Insert Into Config_Param_Option Values (Config_Param_Option_seq.nextval,'EUR','eur')
/
Insert Into Config_Param_Options_Mapping Values (CFG_PARAM_OPTNS_MAPPING_SEQ.nextval, (select id from CONFIG_PARAM where NAME='erpCurrency'), (select id from CONFIG_PARAM_OPTION where value='dealersCurrency'))
/
Insert Into Config_Param_Options_Mapping Values (CFG_PARAM_OPTNS_MAPPING_SEQ.nextval, (select id from CONFIG_PARAM where NAME='erpCurrency'), (select id from CONFIG_PARAM_OPTION where value='usd'))
/
Insert Into Config_Param_Options_Mapping Values (CFG_PARAM_OPTNS_MAPPING_SEQ.nextval, (select id from CONFIG_PARAM where NAME='erpCurrency'), (select id from CONFIG_PARAM_OPTION where value='eur'))
/
INSERT INTO CONFIG_VALUE values (CONFIG_VALUE_SEQ.nextval,1,'',(select id from CONFIG_PARAM where NAME='erpCurrency'),sysdate,'TSA-Migration | Added to boothstrap from DBPatch PATCH_ERP_CURRENCY_BU_CONFIG.sql',sysdate,56,CAST(sysdate AS TIMESTAMP),CAST(sysdate AS TIMESTAMP),1,'Thermo King TSA',(select id from CONFIG_PARAM_OPTION where value='usd'))
/
Commit
/