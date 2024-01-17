create view V_SALE_MSD_P001 as
SELECT zdate,
werks,
zname1,
lgort,
djlx,
matnr,
maktx,
zguig,
zscqymc,
orgname,
rksl,
cksl,
ph,
dw,
dj,
je,
fileno
from  V_SALE_MSD_P001_temp WHERE
matnr NOT IN (SELECT wareid FROM d_msd_ware_exclude) and matnr not in (select wareid from d_msd_ware_ty) AND zdate>=DATE'2023-07-01'
/*NOT (TRIM(ph)  IN('W035231','W018211','W038021','W021232') AND zdate>=DATE'2023-05-25' )
AND NOT (ZDATE>=DATE'2023-06-01' AND ph IN('W038015','W035232','W038015') )
AND matnr NOT IN(10502337,10502442) AND 1=2*/
UNION ALL
/*SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW","DJ","JE","FILENO" from D_SALE_MSD_P001;*/
--所有要导入的数据+7月底之前的数据都放这里,特药进行删除了
SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW","DJ","JE","FILENO"
from  d_sale_msd_p001_2
  union all
  SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW",DJ, JE,fileno FROM v_sale_msd_p001_2
  where zdate>=date'2023-08-01'
  --where 1=2
  union all
  SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW", DJ, JE,fileno FROM d_msd_lsck@hydee_zy
  WHERE zdate>=DATE'2022-12-01' AND zdate<=DATE'2022-12-31'
  --zdate>=DATE'2023-01-01'
  --where 1=2
--包含特药
union all
  ----特药
  SELECT cjsj,WERKS,xsfmc,LGORT,'销售出库单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,0,sl,ph,dw, DJ, JE,fileno FROM V_SALE_msd_ty_P001
  WHERE sl>0
  --and 1=2
  union all
  SELECT cjsj,WERKS,xsfmc,LGORT,'销售退货单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,-sl,0,ph,dw, DJ, -JE,fileno FROM V_SALE_msd_ty_P001
  WHERE sl<0
/

