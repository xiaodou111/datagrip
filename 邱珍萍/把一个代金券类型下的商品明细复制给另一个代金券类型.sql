--把国庆现金券复制给现金抵用券

insert into T_CASH_COUPON_WARE 
select '现金抵用券',WAREID,COMPID from T_CASH_COUPON_WARE 
WHERE coupon_type='国庆现金券'
-- 先在
--CPROC_COUPON_INFO_RSV
--找类型进到哪个存储过程
--比如33进到
--cproc_coupon_618_rsv

--SPYY 新增一个券类型 商品预约活动报表
SELECT s_dddw_list.dddwname,
       s_dddw_list.dddwlistdata,
       s_dddw_list.dddwliststatus,
       s_dddw_list.dddwlistdisplay,
       s_dddw_list.compidlist,
       s_dddw_list.notes,
       s_dddw_list.status,
       s_dddw_list.sort
 ,s_dddw_list.md_dddwlistdata FROM s_dddw_list s_dddw_list
 WHERE  s_dddw_list.dddwname = 'SPYY' 
