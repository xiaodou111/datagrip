CREATE OR REPLACE VIEW V_SALE_TSL_P001_01 AS
SELECT
      a.zdate,
      a.WERKS,
      DECODE(werks,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂药业有限公司')  as zname1,
      LGORT,
      '批发出库单' as djlx,
        null as   lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE
      WHEN  LGORT='P888' THEN
         '瑞人堂医药集团股份有限公司龙泉店'
      ELSE
         '瑞人堂医药集团股份有限公司涌泉店'
      end )as orgname,
      0 AS rksl,
      a.ls AS cksl,
      a.ph ,
      a.dw ,
     0 AS dj ,
    0 AS  je
  from v_accept_tsl_p001 a
  where matnr in (select wareid from d_tsl_ware)
 and  LGORT IN( 'P888','P006') AND  djlx LIKE '%入库%' AND  PH NOT  IN('350705025','350707043')

UNION ALL
SELECT
      a.zdate,
      a.WERKS,
         DECODE(werks,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
      null as    lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      (CASE
      WHEN  LGORT='P888' THEN
         '瑞人堂医药集团股份有限公司龙泉店'
      ELSE
         '瑞人堂医药集团股份有限公司涌泉店'
      end )as orgname,
      a.ls AS rksl,
      0 AS cksl,
      a.ph ,
      a.dw ,
    0 AS dj ,
    0 AS je
  from v_accept_tsl_p001 a
  where matnr in (select wareid from d_tsl_ware)
 and  LGORT IN( 'P888','P006') AND  djlx LIKE '%退货%' AND  PH NOT  IN('350705025','350707043')
 UNION all

 SELECT
      a.zdate,
      a.WERKS,
      DECODE(werks,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂药业有限公司') as zname1,
       LGORT,
      '批发出库单' as djlx,
       null as     lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
     case when bupa like '2%' then '瑞人堂集团有限公司温岭龙泉店(西药D)'  else name1 end  as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
     0 AS dj,
  0 AS je
  from stock_out a
  where matnr in (select wareid from d_tsl_ware) AND
  a.lifnr IN ('110032','110325','110293','110673','110388','110473','110015','110016','110190','110130','112581')
 and LGORT  IN ('P001','P018') AND WERKS IN('D001','D010')  AND ZODERtype=2 AND  zdate>=DATE'2023-01-01'
 AND  zgysph NOT  IN('350705025','350707043')
  UNION all
 SELECT
      a.zdate,
      a.WERKS,
         DECODE(werks,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂药业有限公司') as zname1,
       LGORT,
      '批发退货单' as djlx,
    null as    lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
     case when bupa like '2%' then '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  else name1 end as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
   0 AS dj,
   0 AS je
  from stock_in a
  where matnr in (select wareid from d_tsl_ware) AND
  a.lifnr IN ('110032','110325','110293','110673','110388','110473','110015','110016','110190','110130','112581')
 and LGORT IN ('P001','P018') AND WERKS IN('D001','D010')  AND ZODERtype=2 and  zdate>=DATE'2023-01-01'
 AND  zgysph NOT  IN('350705025','350707043')

 union all
   -----p001 与 P006  P888之间的移仓
 SELECT
      a.zdate,
      a.WERKS,
        DECODE(a.werks,'D001','台州瑞人堂药业有限公司','D010','浙江瑞人堂药业有限公司') as zname1,
      a.LGORT,
     CASE WHEN a.LGORT='P001' THEN '批发出库单' ELSE '批发入库单' END  as djlx,
 null as   lgobe,
      a.MATNR,
      a.MAKTX,
      a.ZGUIG,
      a.zscqymc,
    '瑞人堂集团有限公司温岭龙泉店(西药D)'   AS orgname,
      decode(a.lgort,'P001',0,a.menge) AS rksl,
      decode(a.lgort,'P001',a.menge,0) AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je
  from stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph
  WHERE a.zodertype=3  AND a.matnr in (select wareid from d_tsl_ware)
  AND ((a.lgort ='P001' AND c.lgort='P888') OR (a.lgort ='P001' AND c.lgort='P006') OR  (a.lgort ='P888' AND c.lgort='P001') OR (a.lgort ='P006' AND c.lgort='P001') )
   AND  to_char(a.zdate,'yyyy-mm-dd')>='2022-06-01'
   AND  a.zgysph NOT  IN('350705025','350707043')
UNION ALL
SELECT ZDATE,'D001',ZNAME1,LGORT,'批发出库单',null,MATNR,MAKTX,ZGUIG,ZSCQYMC,ORGNAME,RKSL,CKSL,PH,dw,0,0 FROM d_sale_tsl_ps
;
