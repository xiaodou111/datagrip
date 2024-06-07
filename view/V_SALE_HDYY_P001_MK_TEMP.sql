create view V_SALE_HDYY_P001_MK_TEMP as
SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
      LGORT,
      '批发出库单' as djlx,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      '瑞人堂医药集团股份有限公司龙泉店'
      as orgname,
      0 AS rksl,
      a.ls AS cksl,
      a.ph ,
      a.dw ,
      a.dj ,
     a.je
  from v_accept_mk_p001 a
  WHERE  zdate>=DATE'2023-01-01'
 and  LGORT IN( 'P888','P006') AND  djlx LIKE '%入库%'

 union ALL
 SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
      LGORT,
      '批发出库单' as djlx,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
     '瑞人堂医药集团股份有限公司龙泉店'
      as orgname,
      -a.ls AS rksl,
      0 AS cksl,
      a.ph ,
      a.dw ,
      a.dj ,
     a.je
  from v_accept_mk_p001 a
 WHERE zdate>=DATE'2023-01-01'
 and  LGORT IN( 'P888','P006') AND  djlx LIKE '%退货%'

 UNION ALL

  SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
      a.LGORT,
      '批发出库单'  as djlx,
      a.MATNR,
      a.MAKTX,
      a.ZGUIG,
      a.zscqymc,
     CASE WHEN a.bupa LIKE '24%' THEN  '瑞人堂医药集团股份有限公司龙泉店' ELSE  name1 END  as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
     a.MENGE*a.dmbtr AS je
  FROM stock_out a
  WHERE a.zodertype=2  AND matnr in ('10100162','10500174','10105941','10500176','10110839','10500214','10111793','10303762','10303818','10305285','10504713','10305416')
   AND a.lifnr IN ('110032','110325','110293','110673','110388','110473','110030','110149',
  '110451','110372','110093','110191','110353')
   AND lgort='P001'  AND zdate>=DATE'2023-11-01' AND name1 NOT LIKE '%浙江益洲药业%' AND  werks in ('D001')

   UNION ALL


  SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' AS zname1,
      a.LGORT,
      '批发退货单'  as djlx,
      a.MATNR,
      a.MAKTX,
      a.ZGUIG,
      a.zscqymc,
       CASE WHEN a.bupa LIKE '24%' THEN  '瑞人堂医药集团股份有限公司龙泉店' ELSE  name1 END  as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
     a.MENGE*a.dmbtr AS je
  FROM stock_in a
  WHERE a.zodertype=2  AND matnr in ('10100162','10500174','10105941','10500176','10110839','10500214','10111793','10303762','10303818','10305285','10504713','10305416')
    AND a.lifnr IN ('110032','110325','110293','110673','110388','110473','110030','110149',
  '110451','110372','110093','110191','110353')
   AND lgort='P001'  AND zdate>=DATE'2023-11-01'  AND zname1 NOT LIKE '%浙江益洲药业%' AND  werks in ('D001')
  UNION ALL
  SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
      a.LGORT,
     CASE WHEN a.LGORT='P001' THEN '批发出库单' ELSE '批发入库单' END  as djlx,
     -- a.lgobe,
      a.MATNR,
      a.MAKTX,
      a.ZGUIG,
      a.zscqymc,
     '瑞人堂医药集团股份有限公司龙泉店'
      as orgname,
      decode(a.lgort,'P001',0,a.menge) AS rksl,
      decode(a.lgort,'P001',a.menge,0) AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.dmbtr AS dj,
     a.MENGE*a.dmbtr AS je
  from stock_out a
  left join  s_busi@hydee_zy b  ON to_char(b.BUSNO )= '8'||a.BUPA
  LEFT JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr  and a.zgysph=c.zgysph
  WHERE a.zodertype=3  AND a.matnr in ('10100162','10500174','10105941','10500176','10110839','10500214','10111793','10303762','10303818','10305285','10504713','10305416')
    AND a.lifnr IN ('110032','110325','110293','110673','110388','110473','110030','110149',
  '110451','110372','110093','110191','110353') AND ((a.lgort ='P001' AND c.lgort='P888') OR (a.lgort ='P001' AND c.lgort='P006')
  OR  (a.lgort ='P888' AND c.lgort='P001') OR (a.lgort ='P006' AND c.lgort='P001') )  AND a.zdate>=DATE'2023-11-01' AND  a.werks in ('D001')
  union all
  --11月前配送数据导入进来
  select "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW","DJ","JE" from d_sale_mk   where ZDATE<date'2023-11-01'
/

