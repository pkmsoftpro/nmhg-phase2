--Purpose    : updating the value of new column added for previous data
--Author     : sUDAKSH cHOHAN
--Created On : 08/02/10
--Impact     : None

update recovery_info set saved_at_part_level = 1 where saved_at_part_level is null
/
commit
/


