create view V_SALE_ZMHD_P001_01 as
SELECT o.zodertype||o.zorder as billno,
'' as xsfdm,
o.zname1 as xsfmc,
o.bupa  as cgfdm,
'批发出库单' as djlx,
case WHEN o.zodertype in (4,5 ) THEN '盘亏'
else o.name1  end as cgfmc,
  o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
  0 as rksl,
  o.MENGE AS cksl,
  o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.MENGE as sl,o.lgort
FROM stock_out o left join customer_list l on l.kunnr = o.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype='2' AND o.werks IN ('D001')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
       AND  NOT (o.matnr  IN('10100223','10107141') AND zdate>=DATE'2023-05-23')
      and LIFNR in ('110388','110093')
      and  zdate>=DATE'2023-11-01'     AND o.lgort IN('P001','P018','P021')
UNION ALL
--工厂D010 P001的批发出库单
SELECT o.zodertype||o.zorder as billno,
'' as xsfdm,
o.zname1 as xsfmc,
o.bupa  as cgfdm,
'批发出库单' as djlx,
case WHEN o.zodertype in (4,5 ) THEN '盘亏'
else o.name1  end as cgfmc,
  o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
  0 as rksl,
  o.MENGE AS cksl,
  o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.MENGE,o.lgort
FROM stock_out o left join customer_list l on l.kunnr = o.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype='2' AND o.werks IN ('D010')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
       AND  NOT (o.matnr  IN('10100223','10107141') AND zdate>=DATE'2023-05-23')
      and LIFNR in ('110388','110093')
      and   zdate>=DATE'2023-11-01'    AND o.lgort IN('P001')
UNION ALL
--工厂D001 P001、P018、P021的批发退货单
SELECT o.zodertype||o.zorder as billno,
'' as xsfdm,
o.zname1 as xsfmc,
o.bupa  as cgfdm,
'批发退货单' as djlx,
case WHEN o.zodertype in (4,5 ) THEN '盘亏'
else o.name1  end as cgfmc,
  o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
  o.MENGE as rksl,
  0 AS cksl,
  o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,-o.MENGE,o.lgort
FROM stock_in o left join customer_list l on l.kunnr = o.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype='2' AND o.werks IN ('D001')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
       AND  NOT (o.matnr  IN('10100223','10107141') AND zdate>=DATE'2023-05-23')
      and LIFNR in ('110388','110093')
      and   zdate>=DATE'2023-11-01'    AND o.lgort IN('P001','P018','P021')
UNION ALL
--工厂D010 P001的批发退货单
SELECT o.zodertype||o.zorder as billno,
'' as xsfdm,
o.zname1 as xsfmc,
o.bupa  as cgfdm,
'批发退货单' as djlx,
case WHEN o.zodertype in (4,5 ) THEN '盘亏'
else o.name1  end as cgfmc,
  o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
  o.MENGE as rksl,
  0 AS cksl,
  o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,-o.MENGE,o.lgort
FROM stock_in o left join customer_list l on l.kunnr = o.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype='2' AND o.werks IN ('D010')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
      AND  NOT (o.matnr  IN('10100223','10107141') AND zdate>=DATE'2023-05-23')
      and LIFNR in ('110388','110093')
      and   zdate>=DATE'2023-11-01'    AND o.lgort IN('P001')
UNION ALL
--工厂D001 P001、P018、P021的盘点报溢单
SELECT o.zodertype||o.zorder as billno,
'' as xsfdm,
o.zname1 as xsfmc,
o.bupa  as cgfdm,
'报溢单' as djlx,
case WHEN o.zodertype in (4,5 ) THEN '盘盈'
else o.name1  end as cgfmc,
  o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
  o.MENGE as rksl,
  0 AS cksl,
  o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,-o.MENGE,o.lgort
FROM stock_in o left join customer_list l on l.kunnr = o.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype='4' AND o.werks IN ('D001')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
       AND  NOT (o.matnr  IN('10100223','10107141') AND zdate>=DATE'2023-05-23')
      and LIFNR in ('110388','110093')
      and   zdate>=DATE'2023-11-01'    AND o.lgort IN('P001','P018','P021')
