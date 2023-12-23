--店间调拨单未审核单数（调出）


with s as (
select s.compid,tb.classname as syb,
tb1.classname as pq,
s.zmdz1,s.busno,s.orgname
from s_busi s
join t_busno_class_set ts on s.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode
join t_busno_class_set ts1 on s.busno=ts1.busno and ts1.classgroupno ='304'
join t_busno_class_base tb1 on ts1.classgroupno=tb1.classgroupno and ts1.classcode=tb1.classcode
),
DSSM_NUM_DC as (
select h.srcbusno,count(distinct h.DISTNO) sl from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSM' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.srcbusno
),
--店间调拨单(调出)未审核商品品种数(去重),数量,金额
DSSM_ZT_DC as (
  select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSM'
   group by h.srcbusno
),
--店间调拨单未审核单数（调入）
DSSM_NUM_DR as (
select h.objbusno,count(distinct h.DISTNO) sl from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSM' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.objbusno
),
--店间调拨单(调入)未审核商品品种数(去重),数量,金额
DSSM_ZT_DR as 
(
 select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSM'
   group by h.srcbusno
),

--跨公司调拨单未审核单数（调出）
DSSC_NUM_DC as (
select h.srcbusno,count(distinct h.DISTNO) sl from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSC' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.srcbusno
),
--跨公司调拨单(调出)未审核商品品种数(去重),数量,金额
DSSC_ZT_DC as 
(
select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSC'
   group by h.srcbusno
),
--跨公司调拨单未审核单数（调入）
DSSC_NUM_DR as (
select h.objbusno,count(distinct h.DISTNO) sl from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSC' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.objbusno
),
--跨公司调拨单(调入)未审核商品品种数(去重),数量,金额
DSSC_ZT_DR as (
  select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSC'
   group by h.srcbusno
),
--退仓申请单未完成退货单数
DISTAPPLY_NUM as (   
select h.srcbusno,count( h.applyno) sl
  from   T_DISTAPPLY_H h
  join   T_DISTAPPLY_d d on h.APPLYNO=d.APPLYNO 
  where h.distno is null 
  --and d.wareid=10100462
  and h.createtime>=date'2022-01-01'
  group by h.srcbusno
  ),
  
--退仓申请单在途品种数,数量,金额
DISTAPPLY_ZT AS (
  select a.busno,count(distinct a.wareid)as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
   WHERE a.billcode='RAP'
   and a.wareqty<>0
   group by a.busno 
   )
  select s.compid,s.syb,s.pq,s.zmdz1,s.busno,s.orgname,DSSM_NUM_DC.sl as 店间调拨单未审核单数调出,DSSM_ZT_DC.pzs as pzs1 ,DSSM_ZT_DC.sl as sl1,DSSM_ZT_DC.je as je1,
  DSSM_NUM_DR.sl as 店间调拨单未审核单数调入,DSSM_ZT_DR.pzs as pzs2,DSSM_ZT_DR.sl as sl2,DSSM_ZT_DR.je as je2,DSSC_NUM_DC.sl as 跨公司店间调拨单未审核单数调出,
  DSSC_ZT_DC.pzs as pzs3,DSSC_ZT_DC.sl as sl3,DSSC_ZT_DC.je as je3,DSSC_NUM_DR.sl as 跨公司店间调拨单未审核单数调入,DSSC_ZT_DR.pzs as pzs4,DSSC_ZT_DR.sl as sl4,DSSC_ZT_DR.je as je4,
  DISTAPPLY_NUM.sl as 退仓申请单未完成退货单数,DISTAPPLY_ZT.pzs as pzs5,DISTAPPLY_ZT.sl as sl5,DISTAPPLY_ZT.je as je5
  from s  
  left join DSSM_NUM_DC  on s.busno=DSSM_NUM_DC.srcbusno
  left join DSSM_ZT_DC on   s.busno=DSSM_ZT_DC.srcbusno
  left join DSSM_NUM_DR on  s.busno=DSSM_NUM_DR.objbusno
  left join DSSM_ZT_DR on   s.busno=DSSM_ZT_DR.srcbusno
  left join DSSC_NUM_DC on  s.busno=DSSC_NUM_DC.srcbusno
  left join DSSC_ZT_DC on   s.busno=DSSC_ZT_DC.srcbusno
  left join DSSC_NUM_DR on  s.busno=DSSC_NUM_DR.objbusno
  left join DSSC_ZT_DR on   s.busno=DSSC_ZT_DR.srcbusno
  left join DISTAPPLY_NUM ON s.busno=DISTAPPLY_NUM.srcbusno
  left join DISTAPPLY_ZT ON s.busno=DISTAPPLY_ZT.BUSNO
