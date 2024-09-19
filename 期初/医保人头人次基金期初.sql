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
select count(*) from DM_YB_MD_HEAD_SUM_QC  where RECEIPT_DATE BETWEEN '2023-01-01' AND '2023-12-31';
delete from DM_YB_MD_HEAD_SUM_QC where CITY_AREA_NAME not in
('杭州市上城区','杭州市临平区','杭州市余杭区','杭州市市本级','杭州市建德市','杭州市拱墅区','杭州市桐庐县','杭州市淳安县','杭州市滨江区','杭州市萧山区','杭州市西湖区','杭州市钱塘区')
-- and RECEIPT_DATE >= '2024-01-01'
insert into DM_YB_MD_HEAD_SUM_QC select * from DM_YB_MD_HEAD_SUM_QC AS OF TIMESTAMP SYSDATE - (1/24);
insert into  DM_YB_MD_HEAD_SUM_QC(YEAR_YB, RECEIPT_DATE, WERKS_ID, MD_TYPE, CITY_AREA_NAME, INSURE_REGION_NAME, INSURANCE_TYPE, PER_YB_TYPE,
       YB_PER_NUM, YB_PER_HEADNUM, HEAD_FUND_AMOUNT, TOTAL_AMOUNT, TOTAL_QUOTA, PERSONAL_PAY_AMOUNT, SELF_CHARGE_AMOUNT,
       GT_QUOTA, OVERALL_PAY, CURRENT_ACCOUNT_PAY, PUBLIC_FUND_PAY, ILLNESS_SUBSIDY_AMOUNT, HISTORY_ACCOUNT_PAY,
       PERSONAL_CASH_AMOUNT)
with base as (
  select d_zjys_wl2023xse.erp销售号,sfzs,事业部,d_zjys_wl2023xse.身份证号,创建时间,
           险种,机构编码,
            decode(就医地,'椒江区','椒江本级','市本级','椒江本级',就医地) as 就医地,
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
                   decode(d_zjys_wl2023xse.参保地,'市本级','椒路黄本级',参保地) as 参保地
--                    case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                     left join v_saleno_zed on d_zjys_wl2023xse.ERP销售号 = v_saleno_zed.erp销售号
            where
--                 trunc(创建时间) BETWEEN date'2024-01-01' AND date'2024-07-31'
                trunc(创建时间) BETWEEN date'2023-01-01' AND date'2023-12-31'
--                 and 就医地 not in ('杭州市上城区','杭州市临平区','杭州市余杭区','杭州市市本级','杭州市建德市','杭州市拱墅区','杭州市桐庐县','杭州市淳安县','杭州市滨江区','杭州市萧山区','杭州市西湖区','杭州市钱塘区')
                and 就医地 in ('三门县','临海市','仙居县','天台县','椒江区','市本级','温岭市','玉环市','玉环市','路桥区','黄岩区')
--                 and s_busi.ZMDZ1=81499
--                and d_zjys_wl2023xse.机构编码 in ('85027','85034','85036','85037','85039','85040','85041','85042','85064','85067','85069','85074','85083','85084','89074','89075')
              and not exists (select 1 from T_SALE_RETURN_H a where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
              and not exists (select 1 from T_SALE_RETURN_H a2 where a2.SALENO = D_ZJYS_WL2023XSE.ERP销售号)
),
    base2 as (
    select null as 年度,trunc(创建时间) as 会计日, 机构编码 as 普通门店编码,sfzs as 门店类型,
       就医地,参保地,险种 as 险种类型, 医保类型,
       ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),SFZS,险种,就医地 order by 创建时间) as ord,--人次
--       case when nvl(xzrt.IDENTITY_NO,'0')='0' then 0 else
       case when ROW_NUMBER() OVER (PARTITION BY
                 CASE
                     WHEN 险种 = '职工基本医疗保险' and  参保地 IN ('黄岩区','路桥区','市本级')
                         THEN '市本级'
                     WHEN 险种 = '城乡居民基本医疗保险' and 参保地 IN ('市本级') THEN '市本级'
                     ELSE 参保地
                     END,
                 就医地 ,
                 身份证号,险种 ORDER BY 创建时间 ASC) > 1
                     then 0
                 else
                     1 end  as ord2, --人头
