select INSTITUTIONITEMCODE,INSTITUTIONITEMNAME,CENTERITEMCODE,USAGEFREQUENCYDESC,EACHDOSAGE AS  每次用量 
from HYDEE_SYB_HZ.pros_matched_item@hydee
--SELECT * from pros_matched_item
--SELECT * from t_ware_base
select * from  HYDEE_SYB_HZ.pros_order@hydee
