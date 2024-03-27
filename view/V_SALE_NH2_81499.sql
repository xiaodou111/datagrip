create view V_SALE_NH2_81499 as
SELECT a.saleno,a.compid as xsfdm,'浙江瑞人堂医药连锁有限公司' as xsfmc,
       tb.CLASSNAME as 省份,tb1.CLASSNAME as 城市,
       a.busno cgfdm,nvl(a.ext_str1,d.doctorname) as cgfmc,
b.wareid as cpdm,c.warename as cpmc,c.warespec as cpgg,c.wareunit as dw,b.makeno as ph,b.wareqty*b.times as sl,b.netprice as dj,b.wareqty*b.times * b.netprice as je,
b.accdate as cjsj,CASE when b.wareqty >=0 then '纯销' else '退货' end as 销售类型,'P001'库位,b.invalidate  有效日期,''AS syz,b.invalidate as yxq,null as billno
,f.factoryname,c.fileno,d.zdcont,a.STARTTIME,

 replace(a.MEMBERCARDNO,substr(a.MEMBERCARDNO,4,4),'****') as MEMBERCARDNO,
 REPLACE(nvl(mem.MOBILE,mem.tel),SUBSTR(nvl(mem.MOBILE,mem.tel), 4, 4),'****')  as phone,
 replace(d.USERNAME,SUBSTR(d.USERNAME,2,1),'*') as username ,a.ACCDATE+28 as sfday
FROM t_sale_h a
LEFT JOIN t_remote_prescription_h d ON  substr(a.notes,0,decode(instr(a.notes,' '),0,length(a.notes)+1,instr(a.notes,' '))-1)=d.cfno
 join  t_sale_d b on a.SALENO=b.SALENO
 join  t_ware_base c on b.WAREID=c.WAREID
 join  t_factory f on f.FACTORYID=c.FACTORYID
 join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '322'
 join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
 join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '323'
 join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join t_memcard_reg mem on mem.MEMCARDNO=a.MEMBERCARDNO
 where  b.wareid in(select wareid from d_nh_ware) and b.WAREID in (10305522,10600505)
AND a.busno in (81499,81501)  and a.accdate>=date'2024-01-01'  and  a.accdate< trunc(sysdate)
/