--                      ROW_NUMBER() OVER (PARTITION BY
--                  CASE
--                      WHEN 险种 = '职工基本医疗保险' and  参保地 IN ('黄岩区','路桥区','市本级')
--                          THEN '市本级'
--                      WHEN 险种 = '城乡居民基本医疗保险' and 参保地 IN ('市本级') THEN '市本级'
--                      ELSE 参保地
--                      END,
--                   就医地 ,
--                  身份证号,险种 ORDER BY 创建时间 ASC) end   as ord2,--人头
       '(总额度-国探额度)/人头' as 人头基金, 医疗费用总额 as 总费用,
       zed1 as 总额度,
       自费费用 as 医疗费用自费总额,
       0 AS 医疗费用自理总额,
       zed as 国谈额度,
        基本医疗统筹支付, 当年账户支付, 公务员补助统筹支付,大病金额 AS 大病保险支付,历年账户支付, 现金金额
from base
-- left join  DWB_YB_HEAD_DTL_QC  xzrt
-- on 身份证号 = xzrt.IDENTITY_NO
-- and trunc(创建时间) = trunc(xzrt.RECEIPT_DATE)
-- and case when 险种 = '职工基本医疗保险' then '0' else '1' end =case when xzrt.PER_YB_TYPE ='医保' then 0 else 1 end
-- and to_char(机构编码) = 8||to_char(xzrt.WERKS_ID)
)
select 2023 as 年度, to_char(会计日,'YYYY-MM-DD'), substr(普通门店编码,2,4), 门店类型, 就医地, 参保地, 险种类型, 医保类型,
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
group by 会计日, substr(普通门店编码,2,4), 门店类型, 就医地, 参保地, 险种类型, 医保类型;

--更新人头到汇总表
MERGE INTO DM_YB_MD_HEAD_SUM_QC T1
USING
(
select to_char(RECEIPT_DATE,'YYYY-MM-DD') as RECEIPT_DATE,WERKS_ID,PER_YB_TYPE,count(*) as sl from DWB_YB_HEAD_DTL_QC
-- where CITY_AREA_NAME like '%路桥%' and YEAR_YB=2023 and PER_YB_TYPE='医保'
                                                               group by to_char(RECEIPT_DATE,'YYYY-MM-DD'),WERKS_ID,PER_YB_TYPE
)  T2
ON ( T1.RECEIPT_DATE=T2.RECEIPT_DATE and t1.WERKS_ID=t2.WERKS_ID and t1.PER_YB_TYPE=t2.PER_YB_TYPE)
WHEN MATCHED THEN
UPDATE SET T1.YB_PER_HEADNUM= T2.sl;
--没匹配到的新增人头是0,这里会把杭州的覆盖,需要重刷
UPDATE DM_YB_MD_HEAD_SUM_QC T1
SET T1.YB_PER_HEADNUM = 0
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        select to_char(RECEIPT_DATE, 'YYYY-MM-DD') as RECEIPT_DATE, WERKS_ID, PER_YB_TYPE, count(*) as sl
        from DWB_YB_HEAD_DTL_QC
--         where CITY_AREA_NAME like '%路桥%'
--           and YEAR_YB = 2023
--           and PER_YB_TYPE = '医保'
        group by to_char(RECEIPT_DATE, 'YYYY-MM-DD'), WERKS_ID, PER_YB_TYPE
    ) T2
    WHERE T1.RECEIPT_DATE = T2.RECEIPT_DATE AND T1.WERKS_ID = T2.WERKS_ID AND T1.PER_YB_TYPE = T2.PER_YB_TYPE
);


update dm_yb_md_head_sum_qc set RECEIPT_DATE=TO_CHAR(
           TO_DATE(RECEIPT_DATE, 'DD-MON-RR'),
           'YYYY-MM-DD'
       );
