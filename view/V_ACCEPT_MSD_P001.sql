create view V_ACCEPT_MSD_P001 as
select
   a.zorder,a.zdate,a.WERKS,a.zname1,LGORT,'采购入库单' as djlx ,MATNR,MAKTX,ZGUIG,
      zscqymc,zgysph AS ph,mseh6 AS dw, name1  as gys,a.MENGE AS ls,0 AS  dj,0 AS je,b.fileno
 FROM stock_in  a
 left join t_ware_base@hydee_zy b on a.matnr=b.wareid
  WHERE matnr in (select wareid from d_msd_ware)
  and lgort  in ('P001','P888','P006','P030') AND  zdate>=date'2023-07-01'  and LIFNR in ('110093','110673','110190') and werks in ('D001','D002')
  and zodertype=1 AND matnr NOT IN (SELECT wareid FROM d_msd_ware_exclude)
  union all
  select
  a.zorder,a.zdate,a.WERKS,a.zname1,LGORT,'采购退货单' as djlx ,MATNR,MAKTX,ZGUIG,
     zscqymc,zgysph AS ph,mseh6 AS dw, name1  as gys,-a.MENGE AS ls,0 AS  dj,0 AS je,b.fileno
  FROM stock_out a
left join t_ware_base@hydee_zy b on a.matnr=b.wareid
  WHERE matnr in (select wareid from d_msd_ware)
  and lgort  in ('P001','P888','P006','P030') and zdate>=date'2023-07-01'  and LIFNR in ('110093','110673','110190')  and werks in ('D001','D002')
  and zodertype=1 AND  matnr NOT IN (SELECT wareid FROM d_msd_ware_exclude)

  union all
  SELECT "ZORDER","ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","PH","DW","GYS","LS",0 as DJ, 0 as JE,fileno FROM v_accept_msd_p001_2
  where ZDATE>=date'2023-07-01' and zdate<>date'2023-04-06' AND NOT( TRIM(PH) IN('W035231','W018211','W038021','W021232') AND zdate>=date'2023-07-01')--and 1=2
  union all
  select '',zdate,werks,zname1,lgort,djlx,matnr,maktx,zguig,ZSCQYMC,ph,dw,orgname,case when rksl=0 then -cksl else rksl end ,0,0,fileno FROM d_msd_cgrk
  where ZDATE>=date'2023-07-01' and zdate<>date'2023-04-06' AND  NOT( TRIM(PH) IN('W035231','W018211','W038021','W021232') AND zdate>=date'2023-07-01')--and 1=2
  union all
  ----特药
  select '',cjsj,werks,cgfmc,'P001','采购入库单',cpdm,cpmc,cpgg,ZSCQYMC,ph,dw,xsfmc,sl,0,0,fileno  from V_ACCEPT_msd_ty_P001 WHERE sl>0
  AND  NOT( TRIM(PH) IN('W035231','W018211','W038021','W021232') AND CJSJ>=DATE'2023-07-01')  --AND 1=2
  union all
   select '',cjsj,werks,cgfmc,'P001','采购退货单',cpdm,cpmc,cpgg,ZSCQYMC,ph,dw,xsfmc,0,-sl,0,fileno from V_ACCEPT_msd_ty_P001 WHERE sl<0
   AND  NOT( TRIM(PH) IN('W035231','W018211','W038021','W021232') AND CJSJ>=DATE'2023-07-01') --AND 1=2
   UNION ALL
   --2023年1月到6月底的视图数据全部在D_ACCEPT_MSD_P001+后导入的数据
   SELECT NULL,"ZDATE",a.werks,
   decode(a.werks,'D001','台州瑞人堂药业有限公司','D002','瑞人堂集团股份有限公司','D010','浙江瑞人堂药业有限公司','台州瑞人堂药业有限公司') AS zname1,
   "LGORT","DJLX","MATNR","MAKTX","ZGUIG",f.FACTORYNAME,"PH",w.WAREUNIT,"GYS","LS",0 AS"DJ", 0 AS"JE",w.fileno
   from D_ACCEPT_MSD_P001 a
   LEFT join t_ware_base@hydee_zy w ON a.matnr=w.wareid
   LEFT join t_factory@hydee_zy f ON w.factoryid=f.factoryid
/

