
with s as (
select w.wareid,w.warename,w.warespec,f.factoryname,w.wareunit,tws.saleprice
from t_ware_base w
join t_factory f on w.factoryid=f.factoryid
left join t_ware_saleprice tws on w.wareid=tws.wareid and tws.compid=1000 and tws.salegroupid='1000001'
),
--店间调拨单未审核单数
DSSM_NUM as(
select d.wareid,count(h.srcbusno) sl from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSM' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by d.wareid
),
--店间调拨在途数量,金额  
DSSM_ZT as (
  select a.wareid,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid WHERE a.billcode='DSSM'
   group by a.wareid
),
 --跨公司调拨单未审核单数  
DSSC_NUM as (
 select d.wareid,count(h.srcbusno) sl from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSC' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by d.wareid
  ),
DSSC_ZT as (
--跨公司调拨在途数量,金额    
  select a.wareid,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid WHERE a.billcode='DSSC'
   group by a.wareid  
),
DISTAPPLY_NUM as (
  --退仓申请单未完成退货单数
  select d.wareid,count( h.applyno) sl
  from   T_DISTAPPLY_H h
  join   T_DISTAPPLY_d d on h.APPLYNO=d.APPLYNO 
  where h.distno is null 
--and d.wareid=10100462
--and h.createtime>=date'2022-01-01'
  group by d.wareid
),
--退仓申请单在途数量,金额
DISTAPPLY_ZT AS (
 select a.wareid,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
   WHERE a.billcode='RAP'
   and a.wareqty<>0
   group by a.wareid 
   )
 select s.wareid,s.warename,s.warespec,s.factoryname,s.wareunit,s.saleprice,DSSM_NUM.sl,DSSM_ZT.sl,DSSM_ZT.je,DSSC_NUM.sl,
 DSSC_ZT.SL,DSSC_ZT.JE,DISTAPPLY_NUM.SL,DISTAPPLY_ZT.SL,DISTAPPLY_ZT.JE
 FROM s
 left join DSSM_NUM ON S.WAREID=DSSM_NUM.WAREID
 left join DSSM_ZT ON  DSSM_ZT.WAREID=S.WAREID
 left join DSSC_NUM ON DSSC_NUM.WAREID=S.WAREID
 left join DSSC_ZT ON  DSSC_ZT.WAREID=S.WAREID
 left join DISTAPPLY_NUM ON DISTAPPLY_NUM.WAREID=S.WAREID
 left join DISTAPPLY_ZT ON DISTAPPLY_ZT.WAREID=S.WAREID
 
 
 
 
