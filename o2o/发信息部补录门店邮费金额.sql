declare 
v_saleno      t_sale_h.saleno%TYPE;


begin
   
--update d_o2o_bf set busno=81288 where busno=1288
  

for res in ( select a.busno,wareid,sl,je,s.compid from d_o2o_bf a
  left join s_busi s on trim(a.busno)=trim(s.busno) )loop
  v_saleno := f_get_serial('SAL', res.compid);
  
   insert into t_internal_sale_d 
(saleno,rowno,wareid,stallno,makeno,stdprice,netprice,wareqty,saler,invalidate,distype,purprice,purtax,avgpurprice,rowtype,saletax,batid,disrate)

values( v_saleno,1,50000827,'11111','11111',res.je,res.je,1,168,to_date('2024-04-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),1,res.je,13.00,res.je,1,13.00,null,1)
 ;

INSERT INTO t_internal_sale_h (saleno,billcode,compid,busno,posno,shiftid,createuser,payee,stdsum,netsum,paytype,precash,status,checkbit1,checkbit2,
checkbit3,checkbit4,checkbit5,lastmodify,lasttime,saletype,orderno,reasons,platform) 
values( v_saleno,'SALNG',res.compid,res.busno,'001',10,168,168,res.je,res.je,'Z025',res.je,0,0,0,0,0,0,168,
sysdate,1,v_saleno,'OMS差错问题下账','京东到家');

end loop;

end ;

/*delete from  t_internal_sale_d where saleno in (select saleno from  t_internal_sale_h where lasttime>=date'2023-10-21' and paytype='Z025')

delete from t_internal_sale_h where lasttime>=date'2023-10-21' and paytype='Z025'

select * from t_internal_sale_h where lasttime>=date'2023-10-21' and paytype='Z025'
update t_internal_sale_h set LASTTIME=sysdate  where lasttime>=date'2023-10-21' and paytype='Z025'


select * from t_sale_h h 
join t_sale_d d on h.saleno=d.saleno
join d_o2o_bf bf on d.busno=bf.busno and d.wareid=bf.wareid 
 where h.accdate=date'2023-10-21'*/
 
