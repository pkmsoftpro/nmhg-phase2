--Purpose    : Domain changes for supplier recovery module
--Author     : sUDAKSH cHOHAN
--Created On : 05/02/10
--Impact     : None

alter table recovery_claim_info add ( causal_Part_Recovery number(1,0))
/
update recovery_claim_info set causal_part_recovery = 1 where 
exists (select * from recovery_info where recovery_info.causal_part_recovery = recovery_claim_info.id)
/
update recovery_claim_info set causal_part_recovery = 0 where causal_part_recovery is null
/
insert into REC_INFO_REP_PARTS_REC(recovery_info, replaced_parts_recovery) 
(select id,causal_part_recovery  from recovery_info 
where recovery_info.causal_part_recovery is not null and recovery_info.d_active = 1)
/
commit
/
alter table recovery_info drop column causal_part_recovery
/
alter table recovery_claim_info add (recovery_claim number(19,0))
/
alter table recovery_claim add(recovery_claim_info number(19,0))
/
ALTER TABLE recovery_claim_info ADD (
	CONSTRAINT FK_REC_RECOVERY_CLAIM
	FOREIGN KEY (RECOVERY_CLAIM) 
	REFERENCES RECOVERY_CLAIM (ID)
)
/
ALTER TABLE RECOVERY_CLAIM ADD (
	CONSTRAINT FK_REC_RECOVERY_CLAIM_INFO
	FOREIGN KEY (RECOVERY_CLAIM_INFO) 
	REFERENCES RECOVERY_CLAIM_INFO (ID)
)
/
update recovery_claim_info a set a.recovery_claim = 
(select b.recovery_claims from rec_claim_info_rec_claims b
where b.recovery_claim_info = a.id)
/
drop table rec_claim_info_rec_claims
/
commit
/


