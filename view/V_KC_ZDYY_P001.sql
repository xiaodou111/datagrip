create view V_KC_ZDYY_P001 as
select sysdate as kcrq,'ZJ0J0001J' as gsdm,'浙江瑞人堂医药连锁有限公司' as gsmc,s.matnr as cpdm,s.maktx as cpmc,s.zguig as cpgg,s.mseh6 as dw,
s.zgysph as ph,
case when s.zgysph='522107008' then s.menge+3 else s.menge end as sl,0 as dj,0 as je,s.zdate as cjsj,
      S.vfdat AS yxq,S.lgobe AS CKMC ,t.fileno AS fileno,s.zscqyms AS  zscqyms
from stock S
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=s.matnr
WHERE  S.MATNR IN ('10112119','10305422') and werks in ('D001') and lgort in ('P001')
/

