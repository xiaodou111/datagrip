--proc_zeys_rt_syb24
    call proc_zeys_rt24
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

select CITY_AREA_NAME from DM_YB_MD_HEAD_SUM_QC group by CITY_AREA_NAME;
delete from DM_YB_MD_HEAD_SUM_QC;
select count(*) from DM_YB_MD_HEAD_SUM_QC  where RECEIPT_DATE BETWEEN '2023-01-01' AND '2023-12-31';
insert into DM_YB_MD_HEAD_SUM_QC select * from DM_YB_MD_HEAD_SUM_QC AS OF TIMESTAMP SYSDATE - (1/24);
insert into  DM_YB_MD_HEAD_SUM_QC
with base as (
  select d_zjys_wl2023xse.erp销售号,sfzs,事业部,d_zjys_wl2023xse.身份证号,创建时间,
           险种,机构编码,
           case when 就医地 = '市本级' then '椒江区' else 就医地 end  as 就医地,
           case when 险种='职工基本医疗保险' then '医保' else '农保' end as 医保类型,
           v_saleno_zed.zed,--国谈额度

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
                   d_zjys_wl2023xse.参保地,
                   case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                     left join v_saleno_zed on d_zjys_wl2023xse.ERP销售号 = v_saleno_zed.erp销售号
            where
                trunc(创建时间) BETWEEN date'2024-01-01' AND date'2024-07-31'
                and s_busi.ZMDZ1=81499
--                and d_zjys_wl2023xse.机构编码 in ('85027','85034','85036','85037','85039','85040','85041','85042','85064','85067','85069','85074','85083','85084','89074','89075')
              and not exists (select 1 from T_SALE_RETURN_H a where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
              and not exists (select 1 from T_SALE_RETURN_H a2 where a2.SALENO = D_ZJYS_WL2023XSE.ERP销售号)
),
    base2 as (
    select 2023 as 年度,trunc(创建时间) as 会计日, 机构编码 as 普通门店编码,sfzs as 门店类型,
       就医地,参保地,险种 as 险种类型, 医保类型,
       ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,jyd order by 创建时间) as ord,--人次
       case
                 when ROW_NUMBER() over (partition by 身份证号,险种,sfzs,就医地,
                     case
                         when 险种 = '职工基本医疗保险' and 参保地 in ('市本级', '黄岩区', '路桥区') then '市本级'
                         when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                         else 参保地 end
                     order by 创建时间) > 1
                     then 0
                 else
                     ROW_NUMBER() over (partition by 身份证号,险种,sfzs,就医地,
                         case
                             when 险种 = '职工基本医疗保险' and 参保地 in ('市本级', '黄岩区', '路桥区') then '市本级'
                             when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                             else 参保地 end
                         order by 创建时间) end as ord2,--人头
       '(总额度-国探额度)/人头' as 人头基金, 医疗费用总额 as 总费用,
       zed1 as 总额度,
       自费费用 as 医疗费用自费总额,
       0 AS 医疗费用自理总额,
       zed as 国谈额度,
        基本医疗统筹支付, 当年账户支付, 公务员补助统筹支付,大病金额 AS 大病保险支付,历年账户支付, 现金金额
from base)
select 2024 as 年度, 会计日, 普通门店编码, 门店类型, 就医地, 参保地, 险种类型, 医保类型,
       --ord,
       sum(case when ord > 1 then 0 else ord end) as 人次,
       sum(ord2) as 人头,
       case when sum(ord2)=0 then 0 else
       (sum(总额度)-sum(国谈额度))/sum(ord2) end as 人头基金,

       sum(总费用), sum(总额度),
       sum(医疗费用自费总额), sum(医疗费用自理总额), sum(国谈额度), sum(基本医疗统筹支付), sum(当年账户支付), sum(公务员补助统筹支付), sum(大病保险支付),
       sum(历年账户支付), sum(现金金额)
from base2
-- where 会计日=date'2024-06-04' and 就医地 like'%杭州市%'
group by 会计日, 普通门店编码, 门店类型, 就医地, 参保地, 险种类型, 医保类型;

update dm_yb_md_head_sum_qc set RECEIPT_DATE=TO_CHAR(
           TO_DATE(RECEIPT_DATE, 'DD-MON-RR'),
           'YYYY-MM-DD'
       );


