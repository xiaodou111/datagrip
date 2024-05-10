
select * from (
SELECT ZMDZ1,busno,WAREID, WAREQTY,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.WAREQTY) as WAREQTY,sum(sum(d.WAREQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from T_STORE_D d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = 1000 and s.ZMDZ1 = 81001 and WAREQTY <> 0
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118,0119') and TC.compid = 1000
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
               where rn <= 20;

--数量
with d_sl as (SELECT ZMDZ1,WAREID, WAREQTY,SALEPRICE,WAREQTY*SALEPRICE as je,rn
               FROM (select s.ZMDZ1,d.WAREID,sum(d.WAREQTY) as WAREQTY,tws.SALEPRICE, ROW_NUMBER() OVER (ORDER BY sum(d.WAREQTY) DESC) AS rn
                     from T_STORE_D d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = 1000 and s.ZMDZ1 = 81001 and WAREQTY <> 0
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118,0119') and TC.compid = 1000
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     group by d.WAREID,tws.SALEPRICE,s.ZMDZ1)
               where rn <= 20),
--金额
d_je as ( SELECT ZMDZ1,WAREID, WAREQTY,SALEPRICE,WAREQTY*SALEPRICE as je,rn
FROM (select s.ZMDZ1,d.WAREID, sum(d.WAREQTY) as WAREQTY,tws.SALEPRICE,ROW_NUMBER() OVER (ORDER BY tws.SALEPRICE*sum(d.WAREQTY) DESC) AS rn
      from T_STORE_D d
               join s_busi s on d.BUSNO = s.BUSNO
           left join t_ware_saleprice tws on tws.compid=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
      where d.COMPID = 1000 and s.ZMDZ1 = 81001 and WAREQTY <> 0
        and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118,0119') and TC.compid = 1000
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
      group by d.WAREID,tws.SALEPRICE,s.ZMDZ1  ) where rn<=20),
--滞销--6个月没销售
d_zx as (
SELECT ZMDZ1,WAREID, WAREQTY,SALEPRICE,WAREQTY*SALEPRICE as je,rn
from (
select s.ZMDZ1,d.WAREID, sum(d.WAREQTY) as WAREQTY ,tws.SALEPRICE,ROW_NUMBER() OVER (ORDER BY sum(d.WAREQTY)*tws.SALEPRICE DESC) AS rn
      from T_STORE_D d
               join s_busi s on d.BUSNO = s.BUSNO
      left join t_ware_saleprice tws on tws.compid=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
      where d.COMPID = 1000 and s.ZMDZ1 = 81001 and WAREQTY <> 0
        and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118,0119') and TC.compid = 1000
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
        and not exists (select WAREID from t_sale_d sd
join s_busi s on sd.BUSNO = s.BUSNO where s.COMPID = 1000 and s.ZMDZ1 = 81001 and sd.ACCDATE between ADD_MONTHS(SYSDATE, -6) and SYSDATE
and sd.WAREID=d.WAREID) group by d.WAREID,tws.SALEPRICE,s.ZMDZ1  ) where rn<=20 ),
res as (
 select
      COALESCE(d_sl.ZMDZ1, d_je.ZMDZ1, d_zx.ZMDZ1) as ZMDZ1,
     COALESCE(d_sl.WAREID, d_je.WAREID, d_zx.WAREID) AS WAREID,
     COALESCE(d_sl.WAREQTY, d_je.WAREQTY, d_zx.WAREQTY) as WAREQTY,
     COALESCE(d_sl.SALEPRICE, d_je.SALEPRICE, d_zx.SALEPRICE) as SALEPRICE,
        d_sl.rn as 库存排名
 ,d_je.rn as 金额排行,d_zx.rn as 滞销排行
from
d_sl
FULL OUTER JOIN d_je on d_sl.WAREID=d_je.WAREID
FULL OUTER JOIN d_zx on COALESCE(d_sl.WAREID, d_je.WAREID)=d_zx.WAREID)
select r.ZMDZ1,s.ORGNAME, r.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC,f.FACTORYNAME, r.WAREQTY, r.SALEPRICE,r.WAREQTY*r.SALEPRICE as 金额, r.库存排名, r.金额排行, r.滞销排行
from res r
left join s_busi s on r.ZMDZ1 =s.BUSNO
left join t_ware_base w on r.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID
;;






