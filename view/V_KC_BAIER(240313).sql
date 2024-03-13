create view V_KC_BAIER as
select kcrq,
gsdm,
gsmc,
cpdm,
cpmc,
cpgg,
dw,
ph,
sl,
dj,
je,
cjsj,
yxq,
ckmc,
fileno,
zscqyms
from v_kc_baier_temp  
-- where 1=0
--
-- union all
-- select sysdate as kcrq,'' as gsdm,
-- DECODE(werks,'D001','台州瑞人堂药业有限公司','D002','瑞人堂医药集团股份有限公司','D010','浙江瑞人堂医药连锁有限公司')  as gsmc,s.matnr as cpdm,s.maktx as cpmc,s.zguig as cpgg,s.mseh6 as dw,s.zgysph as ph,
--        sum(s.menge) as sl,0 as dj,0 as je,s.zdate as cjsj,S.vfdat AS yxq,S.lgobe AS CKMC ,t.fileno AS fileno,s.zscqyms as zscqymc
-- from stock s
-- LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=s.matnr
-- where s.werks  in ('D001','D002','D010') and lgort not in ('P888','P006')
--       AND S.MATNR IN (10503528,10600356)
-- --   and 1=0
-- group by s.matnr,s.maktx,s.zguig,s.mseh6,s.zgysph,s.zdate,S.vfdat,S.lgobe ,t.fileno,s.zscqyms,werks
/

