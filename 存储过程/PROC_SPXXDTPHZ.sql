create PROCEDURE proc_spxxdtphz(p_begin IN DATE,
                                          p_end IN DATE,
                                          p_hz IN pls_integer,
                                          p_wareid IN pls_integer,
                                          p_busno IN pls_integer,
                                      --    p_bm IN tmp_yb_cbmd_zb.bm%TYPE,
                                          p_sql OUT SYS_REFCURSOR )
IS
  v_time number;

BEGIN
 select p_end-p_begin
 into v_time
 from dual;
IF p_hz = 1 THEN
 OPEN p_sql FOR
 --按厂家汇总
 with
 a1 as(
 SELECT facturer,COUNT(*) wcount FROM (
SELECT b.wareid,b.facturer FROM t_ware_dtp b
 group by  b.facturer,b.wareid
 ) a group by facturer
 ),
 a2 as(
 SELECT facturer,COUNT(*) bcount FROM (
SELECT a.busno,b.facturer FROM t_bus_wares_dtp  a
left join  t_ware_dtp b  on a.wareid=b.wareid
 group by  b.facturer,a.busno
 ) a group by facturer
 ),
 a3 as(
 SELECT sum(wareqty)qty,sum(a.netsum)net,b.facturer FROM t_rpt_sale_af8  a
 inner join  (SELECT a.wareid,b.facturer FROM t_bus_wares_dtp  a
 left join  t_ware_dtp b  on a.wareid=b.wareid
 group by  b.facturer,a.wareid )  b on a.wareid=b.wareid
 WHERE   accdate between p_begin and p_end
 group by b.facturer
 /*
SELECT sum(wareqty)qty,sum(a.netsum)net,b.facturer FROM t_rpt_sale_af8  a
 inner join  (SELECT a.wareid,b.facturer FROM t_ware_dtp  b
 left join  t_bus_wares_dtp a  on a.wareid=b.wareid
 group by  b.facturer,a.wareid )  b on a.wareid=b.wareid
 WHERE   accdate between date'2023-01-01' and date'2023-01-27'
 group by b.facturer*/
 ),
 a4 as(
 SELECT sum(wareqty) lyqty,sum(a.netsum) lynet,b.facturer FROM t_rpt_sale_af8  a
 inner join  (SELECT a.wareid,b.facturer FROM t_bus_wares_dtp  a
 left join  t_ware_dtp b  on a.wareid=b.wareid
 group by  b.facturer,a.wareid )  b on a.wareid=b.wareid
 WHERE   accdate between add_months(trunc(p_begin),-12) and add_months(trunc(p_end),-12)
 group by b.facturer
 ),
 a5 as(
 SELECT sum(wareqty) lmqty,sum(a.netsum) lmnet,b.facturer FROM t_rpt_sale_af8  a
 inner join  (SELECT a.wareid,b.facturer FROM t_bus_wares_dtp  a
 left join  t_ware_dtp b  on a.wareid=b.wareid
 group by  b.facturer,a.wareid )  b on a.wareid=b.wareid
 WHERE   accdate between p_end-1-v_time and p_end-1
 group by b.facturer
 )
 select a1.facturer,null,null,null,null,null,a2.bcount,a1.wcount,a3.qty,a3.net,
 case WHEN(NVL(a4.lyqty, 0))!=0 THEN (round((a3.qty-a4.lyqty)/a4.lyqty,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(a4.lynet, 0))!=0 THEN (round((a3.net-a4.lynet)/a4.lynet,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(a5.lmqty, 0))!=0 THEN (round((a3.qty-a5.lmqty)/a5.lmqty,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(a5.lmnet, 0))!=0 THEN (round((a3.net-a5.lmnet)/a5.lmnet,4))*100||'%' ELSE '0' END xsehb
 from a1
 left join a2 on a1.facturer=a2.facturer
 left join a3 on a1.facturer=a3.facturer
 left join a4 on a1.facturer=a4.facturer
 left join a5 on a1.facturer=a5.facturer;

END IF;
--按门店汇总
IF p_hz = 2 and p_busno is null THEN
   OPEN p_sql FOR
   with
   a1 as(
 SELECT busno,COUNT(*) facount FROM (
 SELECT a.busno,b.facturer FROM t_bus_wares_dtp  a
left join  t_ware_dtp b  on a.wareid=b.wareid  where b.facturer is not null
 group by  b.facturer,a.busno
 ) a group by busno
 ),
 a2 as(
 SELECT busno,COUNT(*) wcount FROM (
 SELECT a.busno,b.wareid FROM t_bus_wares_dtp  a
left join  t_ware_dtp b  on a.wareid=b.wareid where b.wareid is not null
 group by  b.wareid,a.busno
 ) a group by busno
 ),
 /*a3 as(
 select sum(wareqty)qty,sum(a.netsum)net,c.busno  FROM t_rpt_sale_af8  a
 inner join t_ware_dtp b  on a.wareid=b.wareid
 left join t_bus_dtp c on a.busno=c.busno
 WHERE   accdate between p_begin and p_end
 group by c.busno
 ),*/
 a3 as(
   SELECT sum(wareqty)qty,sum(a.netsum)net,b.busno FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=to_char(b.busno) and a.wareid=b.wareid
 WHERE   accdate between p_begin and p_end
 group by b.busno
  ),
  a4 as(
  select sum(wareqty) lyqty,sum(a.netsum) lynet,b.busno  FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=to_char(b.busno) and a.wareid=b.wareid
 WHERE   accdate between  add_months(trunc(p_begin),-12) and add_months(trunc(p_end),-12)
 group by b.busno
  ),
  a5 as(
  select sum(wareqty) lmqty,sum(a.netsum) lmnet,b.busno  FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=to_char(b.busno) and a.wareid=b.wareid
 WHERE   accdate between p_end-1-v_time and p_end-1
 group by b.busno
  )
 select null,a1.busno,s.orgname,null,null,a1.facount,null,a2.wcount,a3.qty,a3.net,
 case WHEN(NVL(a4.lyqty, 0))!=0 THEN (round((a3.qty-a4.lyqty)/a4.lyqty,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(a4.lynet, 0))!=0 THEN (round((a3.net-a4.lynet)/a4.lynet,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(a5.lmqty, 0))!=0 THEN (round((a3.qty-a5.lmqty)/a5.lmqty,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(a5.lmnet, 0))!=0 THEN (round((a3.net-a5.lmnet)/a5.lmnet,4))*100||'%' ELSE '0' END xsehb
 from a1
 left join a2 on a1.busno=a2.busno
 left join a3 on a1.busno=a3.busno
 left join a4 on a1.busno=a4.busno
 left join a5 on a1.busno=a5.busno
 left join s_busi s on a1.busno=s.busno;



END IF;

IF p_hz = 2 and p_busno is not null THEN
   OPEN p_sql FOR
   with
   a1 as(
 SELECT busno,COUNT(*) facount FROM (
 SELECT a.busno,b.facturer FROM t_bus_wares_dtp  a
left join  t_ware_dtp b  on a.wareid=b.wareid  where b.facturer is not null
 group by  b.facturer,a.busno
 ) a group by busno
 ),
 a2 as(
 SELECT busno,COUNT(*) wcount FROM (
 SELECT a.busno,b.wareid FROM t_bus_wares_dtp  a
left join  t_ware_dtp b  on a.wareid=b.wareid where b.wareid is not null
 group by  b.wareid,a.busno
 ) a group by busno
 ),
 a3 as(
 select sum(wareqty)qty,sum(a.netsum)net,b.busno  FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=to_char(b.busno) and a.wareid=b.wareid
 WHERE   accdate between p_begin and p_end
 group by b.busno
 ),
 /*a3 as(
   SELECT sum(wareqty)qty,sum(a.netsum)net,b.busno FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=b.busno and a.wareid=b.wareid
 WHERE   accdate between p_begin and p_end
 group by b.busno
  )*/
  a4 as(
  select sum(wareqty) lyqty,sum(a.netsum) lynet,b.busno  FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=to_char(b.busno) and a.wareid=b.wareid
 WHERE   accdate between  add_months(trunc(p_begin),-12) and add_months(trunc(p_end),-12)
 group by b.busno
  ),
  a5 as(
  select sum(wareqty) lmqty,sum(a.netsum) lmnet,b.busno  FROM t_rpt_sale_af8  a
 inner join  t_bus_wares_dtp  b
 on a.busno=to_char(b.busno) and a.wareid=b.wareid
 WHERE   accdate between p_end-1-v_time and p_end-1
 group by b.busno
  )
 select null,a1.busno,s.orgname,null,null,a1.facount,null,a2.wcount,a3.qty,a3.net,
 case WHEN(NVL(a4.lyqty, 0))!=0 THEN (round((a3.qty-a4.lyqty)/a4.lyqty,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(a4.lynet, 0))!=0 THEN (round((a3.net-a4.lynet)/a4.lynet,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(a5.lmqty, 0))!=0 THEN (round((a3.qty-a5.lmqty)/a5.lmqty,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(a5.lmnet, 0))!=0 THEN (round((a3.net-a5.lmnet)/a5.lmnet,4))*100||'%' ELSE '0' END xsehb
 from a1
 left join a2 on a1.busno=a2.busno
 left join a3 on a1.busno=a3.busno
 left join a4 on a1.busno=a4.busno
 left join a5 on a1.busno=a5.busno
 left join s_busi s on a1.busno=s.busno
 where a1.busno=p_busno;

END IF;
--按商品汇总
IF p_hz = 3 and p_wareid is null THEN
   OPEN p_sql FOR
   with
   a as(
  select wareid,FACTURER from t_ware_dtp
  ),
   a1 as(
 SELECT a.wareid,COUNT(*) buscount,max(a.FACTURER) FACTURER FROM (
 SELECT b.wareid,b.busno,max(FACTURER) FACTURER FROM  t_bus_wares_dtp b
left join t_ware_dtp a on a.wareid=b.wareid
 group by  b.busno,b.wareid
 ) a  group by a.wareid
 ),
 a2 as(
 SELECT a.wareid,COUNT(facturer) facount FROM (
 SELECT a.wareid,a.facturer FROM t_ware_dtp  a
 group by  a.wareid,a.facturer
 ) a  group by a.wareid
 ),

 /*a3 as(
  SELECT sum(wareqty)qty,sum(a.netsum)net,b.wareid FROM t_rpt_sale_af8  a
 inner join t_bus_wares_dtp b on a.wareid=b.wareid and a.busno=b.busno
  WHERE a.accdate between p_begin and p_end
 group by b.wareid),*/
 a3 as(
 SELECT sum(wareqty)qty,sum(a.netsum)net,a.wareid FROM t_rpt_sale_af8  a
 inner join t_ware_dtp c on a.wareid=c.wareid
 where exists (
 select 1 from t_bus_wares_dtp b
 where a.busno=to_char(b.busno)
 )
  and a.accdate between p_begin and p_end
 group by a.wareid
 ),
 a4 as(
  SELECT sum(wareqty)lyqty,sum(a.netsum)lynet,a.wareid FROM t_rpt_sale_af8  a
 inner join t_ware_dtp c on a.wareid=c.wareid
 where exists (
 select 1 from t_bus_wares_dtp b
 where a.busno=b.busno
 )
  and accdate between add_months(trunc(p_begin),-12) and add_months(trunc(p_end),-12)
 group by a.wareid
 ),
 a5 as(
 SELECT sum(wareqty)lmqty,sum(a.netsum)lmnet,a.wareid FROM t_rpt_sale_af8  a
 inner join t_ware_dtp c on a.wareid=c.wareid
 where exists (
 select 1 from t_bus_wares_dtp b
 where a.busno=to_char(b.busno)
 )
  and accdate between p_end-1-v_time and p_end-1
 group by a.wareid
 )
 select a.FACTURER,null,null,a.wareid,w.warename,a2.facount,a1.buscount,null,a3.qty,a3.net,
 case WHEN(NVL(a4.lyqty, 0))!=0 THEN (round((a3.qty-a4.lyqty)/a4.lyqty,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(a4.lynet, 0))!=0 THEN (round((a3.net-a4.lynet)/a4.lynet,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(a5.lmqty, 0))!=0 THEN (round((a3.qty-a5.lmqty)/a5.lmqty,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(a5.lmnet, 0))!=0 THEN (round((a3.net-a5.lmnet)/a5.lmnet,4))*100||'%' ELSE '0' END xsehb
 from  a
 left join a1 on a.wareid=a1.wareid
 left join a2 on a.wareid=a2.wareid
 left join a3 on a.wareid=a3.wareid
 left join a4 on a.wareid=a4.wareid
 left join a5 on a.wareid=a5.wareid
 left join t_ware_base w on a.wareid=w.wareid;

END IF;
IF p_hz = 3 and p_wareid is not null THEN
   OPEN p_sql FOR

with
  a as(
  select wareid,FACTURER from t_ware_dtp
  ),

  a1 as(
 SELECT a.wareid,COUNT(*) buscount,max(a.FACTURER) FACTURER FROM (
 SELECT b.wareid,b.busno,max(FACTURER) FACTURER FROM  t_bus_wares_dtp b
left join t_ware_dtp a on a.wareid=b.wareid
 group by  b.busno,b.wareid
 ) a  group by a.wareid
 ),
 a2 as(
 SELECT a.wareid,COUNT(facturer) facount FROM (
 SELECT a.wareid,a.facturer FROM t_ware_dtp  a
 group by  a.wareid,a.facturer
 ) a  group by a.wareid
 ),

 a3 as(
 SELECT sum(wareqty)qty,sum(a.netsum)net,a.wareid FROM t_rpt_sale_af8  a
 inner join t_ware_dtp c on a.wareid=c.wareid
 where exists (
 select 1 from t_bus_wares_dtp b
 where a.busno=b.busno
 )
  and a.accdate between p_begin and p_end
 group by a.wareid
 ),
 a4 as(
  SELECT sum(wareqty)lyqty,sum(a.netsum)lynet,a.wareid FROM t_rpt_sale_af8  a
 inner join t_ware_dtp c on a.wareid=c.wareid
 where exists (
 select 1 from t_bus_wares_dtp b
 where a.busno=b.busno
 )
  and accdate between add_months(trunc(p_begin),-12) and add_months(trunc(p_end),-12)
 group by a.wareid
 ),
 a5 as(
 SELECT sum(wareqty)lmqty,sum(a.netsum)lmnet,a.wareid FROM t_rpt_sale_af8  a
 inner join t_ware_dtp c on a.wareid=c.wareid
 where exists (
 select 1 from t_bus_wares_dtp b
 where a.busno=b.busno
 )
  and accdate between p_end-1-v_time and p_end-1
 group by a.wareid
 )
 select a.FACTURER,null,null,a.wareid,w.warename,a2.facount,a1.buscount,null,a3.qty,a3.net,
 case WHEN(NVL(a4.lyqty, 0))!=0 THEN (round((a3.qty-a4.lyqty)/a4.lyqty,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(a4.lynet, 0))!=0 THEN (round((a3.net-a4.lynet)/a4.lynet,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(a5.lmqty, 0))!=0 THEN (round((a3.qty-a5.lmqty)/a5.lmqty,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(a5.lmnet, 0))!=0 THEN (round((a3.net-a5.lmnet)/a5.lmnet,4))*100||'%' ELSE '0' END xsehb
 from  a
 left join a1 on a.wareid=a1.wareid
 left join a2 on a.wareid=a2.wareid
 left join a3 on a.wareid=a3.wareid
 left join a4 on a.wareid=a4.wareid
 left join a5 on a.wareid=a5.wareid
 left join t_ware_base w on a.wareid=w.wareid
 where a1.wareid=p_wareid
 ;
END IF;

 IF p_hz = 4 and p_wareid is  null THEN
   OPEN p_sql FOR
   with a0 as (
   SELECT b.facturer,a.busno,d.orgname,a.wareid,e.warename,g.gs,null,f.gs as pzs,sum(wareqty) as wareqty,sum(NETSUM) as NETSUM,
   tr.wareqtytb,tr.netsumtb,tr1.wareqtyhb,tr1.netsumhb
FROM t_rpt_sale_af8  a
inner join t_ware_dtp b on a.wareid=b.wareid
left join  t_bus_wares_dtp c   on a.busno=to_char(c.busno) and a.wareid=c.wareid
left join  s_busi d   on  a.busno=to_char(d.busno)
left join t_ware_base e    on a.wareid=e.wareid
left join  (SELECT busno,count(*) as gs FROM  t_bus_wares_dtp   group by busno ) f  on  a.busno=to_char(f.busno) ---门店经营的商品数
left join  (SELECT busno,count(*) as gs  FROM   (     -----门店合作的厂家数
            SELECT a.busno,b.facturer
            FROM  t_bus_wares_dtp a
            left join  t_ware_dtp b  on a.wareid=b.wareid
            group by busno,facturer
            ) a
            group by busno
            ) g   on  a.busno=to_char(g.busno)
left join  (
SELECT busno,wareid,sum(wareqty) as  wareqtytb,sum(NETSUM) as netsumtb FROM t_rpt_sale_af8 a
WHERE exists (select 1 from t_ware_dtp b WHERE a.wareid=b.wareid)
and  accdate between add_months(p_begin,-12)  and add_months(p_end,-12)
group by busno,wareid
)  tr  on  a.busno=tr.busno and a.wareid=tr.wareid

left join  (
SELECT busno,wareid,sum(wareqty) as  wareqtyhb,sum(NETSUM) as netsumhb FROM t_rpt_sale_af8 a
WHERE exists (select 1 from t_ware_dtp b WHERE a.wareid=b.wareid)
and  accdate between add_months(p_begin,-1)  and add_months(p_end,-1)
group by busno,wareid
)  tr1  on  a.busno=tr1.busno and a.wareid=tr1.wareid

WHERE   a.accdate between p_begin  and p_end   and a.busno not like '89%'  and  a.busno not like '862%' and a.busno not like 'X%'

group by  b.facturer,a.busno,d.orgname,a.wareid,e.warename,g.gs,tr.wareqtytb,tr.netsumtb,tr1.wareqtyhb,tr1.netsumhb,f.gs
)
SELECT facturer,busno,orgname,wareid,warename,gs ,null,pzs,wareqty,NETSUM,
 case WHEN(NVL(wareqtytb, 0))!=0 THEN (round((wareqty-wareqtytb)/wareqtytb,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(netsumtb, 0))!=0 THEN (round((NETSUM-netsumtb)/netsumtb,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(wareqtyhb, 0))!=0 THEN (round((wareqty-wareqtyhb)/wareqtyhb,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(netsumhb, 0))!=0 THEN (round((NETSUM-netsumhb)/netsumhb,4))*100||'%' ELSE '0' END xsehb
FROM  a0  ;
end if ;

 IF p_hz = 4 and p_wareid is not  null THEN
   OPEN p_sql FOR
with a0 as (
   SELECT b.facturer,a.busno,d.orgname,a.wareid,e.warename,g.gs,null,f.gs as pzs,sum(wareqty) as wareqty,sum(NETSUM) as NETSUM,
   tr.wareqtytb,tr.netsumtb,tr1.wareqtyhb,tr1.netsumhb
FROM t_rpt_sale_af8  a
inner join t_ware_dtp b on a.wareid=b.wareid
left join  t_bus_wares_dtp c   on a.busno=to_char(c.busno) and a.wareid=c.wareid
left join  s_busi d   on  a.busno=to_char(d.busno)
left join t_ware_base e    on a.wareid=e.wareid
left join  (SELECT busno,count(*) as gs FROM  t_bus_wares_dtp   group by busno ) f  on  a.busno=to_char(f.busno) ---门店经营的商品数
left join  (SELECT busno,count(*) as gs  FROM   (     -----门店合作的厂家数
            SELECT a.busno,b.facturer
            FROM  t_bus_wares_dtp a
            left join  t_ware_dtp b  on a.wareid=b.wareid
            group by busno,facturer
            ) a
            group by busno
            ) g   on  a.busno=to_char(g.busno)
left join  (
SELECT busno,wareid,sum(wareqty) as  wareqtytb,sum(NETSUM) as netsumtb FROM t_rpt_sale_af8 a
WHERE exists (select 1 from t_ware_dtp b WHERE a.wareid=b.wareid)
and  accdate between add_months(p_begin,-12)  and add_months(p_end,-12)
group by busno,wareid
)  tr  on  a.busno=tr.busno and a.wareid=tr.wareid

left join  (
SELECT busno,wareid,sum(wareqty) as  wareqtyhb,sum(NETSUM) as netsumhb FROM t_rpt_sale_af8 a
WHERE exists (select 1 from t_ware_dtp b WHERE a.wareid=b.wareid)
and  accdate between add_months(p_begin,-1)  and add_months(p_end,-1)
group by busno,wareid
)  tr1  on  a.busno=tr1.busno and a.wareid=tr1.wareid

WHERE   a.accdate between p_begin  and p_end   and a.busno not like '89%'  and  a.busno not like '862%' and a.busno not like 'X%'   and a.wareid=p_wareid

group by  b.facturer,a.busno,d.orgname,a.wareid,e.warename,g.gs,tr.wareqtytb,tr.netsumtb,tr1.wareqtyhb,tr1.netsumhb,f.gs
)
SELECT facturer,busno,orgname,wareid,warename,gs ,null,pzs,wareqty,NETSUM,
 case WHEN(NVL(wareqtytb, 0))!=0 THEN (round((wareqty-wareqtytb)/wareqtytb,4))*100||'%' ELSE '0' END xltb,
 case WHEN(NVL(netsumtb, 0))!=0 THEN (round((NETSUM-netsumtb)/netsumtb,4))*100||'%' ELSE '0' END xsetb,
 case WHEN(NVL(wareqtyhb, 0))!=0 THEN (round((wareqty-wareqtyhb)/wareqtyhb,4))*100||'%' ELSE '0' END xlhb,
 case WHEN(NVL(netsumhb, 0))!=0 THEN (round((NETSUM-netsumhb)/netsumhb,4))*100||'%' ELSE '0' END xsehb
FROM  a0  ;
end if ;

END ;
/

