delete from d_cash_coupon_info_temp;
 
 select * from d_cash_coupon_info_temp for update;
 
 
update t_cash_coupon_info set CREATETIME=ISSUING_DATE 

where coupon_no in(select COUPON_NO from d_cash_coupon_info_temp);
