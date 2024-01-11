create view V_O2O_JCYY as
with base as
         (SELECT tb303.CLASSNAME as syb,
                 a.busno,
                 s.orgname,
                 a.ifhoursbusno,
                 mtfwname,
                 FWNO,
                 busfwno,
                 ELEWGNAME,
                 WGNO,
                 a.WGBUSNO,
                 tb.classname as 新零售门店铺货等级,
                 xlsyydj,
                 bgl,
                 zhl,
                 bdmll,
                 cwylbq,
                 sdrjmll
          FROM d_o2o_basic a
                   left join s_busi s on a.busno = s.busno
                   join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '326'
                   join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                   join t_busno_class_set ts303 on a.busno = ts303.busno and ts303.classgroupno = '303'
                   join t_busno_class_base tb303
                        on ts303.classgroupno = tb303.classgroupno and ts303.classcode = tb303.classcode),
     k30 as
         (select busno, sum(lks_o2o) as lks
          from d_busi_saler_tj
          where accdate between trunc(ADD_MONTHS(SYSDATE, -1)) and trunc(sysdate)
          group by busno),
     k7 as
         (select busno, sum(lks_o2o) as lks
          from d_busi_saler_tj
          where accdate between trunc(SYSDATE) - 7 and trunc(sysdate)
          group by busno),
     ml30 as
         (select b.busno,
                 sum(round(b.netsum, 2)) as netamt,
                 sum(b.puramount) as puramt,
                 sum(round(b.netsum, 2)) - sum(b.puramount) as ml,
                 case
                     when sum(round(b.netsum, 2)) = 0 or sum(b.puramount) = 0 then 0
                     else (sum(round(b.netsum, 2)) - sum(b.puramount)) / sum(round(b.netsum, 2)) end as mll
          FROM d_rpt_sale_pos_o2o b
          where b.accdate between trunc(ADD_MONTHS(SYSDATE, -1)) and trunc(sysdate)
          group by b.busno),
     ml7 as
         (select b.busno,
                 sum(round(b.netsum, 2)) as netamt,
                 sum(b.puramount) as puramt,
                 sum(round(b.netsum, 2)) - sum(b.puramount) as ml,
                 case
                     when sum(round(b.netsum, 2)) = 0 or sum(b.puramount) = 0 then 0
                     else (sum(round(b.netsum, 2)) - sum(b.puramount)) / sum(round(b.netsum, 2)) end as mll
          FROM d_rpt_sale_pos_o2o b
          where b.accdate between trunc(SYSDATE) - 7 and trunc(sysdate)
          group by b.busno),
     kll as
         -- 前推30天客流量（线上+线下）  lks_o2o :O2O客流量 o2ozb:O2O客流占比
         (SELECT z.busno, sum(d.lks) as lks, sum(d.lks_o2o) as lks_o2o,
                 case when sum(d.lks) = 0 then 0 else sum(d.lks_o2o) / sum(d.lks) end as o2ozb
          FROM d_busi_saler_tj d
                   join s_busi b on b.busno = d.busno
                   join s_busi z on z.busno = b.zmdz1
                   join s_user_base u on u.userid = d.saler
                   left join d_busi_kljl k on k.busno = z.busno
          WHERE d.accdate between add_months(trunc(sysdate), -1) and trunc(sysdate)
          GROUP BY z.busno
          ORDER BY z.busno),
     o2oxs as
         (
             --netamt O2O销售     rjmll
             SELECT o2o.busno as busno, sum(round(o2o.netsum, 2)) as netamt,
                    sum(o2o.salecount) as kll, sum(o2o.PURAMOUNT),
                    round(sum(round(o2o.netsum, 2)) - sum(o2o.PURAMOUNT), 6) / 30 as rjmll
             FROM d_rpt_sale_pos_o2o o2o
             WHERE o2o.accdate between add_months(trunc(sysdate), -1) and trunc(sysdate)
             GROUP BY o2o.busno
--ORDER BY o2o.busno;
         ),
     zxs as
         (
             --O2O销售占比  kll 总销售客流量,  kdj 客单价  rjmll,O2O毛利额（日均30天）,
             SELECT b.busno as busno, sum(round(b.netsum, 2)) as netamt, sum(b.salecount) as kll,
                    case
                        when sum(round(b.netsum, 2)) = 0 or sum(b.salecount) = 0 then 0
                        else sum(round(b.netsum, 2)) / sum(b.salecount) end as kdj,
                    sum(PURAMOUNT) as PURAMOUNT
             --        sum(round(o2o.netsum, 2)) / sum(round(b.netsum, 2)) as O2O销售占比,
--        sum(round(o2o.netsum, 2)) as netamt,
--        sum(o2o.salecount) as kll, sum(o2o.PURAMOUNT),
--        round(sum(round(o2o.netsum, 2)) - sum(o2o.PURAMOUNT), 6) / 30 as rjmll
             FROM t_rpt_sale_pos B
                      LEFT JOIN S_BUSI X ON B.BUSNO = X.BUSNO AND B.COMPID = X.COMPID
             WHERE b.accdate between add_months(trunc(sysdate), -1) and trunc(sysdate)
             GROUP BY b.busno)
