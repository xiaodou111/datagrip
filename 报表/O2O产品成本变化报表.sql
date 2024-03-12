


--O2O销售前推30天均价  round( if ( saleqty=0, 0, netamt/saleqty), 4 )
--净毛利额  netamt - puramt - yhq
-- 净毛利率 if(jnetamt= 0 ,0,round(jmle / jnetamt, 4))  jnetamt= netamt - yhq

with a30 as (SELECT b.wareid as wareid,
                    sum(round(b.stdsum, 2)) as stdsum,
                    sum(round(b.netsum, 2)) as netamt,
                    sum(b.puramount) /*sum(round(nvl(b.puramount,0),6))*/ as puramt,
                    sum(b.yhq) as yhq,
                    sum(round(b.wareqty, 6)) as wareqty
             FROM d_rpt_sale_o2o b
             WHERE exists (select 1
                           from s_user_busi sub
                           where sub.compid = b.compid and sub.busno = b.busno and sub.userid = 50002418
                             and sub.status = 1)
               and b.accdate between trunc(sysdate) - 31 and trunc(sysdate) - 1
               and
                    b.WAREID = '10200025' and EXISTS(SELECT 1
                                                     FROM t_busno_class_set wc__
                                                     WHERE wc__.busno = b.busno AND wc__.classgroupno = '320'
                                                       AND wc__.classcode <> '320105')
             GROUP BY b.wareid),
     a365 as (SELECT b.wareid as wareid,
                     sum(round(b.stdsum, 2)) as stdsum,
                     sum(round(b.netsum, 2)) as netamt,
                     sum(b.puramount) /*sum(round(nvl(b.puramount,0),6))*/ as puramt,
                     sum(b.yhq) as yhq,
                     sum(round(b.wareqty, 6)) as wareqty
              FROM d_rpt_sale_o2o b


              WHERE exists (select 1
                            from s_user_busi sub
                            where sub.compid = b.compid and sub.busno = b.busno and sub.userid = 50002418
                              and sub.status = 1)
                and b.accdate between ADD_MONTHS(trunc(sysdate) - 1, -12) - 30 and ADD_MONTHS(trunc(sysdate) - 1, -12)
                and b.WAREID = '10200025' and EXISTS(SELECT 1
                                                     FROM t_busno_class_set wc__
                                                     WHERE wc__.busno = b.busno AND wc__.classgroupno = '320'
                                                       AND wc__.classcode <> '320105')
              GROUP BY b.wareid),
     hz as (select a30.wareid, w.WARENAME, w.WARESPEC, f.FACTORYNAME, a30.netamt, a30.puramt,
                   case when a30.wareqty = 0 then 0 else a30.netamt / a30.wareqty end as O2O销售前推30天均价,
                   a30.wareqty as O2O前推30天销售量,
                   case
                       when a30.netamt - a30.yhq = 0 then 0
                       else (a30.netamt - a30.puramt - a30.yhq) / (a30.netamt - a30.yhq) end as O2O前推30天毛利率,
                   case when a365.wareqty = 0 then 0 else a365.netamt / a365.wareqty end as O2O同比销售均价,
                   a365.wareqty as O2O同比销售数量,
                   case
                       when a365.netamt - a365.yhq = 0 then 0
                       else (a365.netamt - a365.puramt - a365.yhq) / (a365.netamt - a365.yhq) end as O2O同比销售毛利率,
                   a30.netamt - a30.puramt - a30.yhq as O2O前推30天毛利额
            from a30
                     left join a365 on a30.wareid = a365.wareid
                     left join T_WARE_BASE w on a30.wareid = w.WAREID
                     left join t_factory f on w.FACTORYID = f.FACTORYID)
select hz.wareid, WARENAME, WARESPEC, FACTORYNAME, c107.CLASSNAME as O2O商品运营分类中类,
       c120.CLASSNAME as O2O商品铺货等级,
       cost.oldcost, cost.newcost, cost.rebate, cost.settlementprice,
       cf_get_saleprice_hz(hz.wareid,1000) as 最广泛零售价,
       O2O销售前推30天均价, O2O前推30天销售量,
       O2O前推30天毛利率,
       O2O同比销售均价, O2O同比销售数量, O2O同比销售毛利率,
       --(新成本价-原成本价)/原成本价 as 成本同比增幅
       case when cost.oldcost = 0 then 0 else (cost.newcost - cost.oldcost) / cost.oldcost end as 成本同比增幅,
       case
           when O2O同比销售数量 = 0 then 0
           else (O2O前推30天销售量 - O2O同比销售数量) / O2O同比销售数量 end as 销售同比增幅,
       --(新成本价-原成本价)*O2O前推30天销售量 as 毛利额差额
       (cost.newcost - cost.oldcost) * O2O前推30天销售量 as 毛利额差额,
       O2O前推30天毛利额,
       --毛利额差额/O2O前推30天毛利额 as O2O前推30天单品毛利率影响
       case
           when O2O前推30天毛利额 = 0 then 0
           else
               (cost.newcost - cost.oldcost) * O2O前推30天销售量 / O2O前推30天毛利额 end as O2O前推30天单品毛利率影响,
       --O2O同比销售数量/1 as O2O毛利率影响
       O2O同比销售数量 / 1 as O2O毛利率影响
from hz
         left join d_o2o_warecost cost on hz.wareid = cost.wareid
         left join t_ware_class_base wc107
                   on wc107.compid = 1000 and wc107.classgroupno = '107' and wc107.wareid = hz.wareid
         LEFT JOIN t_class_base c107 ON c107.classcode = wc107.classcode
         left join t_ware_class_base wc120
                   on wc120.compid = 1000 and wc120.classgroupno = '120' and wc120.wareid = hz.wareid
         LEFT JOIN t_class_base c120 ON c120.classcode = wc120.classcode;


select ADD_MONTHS(trunc(sysdate)-1, -12)-30 as time,ADD_MONTHS(trunc(sysdate)-1, -12),
       trunc(sysdate)-31, trunc(sysdate)-1
as time1
from dual;
