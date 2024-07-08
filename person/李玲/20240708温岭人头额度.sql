--todo 温岭人头额度(参保地为温岭的药店诊所算人头的时候合并)
     select 门店类型,qy,sum(zed1) as 总额度 ,sum(zed) as 国谈总额度,count(身份证号) as 人头 from (
    select a.ERP销售号,a.创建时间,a.机构编码,a.身份证号,a.险种,a.参保地, nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) as zed1,
           tb2.CLASSNAME as qy,TB22.CLASSNAME as 门店类型,
           case
                when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                               then
                               nvl(detail.统筹支付数,0)+nvl(detail.公补基金支付数,0)+nvl(detail.个人当年帐户支付数,0)
                           else 0
                       end as zed,
           ROW_NUMBER() OVER (PARTITION BY
                CASE
                     WHEN a.险种='职工基本医疗保险' and TB2.CLASSCODE IN ('324331001', '324331002','324331003','324331004') THEN '324331001'
                     WHEN a.险种='城乡居民基本医疗保险' and TB2.CLASSCODE IN ('324331001', '324331002') THEN '324331002'
                     ELSE TB2.CLASSCODE
                     END,
                  case when a.参保地='331081' then '30510' else TB22.CLASSCODE end ,
                 A.身份证号,A.险种 ORDER BY A.创建时间 )rn  from d_zjys_wl2023xse a
                 left join d_ybsp_jsmx detail
                   on a.ERP销售号 = detail.SALENO
                  left join d_ll_gtml gtml
                   on gtml.WAREID = detail.wareid and a.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
    JOIN T_BUSNO_CLASS_SET TS ON A.机构编码 = TS.BUSNO AND TS.CLASSGROUPNO = '303'
    JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
    AND TB.CLASSCODE IN ('303100', '303101', '303102')
    JOIN T_BUSNO_CLASS_SET TS2 ON A.机构编码 = TS2.BUSNO AND TS2.CLASSGROUPNO = '324'
    JOIN T_BUSNO_CLASS_BASE TB2 ON TS2.CLASSGROUPNO = TB2.CLASSGROUPNO AND TS2.CLASSCODE = TB2.CLASSCODE
    JOIN T_BUSNO_CLASS_SET TS22 ON A.机构编码 = TS22.BUSNO AND TS22.CLASSGROUPNO = '305'
    JOIN T_BUSNO_CLASS_BASE TB22 ON TS22.CLASSGROUPNO = TB22.CLASSGROUPNO AND TS22.CLASSCODE = TB22.CLASSCODE
    WHERE A.创建时间 >= DATE'2023-01-01' and A.创建时间<=date'2024-01-01'
  AND A.参保地 ='温岭市'
    AND EXISTS(SELECT 1
FROM (SELECT A.SALENO
FROM d_ybsp_jsmx A
         JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
         JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
WHERE TB.CLASSCODE = '30510'
  AND NVL(统筹支付数, 0) + NVL(个人当年帐户支付数, 0) + NVL(公补基金支付数, 0) <> 0
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1
FROM D_LL_GTML GT
WHERE GT.WAREID = A.WAREID
  AND A.RECEIPTDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
  AND GT.PZFL IN ('双通道品种', '国谈品种'))
UNION ALL
SELECT A.SALENO
FROM d_ybsp_jsmx A
         JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
         JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
WHERE TB.CLASSCODE = '30511'
  AND NVL(统筹支付数, 0) + NVL(个人当年帐户支付数, 0) + NVL(公补基金支付数, 0) <> 0
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1
FROM D_LL_GTML GT
WHERE GT.WAREID = A.WAREID
  AND A.RECEIPTDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
  AND GT.PZFL IN ('国谈品种'))) aaa where aaa.SALENO=a.ERP销售号  ))
WHERE RN = 1 group by qy,门店类型;

--期初额度算法
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
                trunc(创建时间) BETWEEN date'2023-01-01' AND date'2023-12-31'
--                and d_zjys_wl2023xse.机构编码 in ('85027','85034','85036','85037','85039','85040','85041','85042','85064','85067','85069','85074','85083','85084','89074','89075')
              and not exists (select 1 from T_SALE_RETURN_H a where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
              and not exists (select 1 from T_SALE_RETURN_H a2 where a2.SALENO = D_ZJYS_WL2023XSE.ERP销售号)
),
    base2 as (
    select 2024 as 年度,trunc(创建时间) as 会计日, 机构编码 as 普通门店编码,sfzs as 门店类型,
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
select 2023 as 年度, 会计日, 普通门店编码, 门店类型, 就医地, 参保地, 险种类型, 医保类型,
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