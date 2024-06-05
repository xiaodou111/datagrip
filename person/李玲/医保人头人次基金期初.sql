--proc_zeys_rt_syb24
--人次在a2,其他都在a1
select * from dm_yb_md_head_sum_qc;
-- 年度 2023||2024	year_yb
-- 会计日-yyyy-mm-dd	receipt_date
-- 普通门店编码	werks_id
-- 门店类型  诊所||药店	md_type
-- 就医地	city_area_name
-- 参保地	insure_region_name
-- 险种类型	insurance_type
-- 医保类型  农保||医保	per_yb_type
-- 人次	yb_per_num
-- 人头	yb_per_headnum
-- 人头基金	head_fund_amount
-- 总费用	total_amount
-- 总额度	total_quota
-- 医疗费用自费总额	personal_pay_amount
-- 医疗费用自理总额	self_charge_amount
-- 国谈额度	gt_quota
-- 基本医疗统筹支付	overall_pay
-- 当年账户支付	current_account_pay
-- 公务员补助统筹支付	public_fund_pay
-- 大病保险支付	illness_subsidy_amount
-- 历年账户支付	history_account_pay
-- 现金支付	personal_cash_amount
select sfzs, 事业部, 险种, 就诊类型, 参保地, jyd,
       sum(case when ord > 1 then 0 else ord end) as 人次,
       round(sum(zed), 2) as 国谈总额度,
       round(sum(zed1), 2) as 总额度,
       sum(nvl(基本医疗统筹支付, 0)) as 基本医疗统筹支付,
       sum(nvl(公务员补助统筹支付, 0)) as 公务员补助统筹支付,
       sum(nvl(当年账户支付, 0)) as 当年账户支付,
       sum(nvl(大病金额, 0)) as 大病金额,
       sum(nvl(医疗费用总额, 0)) as 医疗费用总额,
       sum(nvl(历年账户支付, 0)) as 历年账户支付,
       sum(nvl(现金金额, 0)) as 现金金额,
       round((sum(zed1) - sum(zed)) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
             2) as 除国谈总指标,
       round(sum(zed1) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
             2) as 总指标
from (select bbb1.*,
             ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,jyd order by 创建时间) as ord,
             --todo  人头
             case
                 when ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                     case
                         when 险种 = '职工基本医疗保险' and 参保地 in ('市本级', '黄岩区', '路桥区') then '市本级'
                         when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                         else 参保地 end
                     order by 创建时间) > 1
                     then 0
                 else
                     ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                         case
                             when 险种 = '职工基本医疗保险' and 参保地 in ('市本级', '黄岩区', '路桥区') then '市本级'
                             when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                             else 参保地 end
                         order by 创建时间) end as ord2 --人头
      from (select erp销售号,sfzs,事业部,身份证号,创建时间,险种,'1' as 就诊类型,gtje,
                   sum(case
                           when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                               then
                               nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                               nvl(detail.整单公补基金支付数, 0) *
                               detail.单据明细医保比例 +
                               nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                           else 0
                       end) as zed, --国谈+药店双通道额度
                   nvl(基本医疗统筹支付, 0) as 基本医疗统筹支付,
                   nvl(公务员补助统筹支付, 0) as 公务员补助统筹支付,
                   nvl(当年账户支付, 0) as 当年账户支付,
                   nvl(大病金额, 0) as 大病金额,
                   nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) as zed1,
                   nvl(现金金额, 0) as 现金金额,
                   nvl(历年账户支付, 0) as 历年账户支付,
                   nvl(医疗费用总额, 0) as 医疗费用总额,
                   参保地,
                   case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                     left join D_YBZD_detail detail
                               on D_ZJYS_WL2023XSE.ERP销售号 = detail.SALENO
                     left join d_ll_gtml gtml
                               on gtml.WAREID = detail.wareid
                                   and
                                  D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
            where trunc(创建时间) BETWEEN date'2024-01-01' AND date'2024-02-01'
              and not exists (select 1
                              from T_SALE_RETURN_H a
                              where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
            group by erp销售号,
                     sfzs,
                     身份证号,
                     创建时间,
                     险种, 基本医疗统筹支付, 公务员补助统筹支付, 当年账户支付, 大病金额,
                     现金金额, 历年账户支付, 医疗费用总额, 参保地,
                     case when 就医地 = '市本级' then '椒江区' else 就医地 end, gtje, 事业部) bbb1) bbb
group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd


with base as (
    select erp销售号,sfzs,事业部,身份证号,创建时间,
           险种,机构编码,
           case when 就医地 = '市本级' then '椒江区' else 就医地 end  as 就医地
           ,
           case when 险种='职工基本医疗保险' then '医保' else '农保' end as 医保类型,
                   sum(case
                           when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                               then
                               nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                               nvl(detail.整单公补基金支付数, 0) *
                               detail.单据明细医保比例 +
                               nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                           else 0
                       end) as zed, --国谈+药店双通道额度
                   nvl(自费费用,0) as 自费费用,
                   nvl(基本医疗统筹支付, 0) as 基本医疗统筹支付,
                   nvl(公务员补助统筹支付, 0) as 公务员补助统筹支付,
                   nvl(当年账户支付, 0) as 当年账户支付,
                   nvl(大病金额, 0) as 大病金额,
                   nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) as zed1,
                   nvl(现金金额, 0) as 现金金额,
                   nvl(历年账户支付, 0) as 历年账户支付,
                   nvl(医疗费用总额, 0) as 医疗费用总额,
                   0 as 医疗费用自理总额,
                   参保地,
                   case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                     left join D_YBZD_detail detail
                               on D_ZJYS_WL2023XSE.ERP销售号 = detail.SALENO
                     left join d_ll_gtml gtml
                               on gtml.WAREID = detail.wareid
                                   and
                                  D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
            where trunc(创建时间) BETWEEN date'2024-01-01' AND date'2024-02-01'
              and not exists (select 1
                              from T_SALE_RETURN_H a
                              where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
            group by erp销售号,
                     sfzs,
                     身份证号,
                     创建时间,
                     险种, 基本医疗统筹支付, 公务员补助统筹支付, 当年账户支付, 大病金额,
                     现金金额, 历年账户支付, 医疗费用总额, 参保地,
                     case when 就医地 = '市本级' then '椒江区' else 就医地 end, gtje, 事业部,机构编码,自费费用
)
select 2024 as 年度,trunc(创建时间) as 会计日, 机构编码 as 普通门店编码,sfzs as 门店类型, 
       就医地,参保地,险种 as 险种类型, 医保类型,'' as 人次,'' as 人头,
       '(总额度-国探额度)/人头' as 人头基金, 医疗费用总额 as 总费用,
       zed1 as 总额度,
       自费费用 as 医疗费用自费总额,
       0 AS 医疗费用自理总额,
       zed as 国谈额度,
        基本医疗统筹支付, 当年账户支付, 公务员补助统筹支付,大病金额 AS 大病保险支付,历年账户支付, 现金金额
from base;

select 险种 from d_zjys_wl2023xse group by 险种;
select * from d_zjys_wl2023xse where ERP销售号='2301011001123976';
select * from D_ZHYB_HZ_CYB where 销售日期>=date'2023-01-01' and ERP销售单号='2301011001123976';


