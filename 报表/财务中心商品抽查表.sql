select ZMDZ1, busno, WAREID, WAREQTY, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, WAREQTY,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
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
                     and not exists (select WAREID from t_sale_d sd
join s_busi s on sd.BUSNO = s.BUSNO where s.COMPID = 1000 and s.ZMDZ1 = 81001 and sd.ACCDATE between ADD_MONTHS(SYSDATE, -6) and SYSDATE
and sd.WAREID=d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
where rn <= 20

--数量
with d_sl as (select ZMDZ1, busno, WAREID, WAREQTY, sumsl, SALEPRICE, je, rn
from (
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
where rn <= 20),
--金额
d_je as (select ZMDZ1, busno, WAREID, WAREQTY, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, WAREQTY,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
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
where rn <= 20),
--滞销--6个月没销售
d_zx as (select ZMDZ1, busno, WAREID, WAREQTY, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, WAREQTY,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
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
                     and not exists (select WAREID from t_sale_d sd
join s_busi s on sd.BUSNO = s.BUSNO where s.COMPID = 1000 and s.ZMDZ1 = 81001 and sd.ACCDATE between ADD_MONTHS(SYSDATE, -6) and SYSDATE
and sd.WAREID=d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
where rn <= 20 ),
   a1 as (
select ZMDZ1, busno, WAREID, WAREQTY, sumsl, SALEPRICE, je, rn,lx,lxrn
from (
SELECT ZMDZ1,busno,WAREID, WAREQTY,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn,lx,
        row_number() over (partition by lx,busno ORDER BY sumsl DESC) lxrn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.WAREQTY) as WAREQTY,sum(sum(d.WAREQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE,
                            decode(tc.classcode,'01120301','西洋参','01120306','燕窝','01120307','冬虫夏草') as lx
                     from T_STORE_D d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                       join t_ware_class_base tc on tc.CLASSCODE in ('01120301','01120306','01120307') and TC.compid = 1000 and tc.WAREID = d.WAREID and TC.classgroupno = '01'
                     where d.COMPID = 1000 and s.ZMDZ1 = 81001 and WAREQTY <> 0
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE,decode(tc.classcode,'01120301','西洋参','01120306','燕窝','01120307','冬虫夏草')
                     ))
 where lxrn=1 ),
res as (
 select
      COALESCE(d_sl.busno, d_je.busno, d_zx.busno) as busno,
     COALESCE(d_sl.WAREID, d_je.WAREID, d_zx.WAREID) AS WAREID,
     COALESCE(d_sl.WAREQTY, d_je.WAREQTY, d_zx.WAREQTY) as WAREQTY,
     COALESCE(d_sl.SALEPRICE, d_je.SALEPRICE, d_zx.SALEPRICE) as SALEPRICE,
        d_sl.rn as 库存排名
 ,d_je.rn as 金额排行,d_zx.rn as 滞销排行
from
d_sl
FULL OUTER JOIN d_je on d_sl.WAREID=d_je.WAREID and d_sl.BUSNO=d_je.BUSNO
FULL OUTER JOIN d_zx on COALESCE(d_sl.WAREID, d_je.WAREID)=d_zx.WAREID and COALESCE(d_sl.BUSNO, d_je.BUSNO)=d_zx.busno)
-- select * from d_je where WAREID='10117531';
select r.busno,s.ORGNAME, r.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC,f.FACTORYNAME, r.WAREQTY, r.SALEPRICE,r.WAREQTY*r.SALEPRICE as 金额, r.库存排名, r.金额排行, r.滞销排行
from res r
left join s_busi s on r.busno =s.BUSNO
left join t_ware_base w on r.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID
union all
select  a1.busno,s.ORGNAME, a1.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC, f.FACTORYNAME,a1.WAREQTY, a1.SALEPRICE, a1.je, null,null,null
from a1
left join s_busi s on a1.busno =s.BUSNO
left join t_ware_base w on a1.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID;


create table d_cw_pro_check(
 busno number,
 ORGNAME varchar2(100),
 WAREID number,
 WARENAME varchar2(100),
 WAREUNIT varchar2(100),
 WARESPEC varchar2(100),
 FACTORYNAME varchar2(100),
 WAREQTY number,
 SALEPRICE number(14,4),
 je    number(14,4),
 kcrn number,
 jern number,
 zxrn number,
 lx   varchar2(100)
);







select ZMDZ1, busno, WAREID, WAREQTY, sumsl, SALEPRICE, je, rn,lx,lxrn
from (
SELECT ZMDZ1,busno,WAREID, WAREQTY,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn,lx,
        row_number() over (partition by lx,busno ORDER BY sumsl DESC) lxrn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.WAREQTY) as WAREQTY,sum(sum(d.WAREQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE,
                            decode(tc.classcode,'01120301','西洋参','01120306','燕窝','01120307','冬虫夏草') as lx
                     from T_STORE_D d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                       join t_ware_class_base tc on tc.CLASSCODE in ('01120301','01120306','01120307') and TC.compid = 1000 and tc.WAREID = d.WAREID and TC.classgroupno = '01'
                     where d.COMPID = 1000 and s.ZMDZ1 = 81001 and WAREQTY <> 0
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE,decode(tc.classcode,'01120301','西洋参','01120306','燕窝','01120307','冬虫夏草')
                     ))
 where lxrn=1;

select * from t_ware_class_base where CLASSCODE in ('01120301','01120306','01120307') and compid = 1000  and classgroupno = '01';



