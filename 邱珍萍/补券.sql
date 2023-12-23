select membercardno,  sum(sl) from (

select saleno,membercardno,sum(sl) sl from (

select h.saleno,h.membercardno,h.accdate,d.sl as wareqty,d.wareid,case when d.wareid=30968118 then floor(d.sl/6)
when d.wareid in(30968098,30966767) then floor(d.sl/4) end as sl   
from 
--明细表每个单号商品数量和
(select d.saleno,sum(d.wareqty) as sl,d.wareid
from t_sale_d d
 where d.wareid in (30968118,30968098,30966767) 
and d.accdate between date'2023-09-20' and date'2023-10-05'
and d.saleno not in(select RETSALENO from  t_sale_return_h where CHECKDATE between date'2023-09-20' and date'2023-10-05' )
and d.saleno not in (select SALENO from  t_sale_return_h where CHECKDATE between date'2023-09-20' and date'2023-10-05' )
group by d.saleno,d.wareid)
 d 
join t_sale_h h on h.saleno=d.saleno
where h.saleno not in (select saleno  from t_internal_sale_h   where shiftdate between date'2023-09-20' and date'2023-10-05') 
) a

where sl>0
 group by saleno,membercardno )
 where membercardno is not null
 group by membercardno
 
 select * from t_sale_d where saleno='2309213005092505'
