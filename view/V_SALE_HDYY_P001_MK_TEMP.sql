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
  SELECT a.zdate,a.WERKS,'台州瑞人堂药业有限公司',a.lgort,'批发出库单',a.matnr,a.maktx,a.zguig,a.zscqymc,'瑞人堂医药集团股份有限公司龙泉店',
  0 as rksl,a.menge as cksl,a.zgysph AS ph,a.mseh6 AS dw,a.dmbtr AS dj,a.MENGE*a.dmbtr AS je
  FROM  stock_out a
  INNER JOIN stock_in i ON a.zorder=i.zorder AND a.matnr=i.matnr AND a.zgysph=i.zgysph and a.CHARG=i.CHARG
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
   where a.matnr in (
  '10100162','10500174','10105941','10500176','10110839','10500214','10111793','10303762','10303818','10305285','10504713','10305416'
  )
 and a.WERKS in ('D001') and a.LGORT  IN ('P001')  and i.lgort in('P005','P006','P007','P888','P889')  AND a.ZODERtype=3
     AND a.LIFNR in ('110032','110325','110293','110673','110388','110473','110030','110149','110451','110372','110093','110191','110353')
 and a.zdate>=date'2023-11-01'
   --and 1=0
 union all
  --P888、P006移仓给P001
   SELECT a.zdate,a.WERKS,'台州瑞人堂药业有限公司',a.lgort,'批发退货单',a.matnr,a.maktx,a.zguig,a.zscqymc,'瑞人堂医药集团股份有限公司龙泉店',
  a.menge as rksl,0 as cksl,a.zgysph AS ph,a.mseh6 AS dw,a.dmbtr AS dj,a.MENGE*a.dmbtr AS je
  FROM  stock_out i
  INNER JOIN stock_in a ON a.zorder=i.zorder AND a.matnr=i.matnr AND a.zgysph=i.zgysph and a.CHARG=i.CHARG
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
   where a.matnr in (
 '10100162','10500174','10105941','10500176','10110839','10500214','10111793','10303762','10303818','10305285','10504713','10305416'
  )
 and i.WERKS in ('D001') and a.LGORT  IN ('P001') AND i.lgort in('P005','P006','P007','P888','P889')  AND a.ZODERtype=3
     AND a.LIFNR in ('110032','110325','110293','110673','110388','110473','110030','110149','110451','110372','110093','110191','110353')
 and a.zdate>=date'2023-11-01'
  union all
  --11月前配送数据导入进来
  select "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW","DJ","JE" from d_sale_mk   where ZDATE<date'2023-11-01'
/

