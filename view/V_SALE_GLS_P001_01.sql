create or replace view V_SALE_GLS_P001_01 as
SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘亏' else '批发出库单' end as djlx,
       a.lgobe,
      trim(MATNR) MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE when  ZODERtype   in('4','5')  then '盘亏'  else
      case  when bupa='4577' then '杭州瑞人堂医药连锁有限公司上塘路健康药房'
        when bupa='4545' then '瑞人堂医药集团股份有限公司温岭涌泉药店'
          else  case when  bupa like'2%' then '瑞人堂医药集团股份有限公司温岭龙泉药店' else
         case
        WHEN name1 LIKE '%诊%'  THEN (SELECT orgname FROM s_busi@hydee_zy WHERE busno IN (SELECT zmdz1 FROM s_busi@hydee_zy WHERE  busno = to_number( '8'||a.BUPA) ))
         ELSE name1 end end end end ) as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_out a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
select wareid from d_gls_ware_py
  )
 and LGORT  IN ('P001','P018','P021') AND WERKS='D001'  AND ZODERtype in('2','4','5')  AND  bupa<>'D010' AND ZDATE >= DATE'2023-12-26'
 and trim(a.zgysph) not in ('U59K','UB3F')
 --and 1=2--and   a.zdate between add_months(trunc(sysdate),-3) and trunc(sysdate)
UNION ALL
 --D001 批发退货单
SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘盈'else '批发退货单' end as djlx,
       a.lgobe,
       MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE when  ZODERtype   in('4','5')  then '盘盈'  else
       case when bupa='4577' then '杭州瑞人堂医药连锁有限公司上塘路健康药房'
        when bupa='4545' then '瑞人堂医药集团股份有限公司温岭涌泉药店'
         else  case when  bupa like'2%' then '瑞人堂医药集团股份有限公司温岭龙泉药店' else
         case
        WHEN name1 LIKE '%诊%'  THEN (SELECT orgname FROM s_busi@hydee_zy WHERE busno IN (SELECT zmdz1 FROM s_busi@hydee_zy WHERE  busno = to_number( '8'||a.BUPA) ))
         ELSE name1 end end end end) as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_in a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
select wareid from d_gls_ware_py
  )
 and LGORT  IN ('P001','P018','P021') AND WERKS='D001'  AND ZODERtype in('2','4','5')  AND  bupa<>'D010' AND ZDATE >= DATE'2023-12-26'
 and trim(a.zgysph) not in ('U59K','UB3F')
 --and 1=2-- and   a.zdate between add_months(trunc(sysdate),-3) and trunc(sysdate)
 UNION ALL
 --D010  批发出库单
 SELECT
      a.zdate,
      a.WERKS,
      '浙江瑞人堂药业有限公司' as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘亏' else '批发出库单' end as djlx,
       a.lgobe,
      trim(MATNR) MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE when  ZODERtype   in('4','5')  then '盘亏'  else
      case  when bupa='4577' then '杭州瑞人堂医药连锁有限公司上塘路健康药房'
        when bupa='4545' then '瑞人堂医药集团股份有限公司温岭涌泉药店'
        WHEN bupa='9059' then '杭州瑞人堂医药连锁有限公司仁爱路健康药房'
           else
         case
        WHEN name1 LIKE '%诊%'  THEN (SELECT orgname FROM s_busi@hydee_zy WHERE busno IN (SELECT zmdz1 FROM s_busi@hydee_zy WHERE  busno = to_number( '8'||a.BUPA) ))
         ELSE name1 end end end ) as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_out a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
select wareid from d_gls_ware_py
  )
 and LGORT  IN ('P001') AND WERKS='D010'  AND ZODERtype in('2','4','5')  AND  bupa<>'D001' AND ZDATE >= DATE'2023-12-26'
 and trim(a.zgysph) not in ('U59K','UB3F')
 --and 1=2-- and   a.zdate between add_months(trunc(sysdate),-3) and trunc(sysdate) AND a.zdate<>DATE'2023-05-31'
 UNION ALL
 --D010 批发退货单
SELECT
      a.zdate,
      a.WERKS,
      '浙江瑞人堂药业有限公司' as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘盈'else '批发退货单' end as djlx,
       a.lgobe,
       MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE when  ZODERtype   in('4','5')  then '盘盈'  else
       case when bupa='4577' then '杭州瑞人堂医药连锁有限公司上塘路健康药房'
        when bupa='4545' then '瑞人堂医药集团股份有限公司温岭涌泉药店'
          WHEN bupa='9059' then '杭州瑞人堂医药连锁有限公司仁爱路健康药房'
         else
         case
        WHEN name1 LIKE '%诊%'  THEN (SELECT orgname FROM s_busi@hydee_zy WHERE busno IN (SELECT zmdz1 FROM s_busi@hydee_zy WHERE  busno = to_number( '8'||a.BUPA) ))
         ELSE name1 end end end ) as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_in a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
select wareid from d_gls_ware_py
  )
 and LGORT  IN ('P001') AND WERKS='D010'  AND ZODERtype in('2','4','5')  AND  bupa<>'D001' AND ZDATE >= DATE'2023-12-26'
 and trim(a.zgysph) not in ('U59K','UB3F')
 --and 1=2-- and   a.zdate between add_months(trunc(sysdate),-3) and trunc(sysdate) AND a.zdate<>DATE'2023-05-31'



 UNION ALL
 --P888,P006入库移仓分配
