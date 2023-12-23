call p_hd_out_dist_dssm_h(202212138142081291) --调拨单
call p_hd_out_distapply_app_h(221207165833) --配送申请单,请货单
call p_hd_out_distapply_rap_h(2312070278961)  --退仓申请单
CALL p_hd_out_abnormity_h(22111411660794) --盘点作业单，损益单
call    p_jkctsj(22111412640445) --MSG_ID,COMPID,BILLCODE 

call p_hd_out_distapply_rap_h14(221114292430) --超14天的退仓申请单重推
call p_hd_out_dist_dssm_h14()--超14天的调拨单重推
call p_hd_out_abnormity_h14() --超14天的盘点作业单，损益单重推
