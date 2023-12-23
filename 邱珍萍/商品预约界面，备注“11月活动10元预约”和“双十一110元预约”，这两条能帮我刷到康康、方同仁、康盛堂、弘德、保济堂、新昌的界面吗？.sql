SELECT a.compid,a.wareid,b.warecode,b.warename,b.warespec,tf.factoryname,ta.areaname,b.wareunit,b.lastsaleprice,    
a.begindate,a.enddate,a.user_begindate,a.user_enddate,a.is_print,a.use_busno,
a.reserve_type,a.reserve_amt,a.coupon_values,a.least_sales,a.busnos,a.notes,
a.checker1,a.checker2,a.checker3,a.checker4,a.checker5,
a.checkbit1,a.checkbit2,a.checkbit3,a.checkbit4,a.checkbit5,
a.checkdate1,a.checkdate2,a.checkdate3,a.checkdate4,a.checkdate5,
a.createuser,a.createtime,a.lastmodify,a.lasttime,a.status,a.mem_limit,a.pst_ware,a.pst_begindate,a.pst_enddate FROM d_ware_coupon_rsv a 
     join t_ware b on a.compid=b.compid and a.wareid=b.wareid and b.status=1
     left join t_factory tf on b.factoryid=tf.factoryid
     left join t_area ta on b.areacode=ta.areacode WHERE (  a.notes like '%11月活动%' or  a.notes like '%双十一%'  );
     
     /*select * from d_ware_coupon_rsv
     1010,1020,1030,1050,1040,1070*/
 insert into d_ware_coupon_rsv select 1070, 
wareid, 
begindate, 
enddate, 
user_begindate, 
user_enddate, 
reserve_type, 
reserve_amt, 
coupon_values, 
least_sales, 
busnos, 
notes, 
checker1, 
checker2, 
checker3, 
checker4, 
checker5, 
checkbit1, 
checkbit2, 
checkbit3, 
checkbit4, 
checkbit5, 
checkdate1, 
checkdate2, 
checkdate3, 
checkdate4, 
checkdate5, 
createuser, 
createtime, 
lastmodify, 
lasttime, 
stamp, 
status, 
is_print, 
use_busno, 
mem_limit, 
pst_ware, 
pst_begindate, 
pst_enddate
from d_ware_coupon_rsv a  where a.compid=1000 
and (  a.notes like '%11月活动%' or  a.notes like '%双十一%'  )