select
zdate,null,'台州瑞人堂药业有限公司','P001',null,null,matnr,to_char(b.WARENAME),b.WARESPEC,zscqymc,orgname,
case when ls<0 then ls else 0 end as rksl,
case when ls>0 then ls else 0 end as cksl,
ph ,MSEH6,null,null
from d_gls_pjfp a
left join t_ware_base@hydee_zy b on a.matnr=b.wareid
where a.zdate>=DATE'2023-12-26'
and trim(a.ph) not in ('U59K','UB3F')
UNION ALL
--导入  date'2023-04-01' and date'2023-11-01
select GZDATE,NULL,NAME1,NULL as lgort,decode(rksl,0,'批发出库单','批发退货单') as DJLX,NULL,trim(MATNR),MAKTX,b.WARESPEC,
f.FACTORYNAME as  ZSCQYMC,NAME2,RKSL,CKSL,a.PH,b.WAREUNIT,NULL,NULL
FROM d_gls_sale a
left join t_ware_base@hydee_zy b on a.matnr=b.wareid
left join t_factory@hydee_zy f on b.factoryid=f.factoryid

WHERE GZDATE>=DATE'2023-01-01'
UNION ALL
--10100568,10108932,10500013,10502495,10502496,2023/6/30,2023/6/29
SELECT zdate,'D001' AS werks,zname1,'P001' AS lgort,djlx, lgobe,matnr,maktx,zguig,zscqymc,orgname,rksl,cksl,
ph,dw,dj,je
from d_gls_rkfp
where zdate>=DATE'2023-12-26'
UNION ALL
--10601827
SELECT
      a.zdate,
      a.WERKS,
      decode(werks,'D001','台州瑞人堂药业有限公司','瑞人堂医药集团股份有限公司') as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘亏' else '批发出库单' end as djlx,
       a.lgobe,
      trim(MATNR) MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      name1 as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_out a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
   10601827
  )
 AND WERKS IN('D001','D002')  AND ZODERtype in('2','4','5')  AND ZDATE >= DATE'2023-12-26'
 --and 1=2

UNION ALL
SELECT
      a.zdate,
      a.WERKS,
      decode(werks,'D001','台州瑞人堂药业有限公司','瑞人堂医药集团股份有限公司') as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘盈'else '批发退货单' end as djlx,
       a.lgobe,
       MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      name1 as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_in a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
  10601827
  )
 AND WERKS IN('D001','D002')  AND ZODERtype in('2','4','5')  AND ZDATE >= DATE'2023-12-26'
 --and 1=2

  -- D001 和 D010 p003  10502632 这个体现P003
 union all

SELECT
      a.zdate,
      a.WERKS,
      DECODE(werks,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂药业有限公司') as zname1,
       LGORT,
      case when ZODERtype in('4','5') then '盘亏' else '批发出库单' end as djlx,
       a.lgobe,
      trim(MATNR) MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE when  ZODERtype   in('4','5')  then '盘亏'  else
      case  when bupa='4577' then '杭州瑞人堂医药连锁有限公司上塘路健康药房'
        when bupa='4545' then '瑞人堂医药集团股份有限公司温岭涌泉药店'
          else  case when  bupa like'2%' then '瑞人堂医药集团股份有限公司温岭龙泉药店' else
         case
        WHEN name1 LIKE '%诊%'  THEN (SELECT orgname FROM s_busi@hydee_zy WHERE busno IN (SELECT zmdz1 FROM s_busi@hydee_zy WHERE  busno = to_number( '8'||a.BUPA) ))
         ELSE name1 end end end end ) as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_out a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
 10502632
  )
 and LGORT  IN ('P003') AND WERKS in('D001','D010')  AND ZODERtype in('2','4','5')  AND  bupa NOT IN('D001','D010') AND ZDATE >= DATE'2023-12-26'
 and trim(a.zgysph) not in ('U59K','UB3F')
 --and 1=2
 UNION ALL
 SELECT
      a.zdate,
      a.WERKS,
      decode(werks,'D001','台州瑞人堂药业有限公司','浙江瑞人堂药业有限公司') as zname1,
       LGORT,
      case when ZODERtype in(4,5) then '盘盈'else '批发退货单' end as djlx,
       a.lgobe,
       MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE when  ZODERtype   in(4,5)  then '盘盈'  else
       case when bupa='4577' then '杭州瑞人堂医药连锁有限公司上塘路健康药房'
        when bupa='4545' then '瑞人堂医药集团股份有限公司温岭涌泉药店'
          WHEN bupa='9059' then '杭州瑞人堂医药连锁有限公司仁爱路健康药房'
         else
         case
        WHEN name1 LIKE '%诊%'  THEN (SELECT orgname FROM s_busi@hydee_zy WHERE busno IN (SELECT zmdz1 FROM s_busi@hydee_zy WHERE  busno = to_number( '8'||a.BUPA) ))
         ELSE name1 end end end ) as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
    a.MENGE*dmbtr AS je
  from stock_in a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
  where matnr in (
10502632
  )
 and LGORT  IN ('P003') AND WERKS in('D001','D010')  AND ZODERtype in('2','4','5')  AND  bupa NOT IN('D001','D010') AND ZDATE >= DATE'2023-12-26'
 and trim(a.zgysph) not in ('U59K','UB3F')
 --and 1=2
/

