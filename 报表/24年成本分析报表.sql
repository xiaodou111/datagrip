select w.WAREID, w.WARENAME, w.WARESPEC, f.FACTORYNAME,
       SUBSTR(g.PARENT_CLASSCODE, INSTR(g.PARENT_CLASSCODE, ';', 1, 2) + 1,
              INSTR(g.PARENT_CLASSCODE, ';', 1, 3) - INSTR(g.PARENT_CLASSCODE, ';', 1, 2) - 1) middle,
       DECODE(f.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(f.PARENT_CLASSCODE, 2, length(f.PARENT_CLASSCODE) - 2), ';', ' - ')) gljb,
       DECODE(e.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(e.PARENT_CLASSCODE, 2, length(e.PARENT_CLASSCODE) - 2), ';', ' - ')) khlb
from t_ware_base w
         left join t_factory f on w.FACTORYID = f.FACTORYID
         LEFT JOIN t_ware_class_base g ON g.compid = 1000 AND w.wareid = g.wareid and g.classgroupno = '01'
         LEFT JOIN t_ware_class_base f ON f.compid = 1000 AND w.wareid = f.wareid and f.classgroupno = '12'
         LEFT JOIN t_ware_class_base e ON e.compid = 1000 AND w.wareid = e.wareid and e.classgroupno = '90'
where w.WAREID = 10110500;


select WAREID, PURPRICE, ADJUSTPRICE
from T_STORE_I
where WAREID = 10110500 and ACCOUNT_DATE between date'2023-01-01' and date'2023-12-31';
select WAREID, PURPRICE, ADJUSTPRICE
from T_STORE_I
where WAREID = 10110500 and ACCOUNT_DATE between date'2024-01-01' and date'2024-12-31';

select NETPRICE, ACCDATE, AVG(NETPRICE) over ( partition by WAREID)
from T_SALE_D
where ACCDATE between date'2023-01-01' and date'2023-12-31' and WAREID = 10110500;
select NETPRICE, ACCDATE, AVG(NETPRICE) over ( partition by WAREID)
from T_SALE_D
where ACCDATE between date'2024-01-01' and date'2024-12-31' and WAREID = 10110500;

select WAREID, ACCDATE, AVG(NETPRICE)
from T_SALE_D
where ACCDATE = date'2024-01-01'
group by WAREID, ACCDATE;
select WAREID, ACCDATE, NETPRICE, PURPRICE, WAREID, WAREQTY, NETAMT, BUSNO
from T_SALE_D
where ACCDATE = date'2024-01-01' and WAREID = '10107833';

select WAREID, ACCDATE,
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as 平均进价,
       sum(WAREQTY),
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as 平均售价,

       sum(WAREQTY) as 总数, sum(NETAMT) as 总金额,

from T_SALE_D
where ACCDATE = date'2024-01-01' and WAREID = '10106656'
group by WAREID, ACCDATE;


with a_24 as (
select WAREID, ACCDATE,PURPRICE,PURPRICE*case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as PURPRICE1, case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as WAREQTY,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end as NETPRICE,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end * case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as NETAMT
from T_SALE_D d where ACCDATE = date'2024-01-01'),
    avg_24 as (
select WAREID, sum(WAREQTY) as sumWAREQTY ,sum(PURPRICE1),sum(NETAMT),
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as avgPURPRICE1_24,
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as avgNETPRICE_24
       from a_24 group by WAREID),
    a_23 as (
 select WAREID, ACCDATE,PURPRICE,PURPRICE*case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as PURPRICE1, case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as WAREQTY,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end as NETPRICE,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end * case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as NETAMT
from T_SALE_D d where ACCDATE = date'2023-01-01'
    ),
    avg_23 as (
select WAREID, sum(WAREQTY) as sumWAREQTY ,sum(PURPRICE1),sum(NETAMT),
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as avgPURPRICE1_23,
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as avgNETPRICE_23
       from a_23 group by WAREID)
  select nvl(avg_23.WAREID, avg_24.WAREID) as wareid,
         avg_23.avgPURPRICE1_23,avg_24.avgPURPRICE1_24,
         avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23 as 进价变化,
         avg_23.avgNETPRICE_23,avg_24.avgNETPRICE_24,
         avg_24.avgNETPRICE_24-avg_23.avgNETPRICE_23 as 售价变化,
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_23,
        case when avgNETPRICE_24=0 then 0 else
         (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end as mll_24,
         case when avgNETPRICE_24=0 then 0 else (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end-
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_change,
         avg_24.sumWAREQTY,
         ((avg_24.avgNETPRICE_24-avg_24.avgPURPRICE1_24)-(avg_23.avgNETPRICE_23-avg_23.avgPURPRICE1_23))*avg_24.sumWAREQTY as mlce
          from
  avg_23 full join avg_24 on avg_23.WAREID = avg_24.WAREID;

 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
 join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode
 join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
 join t_busno_class_base tb1 on ts1.classgroupno=tb1.classgroupno and ts1.classcode=tb1.classcode

 --事业部
 select * from t_busno_class_set where CLASSCODE='303100';
--集团管理级别
 select * from t_ware_class_base where classgroupno=12 and COMPID=1000;

select * from t_class_base ;


 select * from t_busno_class_base where CLASSCODE='303100';




select SALENO,WAREID, ACCDATE, PURPRICE, WAREQTY, NETAMT, NETPRICE
from T_SALE_D
where ACCDATE = date'2024-01-01' and WAREID = '10106656';
select WAREID, avg(PURPRICE) as 平均进价
from T_STORE_I
where WAREID = 10107833 and ACCOUNT_DATE between date'2024-01-01' and date'2024-01-31'
group by WAREID;

select WAREID, PURPRICE
from T_STORE_I
where WAREID = 10107833 and ACCOUNT_DATE between date'2024-01-01' and date'2024-01-31';



select *
from;


