--call CPROC_COUPON_INFO_RSV
declare
 v_qh1 t_cash_coupon_info.coupon_no%type;
 v_cnt integer ;
   v_begin date;
  v_end date;
    v_mobile t_memcard_reg.mobile%type;
begin
for res in (
  
 select 
 
max(issuing_date)as issuing_date, 
max(compid)as compid, 
max(busnos)as busnos, 
0 as coupon_values, 
0 as least_sales, 
'礼品券30701294' as coupon_type, 
'礼品券30701294' as coupon_desc, 
card_no, 
max(mobile)as mobile, 
max(start_date)as start_date, 
max(end_date)as end_date, 
max(pwd_judge_type)as pwd_judge_type, 
max(password) as password, 
max(use_status)as use_status, 
max(use_date)as use_date, 
max(status)as status, 
max(use_sale_no)as use_sale_no, 
max(use_busnos)as use_busnos, 
max(notes)as notes, 
max(createuser)as createuser, 
max(createtime)as createtime, 
max(lastmodify)as lastmodify, 
max(lasttime)as lasttime, 
max(stamp)as stamp, 
max(use_memcardno)as use_memcardno, 
max(openid)as openid, 
max(cost)as cost, 
max(cardno)as cardno, 
max(give_saleno)as give_saleno, 
2 as coupon_kind, 
max(payamt)as payamt, 
3 as advance_payamt, 
max(create_busno)as create_busno, 
max(create_tpye)as create_tpye, 
max(print_sn)as print_sn, 
max(bak4)as bak4, 
max(bak5)as bak5, 
max(bak6)as bak6, 
max(bak7)as bak7, 
max(bak8)as bak8, 
max(bak9)as bak9, 
max(bak10)as bak10, 
max(adv_type)as adv_type, 
max(banktype)as banktype, 
max(drag_type)as drag_type, 
max(adj_date)as adj_date
from T_CASH_COUPON_INFO where card_no  in(select * from  t_cash_coupon_info_temp)
--and NOTES like '%双十二3元预约%'
                        group by CARD_NO
)
 loop 
   v_qh1 := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => res.CREATE_BUSNO);
   
   
  
  INSERT INTO T_CASH_COUPON_INFO
        
        SELECT v_qh1, 
res.issuing_date, 
res.compid, 
res.busnos, 
res.coupon_values, 
res.least_sales, 
res.coupon_type, 
res.coupon_desc, 
res.card_no, 
res.mobile, 
res.start_date, 
res.end_date, 
res.pwd_judge_type, 
res.password, 
res.use_status, 
res.use_date, 
res.status, 
res.use_sale_no, 
res.use_busnos, 
res.notes, 
res.createuser, 
res.createtime, 
res.lastmodify, 
res.lasttime, 
res.stamp, 
res.use_memcardno, 
res.openid, 
res.cost, 
res.cardno, 
res.give_saleno, 
res.coupon_kind, 
res.payamt, 
res.advance_payamt, 
res.create_busno, 
res.create_tpye, 
res.print_sn, 
res.bak4, 
res.bak5, 
v_qh1, 
res.bak7, 
res.bak8, 
res.bak9, 
res.bak10, 
res.adv_type, 
res.banktype, 
res.drag_type, 
res.adj_date
from dual ;
DBMS_OUTPUT.PUT_LINE('card_no: ' || res.card_no ||'已发券');
  end loop;
  
  
  end ;
  
 /* select count(*)  from T_CASH_COUPON_INFO where card_no  in(select * from  d_memcard_temp)
and NOTES like '%双十二3元预约%'*/

/*select * from T_CASH_COUPON_INFO where card_no  in(select * from  t_cash_coupon_info_temp)
and NOTES like '%双十二3元预约%'
delete from t_cash_coupon_info_temp
select * from t_cash_coupon_info_temp for update
--预约金改0
update  T_CASH_COUPON_INFO set ADVANCE_PAYAMT=0 where COUPON_NO in (
select * from t_cash_coupon_info_temp
)
select ADVANCE_PAYAMT from T_CASH_COUPON_INFO where COUPON_NO in (
select * from t_cash_coupon_info_temp
)*/


--select * from  t_cash_coupon_info_temp for update

