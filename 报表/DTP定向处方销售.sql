create or replace procedure cproc_dtpdxcf(p_begindate in  date,
                                          p_enddate   in  date,
                                          p_jg        out sys_refcursor) is
v_days integer;
v_days_tb integer;
v_days_hb integer;

begin
--DTP+定向处方报表,p_flhz 分类汇总类型 0门店，1片区，2事业部
--select * from d_rw_rj_ztxsqk where class in ('12116','zxcy_yw')
--20230401修改  有指标的才统计销售，没有指标的不统计，dtp，定向处方数据 拆成两行
--'12116':定向处方引流商品,'12105':DTP商品
--30510:门店   30511:诊所
--303 事业部 304 片区
--320108  按公司分类桐乡
    v_days := round(to_number(p_enddate - p_begindate) +1);
    v_days_tb := round(to_number(add_months(p_enddate,-12) - add_months(p_begindate,-12)) +1);
    v_days_hb := round(to_number(add_months(p_enddate,-1) - add_months(p_begindate,-1)) +1);

          --结果
          open p_jg for
          --指标处理
          with zb_period as(
              select to_char(add_months(p_begindate,rownum - 1),'yyyymm') as period,
                     case when add_months(last_day(p_begindate),rownum - 1) > p_enddate then p_enddate else add_months(last_day(p_begindate),rownum - 1) end -
                     case when add_months(trunc(p_begindate,'mm'),rownum - 1) < p_begindate then p_begindate else add_months(trunc(p_begindate,'mm'),rownum - 1) end + 1 as days
              from dual
              connect by rownum <= months_between(trunc(p_enddate,'mm'),trunc(p_begindate,'mm')) + 1),
          md_rwzb as(
          select b.busno,case when b.class= 'zxcy_yw' then '12105' else b.class end as classcode,sum(a.days*b.xsrw ) as xszb,
                 max(nvl(bs303.classname,'未划分')) as dept,
                 max(nvl(bs304.classname,'未划分')) as zoneno
          from zb_period a
               join d_rw_rj_ztxsqk b on a.period=b.period and b.class in ('12116','zxcy_yw')
               left join t_busno_class_set bc303 on bc303.busno =b.busno and bc303.classgroupno = '303'
               left join t_busno_class_base bs303 on bs303.classgroupno = bc303.classgroupno and bs303.classcode=bc303.classcode
               left join t_busno_class_set bc304 on bc304.busno =b.busno and bc304.classgroupno = '304'
               left join t_busno_class_base bs304 on bs304.classgroupno = bc304.classgroupno and bs304.classcode=bc304.classcode
          group by b.busno,case when b.class= 'zxcy_yw' then '12105' else b.class end),
          md_rwzbpx as(
          select md_rwzb.*,rank() over(order by dept) as deptpx,
                 rank() over(order by zoneno) as zonenopx
           from md_rwzb ),
          --销售数据
          rpt_xsmx as(
          select '8'||bs.zmdz as busno,twc.classcode,sum(a.netsum) as netsum,
                 sum(nvl(a.puramount,0)) as puramount,sum(netsum-puramount) as mle,round(sum(netsum-puramount)/sum(netsum),4) as mlv
          from t_rpt_sale a
               join s_busi bs on a.compid=bs.compid and a.busno=bs.busno
               join t_ware_class_base twc on a.compid=twc.compid and twc.classgroupno ='12' and a.wareid=twc.wareid and twc.classcode in ('12116','12105')
          where a.accdate between p_begindate and p_enddate
                and exists(select 1 from t_busno_class_set tcb where tcb.classgroupno='305' and tcb.classcode in('30510','30511')and a.busno=tcb.busno )
                and not exists(select 1 from t_busno_class_set bc320 where bc320.classgroupno = '320' and bc320.classcode = '320108' and bc320.busno = a.busno)
          group by bs.zmdz,twc.classcode),
          --销售数据环比
          rpt_xsmx_hb as(
          select '8'||bs.zmdz as busno,twc.classcode,sum(a.netsum) as netsum_hb
          from t_rpt_sale a
               join s_busi bs on a.compid=bs.compid and a.busno=bs.busno
               join t_ware_class_base twc on a.compid=twc.compid and twc.classgroupno ='12' and a.wareid=twc.wareid and twc.classcode in ('12116','12105')
          where a.accdate between add_months(p_begindate,-1) and add_months(p_enddate,-1)
                and exists(select 1 from t_busno_class_set tcb where tcb.classgroupno='305' and tcb.classcode in('30510','30511')and a.busno=tcb.busno )
                and not exists(select 1 from t_busno_class_set bc320 where bc320.classgroupno = '320' and bc320.classcode = '320108' and bc320.busno = a.busno)
          group by bs.zmdz,twc.classcode),
          --销售数据同比
          rpt_xsmx_tb as(
          select '8'||bs.zmdz as busno,twc.classcode,sum(a.netsum) as netsum_tb
          from t_rpt_sale a
               join s_busi bs on a.compid=bs.compid and a.busno=bs.busno
               join t_ware_class_base twc on a.compid=twc.compid and twc.classgroupno ='12' and a.wareid=twc.wareid and twc.classcode in ('12116','12105')
          where a.accdate between add_months(p_begindate,-12) and add_months(p_enddate,-12)
                and exists(select 1 from t_busno_class_set tcb where tcb.classgroupno='305' and tcb.classcode in('30510','30511')and a.busno=tcb.busno )
                and not exists(select 1 from t_busno_class_set bc320 where bc320.classgroupno = '320' and bc320.classcode = '320108' and bc320.busno = a.busno)
          group by bs.zmdz,twc.classcode),
          --销售客流
          rpt_lks as(
          select busno,class as classcode,sum(salecount) as salecount
          from d_rpt_sale_lks where class in('12105','12116')
          and accdate between p_begindate and p_enddate
          group by busno,class
          ),
          --销售客流环比
          rpt_lks_hb as(
          select busno,class as classcode,sum(salecount) as salecount
          from d_rpt_sale_lks where class in('12105','12116')
          and accdate between add_months(p_begindate,-1) and add_months(p_enddate,-1)
          group by busno,class
          ),
          --销售客流同比
          rpt_lks_tb as(
          select busno,class as classcode,sum(salecount) as salecount
          from d_rpt_sale_lks where class in('12105','12116')
          and accdate between add_months(p_begindate,-12) and add_months(p_enddate,-12)
          group by busno,class
          ),
          rpt_mx_ref as (
          select 1 as px1,case when z.classcode='12105' then 1 else 2 end as px2,
                 to_char(p_begindate,'yyyymm') as period,z.busno,bs.orgname,z.classcode,
                 z.dept,z.zoneno,z.xszb,
                 nvl(decode(z.xszb,0,0,a.netsum),0) as netsum,nvl(decode(z.xszb,0,0,b.netsum_hb),0) as netsum_hb,nvl(decode(z.xszb,0,0,c.netsum_tb),0) as netsum_tb,
                 nvl(case when nvl(a.netsum,0)=0 or z.xszb=0 then 0 else round(a.netsum/z.xszb,4) end,0) as zbwcl,
                 nvl(decode(z.xszb,0,0,a.mle),0) as mle,
                 nvl(case when nvl(z.xszb,0)=0 or nvl(a.mle,0)=0 or nvl(a.netsum,0)=0 then 0 else round(a.mle/a.netsum,4) end,0) as mlv,
                 nvl(case when a.netsum=0 or b.netsum_hb=0 or z.xszb=0 then 0 else (a.netsum/v_days)/(b.netsum_hb/v_days_hb) -1 end,0) as nethb,
                 nvl(case when a.netsum=0 or c.netsum_tb=0 or z.xszb=0 then 0 else (a.netsum/v_days)/(c.netsum_tb/v_days_tb) -1 end,0) as nettb,
                 nvl(aa.salecount,0) as lks,nvl(bb.salecount,0) as lkh,nvl(cc.salecount,0) as lkt,
                 nvl(case when nvl(aa.salecount,0) = 0 or nvl(bb.salecount,0)=0 or z.xszb=0 then 0 else (nvl(aa.salecount,0) / v_days) / (bb.salecount / v_days_tb) - 1 end,0) as lks_hb,
                 nvl(case when nvl(aa.salecount,0) = 0 or nvl(cc.salecount,0)=0 or z.xszb=0 then 0 else (nvl(aa.salecount,0) / v_days) / (cc.salecount / v_days_tb) - 1 end,0) as lks_tb,
                 nvl(case when nvl(a.netsum,0) = 0 or nvl(aa.salecount,0)=0 or z.xszb=0 then 0 else a.netsum / aa.salecount end,0) as kdj,
                 nvl(case when nvl(a.netsum,0) = 0 or nvl(aa.salecount,0)=0 or z.xszb=0 then 0 else a.netsum / aa.salecount end
                   - case when nvl(b.netsum_hb,0) = 0 or nvl(bb.salecount,0)=0 or z.xszb=0 then 0 else b.netsum_hb / bb.salecount end,0) as kdj_hb,
                 nvl(case when nvl(a.netsum,0) = 0 or nvl(aa.salecount,0)=0 or z.xszb=0 then 0 else a.netsum / aa.salecount end
                   - case when nvl(c.netsum_tb,0) = 0 or nvl(cc.salecount,0)=0 or z.xszb=0 then 0 else c.netsum_tb / cc.salecount end,0) as kdj_tb,
                 z.deptpx,z.zonenopx
          from md_rwzbpx z
               join s_busi bs on z.busno=bs.busno
               left join rpt_xsmx a on z.busno=a.busno and z.classcode=a.classcode
               left join rpt_xsmx_hb b on z.busno=b.busno and z.classcode=b.classcode
               left join rpt_xsmx_tb c on z.busno=c.busno and z.classcode=c.classcode
               left join rpt_lks aa on z.busno=aa.busno and z.classcode=aa.classcode
               left join rpt_lks_hb bb on z.busno=bb.busno and z.classcode=bb.classcode
               left join rpt_lks_tb cc on z.busno=cc.busno and z.classcode=cc.classcode
          where z.xszb<>0
                and exists(select 1 from t_busno_class_set tcb where tcb.classgroupno='305' and tcb.classcode in('30510','30511')and z.busno=tcb.busno )
                and not exists(select 1 from t_busno_class_set bc320 where bc320.classgroupno = '320' and bc320.classcode = '320108' and bc320.busno = z.busno)
         )
         select * from
         (
         select px1,px2,
                period,busno,orgname,
                dept,zoneno,classcode,xszb,
                netsum,zbwcl,
                mle,mlv,
                nethb,
                nettb,
                lks,
                lks_hb,
                lks_tb,
                kdj,
                kdj_hb,
                kdj_tb
         from rpt_mx_ref
         union all
         --门店小计
         select 1 as px1,3 as px2,
                max(period) as period,busno,max(orgname) as orgname,
                max(dept) as dept,max(zoneno) as zoneno,'小计：' classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref
         group by busno
         union all
         --事业部合计
         select 2 as px1,4 as px2,
                max(period) as period,max(deptpx) as busno,null orgname,
                dept,null as zoneno,classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref
         group by dept,classcode
         union all
         --事业部汇总
         select 2 as px1,5 as px2,
                max(period) as period,max(to_number(deptpx||.1)) as busno,null orgname,
                dept,null as zoneno,'事业部汇总：' classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref
         group by dept
         union all
         --台州事业部分类
         select 2 as px1,6 as px2,
                max(period) as period,99998 as busno,null orgname,
                '台州事业部',null as zoneno,classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref where dept in ('台州事业一部','台州事业二部','台州事业三部')
         group by classcode
         union all
         --台州事业部
         select 2 as px1,6 as px2,
                max(period) as period,99999 as busno,null orgname,
                '台州事业部',null as zoneno,'台州事业部：' classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref where dept in ('台州事业一部','台州事业二部','台州事业三部')
         union all
         --片区合计
         select 3 as px1,7 as px2,
                max(period) as period,max(zonenopx)  busno,null orgname,
                null as dept,zoneno,classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref
         group by zoneno,classcode
         union all
         --片区汇总
         select 3 as px1,8 as px2,
                max(period) as period,max(to_number(zonenopx||.1)) busno,null orgname,
                null as dept,zoneno,'片区汇总：' classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref
         group by zoneno
         union all
         --总计
         select 4 as px1,1 as px2,
                max(period) as period,null as busno,'总计:' orgname,
                null as dept,null as zoneno,null as classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref
         union all
         --总计
         select 4 as px1,1 as px2,
                max(period) as period,null as busno,'总计:' orgname,
                null as dept,null as zoneno, classcode,sum(xszb) as xszb,
                sum(netsum) as netsum,case when sum(netsum)=0 or sum(xszb)=0 then 0 else round(sum(netsum)/sum(xszb),4) end as zbwcl,
                sum(mle) as mle,case when sum(netsum)=0 then 0 else round(sum(mle)/sum(netsum),4) end as mlv,
                case when sum(netsum)=0 or sum(netsum_hb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_hb)/v_days_hb) -1 end as nethb,
                case when sum(netsum)=0 or sum(netsum_tb)=0 or sum(xszb)=0 then 0 else (sum(netsum)/v_days)/(sum(netsum_tb)/v_days_tb) -1 end as nettb,
                sum(lks) as lks,
                case when sum(lks) = 0 or sum(lkh) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkh) / v_days_tb) - 1 end as lks_hb,
                case when sum(lks) = 0 or sum(lkt) =0 or sum(xszb)=0 then 0 else (sum(lks) / v_days) / (sum(lkt) / v_days_tb) - 1 end as lks_tb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end as kdj,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_hb) = 0 or sum(lkh)=0 or sum(xszb)=0 then 0 else sum(netsum_hb) / sum(lkh) end as kdj_hb,
                case when sum(netsum) = 0 or sum(lks)=0 or sum(xszb)=0 then 0 else sum(netsum) / sum(lks) end
                 - case when sum(netsum_tb) = 0 or sum(lkt)=0 or sum(xszb)=0 then 0 else sum(netsum_tb) / sum(lkt) end as kdj_tb
         from rpt_mx_ref group by classcode
         )ww order by ww.px1,ww.busno,ww.px2;

end;
