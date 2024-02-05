create view V_ACCEPT_ZDYY_P001 as
select nvl(l.name1_snf,i.name1) as xsfmc,'ZJ0J0001J' as cgfdm,'台州瑞人堂药业有限公司' as cgfmc,i.matnr as cpdm,i.maktx as cpmc,i.zguig as cpgg,
       i.mseh6 as dw,i.zgysph as ph,sum(i.menge) as sl,i.dmbtr as dj, i.dmbtr*i.menge  as je,i.zdate as cjsj,i.VFDAT AS yxq,i.LGOBE AS CKMC,t.fileno AS fileno,i.zscqymc AS  zscqymc
from stock_in i left join customer_list l on l.kunnr = i.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE   i.zodertype =1 and i.matnr in('10112119','10305422')  and   zdate between trunc(add_months(sysdate,-3)) and trunc(sysdate)  and i.lgort='P001'
group by nvl(l.name1_snf,i.name1) ,i.matnr,i.maktx,i.zguig,i.mseh6,i.zgysph,i.zdate,i.dmbtr ,i.dmbtr*i.menge,i.VFDAT,i.LGOBE,t.fileno,i.vfdat ,i.zscqymc
UNION ALL
SELECT o.name1 AS XSFMC,'ZJ0J0001J' as cgfdm,'台州瑞人堂药业有限公司' as cgfmc,o.matnr AS CPDM,o.maktx AS CPMC,o.zguig as cpgg,o.mseh6 AS DW,o.zgysph as ph,-sum(o.menge) AS sl,o.dmbtr as dj,- o.dmbtr*o.menge  as je,o.zdate as cjsj,o.VFDAT
 AS yxq,o.LGOBE AS CKMC,t.fileno AS fileno,o.zscqymc AS zscqymc
FROM stock_out o
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
 WHERE zodertype=1 AND o.matnr IN('10112119','10305422')  and   zdate between trunc(add_months(sysdate,-3)) and trunc(sysdate) and o.lgort='P001'
group by  o.name1,o.matnr,o.maktx,o.zguig,o.mseh6,o.zgysph,o.zdate,o.dmbtr ,-o.dmbtr*o.menge,o.VFDAT,o.LGOBE,t.fileno,o.zscqymc
/

