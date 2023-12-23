 insert into t_prom_d 
 --目标单号
 select  '202310090000001', 
rowno, 
distype, 
wareid, 
batchno, 
disrate, 
promqty, 
promprice, 
promminprice, 
mempromprice, 
mempromminprice, 
promqty_c, 
promqty_c_flag, 
integral_times, 
promdays, 
memdisrate, 
stamp, 
classcode, 
salegroupid, 
lastsaleprice, 
set_price_flag, 
profitrate, 
typeno, 
compid, 
profitrate_e, 
starttime, 
endtime, 
mempromqty, 
mempromqty_c, 
minprice, 
limitedtype, 
onedaypromqty
--源单号
from t_prom_d WHERE promno='202208100000007';

select count(*) from t_prom_d where promno='202311030000002';
select * from t_prom_d where promno='202311030000002';
