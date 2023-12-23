WITH a AS(
SELECT  a.zdate,a.WERKS,a.LGORT,a.MATNR,a.MAKTX,a.ZGUIG,
      a.zscqymc,a.name1,a.menge,a.zgysph,a.mseh6,a.DMBTR,a.fileno,a.bupa,a.ZODERtype,a.LIFNR
      FROM stock_out a
      left join t_ware_base@hydee_zy d on a.matnr=d.wareid
      AND EXISTS(SELECT 1 FROM d_msd_ware w WHERE w.wareid=a.matnr)
 AND a.zdate>=DATE'2023-01-01'
)
SELECT a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
       name1   as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,a.fileno
     FROM a where  matnr not in (10113315) and a.werks in ('D001','D002','D006','D010') --and   name1 not like '%浙江瑞人堂药业%'
 and not (matnr=10106748 and zdate>=date'2023-04-01')
 and  LGORT IN ('P001','P030')
 and  LIFNR in ('110093','110673','110190')
 AND ZODERtype=2
 and  name1 not LIKE '%诊所%' and trim(a.bupa) NOT like '24%' and a.bupa not like 'D%'