select a.syb as 事业部,
       a.busno,
       a.orgname,
       a.ifhoursbusno as 是否24小时门店,
       mtfwname,
       FWNO,
       busfwno,
       ELEWGNAME,
       WGNO,
       a.WGBUSNO,
       a.新零售门店铺货等级,
       xlsyydj as 新零售运营等级,
       bgl as 曝光率,
       zhl as 转换率,
       --k30.lks as 前推30天o2o客流量,-- lks30
       k7.lks as 前推7天o2o客流量,-- lks7
       case when k7.lks=0 or kll.lks_o2o=0 then 0 else
       (k7.lks/7-kll.lks_o2o/30)/kll.lks_o2o*30 end as 环比客流情况,
       kll.lks as 前推30天客流量线上线下,
       kll.lks_o2o as 前推30天O2O客流量,
       kll.o2ozb as O2O客流占比,
       zxs.netamt as 整体30天销售额,
       o2oxs.netamt as O2O30天销售额,
       case when o2oxs.netamt = 0 or zxs.netamt = 0 then 0 else o2oxs.netamt / zxs.netamt end as O2O销售占比,
       case
           when zxs.netamt - o2oxs.netamt = 0 or kll.lks - kll.lks_o2o = 0 then 0
           else (zxs.netamt - o2oxs.netamt) / (kll.lks - kll.lks_o2o) end as 前推30天线下客单价不包含o2o,--(30天总销售额-30天o2o销售额)/(30天总客流量-30天o2o客流量)
       case
           when zxs.netamt - o2oxs.netamt = 0 or zxs.netamt - o2oxs.netamt - zxs.PURAMOUNT + ml30.puramt = 0 then 0
           else
               (zxs.netamt - o2oxs.netamt - zxs.PURAMOUNT + ml30.puramt) /
               (zxs.netamt - o2oxs.netamt) end as 前推30天毛利率不包含o2o,
       --整体30天销售额-30天O2O销售额-(整体30天成本-o2o30天成本)/(整体30天销售额-30天o2o销售额)
       case when k30.lks = 0 or ml30.netamt = 0 then 0 else ml30.netamt / k30.lks end as 前推30天客单价,-- kdj30
       case when k7.lks = 0 or ml7.netamt = 0 then 0 else ml7.netamt / k7.lks end as 前推7天客单价,-- kdj7
       ml30.mll as 前推30天毛利率,-- mll30
       ml7.mll as 前推7天毛利率, -- ml7
       bdmll as 事业部保底毛利率,
       --ml7.mll-nvl(bdmll,0) as 毛利率差额,
       case
           when BDMLL is null then 0
           else ml7.mll - TO_NUMBER(SUBSTR(BDMLL, 1, INSTR(BDMLL, '%') - 1), '999.99') / 100 end as 毛利率差额,
       cwylbq as 财务盈利标签,
       sdrjmll as 设定日均毛利额前推30天,
       o2oxs.rjmll as O2O毛利额日均30天
from base a
         left join k30 on a.busno = k30.BUSNO
         left join k7 on a.BUSNO = k7.BUSNO
         left join ml30 on a.busno = ml30.BUSNO
         left join ml7 on a.BUSNO = ml7.BUSNO
         left join kll on a.BUSNO = kll.BUSNO
         left join o2oxs on a.BUSNO = o2oxs.busno
         left join zxs on a.BUSNO = zxs.busno
/

