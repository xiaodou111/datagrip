create or replace view V_SALE_OJL_P001 as
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else case when trim(o.bupa) like '24%' and o.MENGE>150 then '1516' else o.bupa  end end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '盘亏'
else case when trim(o.bupa) like '24%' and o.MENGE>150 then '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'
else o.NAME1 end end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('2','4','5') and werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and o.NAME1 not like '%诊所%'

UNION ALL
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else case when trim(i.bupa) like '24%' and i.MENGE>150 then '1516' else i.bupa  end end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '盘亏'
else case when trim(i.bupa) like '24%' and i.MENGE>150 then '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'
else i.NAME1 end end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-i.menge AS sl,i.dmbtr as dj,- i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('2','4','5') AND  i.werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and i.NAME1 not like '%诊所%'
--P888,P006采购退货即入库
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  '1516' end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '盘亏'
else '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,-o.menge as sl,o.dmbtr as dj,
      -o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,'P001'
from stock_out o
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('1') and werks in ('D001','D006','D007','D010') and lgort in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01'
--P888,P006采购入库即出库
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  '1516' end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '盘盈'
       else  '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,i.menge AS sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,'P001'
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('1') AND  i.werks in ('D001','D006','D007','D010')  and lgort in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01'
--P888,P006移到P001,显示负数
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(o.werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
 '1516'  as cgfdm,
 '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,-o.menge as sl,o.dmbtr as dj,
      -o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,'P001'
from stock_out o left join customer_list l on l.kunnr = o.bupa
join stock_in i  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in('P888','P006') AND i.lgort='P001' and o.zodertype IN ('3') and o.werks in ('D001','D006','D007','D010')
and o.matnr in  (select wareid from d_ojl_ware)
and   o.zdate>=date'2024-01-01'
union all
--P001移到P888,P006,显示正数出库
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(o.werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
 '1516'  as cgfdm,
 '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,'P001'
from stock_out i
join stock_in o  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in('P888','P006') AND i.lgort='P001' and o.zodertype IN ('3') and o.werks in ('D001','D006','D007','D010')
and o.matnr in  (select wareid from d_ojl_ware)
and   o.zdate>=date'2024-01-01'
--批发出库和批发退货相关单位为诊所的 75%的数量 改为对应的门店,门店匹配不到就改为：瑞人堂医药集团股份有限公司龙泉店(西药D),25%的数量真实体现
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '盘亏'
else nvl(c.orgname,  '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' ) end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
   ceil(o.menge*0.75)  as sl,o.dmbtr as dj,
      o.dmbtr*ceil(o.menge*0.75) as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o
left join d_msd_busno_zs b on trim(o.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('2','4','5') and werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and o.NAME1 like '%诊所%'
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '盘亏'
else nvl(c.orgname,  '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' ) end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
   floor(o.menge*0.25)  as sl,o.dmbtr as dj,
      o.dmbtr*ceil(o.menge*0.25) as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o
left join d_msd_busno_zs b on trim(o.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('2','4','5') and werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and o.NAME1 like '%诊所%' and floor(o.menge*0.25)>0
--诊所退货
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '盘亏'
else nvl(c.orgname,  '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' ) end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-ceil(i.menge*0.75) AS sl,i.dmbtr as dj,- i.dmbtr*ceil(i.menge*0.75)  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
left join d_msd_busno_zs b on trim(i.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('2','4','5') AND  i.werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and i.NAME1  like '%诊所%'
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D006','金华瑞人堂保济堂医药连锁有限公司','D007','宁波瑞人堂弘德医药连锁有限公司','D010','浙江瑞人堂医药连锁有限公司') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '盘亏'
else nvl(c.orgname,  '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' ) end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-floor(i.menge*0.25) AS sl,i.dmbtr as dj,- i.dmbtr*floor(i.menge*0.25)  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
left join d_msd_busno_zs b on trim(i.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('2','4','5') AND  i.werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and i.NAME1  like '%诊所%' and floor(i.menge*0.25)>0


/



