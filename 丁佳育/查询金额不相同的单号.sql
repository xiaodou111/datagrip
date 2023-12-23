select saleno,sum(netsum) from t_sale_h where accdate between date'2023-10-01' and date'2023-10-31' and saleno='2310011275001557' group by SALENO;
select SALENO,sum(NETPRICE*WAREQTY) from t_sale_d where accdate between date'2023-10-01' and date'2023-10-31' group by SALENO ;
select SALENO,sum(NETSUM) from t_sale_pay group by SALENO

with 
a1 as(
select saleno,round(sum(netsum),2) netsum from t_sale_h where accdate between date'2023-10-01' and date'2023-10-31'  group by SALENO
),
a2 as(
select SALENO,sum(nvl(t_sale_d.netamt,round((t_sale_d.wareqty  * t_sale_d.times * t_sale_d.netprice + t_sale_d.minqty  * t_sale_d.times * t_sale_d.minprice),2)))
 netsum from t_sale_d where accdate between date'2023-10-01' and date'2023-10-31' group by SALENO
),
a3 as(
select SALENO,round(sum(NETSUM),2) netsum from t_sale_pay group by SALENO
)
select a1.saleno,a1.netsum,a2.netsum,a3.netsum
from a1 
left join a2  on a1.saleno=a2.saleno
left join a3 on a1.saleno=a3.saleno
where 
(abs(a1.netsum-a2.netsum)>1) or (abs(a1.netsum-a3.netsum)>1) 
or (abs(a2.netsum-a3.netsum)>1)
