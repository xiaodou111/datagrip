create view V_SALE_QL_P001_PY as
SELECT
      a.zdate,a.WERKS,'台州瑞人堂药业有限公司' as zname1,
      'P001' as lgort,'批发出库单' as djlx,'正常仓' as lgobe,MATNR,
      MAKTX,ZGUIG,zscqymc,
      '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' as orgname,
       0 AS rksl,a.ls AS cksl,a.ph ,a.dw ,a.dj ,a.je,a.fileno,a.VFDAT
  from v_accept_ql_p001 a
  where matnr in (
 select WAREID FROM D_QL_WARE_PY
  )
 and  LGORT IN( 'P888','P006','P030') AND  djlx LIKE '%入库%'
 union ALL
 SELECT
      a.zdate,a.WERKS,'台州瑞人堂药业有限公司' as zname1,
       'P001','批发退货单' as djlx, '正常仓',MATNR,
      MAKTX,ZGUIG,zscqymc,
      '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' as orgname,
       -a.ls AS rksl,0 AS cksl,a.ph ,a.dw,a.dj,-a.je,a.fileno,a.VFDAT
  from v_accept_ql_p001 a
  where matnr in (
  select WAREID FROM D_QL_WARE_PY
  )
 and  LGORT IN( 'P888','P006','P030') AND  djlx LIKE '%退货%'
---
union all
--D001出入库
SELECT

      a.zdate,a.WERKS,decode(a.WERKS,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂医药连锁有限公司') as zname1,
       LGORT,case when ZODERtype in('4','5') then '盘亏' else '批发出库单' end as djlx,a.lgobe,MATNR,
       MAKTX,ZGUIG,zscqymc,
     case when ZODERtype in('4','5') then '盘亏' else  name1 end as orgname,
      0 AS rksl,a.menge AS cksl,a.zgysph AS ph,a.mseh6 AS dw,
      a.dmbtr AS dj,a.MENGE*dmbtr AS je,t.fileno,a.VFDAT
  from stock_out a
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
  where matnr in (
  select WAREID FROM D_QL_WARE_PY
  )
 and LGORT  IN ('P001','P018','P021') AND WERKS in ('D001')  AND ZODERtype in ('2','4','5')  AND LIFNR in ('110673','110388')
 and zdate>=date'2023-09-01'
 union all
SELECT
      a.zdate,a.WERKS,decode(a.WERKS,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂医药连锁有限公司') as zname1,
       LGORT,case when ZODERtype in('4','5') then '盘盈'else '批发退货单' end as djlx,a.lgobe,MATNR,
       MAKTX,ZGUIG,zscqymc,
      case when ZODERtype in('4','5') then '盘亏' else  name1 end as  orgname,
      a.menge AS rksl,0 AS cksl,a.zgysph AS ph,a.mseh6 AS dw,
      a.dmbtr AS dj,a.MENGE*dmbtr AS je,t.fileno,a.VFDAT
  from stock_in a
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
  where matnr in (
  select WAREID FROM D_QL_WARE_PY
  )
 and LGORT IN ('P001','P018','P021') AND WERKS in ('D001')  AND ZODERtype in ('2','4','5') AND LIFNR in ('110673','110388')
 and zdate>=date'2023-09-01'


 --移仓D001 P001移仓给P888、P006,出库数量不为0，单据类型改为批发出库单，再配送到瑞人堂龙泉药店（西药D）；
 --入库数量不为0，单据类型改为批发退货单，从瑞人堂龙泉药店（西药D）退回。（P888与P006之间的移仓单不体现）
 union all
 --P001移仓给P888、P006
  SELECT a.zdate,a.WERKS,'台州瑞人堂药业有限公司',a.lgort,'批发出库单',a.lgobe,a.matnr,a.maktx,a.zguig,a.zscqymc,'瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）',
  0 as rksl,a.menge as cksl,a.zgysph AS ph,a.mseh6 AS dw,a.dmbtr AS dj,a.MENGE*a.dmbtr AS je,t.fileno,a.VFDAT
  FROM  stock_out a
  INNER JOIN stock_in i ON a.zorder=i.zorder AND a.matnr=i.matnr AND a.zgysph=i.zgysph and a.CHARG=i.CHARG
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
   where a.matnr in (
  select WAREID FROM D_QL_WARE_PY
  )
 and a.WERKS in ('D001') and a.LGORT  IN ('P001')  and i.lgort in('P888','P006')  AND a.ZODERtype=3  AND a.LIFNR in ('110673','110388')
 and a.zdate>=date'2023-09-01'
 union all
  --P888、P006移仓给P001
   SELECT a.zdate,a.WERKS,'台州瑞人堂药业有限公司',a.lgort,'批发退货单',a.lgobe,a.matnr,a.maktx,a.zguig,a.zscqymc,'瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）',
  a.menge as rksl,0 as cksl,a.zgysph AS ph,a.mseh6 AS dw,a.dmbtr AS dj,a.MENGE*a.dmbtr AS je,t.fileno,a.VFDAT
  FROM  stock_out i
  INNER JOIN stock_in a ON a.zorder=i.zorder AND a.matnr=i.matnr AND a.zgysph=i.zgysph and a.CHARG=i.CHARG
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
   where a.matnr in (
  select WAREID FROM D_QL_WARE_PY
  )

 and i.WERKS in ('D001') and a.LGORT  IN ('P001') AND i.lgort in('P888','P006')  AND a.ZODERtype=3  AND a.LIFNR in ('110673','110388')
/

