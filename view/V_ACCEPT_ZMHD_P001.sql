create view V_ACCEPT_ZMHD_P001 as
select i.name1 as xsfmc,'' as cgfdm, '采购入库单' as djlx,i.lgort, decode(i.werks,'DOO1','台州瑞人堂药业有限公司','浙江瑞人堂连锁有限公司') as cgfmc,i.matnr as cpdm,i.maktx as cpmc,i.zguig as cpgg,
       i.mseh6 as dw,i.zgysph as ph,i.menge as sl,i.dmbtr as dj, i.dmbtr*i.menge  as je,i.zdate as cjsj,i.VFDAT AS yxq,'正常仓' AS CKMC,
       t.fileno AS fileno,ZSCQYMC  as  scqy
from stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE  i.zodertype =1 AND i.werks='D001' and   zdate>date'2022-08-01' --between trunc(add_months(sysdate,-3)) and trunc(sysdate)
and lgort IN('P001','P018','P021','P006','P888')
      and i.matnr in('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516') and LIFNR in ('110388','110093')
and 1=0



UNION ALL
SELECT o.name1 AS XSFMC,'' as cgfdm, '采购退货单' as djlx,o.lgort,decode(o.werks,'DOO1','台州瑞人堂药业有限公司','浙江瑞人堂连锁有限公司') as cgfmc,o.matnr AS CPDM,o.maktx AS CPMC,o.zguig as cpgg,o.mseh6 AS DW,
o.zgysph as ph,-o.menge AS sl,o.dmbtr as dj,- o.dmbtr*o.menge  as je,o.zdate as cjsj,
o.VFDAT AS yxq,'正常仓' AS CKMC,t.fileno AS fileno,ZSCQYMC  as  scqy
FROM stock_out o
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
 WHERE zodertype=1   AND o.werks='D001' and   zdate>date'2022-08-01'
 and lgort IN('P001','P018','P021','P006','P888')
      and o.matnr in('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219','10305516')

        and LIFNR in ('110388','110093')
and 1=0
/

