--PURPOSE    : PATCH TO RENAME HOURS IN SERVICE LABEL IN TEMPLATE TO MACHINE HOURS
--AUTHOR     : ROOPA KARIYAPPA
--CREATED ON : 17-JULY-12

alter table STG_DRAFT_CLAIM rename column HOURS_IN_SERVICE to MACHINE_HOURS
/
alter table STG_INSTALL_BASE rename column HOURS_IN_SERVICE to MACHINE_HOURS
/