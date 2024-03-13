create view V_ACCEPT_BAIER as
SELECT
zorder,
zdate,
werks,
zname1,
lgort,
djlx,
lgobe,
matnr,
maktx,
zguig,
zscqymc,
ph,
dw,
gys,
ls,
dj,
je
from V_ACCEPT_BAIER_TEMP  
-- where 1=0
union all
select null,CJSJ,null,cgfmc,null,'采购入库单',ckmc,CPDM,CPMC,CPGG,ZSCQYMC,PH,DW,XSFMC,SL,DJ,JE
from v_accept_be_ls_0920 where sl>0 
--                            and 1=0
union all
select null,CJSJ,null,cgfmc,null,'采购退货单',ckmc,CPDM,CPMC,CPGG,ZSCQYMC,PH,DW,XSFMC,SL,DJ,JE
from v_accept_be_ls_0920 where sl<0
--特药导入
union all
select ZORDER, ZDATE, WERKS, ZNAME1, LGORT, DJLX, LGOBE, MATNR, MAKTX, ZGUIG, ZSCQYMC, PH, DW, GYS, LS, DJ, JE
from D_ACCEPT_BAIER_ty
/

