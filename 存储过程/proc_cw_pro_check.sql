create or replace PROCEDURE proc_cw_pro_check(p_compid IN number,
                                          p_busno IN number,
                                          p_sql OUT SYS_REFCURSOR )
IS
  v_time number;
  v_zmdz1 number;
  --v_lastyear date;
BEGIN
 v_zmdz1:=8||p_busno;
 OPEN p_sql FOR

 with d_sl as ( select ZMDZ1, busno, WAREID, 总数量, 待出库数量总计, 总不合格数量, 总待验数量, 可用数量, sumsl, SALEPRICE, je, rn
 from (
SELECT ZMDZ1,busno,WAREID ,总数量,待出库数量总计,总不合格数量,总待验数量,可用数量,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn
               FROM (
 select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as 总数量,sum(d.SUMAWAITQTY) as 待出库数量总计,
        sum(d.SUMDEFECTQTY) as 总不合格数量,sum(SUMTESTQTY) as 总待验数量,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as 可用数量,
        sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from t_store_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118','0119') and TC.compid = p_compid
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE ) )where rn <= 10),
--金额
d_je as (select ZMDZ1, busno, WAREID, 总数量,待出库数量总计,总不合格数量,总待验数量,可用数量, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, 总数量,待出库数量总计,总不合格数量,总待验数量,可用数量,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as 总数量,sum(d.SUMAWAITQTY) as 待出库数量总计,
        sum(d.SUMDEFECTQTY) as 总不合格数量,sum(SUMTESTQTY) as 总待验数量,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as 可用数量,sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from t_store_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118','0119') and TC.compid = p_compid
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
where rn <= 10),
--滞销--6个月没销售
d_zx as (select ZMDZ1, busno, WAREID, 总数量,待出库数量总计,总不合格数量,总待验数量,可用数量, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, 总数量,待出库数量总计,总不合格数量,总待验数量,可用数量,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as 总数量,sum(d.SUMAWAITQTY) as 待出库数量总计,
        sum(d.SUMDEFECTQTY) as 总不合格数量,sum(SUMTESTQTY) as 总待验数量,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as 可用数量,sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from T_STORE_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118','0119') and TC.compid = p_compid
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     and not exists (select WAREID from t_sale_d sd
join s_busi s on sd.BUSNO = s.BUSNO where s.COMPID = p_compid and s.ZMDZ1 = v_zmdz1 and sd.ACCDATE between ADD_MONTHS(SYSDATE, -6) and SYSDATE
and sd.WAREID=d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
where rn <= 10 ),
   a1 as (select ZMDZ1, busno, WAREID, 总数量,待出库数量总计,总不合格数量,总待验数量,可用数量, sumsl, SALEPRICE, je, rn,lx,lxrn
from (
SELECT ZMDZ1,busno,WAREID, 总数量,待出库数量总计,总不合格数量,总待验数量,可用数量,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn,lx,
        row_number() over (partition by lx,busno ORDER BY sumsl DESC) lxrn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as 总数量,sum(d.SUMAWAITQTY) as 待出库数量总计,
        sum(d.SUMDEFECTQTY) as 总不合格数量,sum(SUMTESTQTY) as 总待验数量,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as 可用数量,sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE,
                            decode(tc.classcode,'01120301','西洋参','01120306','燕窝','01120307','冬虫夏草') as lx
                     from T_STORE_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                       join t_ware_class_base tc on tc.CLASSCODE in ('01120301','01120306','01120307') and TC.compid = p_compid and tc.WAREID = d.WAREID and TC.classgroupno = '01'
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE,decode(tc.classcode,'01120301','西洋参','01120306','燕窝','01120307','冬虫夏草')
                     ))
 where lxrn=1 ),
res as (
 select
      COALESCE(d_sl.busno, d_je.busno, d_zx.busno) as busno,
     COALESCE(d_sl.WAREID, d_je.WAREID, d_zx.WAREID) AS WAREID,
     COALESCE(d_sl.总数量, d_je.总数量, d_zx.总数量) as 总数量,
     COALESCE(d_sl.待出库数量总计, d_je.待出库数量总计, d_zx.待出库数量总计) as 待出库数量总计,
     COALESCE(d_sl.总不合格数量, d_je.总不合格数量, d_zx.总不合格数量) as 总不合格数量,
     COALESCE(d_sl.总待验数量, d_je.总待验数量, d_zx.总待验数量) as 总待验数量,
     COALESCE(d_sl.可用数量, d_je.可用数量, d_zx.可用数量) as 可用数量,
     COALESCE(d_sl.SALEPRICE, d_je.SALEPRICE, d_zx.SALEPRICE) as SALEPRICE,
        d_sl.rn as 库存排名
 ,d_je.rn as 金额排行,d_zx.rn as 滞销排行
from
d_sl
FULL OUTER JOIN d_je on d_sl.WAREID=d_je.WAREID and d_sl.BUSNO=d_je.BUSNO
FULL OUTER JOIN d_zx on COALESCE(d_sl.WAREID, d_je.WAREID)=d_zx.WAREID and COALESCE(d_sl.BUSNO, d_je.BUSNO)=d_zx.busno)
-- select * from d_je where WAREID='10117531';
select r.busno,s.ORGNAME, r.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC,f.FACTORYNAME
     , r.总数量,r.待出库数量总计,r.总不合格数量,r.总待验数量,r.可用数量, r.SALEPRICE,r.总数量*r.SALEPRICE as 金额, r.库存排名, r.金额排行, r.滞销排行
from res r
left join s_busi s on r.busno =s.BUSNO
left join t_ware_base w on r.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID
union all
select  a1.busno,s.ORGNAME, a1.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC, f.FACTORYNAME,a1.总数量,a1.待出库数量总计,a1.总不合格数量,a1.总待验数量,a1.可用数量, a1.SALEPRICE, a1.je, null,null,null
from a1
left join s_busi s on a1.busno =s.BUSNO
left join t_ware_base w on a1.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID order by WAREID,busno;

END ;
/

