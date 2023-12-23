insert into d_o2o_ware_tm(wareid) 
select wareid from (
SELECT a.wareid,a.WARENAME,a.WARESPEC,f.factoryname,c1.classname khlb,c2.classname jtgl,c3.classname xlsgl,w.sfsjo2o,ext.we_schar01,
w.INSURANCENO,w.FILENO,NVL(wa.sumqty,0) kcsl,NVL(busnoqty,0) kcmds,
NVL(a5.saleqty,0) sumxl,NVL(a5.美团销售额,0) mtxl,NVL(a5.饿了么销售额,0)elmxl,NVL(a5.京东到家销售额,0) jddjxl,
NVL(a5.京东健康销售额,0)jdjkxl ,nvl(o2o.barcode,w.barcode) as barcode ,o2o.mt,o2o.elm,o2o.jddj,o2o.jdjk,
o2o.lastmodify,o2o.lasttime FROM t_ware_base a
join (select wareid  from t_store_d group by wareid
UNION select TO_NUMBER(WAREID) from CV_STORE_SAP_KCDD  GROUP BY  TO_NUMBER(WAREID)) td on td.wareid=a.wareid 
left join  d_o2o_ware_tm o2o on a.wareid=o2o.wareid
LEFT join  t_ware w  ON a.wareid=w.wareid AND w.compid=1000
LEFT JOIN t_factory f ON a.factoryid=f.factoryid
LEFT JOIN t_ware_class_base b1 ON a.wareid=b1.wareid AND b1.classgroupno=12 AND b1.compid=1000
LEFT JOIN t_class_base c1 ON b1.classcode=c1.classcode 
LEFT JOIN t_ware_class_base b2 ON a.wareid=b2.wareid AND b2.classgroupno=90 AND b2.compid=1000
LEFT JOIN t_class_base c2 ON b2.classcode=c2.classcode 
LEFT JOIN t_ware_class_base b3 ON a.wareid=b3.wareid AND b3.classgroupno=107 AND b3.compid=1000
LEFT JOIN t_class_base c3 ON b3.classcode=c3.classcode 
LEFT JOIN t_ware_ext ext
    ON w.wareid = ext.wareid
   AND w.compid = ext.compid
LEFT JOIN(
SELECT wareid,SUM(wareqty) sumqty,COUNT(DISTINCT busno) busnoqty from  t_store_d WHERE  wareqty>0 and compid<>1900 GROUP BY wareid
) wa ON a.wareid=wa.wareid
LEFT join (
SELECT b.wareid,
SUM(CASE WHEN l.dddwlistdisplay='美团' THEN round(b.wareqty,6) ELSE 0 END ) AS 美团销售额,
SUM(CASE WHEN l.dddwlistdisplay='饿了么' THEN round(b.wareqty,6) ELSE 0 END ) AS 饿了么销售额,
SUM(CASE WHEN l.dddwlistdisplay='京东到家' THEN round(b.wareqty,6) ELSE 0 END ) AS 京东到家销售额,
SUM(CASE WHEN l.dddwlistdisplay='京东健康' THEN round(b.wareqty,6) ELSE 0 END ) AS 京东健康销售额,
SUM(CASE WHEN l.dddwlistdisplay IN('美团','饿了么','京东到家','京东健康') THEN round(b.wareqty,6) ELSE 0 END ) as saleqty 
from  d_rpt_sale_o2o b
JOIN s_dddw_list l 
on l.dddwname = '222' and l.dddwlistdata = b.paytype
WHERE b.accdate BETWEEN TRUNC(SYSDATE)-30 AND TRUNC(SYSDATE)
and EXISTS(SELECT 1 FROM t_busno_class_set wc__ 
 WHERE wc__.busno = b.busno AND wc__.classgroupno = '320' AND wc__.classcode <> '320105' )
GROUP BY b.wareid) a5 ON a5.wareid=a.wareid ) a where not exists (select 1 from d_o2o_ware_tm b where a.wareid=b.wareid)
