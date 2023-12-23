--店间调拨单未审核单数
select d.wareid,count(h.srcbusno) from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSM' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by d.wareid
--店间调拨在途数量,金额  
  select a.wareid,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid WHERE a.billcode='DSSM'
   group by a.wareid
 --跨公司调拨单未审核单数  
 select d.wareid,count(h.srcbusno) from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSC' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by d.wareid
--跨公司调拨在途数量,金额    
  select a.wareid,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid WHERE a.billcode='DSSC'
   group by a.wareid  
  

  --退仓申请单未完成退货单数

  select d.wareid,count( h.applyno)
  from   T_DISTAPPLY_H h
  join   T_DISTAPPLY_d d on h.APPLYNO=d.APPLYNO 
  where h.distno is null 
  --and d.wareid=10100462
  --and h.createtime>=date'2022-01-01'
  group by d.wareid
  

  --退仓申请单在途数量,金额
  


  select a.wareid,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
   WHERE a.billcode='RAP'
   and a.wareqty<>0
   group by a.wareid 