UNION ALL
--工厂D001 P001、P018、P021的盘点报损单
SELECT o.zodertype||o.zorder as billno,
'' as xsfdm,
o.zname1 as xsfmc,
o.bupa  as cgfdm,
'报损单' as djlx,
case WHEN o.zodertype in (4,5 ) THEN '盘亏'
else o.name1  end as cgfmc,
  o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
  0 as rksl,
  o.MENGE AS cksl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.MENGE,o.lgort
FROM stock_out o left join customer_list l on l.kunnr = o.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype='4' AND o.werks IN ('D001')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
       AND  NOT (o.matnr  IN('10100223','10107141') AND zdate>=DATE'2023-05-23')
      and LIFNR in ('110388','110093')
      and   zdate>=DATE'2023-11-01'    AND o.lgort IN('P001','P018','P021')



--P888,P006采购退货即入库
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D002','瑞人堂医药集团股份有限公司','D010','浙江瑞人堂医药连锁有限公司','D008','杭州瑞人堂医药连锁有限公司') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  '1516' end as cgfdm,'批发退货单',
case WHEN o.zodertype in ('4','5') THEN '盘亏'
else '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,0,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,-o.menge,o.lgort
from stock_out o left join customer_list l on l.kunnr = o.bupa
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('1') and werks in ('D001') and lgort in ('P888','P006')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
and   zdate>=date'2023-11-01'  and LIFNR in ('110388','110093')
--P888,P006采购入库即出库
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','台州瑞人堂药业有限公司','D002','瑞人堂医药集团股份有限公司','D010','浙江瑞人堂医药连锁有限公司','D008','杭州瑞人堂医药连锁有限公司') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  '1516' end as cgfdm,'批发出库单',
case WHEN i.zodertype in ('4','5') THEN '盘盈'
       else  '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）' end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,0,i.menge AS sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.menge,i.lgort
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('1') AND  i.werks in ('D001')  and lgort in ('P888','P006')
AND i.matnr IN ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
and   zdate>=date'2023-11-01'  and LIFNR in ('110388','110093')
--P888,P006移到P001,显示负数
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(o.werks,'D001','台州瑞人堂药业有限公司','D002','瑞人堂医药集团股份有限公司','D010','浙江瑞人堂医药连锁有限公司','D008','杭州瑞人堂医药连锁有限公司') as xsfmc,
 '1516'  as cgfdm,'批发退货单',
 '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,0,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,-o.menge,o.lgort
from stock_out o left join customer_list l on l.kunnr = o.bupa
join stock_in i  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in('P888','P006') AND i.lgort='P001' and o.zodertype IN ('3') and o.werks in ('D001')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
and   o.zdate>=date'2023-11-01'  and o.LIFNR in ('110388','110093')
union all
--P001移到P888,P006,显示正数出库
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(o.werks,'D001','台州瑞人堂药业有限公司','D002','瑞人堂医药集团股份有限公司','D010','浙江瑞人堂医药连锁有限公司','D008','杭州瑞人堂医药连锁有限公司') as xsfmc,
 '1516'  as cgfdm,'批发出库单',
 '瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,0,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'正常仓' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,o.menge,o.lgort
from stock_out i left join customer_list l on l.kunnr = i.bupa
join stock_in o  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in('P888','P006') AND i.lgort='P001' and o.zodertype IN ('3') and o.werks in ('D001')
and o.matnr in  ('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')
and   o.zdate>=date'2023-11-01' and o.LIFNR in ('110388','110093')



UNION ALL
select "BILLNO","XSFDM","XSFMC","CGFDM","DJLX","CGFMC","CPDM","CPMC","CPGG","DW","PH","RKSL","CKSL","DJ","JE","CJSJ","YXQ","CKMC","FILENO","SCQY","SL","LGORT" from d_sale_zmhd1
/

