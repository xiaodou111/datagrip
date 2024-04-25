create or replace view V_SALE_MSD_P001 as
select ZDATE, WERKS, ZNAME1, LGORT, DJLX, MATNR, MAKTX, ZGUIG, ZSCQYMC, ORGNAME, RKSL, CKSL, PH, DW, DJ, JE, FILENO
from D_SALE_MSD_2023 where ZDATE>=date'2023-01-01' ----所有V_SALE_MSD_P001的23年配送数据
-- and 1=0
--默沙东
-- union all
-- SELECT "ZDATE","WERKS","ZNAME1","LGORT","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","ORGNAME","RKSL","CKSL","PH","DW",DJ, JE,fileno
-- FROM v_sale_msd_p001_2
-- where zdate>=date'2024-01-01'
--欧加隆24年逻辑
union all
select  CJSJ,null,XSFMC,null,'批发出库单',CPDM,CPMC,CPGG,SCQY,CGFMC,0,SL,PH,DW,DJ,JE,FILENO
from V_SALE_OJL_P001 where sl>0  AND trim(PH) NOT IN (SELECT PH FROM d_ojl_ph)
--                      and 1=0
union all
select  CJSJ,null,XSFMC,null,'批发出库单',CPDM,CPMC,CPGG,SCQY,CGFMC,0,SL,PH,DW,DJ,JE,FILENO
from V_SALE_OJL_P001 where sl>0  AND ph='X007568' and cjsj>=date'2024-03-06'
union all
select  CJSJ,null,XSFMC,null,'批发退货单',CPDM,CPMC,CPGG,SCQY,CGFMC,-SL,0,PH,DW,DJ,JE,FILENO
from V_SALE_OJL_P001 where sl<0  and trim(PH) NOT IN (SELECT PH FROM d_ojl_ph)
union all
select  CJSJ,null,XSFMC,null,'批发退货单',CPDM,CPMC,CPGG,SCQY,CGFMC,-SL,0,PH,DW,DJ,JE,FILENO
from V_SALE_OJL_P001 where sl<0  and ph='X007568' and cjsj>=date'2024-03-06'
--                      and 1=0
union all
----特药改成邮件了
SELECT cjsj,WERKS,xsfmc,LGORT,'销售出库单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,0,sl,ph,dw, DJ, JE,fileno FROM V_SALE_msd_ty_P001
WHERE sl>0 and CJSJ>=date'2024-01-01'
--   and 1=0
  --and 1=2
union all
--默沙东
SELECT cjsj,WERKS,xsfmc,LGORT,'销售退货单',cpdm,cpmc,cpgg,ZSCQYMC,cgfmc,-sl,0,ph,dw, DJ, -JE,fileno FROM V_SALE_msd_ty_P001
WHERE sl<0 and CJSJ>=date'2024-01-01'
union all
select  CJSJ,null,XSFMC,null,'批发出库单',CPDM,CPMC,CPGG,SCQY,CGFMC,0,SL,PH,DW,DJ,JE,FILENO
from V_SALE_MSD_P001_PY where sl>0
union all
select  CJSJ,null,XSFMC,null,'批发退货单',CPDM,CPMC,CPGG,SCQY,CGFMC,-SL,0,PH,DW,DJ,JE,FILENO
from V_SALE_MSD_P001_PY where sl<0
/

