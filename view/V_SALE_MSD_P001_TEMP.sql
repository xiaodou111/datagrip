create view V_SALE_MSD_P001_TEMP as
SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
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
     a.menge*a.DMBTR AS je,d.fileno
  from stock_out a
  left join  s_busi@hydee_zy b  ON b.BUSNO= '8'||a.BUPA
    left join t_ware_base@hydee_zy d on a.matnr=d.wareid
  where  matnr not in (10113315) and a.werks in ('D001','D002','D006','D010') --and   name1 not like '%浙江瑞人堂药业%'
 and not (matnr=10106748 and zdate>=date'2023-04-01')
 and  LGORT IN ('P001','P030')
 and  LIFNR in ('110093','110673','110190')
 AND ZODERtype=2
 and  name1 not LIKE '%诊所%' and trim(a.bupa) NOT like '24%' and a.bupa not like 'D%'
 AND EXISTS(SELECT 1 FROM d_msd_ware w WHERE w.wareid=a.matnr )
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'

 --引入的数据 现在只有引入有数据其他语句时间范围都小于7月没取
 /* union all
  SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW",DJ, JE,fileno FROM v_sale_msd_p001_2
  --where 1=2
  union all
  SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW", DJ, JE,fileno FROM d_msd_lsck@hydee_zy
  WHERE zdate>=DATE'2022-12-01' AND zdate<=DATE'2022-12-31' */
  --zdate>=DATE'2023-01-01'
  --where 1=2
 /* union all
  ----特药
  SELECT cjsj,WERKS,xsfmc,'P001','销售出库单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,0,sl,ph,dw, DJ, JE,fileno FROM V_SALE_msd_ty_P001  WHERE sl>0
  --and 1=2
  union all
  SELECT cjsj,WERKS,xsfmc,'P001','销售退货单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,-sl,0,ph,dw, DJ, -JE,fileno FROM V_SALE_msd_ty_P001  WHERE sl<0*/
 --and 1=2

union all
 SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      name1   as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,d.fileno
  from stock_in a
  left join  s_busi@hydee_zy b  ON b.BUSNO = '8'||a.BUPA
    left join t_ware_base@hydee_zy d on a.matnr=d.wareid
  where matnr in (select wareid from d_msd_ware) and matnr not in (10113315) and a.werks in ('D001','D002','D006','D010') --and   name1 not like '%浙江瑞人堂药业%'
  and  LIFNR in ('110093','110673','110190')
 and  LGORT IN ('P001','P030') AND ZODERtype=2
 --AND a.zdate>=DATE'2023-06-30'
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 and  name1 not LIKE '%诊所%' and trim(a.bupa) NOT like '24%' and a.bupa not like 'D%'
 and not (matnr=10106748 and zdate>=date'2023-04-01')
 --and 1=2
 union all
----加盟店改成直营店
 SELECT
      a.zdate,
      a.WERKS,
   decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
       nvl(b.orgname,  '瑞人堂医药集团股份有限公司龙泉店(西药D)' ) as orgname,
      0 AS rksl,
      a.menge AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,d.fileno
  from stock_out a
  left join  d_msd_busno_jmd c on  '8'||trim(a.bupa)=c.jmbusno
  left join  s_busi@hydee_zy b  ON to_char(b.BUSNO )= '8'||c.dybusno
    left join t_ware_base@hydee_zy d on a.matnr=d.wareid
 where matnr in (select wareid from d_msd_ware)  and trim(a.bupa) like '24%' and zodertype=2
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'
 and a.werks in ('D001','D002','D006','D010') and LIFNR in ('110093','110673','110190')
 and not (matnr=10106748 and zdate>=date'2023-04-01')
 --and 1=2

 union all
 SELECT
      a.zdate,
      a.WERKS,
   decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
   --   a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
        nvl(b.orgname,  '瑞人堂医药集团股份有限公司龙泉店(西药D)' ) as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,d.fileno
  from stock_in a
  left join  d_msd_busno_jmd c on  '8'||trim(a.bupa)=c.jmbusno
  left join  s_busi@hydee_zy b  ON to_char(b.BUSNO )= '8'||c.dybusno
  left join t_ware_base@hydee_zy d on a.matnr=d.wareid
 where matnr in (select wareid from d_msd_ware)  and trim(a.bupa) like '24%' and zodertype=2 and  matnr<>10106748
  AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
  --AND a.zdate>=DATE'2023-06-30'
  and a.werks in ('D001','D002','D006','D010')   and LIFNR in ('110093','110673','110190')
  and not (matnr=10106748 and zdate>=date'2023-04-01') --and a.werks in ('D001','D006','D007','D010')
  --and 1=2

