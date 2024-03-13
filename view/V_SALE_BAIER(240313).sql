create view V_SALE_BAIER as
select
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
orgname,
rksl,
cksl,
ph,
dw,
dj,
je
from V_SALE_BAIER_temp 
-- where 1=0
union all
select CJSJ,null,XSFMC,null,'批发出库单',CKMC,CPDM,CPMC,CPGG,SCQY,CGFMC,0,SL,PH,DW,DJ,JE
from V_SALE_BE_LS_0920 where sl>0 
--                          and 1=0
union all
select CJSJ,null,XSFMC,null,'批发退货单',CKMC,CPDM,CPMC,CPGG,SCQY,CGFMC,-SL,0,PH,DW,DJ,JE
from V_SALE_BE_LS_0920 where sl<0
/

