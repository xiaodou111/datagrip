/*SELECT a.busno,MAX(tb.classname),MAX(tb1.classname),MAX(tb3.classname),MAX(参保地),
case when MAX(参保人员类别) like '%居民%' then '城乡居民基本医疗保险(医保)' else '职工基本医疗保险(农保)' end as 险种 from d_rpt_sale_pos_yb  a 
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno  AND tb.classcode=303105
join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
join t_busno_class_base tb1 on ts1.classgroupno=tb1.classgroupno and ts1.classcode=tb1.classcode
join t_busno_class_set ts3 on a.busno=ts3.busno and ts3.classgroupno ='324'
join t_busno_class_base tb3 on ts3.classgroupno=tb3.classgroupno and ts3.classcode=tb3.classcode
JOIN d_zhyb_hz_cyb b ON a.busno=b.busno
WHERE a.compid=1040
GROUP BY a.busno

SELECT y.busno, 
sum(wareqty) as wareqty,sum(round(y.stdsum,2)) as stdsum,
sum(round(y.netsum,2)) as netamt,sum(y.salecount) as kll ,sum(round(y.netsum - y.puramount,2)) as ml,
DECODE(sum(y.salecount),0,0,sum(round(y.netsum,2))/sum(y.salecount)) AS kdj
from d_rpt_sale_pos_yb  y
WHERE y.compid=1040
GROUP BY y.busno*/


SELECT tb.classname AS syb,tb1.classname AS PQ,a.busno,s.orgname,a.销售片区 AS 统筹区,tb3.classname AS 门店所在辖区名称,wareqty,stdsum,netamt,kll,kdj
FROM (
SELECT y.busno, decode(y.nb_flag,1,'农保','医保') AS 医保类型,tb2.classname AS 销售片区,
sum(wareqty) as wareqty,sum(round(y.stdsum,2)) as stdsum,
sum(round(y.netsum,2)) as netamt,sum(y.salecount) as kll ,
DECODE(sum(y.salecount),0,0,sum(round(y.netsum,2))/sum(y.salecount)) AS kdj
from d_rpt_sale_pos_yb  y
join t_busno_class_set ts2 on y.busno=ts2.busno and ts2.classgroupno ='324'
join t_busno_class_base tb2 on ts2.classgroupno=tb2.classgroupno and ts2.classcode=tb2.classcode  
WHERE y.compid=1040 AND y.accdate BETWEEN DATE'2023-04-01' AND DATE'2023-06-01'
GROUP BY y.busno ,decode(y.nb_flag,1,'农保','医保'),tb2.classname
)a 
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno  AND tb.classcode=303105
join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
join t_busno_class_base tb1 on ts1.classgroupno=tb1.classgroupno and ts1.classcode=tb1.classcode
join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
join t_busno_class_base tb2 on ts2.classgroupno=tb2.classgroupno and ts2.classcode=tb2.classcode
join t_busno_class_set ts3 on a.busno=ts3.busno and ts3.classgroupno ='323'
join t_busno_class_base tb3 on ts3.classgroupno=tb3.classgroupno and ts3.classcode=tb3.classcode
JOIN s_busi s ON a.busno=s.busno