-- 参保地市本级要不就命名为椒路黄本级
-- 就医地台州市本级和台州市椒江区命名为椒江本级
select count(*) from DWB_YB_HEAD_DTL_QC where (CITY_AREA_NAME like '%台州%' or CITY_AREA_NAME='椒江本级');
delete from DWB_YB_HEAD_DTL_QC where CITY_AREA_NAME like '%台州%';
--期初明细
insert into DWB_YB_HEAD_DTL_QC(TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE
                               , MD_TYPE,
                               CITY_AREA_NAME)
select tenant_id, year_yb, substr(to_number(机构编码),2,4), 创建时间, ERP销售号, 身份证号, case when 险种='职工基本医疗保险' then '医保' else '农保' end, 门店类型, 就医地
from (
select 'rrt' as tenant_id,2024 as year_yb,a.机构编码,a.创建时间,a.ERP销售号,a.身份证号,a.险种,tb22.CLASSNAME as 门店类型,
       decode(TB2.CLASSNAME,'台州市本级','椒江本级','台州市椒江区','椒江本级',TB2.CLASSNAME) as 就医地,ROW_NUMBER() OVER (PARTITION BY
                 CASE
                     WHEN a.险种 = '职工基本医疗保险' and  a.参保地 IN ('黄岩区','路桥区','市本级')
                         THEN '市本级'
                     WHEN a.险种 = '城乡居民基本医疗保险' and a.参保地 IN ('市本级') THEN '市本级'
                     ELSE a.参保地
                     END,
                  decode(TB2.CLASSNAME,'台州市本级','椒江本级','台州市椒江区','椒江本级',TB2.CLASSNAME),
                 A.身份证号,A.险种 ORDER BY A.创建时间 ASC) RN from d_zjys_wl2023xse a
JOIN T_BUSNO_CLASS_SET TS ON to_char(A.机构编码) = TS.BUSNO AND TS.CLASSGROUPNO = '303'
               JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
          AND TB.CLASSCODE IN ('303100', '303101', '303102')
               JOIN T_BUSNO_CLASS_SET TS2 ON to_char(A.机构编码) = TS2.BUSNO AND TS2.CLASSGROUPNO = '324'
               JOIN T_BUSNO_CLASS_BASE TB2 ON TS2.CLASSGROUPNO = TB2.CLASSGROUPNO AND TS2.CLASSCODE = TB2.CLASSCODE
               JOIN T_BUSNO_CLASS_SET TS22 ON to_char(A.机构编码) = TS22.BUSNO AND TS22.CLASSGROUPNO = '305'
               JOIN T_BUSNO_CLASS_BASE TB22 ON TS22.CLASSGROUPNO = TB22.CLASSGROUPNO AND TS22.CLASSCODE = TB22.CLASSCODE
 WHERE A.创建时间 > date'2024-01-01' and  A.创建时间<date'2024-08-01'
        AND A.参保地 IN
           ('玉环市','仙居县','温岭市','黄岩区','市本级','天台县','临海市','三门县','路桥区')
AND EXISTS(SELECT 1
                   FROM (SELECT A.SALENO
                         FROM D_YB_SPXX_DETAIL A
                                  JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
                                  JOIN T_BUSNO_CLASS_BASE TB
                                       ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
                         WHERE TB.CLASSCODE = '30510'
                           AND NVL(统筹支付数, 0) + NVL(个人当年帐户支付数, 0) + NVL(公补基金支付数, 0) <> 0
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1
                                          FROM D_LL_GTML GT
                                          WHERE GT.WAREID = A.WAREID
                                            AND A.ACCDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
                                            AND GT.PZFL IN ('双通道品种', '国谈品种'))
                         UNION ALL
                         SELECT A.SALENO
                         FROM D_YB_SPXX_DETAIL A
                                  JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
                                  JOIN T_BUSNO_CLASS_BASE TB
                                       ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
                         WHERE TB.CLASSCODE = '30511'
                           AND NVL(统筹支付数, 0) + NVL(个人当年帐户支付数, 0) + NVL(公补基金支付数, 0) <> 0
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1
                                          FROM D_LL_GTML GT
                                          WHERE GT.WAREID = A.WAREID
                                            AND A.ACCDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
                                            AND GT.PZFL IN ('国谈品种'))) aaa
                   where aaa.SALENO = a.ERP销售号)) where rn=1;