union all
----诊所75% 对应到 门店
 SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
       nvl(c.orgname,  '瑞人堂医药集团股份有限公司龙泉店(西药D)' )  as orgname,
      0 AS rksl,
      ceil(a.menge*0.75)  AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,d.fileno
  from stock_out a
  left join d_msd_busno_zs b on trim(a.bupa)=b.zsbm
  left join s_busi@hydee_zy c on b.busno=c.busno
  left join t_ware_base@hydee_zy d on a.matnr=d.wareid
where matnr in (select wareid from d_msd_ware)
 and  LGORT IN ('P001','P030') AND ZODERtype=2 and a.werks in ('D001','D002','D006','D010')  and LIFNR in ('110093','110673','110190')-- and a.werks in ('D001','D006','D007','D010')
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'
 and  name1  LIKE '%诊所%' and not (matnr=10106748 and zdate>=date'2023-04-01')
 --and 1=2
 union all
  SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
    --  a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
       nvl(c.orgname,  '瑞人堂医药集团股份有限公司龙泉店(西药D)' )  as orgname,
      ceil(a.menge*0.75) AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,d.fileno
  from stock_in a
left join d_msd_busno_zs b on trim(a.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
left join t_ware_base@hydee_zy d on a.matnr=d.wareid
where matnr in (select wareid from d_msd_ware)
 and  LGORT IN ('P001','P030') AND ZODERtype=2 and a.werks in ('D001','D002','D006','D010')  and LIFNR in ('110093','110673','110190') --and a.werks in ('D001','D006','D007','D010')  SELECT * FROM d_msd_busno_zs
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'
 and  name1  LIKE '%诊所%' and not (matnr=10106748 and zdate>=date'2023-04-01')--and 1=2
 union all

 SELECT
      a.zdate,
      a.WERKS,
    decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      a.name1 as orgname,
      0 AS rksl,
     floor(a.menge*0.25)  AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,
         d.fileno
  from stock_out a
     left join t_ware_base@hydee_zy d on a.matnr=d.wareid
where matnr in (select wareid from d_msd_ware)
 and  LGORT IN ('P001','P030') AND ZODERtype=2 and a.werks in ('D001','D002','D006','D010')   and LIFNR in ('110093','110673','110190')-- and a.werks in ('D001','D006','D007','D010')
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'
 and  name1  LIKE '%诊所%' and not (matnr=10106748 and zdate>=date'2023-04-01') --and 1=2
 union all
  SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '批发退货单' as djlx,
    --  a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      a.name1 as orgname,
      floor(a.menge*0.25)  AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,
     d.fileno
  from stock_in a
    left join t_ware_base@hydee_zy d on a.matnr=d.wareid
where matnr in (select wareid from d_msd_ware)
 and  LGORT IN ('P001','P030') AND ZODERtype=2  and a.werks in ('D001','D002','D006','D010')  and LIFNR in ('110093','110673','110190') --and a.werks in ('D001','D006','D007','D010')
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'
 and  name1  LIKE '%诊所%' and not (matnr=10106748 and zdate>=date'2023-04-01') --and 1=2
 union all
 -----p001 与 P006  P888之间的移仓
 SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      a.LGORT,
     CASE WHEN a.LGORT='P001' THEN '批发出库单' ELSE '批发入库单' END  as djlx,
    --  a.lgobe,
      a.MATNR,
      a.MAKTX,
      a.ZGUIG,
      a.zscqymc,
    '瑞人堂医药集团股份有限公司龙泉店(西药D)'   AS orgname,
      decode(a.lgort,'P001',0,a.menge) AS rksl,
      decode(a.lgort,'P001',a.menge,0) AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
       a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,
     d.fileno
  from stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.menge=c.menge
  left join t_ware_base@hydee_zy d on a.matnr=d.wareid
  WHERE a.zodertype=3  AND a.matnr in (select wareid from d_msd_ware)
  AND ((a.lgort ='P001' AND c.lgort='P888') OR (a.lgort ='P001' AND c.lgort='P006') OR  (a.lgort ='P888' AND c.lgort='P001') OR (a.lgort ='P006' AND c.lgort='P001') )
   AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
  -- AND  a.zdate>=DATE'2023-06-30'
   and a.LIFNR in ('110093','110673','110190')  and not (a.matnr=10106748 and a.zdate>=date'2023-04-01')--and 1=2
 union all
 ---按销量 均分至门店
  SELECT
      a.zdate,
      'D001',
      '台州瑞人堂药业有限公司' as zname1,
      'P000',
      '批发出库单' as djlx,
     -- '正常仓',
      to_char(a.wareid),
      to_char(b.warename),
      b.warespec,
      d.factoryname,
      c.orgname as orgname,
      0 AS rksl,
      a.wareqty AS cksl,
      ph AS ph,
      b.wareunit AS dw,
       a.dj AS dj,
     a.dj*a.wareqty AS je,
     b.fileno
  from d_msd_suiji2 a
  left join t_ware_base@hydee_zy b on a.wareid=b.wareid
  left join s_busi@hydee_zy c on (a.busno+80000)=c.busno
  left join t_factory@hydee_zy d on b.factoryid=d.factoryid
  WHERE a.wareqty>0
  AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
  --and a.zdate>=DATE'2023-06-30'  --and 1=2
   union all
  SELECT
      a.zdate,
      'D001',
      '台州瑞人堂药业有限公司' as zname1,
      'P000',
      '批发出库单' as djlx,
    --  '正常仓',
      to_char(a.wareid),
      to_char(b.warename),
      b.warespec,
      d.factoryname,
      c.orgname as orgname,
      a.wareqty AS rksl,
      0 AS cksl,
      a.ph AS ph,
      b.warespec AS dw,
       a.dj AS dj,
     a.dj*a.wareqty AS je,
     b.fileno
  from d_msd_suiji2 a
  left join t_ware_base@hydee_zy b on a.wareid=b.wareid
  left join s_busi@hydee_zy c on (a.busno+80000)=c.busno
  left join t_factory@hydee_zy d on b.factoryid=d.factoryid
  WHERE a.wareqty<0
  AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
  --and a.zdate>=DATE'2023-06-30' --and 1=2
/*    union all
   -----欧加龙的不均分了  都改到龙泉西药D
    SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
        '瑞人堂医药集团股份有限公司龙泉店(西药D)' ,
      case when a.ls>0 then 0 else ls end  AS rksl,
      case when a.LS>0 then ls else 0 end  AS cksl,
      a.ph ,
      a.dw AS dw,
      a.dj AS dj,
     a.ls*A.dj AS je,
     a.fileno
  from v_accept_msd_p001 a
  WHERE to_char(a.zdate,'yyyy-mm-dd') in ( '2022-07-30','2022-07-31') and lgort in ('P888') and a.matnr in (select wareid from d_msd_ware)*/
 union all
 --p888,p006的入库  显示在一起
    SELECT
      a.zdate,
      a.WERKS,
      '台州瑞人堂药业有限公司' as zname1,
      LGORT,
      '批发出库单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
        '瑞人堂医药集团股份有限公司龙泉店(西药D)' ,
      case when a.ls>0 then 0 else ls end  AS rksl,
      case when a.LS>0 then ls else 0 end  AS cksl,
      a.ph ,
      a.dw AS dw,
      a.dj AS dj,
     a.ls*A.dj AS je,
     a.fileno
  from v_accept_msd_p001 a
  WHERE
  --a.zdate >=DATE'2023-06-30'
  a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
  and lgort in ('P888','P006') and a.matnr in (select wareid from d_msd_ware)
  and to_char(a.zdate,'yyyy-mm-dd') <>'2023-03-03' and zdate<>date'2023-04-06' and a.DJLX like '%入库%' and not (matnr=10106748 and zdate>=date'2023-04-01') --and 1=2


  /*union all
  SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW",DJ, JE,fileno FROM v_sale_msd_p001_2
  --where 1=2
  union all
  SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW", DJ, JE,fileno FROM d_msd_lsck@hydee_zy
  WHERE zdate>=DATE'2022-12-01' AND zdate<=DATE'2022-12-31'
  --zdate>=DATE'2023-01-01'
  --where 1=2
  union all
  ----特药
  SELECT cjsj,WERKS,xsfmc,'P001','销售出库单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,0,sl,ph,dw, DJ, JE,fileno FROM V_SALE_msd_ty_P001  WHERE sl>0
  --and 1=2
  union all
  SELECT cjsj,WERKS,xsfmc,'P001','销售退货单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,-sl,0,ph,dw, DJ, -JE,fileno FROM V_SALE_msd_ty_P001  WHERE sl<0*/
  --and 1=2
  union all
  --漏掉的数据
  select
  zdate,
  'D001' as WERKS ,
  trim(zname1),
  LGORT,
  '批发出库单' as djlx,
  matnr,
  maktx,
  zguig,
  null as zscqymc,
  orgname,
  rksl,
  cksl,
  zgysph,
  null as dw,
  null as dj,
  null AS je,
  null as fileno
  from t_MSD where cksl<>0
  --and 1=2
  /*union all
  select
  zdate,
  'D001' as WERKS ,
  trim(zname1),
  LGORT,
  '批发入库单' as djlx,
  matnr,
  maktx,
  zguig,
  '比利时先灵葆雅制药Schering-Plough Labo' as zscqymc,
  null,
  rksl,
  cksl,
  zgysph,
  null as dw,
  null as dj,
  null AS je,
  '注册证号H20140100' as fileno
  from t_MSD where rksl<>0*/
  union all
  SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '盘点损益单' as djlx,
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
     a.menge*a.DMBTR AS je,d.fileno
  from stock_out a
  left join  s_busi@hydee_zy b  ON to_char(b.BUSNO )= '8'||a.BUPA
    left join t_ware_base@hydee_zy d on a.matnr=d.wareid
  where matnr in (select wareid from d_msd_ware)  and matnr not in (10113315) and a.werks in ('D001','D002','D006','D010') --and   name1 not like '%浙江瑞人堂药业%'
  and  LIFNR in ('110093','110673','110190')
 and  LGORT IN ('P001','P030')
 AND zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 --AND a.zdate>=DATE'2023-06-30'
 AND ZODERtype=4
 --and 1=2
 --and  name1 not LIKE '%诊所%' and trim(a.bupa) NOT like '24%' and a.bupa not like 'D%'
 union all
  SELECT
      a.zdate,
      a.WERKS,
     decode( a.werks,'D002','瑞人堂集团股份有限公司','D006','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂药业仓库','台州瑞人堂药业有限公司') as zname1,
      LGORT,
      '盘点损益单' as djlx,
  --    a.lgobe,
      MATNR,
      MAKTX,
      ZGUIG,
      zscqymc,
      name1   as orgname,
      a.menge AS rksl,
      0 AS cksl,
      a.zgysph AS ph,
      a.mseh6 AS dw,
      a.DMBTR AS dj,
     a.menge*a.DMBTR AS je,d.fileno
  from stock_in a
  left join  s_busi@hydee_zy b  ON to_char(b.BUSNO )= '8'||a.BUPA
    left join t_ware_base@hydee_zy d on a.matnr=d.wareid
  where matnr in (select wareid from d_msd_ware) and matnr not in (10113315) and a.werks in ('D001','D002','D006','D010') --and   name1 not like '%浙江瑞人堂药业%'
  and  LIFNR in ('110093','110673','110190')
 and  LGORT IN ('P001','P030')
 --AND a.zdate>=DATE'2023-06-30'
 AND a.zdate>=DATE'2022-12-01' AND a.zdate<=DATE'2022-12-31'
 AND ZODERtype=4
/

