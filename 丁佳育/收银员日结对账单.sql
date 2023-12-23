--在零售缴款差异报表中 查询后选中一行点击按钮生成该门店的收银员日结对账单
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
select ''||f_get_serial('PAYC','81124')
into v_checkno
from dual ;  



select nvl(round(sum(netsum),2),0) netsum,nvl(round(sum(loss),2),0) loss,nvl(round(sum(netsum + loss),2),0) netsumloos
into v_netsum,v_netsumloss,v_loss
from t_sale_h h where h.busno = p_busno and trunc(accdate) = 
trunc(p_accdate) ;
--select sum(rechargeamt) from V_PAYEE_CHECK  where busno =81124 and accdate = to_date('2023-11-03','yyyy-mm-dd') ;
/*select nvl(round(sum(netsum),2),0) netsum,nvl(round(sum(loss),2),0) loss,nvl(round(sum(netsum + loss),2),0) netsumloos from t_sale_h h where h.busno = 81124 and trunc(accdate) = 
to_date('2023-11-03','yyyy-mm-dd') ;*/


select NULL checkno, NULL rowno, paytype, SUM(netsum), SUM(paymentsum), SUM(divesum), NULL notes, NULL subjectid, NULL subjectname, NULL vencusno, 
SUM(rechargeamt), case when MAX(is_pay_interface) = 1 then SUM(netsum) else 0.00 end  AS amt_confirm,SUM(advance_payment_amt),   
SUM(advance_payment_amt) AS advance_deposit_amt, MAX(is_pay_interface),SUM(rechargeamt) as rechargesum 
from V_PAYEE_CHECK	where busno =81124   and( accdate = to_date('2023-11-03','yyyy-mm-dd') 
or accdate  = to_date('99990101','yyyy-mm-dd') ) group by paytype,busno;

--生成主表
INSERT INTO t_payee_check_h 
(checkno,compid,busno,createdate,netsum,netsumloss,loss,accdate,payee,lastmodify,lasttime,status,checkbit1,
checkbit2,checkbit3,checkbit4,checkbit5,createuser,createtime,acc_flag,bill_status,rechargeamt) 
VALUES (v_checkno,p_compid,p_busno,sysdate,v_netsum,v_netsumloss,v_loss,sysdate,168,168,sysdate,0,0,0,0,0,0,168,
sysdate,1,'0',0);
--生成明细表 
end;


INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) 
VALUES ('23110311240101',1,'1',17299.350000,17299.350000,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) 
VALUES ('23110311240101',2,'43',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',3,'44',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',4,'45',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',5,'46',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',6,'47',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',7,'48',16240.640000,16240.640000,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',8,'67',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',9,'91',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',10,'Z003',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',11,'Z009',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',12,'Z010',5.400000,5.400000,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',13,'Z011',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',14,'Z012',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',15,'Z014',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',16,'Z015',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',17,'Z016',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',18,'Z017',50901.470000,50901.470000,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',19,'Z018',70549.130000,70549.130000,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',20,'Z020',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',21,'Z021',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',22,'Z022',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',23,'Z025',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',24,'Z027',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',25,'Z030',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',26,'Z032',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',27,'Z034',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',28,'Z037',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',29,'Z042',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',30,'Z043',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',31,'Z044',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',32,'Z050',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',33,'Z051',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',34,'Z052',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',35,'Z060',161760.370000,161760.370000,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',36,'Z061',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',37,'Z062',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',38,'Z063',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',39,'Z064',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',40,'Z065',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',41,'Z067',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',42,'Z068',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',43,'Z069',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',44,'Z070',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',45,'Z071',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',46,'Z072',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',47,'Z073',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',48,'Z074',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',49,'Z075',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',50,'Z076',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',51,'Z077',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',52,'Z078',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',53,'Z079',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',54,'Z080',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',55,'Z081',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',56,'Z082',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',57,'Z083',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',58,'Z084',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',59,'Z085',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',60,'Z086',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',61,'Z087',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',62,'Z088',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',63,'Z089',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',64,'Z090',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',65,'Z091',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',66,'Z092',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',67,'Z093',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',68,'Z094',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',69,'Z095',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',70,'Z096',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',71,'Z097',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',72,'Z098',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',73,'Z099',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',74,'Z100',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',75,'Z101',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',76,'Z102',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',77,'Z103',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum,ifonline) VALUES ('23110311240101',78,'Z104',0,0,0,0,0,0,0,0,0,1)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',79,'Z105',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',80,'Z106',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',81,'Z995',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',82,'Z996',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',83,'Z997',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',84,'Z998',0,0,0,0,0,0,0,0,0)
INSERT INTO t_payee_check_d (checkno,rowno,paytype,netsum,paymentsum,divesum,rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface,rechargesum) VALUES ('23110311240101',85,'Z999',0,0,0,0,0,0,0,0,0)

