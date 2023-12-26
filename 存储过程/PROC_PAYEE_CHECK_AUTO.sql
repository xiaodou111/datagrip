create or replace procedure proc_payee_check_auto(p_compid  in number,
                                                  p_busno   in number,
                                                  p_accdate in date)
is
v_checkno varchar2(200);
v_netsum number(14,4);
v_netsumloss number(14,4);
v_loss  number(14,4);
begin
  --生成单号
select ''||f_get_serial('PAYC',p_busno)
into v_checkno
from dual ;
  DBMS_OUTPUT.PUT_LINE('v_checkno'||'---'||v_checkno);

/*select nvl(round(sum(netsum),2),0) netsum,nvl(round(sum(loss),2),0) loss,nvl(round(sum(netsum + loss),2),0) netsumloos from t_sale_h h where h.busno = 81010 and trunc(accdate) = to_date('2023-11-06','yyyy-mm-dd') ;
select sum(rechargeamt) from V_PAYEE_CHECK  where busno =81010 and accdate = to_date('2023-11-06','yyyy-mm-dd') ;

--==============================================================
--通道号: 1, 交互结果=true, 请求耗时=2797ms.  执行时间: 2023-11-06 09:58:49.190
select NULL checkno, NULL rowno, paytype, SUM(netsum), SUM(paymentsum), SUM(divesum), NULL notes, NULL subjectid, NULL subjectname, NULL vencusno, SUM(rechargeamt), case when MAX(is_pay_interface) = 1 then SUM(netsum) else 0.00 end  AS amt_confirm,SUM(advance_payment_amt),   SUM(advance_payment_amt) AS advance_deposit_amt, MAX(is_pay_interface),SUM(rechargeamt) as rechargesum from V_PAYEE_CHECK  where busno =81010   and( accdate = to_date('2023-11-06','yyyy-mm-dd') or accdate  = to_date('99990101','yyyy-mm-dd') )
group by paytype,busno;

--==============================================================
select checkno,createdate from t_payee_check_h h where trunc(h.createdate) = trunc(to_date('2023/11/06 09:58:41','yyyy/mm/dd hh24:mi:ss'))
and nvl(bill_status,'0') ='0' and status<>2 and busno =81010;*/


select nvl(round(sum(netsum),2),0) netsum,nvl(round(sum(loss),2),0) loss,nvl(round(sum(netsum + loss),2),0) netsumloos
into v_netsum,v_loss,v_netsumloss
from t_sale_h h where h.busno = p_busno and trunc(accdate) =
trunc(p_accdate) ;





--生成主表
INSERT INTO t_payee_check_h
(checkno,compid,busno,createdate,netsum,netsumloss,loss,accdate,payee,lastmodify,lasttime,status,CHECKER1,checkbit1,
checkbit2,checkbit3,checkbit4,checkbit5,createuser,createtime,acc_flag,bill_status,rechargeamt,NOTES)
VALUES (v_checkno,p_compid,p_busno,
p_accdate,
v_netsum,v_netsumloss,v_loss,
p_accdate,
10007723,10007723,sysdate,0,10007723,1,0,0,0,0,10007723,
sysdate,1,'0',0,'零售缴款差异报表生成');
--生成明细表
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,
advance_deposit_amt,is_pay_interface,rechargesum)
select                       checkno,rownum,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,
advance_deposit_amt,is_pay_interface,rechargesum from (
select v_checkno as checkno,null as rowno,paytype,SUM(netsum) netsum, SUM(paymentsum) paymentsum, SUM(divesum) divesum, 
NULL notes, NULL subjectid, NULL subjectname, NULL vencusno, 
SUM(rechargeamt) rechargeamt, case when MAX(is_pay_interface) = 1 then SUM(netsum) else 0.00 end  AS amt_confirm,SUM(advance_payment_amt)advance_payment_amt,   
SUM(advance_payment_amt) AS advance_deposit_amt, MAX(is_pay_interface) is_pay_interface,SUM(rechargeamt) as rechargesum 
from V_PAYEE_CHECK where busno =p_busno   and( accdate = p_accdate
or accdate  = to_date('99990101','yyyy-mm-dd') ) group by paytype,busno  ) ;
--插入list表,状态为1解锁
insert into t_payee_check_list(compid,busno,createdate,status,checkno,lastsaleno,lasttime)
values(p_compid,p_busno,p_accdate,1,v_checkno,null,null);

/*select checkno,rownum,paytype,netsum,paymentsum,divesum,notes,subjectid,subjectname,vencusno,rechargeamt,amt_confirm,advance_payment_amt,
advance_deposit_amt,is_pay_interface,rechargesum from (
select v_checkno as checkno,null as rowno,paytype,SUM(netsum) netsum, SUM(paymentsum) paymentsum, SUM(divesum) divesum,
NULL notes, NULL subjectid, NULL subjectname, NULL vencusno,
SUM(rechargeamt) rechargeamt, case when MAX(is_pay_interface) = 1 then SUM(netsum) else 0.00 end  AS amt_confirm,SUM(advance_payment_amt)advance_payment_amt,
SUM(advance_payment_amt) AS advance_deposit_amt, MAX(is_pay_interface) is_pay_interface,SUM(rechargeamt) as rechargesum
from V_PAYEE_CHECK where busno =p_busno   and( accdate = p_accdate
or accdate  = to_date('99990101','yyyy-mm-dd') ) group by paytype,busno  ) ;*/

end;
/

