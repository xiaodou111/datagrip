create PROCEDURE proc_24_cost_change(p_begin IN DATE,
                                          p_end IN DATE,
                                          p_syb IN pls_integer,
                                          p_gljb IN pls_integer,
                                          p_sql OUT SYS_REFCURSOR )
IS
  v_syb varchar2(100);
  v_gljb varchar2(100);
        v_sql VARCHAR2(30000);
BEGIN
  if p_syb is not null then
      v_syb:=to_char(p_syb);
  end if;
   if p_gljb ='12105' then
      v_gljb:='12105,12116' ;
      SELECT f_get_sjzl_rename(v_gljb)
           into  v_gljb
       FROM dual ;
          end if;
  if p_gljb =2 then
      v_gljb:='12100,12101,12102,12103,12104,12106,12107,12108,12109,12110,12111,12112,12113,12114,12115' ;
      SELECT f_get_sjzl_rename(v_gljb)
           into  v_gljb
       FROM dual ;
          end if;

  if p_syb is null and p_gljb is not null then


  v_sql:='with a_24 as (
select WAREID, ACCDATE,PURPRICE,PURPRICE*case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as PURPRICE1, case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as WAREQTY,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end as NETPRICE,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end * case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as NETAMT
from T_SALE_D d where ACCDATE between TO_DATE(''' || TO_CHAR(p_begin, 'YYYY-MM-DD') || ''', ''YYYY-MM-DD'') AND TO_DATE(''' || TO_CHAR(p_end, 'YYYY-MM-DD') || ''', ''YYYY-MM-DD'')
    and exists(select 1 from t_ware_class_base where CLASSCODE IN (' || v_gljb || ') and d.wareid=t_ware_class_base.wareid)
                ),
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
from T_SALE_D d where ACCDATE between TO_DATE(''' || TO_CHAR(p_begin, 'YYYY-MM-DD') || ''', ''YYYY-MM-DD'') AND TO_DATE(''' || TO_CHAR(p_end, 'YYYY-MM-DD') || ''', ''YYYY-MM-DD'')
           and exists(select 1 from t_ware_class_base where CLASSCODE IN (' || v_gljb || ') and d.wareid=t_ware_class_base.wareid)
    ),
    avg_23 as (
select WAREID, sum(WAREQTY) as sumWAREQTY ,sum(PURPRICE1),sum(NETAMT),
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as avgPURPRICE1_23,
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as avgNETPRICE_23
       from a_23 group by WAREID),
    res as (
  select nvl(avg_23.WAREID, avg_24.WAREID) as wareid,
         avg_24.sumWAREQTY as sumWAREQTY_24,
         avg_23.sumWAREQTY as sumWAREQTY_23,
         avg_24.avgPURPRICE1_24,
         avg_23.avgPURPRICE1_23,
         avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23 as 进价差额,
         (avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23)*avg_24.sumWAREQTY as 成本上涨绝对值,
         avg_24.avgNETPRICE_24,
         avg_23.avgNETPRICE_23,
         avg_24.avgNETPRICE_24-avg_23.avgNETPRICE_23 as 单盒零售价差,
         case when avgNETPRICE_24=0 then 0 else
         (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end as mll_24,
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_23,

         case when avgNETPRICE_24=0 then 0 else (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end-
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_change,
         avgNETPRICE_24-avgPURPRICE1_24 as permle_24,
         avgNETPRICE_23-avgPURPRICE1_23 as permle_23,
         (avgNETPRICE_24-avgPURPRICE1_24)-(avgNETPRICE_23-avgPURPRICE1_23) as permlce,
         ((avg_24.avgNETPRICE_24-avg_24.avgPURPRICE1_24)-(avg_23.avgNETPRICE_23-avg_23.avgPURPRICE1_23))*avg_24.sumWAREQTY as mlce
          from
  avg_23 full join avg_24 on avg_23.WAREID = avg_24.WAREID)
select r.wareid,w.WARENAME, w.WARESPEC, f.FACTORYNAME,
       SUBSTR(g.PARENT_CLASSCODE, INSTR(g.PARENT_CLASSCODE, '';'', 1, 2) + 1,
              INSTR(g.PARENT_CLASSCODE, '';'', 1, 3) - INSTR(g.PARENT_CLASSCODE, '';'', 1, 2) - 1) middle,
       DECODE(f.PARENT_CLASSCODE, ''未划分;'', '''',
              replace(substr(f.PARENT_CLASSCODE, 2, length(f.PARENT_CLASSCODE) - 2), '';'', '' - '')) gljb,
       DECODE(e.PARENT_CLASSCODE, ''未划分;'', '''',
              replace(substr(e.PARENT_CLASSCODE, 2, length(e.PARENT_CLASSCODE) - 2), '';'', '' - '')) khlb,
       r.sumWAREQTY_24, r.sumWAREQTY_23, r.avgPURPRICE1_24, r.avgPURPRICE1_23, r.进价差额, r.成本上涨绝对值, r.avgNETPRICE_24,
       r.avgNETPRICE_23, r.单盒零售价差, r.mll_24, r.mll_23, r.mll_change, r.permle_24, r.permle_23, r.permlce, r.mlce
from res r
left join t_ware_base w on r.wareid = w.wareid
left join t_factory f on w.FACTORYID = f.FACTORYID
LEFT JOIN t_ware_class_base g ON g.compid = 1000 AND w.wareid = g.wareid and g.classgroupno = ''01''
LEFT JOIN t_ware_class_base f ON f.compid = 1000 AND w.wareid = f.wareid and f.classgroupno = ''12''
LEFT JOIN t_ware_class_base e ON e.compid = 1000 AND w.wareid = e.wareid and e.classgroupno = ''90''';


       DBMS_OUTPUT.PUT_LINE('v_sql:'||v_sql);
      OPEN p_sql FOR  v_sql;
  end if;

  if  p_syb is null and p_gljb is null then
      OPEN p_sql FOR

  with a_24 as (
select WAREID, ACCDATE,PURPRICE,PURPRICE*case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as PURPRICE1, case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as WAREQTY,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end as NETPRICE,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end * case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as NETAMT
from T_SALE_D d where ACCDATE between p_begin and p_end),
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
from T_SALE_D d where ACCDATE between add_months(p_begin,-12) and add_months(p_end,-12)
    ),
    avg_23 as (
select WAREID, sum(WAREQTY) as sumWAREQTY ,sum(PURPRICE1),sum(NETAMT),
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as avgPURPRICE1_23,
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as avgNETPRICE_23
       from a_23 group by WAREID),
    res as (
  select nvl(avg_23.WAREID, avg_24.WAREID) as wareid,
         avg_24.sumWAREQTY as sumWAREQTY_24,
         avg_23.sumWAREQTY as sumWAREQTY_23,
         avg_24.avgPURPRICE1_24,
         avg_23.avgPURPRICE1_23,
         avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23 as 进价差额,
         (avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23)*avg_24.sumWAREQTY as 成本上涨绝对值,
         avg_24.avgNETPRICE_24,
         avg_23.avgNETPRICE_23,
         avg_24.avgNETPRICE_24-avg_23.avgNETPRICE_23 as 单盒零售价差,
         case when avgNETPRICE_24=0 then 0 else
         (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end as mll_24,
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_23,

         case when avgNETPRICE_24=0 then 0 else (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end-
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_change,
         avgNETPRICE_24-avgPURPRICE1_24 as permle_24,
         avgNETPRICE_23-avgPURPRICE1_23 as permle_23,
         (avgNETPRICE_24-avgPURPRICE1_24)-(avgNETPRICE_23-avgPURPRICE1_23) as permlce,
         ((avg_24.avgNETPRICE_24-avg_24.avgPURPRICE1_24)-(avg_23.avgNETPRICE_23-avg_23.avgPURPRICE1_23))*avg_24.sumWAREQTY as mlce
          from
  avg_23 full join avg_24 on avg_23.WAREID = avg_24.WAREID)
select r.wareid,w.WARENAME, w.WARESPEC, f.FACTORYNAME,
       SUBSTR(g.PARENT_CLASSCODE, INSTR(g.PARENT_CLASSCODE, ';', 1, 2) + 1,
              INSTR(g.PARENT_CLASSCODE, ';', 1, 3) - INSTR(g.PARENT_CLASSCODE, ';', 1, 2) - 1) middle,
       DECODE(f.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(f.PARENT_CLASSCODE, 2, length(f.PARENT_CLASSCODE) - 2), ';', ' - ')) gljb,
       DECODE(e.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(e.PARENT_CLASSCODE, 2, length(e.PARENT_CLASSCODE) - 2), ';', ' - ')) khlb,
       r.sumWAREQTY_24, r.sumWAREQTY_23, r.avgPURPRICE1_24, r.avgPURPRICE1_23, r.进价差额, r.成本上涨绝对值, r.avgNETPRICE_24,
       r.avgNETPRICE_23, r.单盒零售价差, r.mll_24, r.mll_23, r.mll_change, r.permle_24, r.permle_23, r.permlce, r.mlce
from res r
left join t_ware_base w on r.wareid = w.wareid
left join t_factory f on w.FACTORYID = f.FACTORYID
LEFT JOIN t_ware_class_base g ON g.compid = 1000 AND w.wareid = g.wareid and g.classgroupno = '01'
LEFT JOIN t_ware_class_base f ON f.compid = 1000 AND w.wareid = f.wareid and f.classgroupno = '12'
LEFT JOIN t_ware_class_base e ON e.compid = 1000 AND w.wareid = e.wareid and e.classgroupno = '90';
  end if;

  if p_syb is not null and p_gljb is null then
     OPEN p_sql FOR

  with a_24 as (
select WAREID, ACCDATE,PURPRICE,PURPRICE*case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as PURPRICE1, case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as WAREQTY,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end as NETPRICE,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end * case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as NETAMT
from T_SALE_D d where ACCDATE between p_begin and p_end
    and exists(select 1 from t_busno_class_set where CLASSCODE=v_syb and d.BUSNO=t_busno_class_set.BUSNO)
                ),
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
from T_SALE_D d where ACCDATE between add_months(p_begin,-12) and add_months(p_end,-12)
            and exists(select 1 from t_busno_class_set where CLASSCODE=v_syb and d.BUSNO=t_busno_class_set.BUSNO)
    ),
    avg_23 as (
select WAREID, sum(WAREQTY) as sumWAREQTY ,sum(PURPRICE1),sum(NETAMT),
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as avgPURPRICE1_23,
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as avgNETPRICE_23
       from a_23 group by WAREID),
    res as (
  select nvl(avg_23.WAREID, avg_24.WAREID) as wareid,
         avg_24.sumWAREQTY as sumWAREQTY_24,
         avg_23.sumWAREQTY as sumWAREQTY_23,
         avg_24.avgPURPRICE1_24,
         avg_23.avgPURPRICE1_23,
         avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23 as 进价差额,
         (avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23)*avg_24.sumWAREQTY as 成本上涨绝对值,
         avg_24.avgNETPRICE_24,
         avg_23.avgNETPRICE_23,
         avg_24.avgNETPRICE_24-avg_23.avgNETPRICE_23 as 单盒零售价差,
         case when avgNETPRICE_24=0 then 0 else
         (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end as mll_24,
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_23,

         case when avgNETPRICE_24=0 then 0 else (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end-
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_change,
         avgNETPRICE_24-avgPURPRICE1_24 as permle_24,
         avgNETPRICE_23-avgPURPRICE1_23 as permle_23,
         (avgNETPRICE_24-avgPURPRICE1_24)-(avgNETPRICE_23-avgPURPRICE1_23) as permlce,
         ((avg_24.avgNETPRICE_24-avg_24.avgPURPRICE1_24)-(avg_23.avgNETPRICE_23-avg_23.avgPURPRICE1_23))*avg_24.sumWAREQTY as mlce
          from
  avg_23 full join avg_24 on avg_23.WAREID = avg_24.WAREID)
select r.wareid,w.WARENAME, w.WARESPEC, f.FACTORYNAME,
       SUBSTR(g.PARENT_CLASSCODE, INSTR(g.PARENT_CLASSCODE, ';', 1, 2) + 1,
              INSTR(g.PARENT_CLASSCODE, ';', 1, 3) - INSTR(g.PARENT_CLASSCODE, ';', 1, 2) - 1) middle,
       DECODE(f.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(f.PARENT_CLASSCODE, 2, length(f.PARENT_CLASSCODE) - 2), ';', ' - ')) gljb,
       DECODE(e.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(e.PARENT_CLASSCODE, 2, length(e.PARENT_CLASSCODE) - 2), ';', ' - ')) khlb,
       r.sumWAREQTY_24, r.sumWAREQTY_23, r.avgPURPRICE1_24, r.avgPURPRICE1_23, r.进价差额, r.成本上涨绝对值, r.avgNETPRICE_24,
       r.avgNETPRICE_23, r.单盒零售价差, r.mll_24, r.mll_23, r.mll_change, r.permle_24, r.permle_23, r.permlce, r.mlce
from res r
left join t_ware_base w on r.wareid = w.wareid
left join t_factory f on w.FACTORYID = f.FACTORYID
LEFT JOIN t_ware_class_base g ON g.compid = 1000 AND w.wareid = g.wareid and g.classgroupno = '01'
LEFT JOIN t_ware_class_base f ON f.compid = 1000 AND w.wareid = f.wareid and f.classgroupno = '12'
LEFT JOIN t_ware_class_base e ON e.compid = 1000 AND w.wareid = e.wareid and e.classgroupno = '90';
  end if;





    if p_syb is not null and p_gljb is not null then
       OPEN p_sql FOR
     with a_24 as (
select WAREID, ACCDATE,PURPRICE,PURPRICE*case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as PURPRICE1, case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as WAREQTY,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end as NETPRICE,
       case when d.NETPRICE = 0 then d.MINPRICE else d.NETPRICE end * case when d.WAREQTY = 0 then d.MINQTY else d.WAREQTY end as NETAMT
from T_SALE_D d where ACCDATE between p_begin and p_end
    and exists(select 1 from t_ware_class_base where CLASSCODE=v_gljb and d.wareid=t_ware_class_base.wareid)
    and exists(select 1 from t_busno_class_set where CLASSCODE=v_syb and d.BUSNO=t_busno_class_set.BUSNO)
                ),
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
from T_SALE_D d where ACCDATE between add_months(p_begin,-12) and add_months(p_end,-12)
           and exists(select 1 from t_ware_class_base where CLASSCODE=v_gljb and d.wareid=t_ware_class_base.wareid)
           and exists(select 1 from t_busno_class_set where CLASSCODE=v_syb and d.BUSNO=t_busno_class_set.BUSNO)
    ),
    avg_23 as (
select WAREID, sum(WAREQTY) as sumWAREQTY ,sum(PURPRICE1),sum(NETAMT),
       case when sum(WAREQTY)=0 then 0 else
       sum(PURPRICE * WAREQTY) / sum(WAREQTY) end as avgPURPRICE1_23,
       case when sum(WAREQTY)=0 then 0 else
       sum(NETAMT) / sum(WAREQTY) end as avgNETPRICE_23
       from a_23 group by WAREID),
    res as (
  select nvl(avg_23.WAREID, avg_24.WAREID) as wareid,
         avg_24.sumWAREQTY as sumWAREQTY_24,
         avg_23.sumWAREQTY as sumWAREQTY_23,
         avg_24.avgPURPRICE1_24,
         avg_23.avgPURPRICE1_23,
         avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23 as 进价差额,
         (avg_24.avgPURPRICE1_24-avg_23.avgPURPRICE1_23)*avg_24.sumWAREQTY as 成本上涨绝对值,
         avg_24.avgNETPRICE_24,
         avg_23.avgNETPRICE_23,
         avg_24.avgNETPRICE_24-avg_23.avgNETPRICE_23 as 单盒零售价差,
         case when avgNETPRICE_24=0 then 0 else
         (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end as mll_24,
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_23,

         case when avgNETPRICE_24=0 then 0 else (avgNETPRICE_24-avgPURPRICE1_24)/avgNETPRICE_24 end-
         case when avgNETPRICE_23=0 then 0 else
         (avgNETPRICE_23-avgPURPRICE1_23)/avgNETPRICE_23 end as mll_change,
         avgNETPRICE_24-avgPURPRICE1_24 as permle_24,
         avgNETPRICE_23-avgPURPRICE1_23 as permle_23,
         (avgNETPRICE_24-avgPURPRICE1_24)-(avgNETPRICE_23-avgPURPRICE1_23) as permlce,
         ((avg_24.avgNETPRICE_24-avg_24.avgPURPRICE1_24)-(avg_23.avgNETPRICE_23-avg_23.avgPURPRICE1_23))*avg_24.sumWAREQTY as mlce
          from
  avg_23 full join avg_24 on avg_23.WAREID = avg_24.WAREID)
select r.wareid,w.WARENAME, w.WARESPEC, f.FACTORYNAME,
       SUBSTR(g.PARENT_CLASSCODE, INSTR(g.PARENT_CLASSCODE, ';', 1, 2) + 1,
              INSTR(g.PARENT_CLASSCODE, ';', 1, 3) - INSTR(g.PARENT_CLASSCODE, ';', 1, 2) - 1) middle,
       DECODE(f.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(f.PARENT_CLASSCODE, 2, length(f.PARENT_CLASSCODE) - 2), ';', ' - ')) gljb,
       DECODE(e.PARENT_CLASSCODE, '未划分;', '',
              replace(substr(e.PARENT_CLASSCODE, 2, length(e.PARENT_CLASSCODE) - 2), ';', ' - ')) khlb,
       r.sumWAREQTY_24, r.sumWAREQTY_23, r.avgPURPRICE1_24, r.avgPURPRICE1_23, r.进价差额, r.成本上涨绝对值, r.avgNETPRICE_24,
       r.avgNETPRICE_23, r.单盒零售价差, r.mll_24, r.mll_23, r.mll_change, r.permle_24, r.permle_23, r.permlce, r.mlce
from res r
left join t_ware_base w on r.wareid = w.wareid
left join t_factory f on w.FACTORYID = f.FACTORYID
LEFT JOIN t_ware_class_base g ON g.compid = 1000 AND w.wareid = g.wareid and g.classgroupno = '01'
LEFT JOIN t_ware_class_base f ON f.compid = 1000 AND w.wareid = f.wareid and f.classgroupno = '12'
LEFT JOIN t_ware_class_base e ON e.compid = 1000 AND w.wareid = e.wareid and e.classgroupno = '90';

        end if;
END ;
/

