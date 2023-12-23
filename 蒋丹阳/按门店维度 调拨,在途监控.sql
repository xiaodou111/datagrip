--��������δ��˵�����������
select h.srcbusno,count(distinct h.DISTNO) from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSM' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.srcbusno

--��������(����)δ�����ƷƷ����(ȥ��),����,���

  select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSM'
   group by h.srcbusno
  
--��������δ��˵��������룩
select h.objbusno,count(distinct h.DISTNO) from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSM' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.objbusno
 
--��������(����)δ�����ƷƷ����(ȥ��),����,���

  select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSM'
   group by h.srcbusno

--�繫˾������δ��˵�����������
select h.srcbusno,count(distinct h.DISTNO) from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSC' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.srcbusno

--�繫˾������(����)δ�����ƷƷ����(ȥ��),����,���

  select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSC'
   group by h.srcbusno
   
--�繫˾������δ��˵��������룩
select h.objbusno,count(distinct h.DISTNO) from t_dist_h h
join t_dist_d d on h.distno=d.distno
 where h.billcode = 'DSSC' and h.status=0
 and h.createtime>=date'2023-01-01'
  group by h.objbusno
 
--�繫˾������(����)δ�����ƷƷ����(ȥ��),����,���

  select h.srcbusno,count(distinct a.wareid) as pzs,sum(a.wareqty) sl,sum(a.wareqty*b.purprice) je
   FROM t_await_store_ware a
  LEFT JOIN t_store_i b
    ON a.batid = b.batid
   AND a.compid = b.compid
   AND a.wareid = b.wareid 
  left join  t_dist_h h on a.billno=h.distno
   WHERE a.billcode='DSSC'
   group by h.srcbusno
   
--�˲����뵥δ����˻�����   
select h.srcbusno,count( h.applyno)
  from   T_DISTAPPLY_H h
  join   T_DISTAPPLY_d d on h.APPLYNO=d.APPLYNO 
  where h.distno is null 
  --and d.wareid=10100462
  --and h.createtime>=date'2022-01-01'
  group by h.srcbusno
