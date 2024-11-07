select sum(YB_PER_HEADNUM) from dm_yb_md_head_sum_qc
                      where CITY_AREA_NAME like '%杭州%';
delete from dm_yb_md_head_sum_qc where CITY_AREA_NAME like '%杭州%' ;
delete from dm_yb_md_head_sum_qc where WERKS_ID='4577';
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP销售单号, 销售日期, a.BUSNO, 身份证号,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 销售日期 ASC) 人头,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号,trunc(销售日期) ORDER BY 销售日期 ASC) 人次,
                   医疗费用总额 - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY as 列支费用,
                   case
                       when 参保人员类别 like '%居民%' OR 参保人员类别 like '%学%' or 参保人员类别 like '%新生儿%'
                           then 1
                       else 0 end as nb_flag, -- --医保0/农保1
                   tb1.CLASSNAME as mdlx,参保地,tb2.CLASSNAME as 就医地
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.销售日期 >= DATE'2023-01-01' and a.销售日期 < DATE'2024-01-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --去掉省本级
              AND a.参保地 <> '浙江省省本级'
              and a.异地标志 = '非异地'
              and a.BUSNO not in
                  ('84577', '81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
--     and a.BUSNO=84557
--   and a.结算类型<>'门诊特病'--and a.参保地 like '%杭州市%'
              and a.JSLX <> '门诊特病'
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP销售单号)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP销售单号)
            )
select to_char(销售日期,'YYYY'),to_char(销售日期,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='门店' then 0 else 1 end as 门店类型, 就医地,参保地,
       case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end as 险种类型,
       case when nb_flag=1 then '农保' else '医保' end as 医保类型,
       sum(case when 人次 = 1 then 1 else 0 end) as 人次和,
       sum(case when 人头 = 1 then 1 else 0 end) as 人头和,
       sum(列支费用)
from a1
group by to_char(销售日期,'YYYY'), to_char(销售日期,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='门店' then 0 else 1 end,参保地
       ,就医地, case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end,case when nb_flag=1 then '农保' else '医保' end;;
--24年门店
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP销售单号, 销售日期, a.BUSNO, 身份证号,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 销售日期 ASC) 人头,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号,trunc(销售日期) ORDER BY 销售日期 ASC) 人次,
                   医疗费用总额 - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY as 列支费用,
                   case
                       when 参保人员类别 like '%居民%' OR 参保人员类别 like '%学%' or 参保人员类别 like '%新生儿%'
                           then 1
                       else 0 end as nb_flag, -- --医保0/农保1
                   tb1.CLASSNAME as mdlx,参保地,tb2.CLASSNAME as 就医地
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.销售日期 >= DATE'2024-01-01' and a.销售日期 < DATE'2024-08-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --去掉省本级
              AND a.参保地 <> '浙江省省本级'
              and a.异地标志 = '非异地'
              and a.BUSNO not in
                  ('84577', '81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
--     and a.BUSNO=84557
--   and a.结算类型<>'门诊特病'--and a.参保地 like '%杭州市%'
              and a.JSLX <> '门诊特病'
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP销售单号)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP销售单号)
            )
select to_char(销售日期,'YYYY'),to_char(销售日期,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='门店' then 0 else 1 end as 门店类型, 就医地,参保地,
       case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end as 险种类型,
       case when nb_flag=1 then '农保' else '医保' end as 医保类型,
       sum(case when 人次 = 1 then 1 else 0 end) as 人次和,
       sum(case when 人头 = 1 then 1 else 0 end) as 人头和,
       sum(列支费用)
from a1
group by to_char(销售日期,'YYYY'), to_char(销售日期,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='门店' then 0 else 1 end,参保地
       ,就医地, case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end,case when nb_flag=1 then '农保' else '医保' end;
--23年诊所
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP销售单号, 销售日期, a.BUSNO, 身份证号,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 销售日期 ASC) 人头,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号,trunc(销售日期) ORDER BY 销售日期 ASC) 人次,
                   case when JSLX='门诊特病' then 0 else 医疗费用总额 - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY end as 列支费用,
                   case
                       when 参保人员类别 like '%居民%' OR 参保人员类别 like '%学%' or 参保人员类别 like '%新生儿%'
                           then 1
                       else 0 end as nb_flag, -- --医保0/农保1
                   tb1.CLASSNAME as mdlx,参保地,tb2.CLASSNAME as 就医地
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.销售日期 >= DATE'2023-01-01' and a.销售日期 < DATE'2024-01-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --去掉省本级
              AND a.参保地 <> '浙江省省本级'
              and a.异地标志 = '非异地'
              and a.BUSNO=84577
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP销售单号)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP销售单号)
              )
select to_char(销售日期,'YYYY'),to_char(销售日期,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='门店' then 0 else 1 end as 门店类型, 就医地,参保地,
       case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end as 险种类型,
       case when nb_flag=1 then '农保' else '医保' end as 医保类型,
       sum(case when 人次 = 1 then 1 else 0 end) as 人次和,
       sum(case when 人头 = 1 then 1 else 0 end) as 人头和,
       sum(列支费用)
from a1
group by to_char(销售日期,'YYYY'), to_char(销售日期,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='门店' then 0 else 1 end,参保地
       ,就医地, case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end,case when nb_flag=1 then '农保' else '医保' end;

--24年诊所
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP销售单号, 销售日期, a.BUSNO, 身份证号,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 销售日期 ASC) 人头,
                   ROW_NUMBER() OVER (PARTITION BY 身份证号,trunc(销售日期) ORDER BY 销售日期 ASC) 人次,
                   case when JSLX='门诊特病' then 0 else 医疗费用总额 - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY end as 列支费用,
                   case
                       when 参保人员类别 like '%居民%' OR 参保人员类别 like '%学%' or 参保人员类别 like '%新生儿%'
                           then 1
                       else 0 end as nb_flag, -- --医保0/农保1
                   tb1.CLASSNAME as mdlx,参保地,tb2.CLASSNAME as 就医地
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.销售日期 >= DATE'2024-01-01' and a.销售日期 < DATE'2024-08-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --去掉省本级
              AND a.参保地 <> '浙江省省本级'
              and a.异地标志 = '非异地'
              and a.BUSNO=84577
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP销售单号)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP销售单号)
              )
select to_char(销售日期,'YYYY'),to_char(销售日期,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='门店' then 0 else 1 end as 门店类型, 就医地,参保地,
       case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end as 险种类型,
       case when nb_flag=1 then '农保' else '医保' end as 医保类型,
       sum(case when 人次 = 1 then 1 else 0 end) as 人次和,
       sum(case when 人头 = 1 then 1 else 0 end) as 人头和,
       sum(列支费用)
from a1
group by to_char(销售日期,'YYYY'), to_char(销售日期,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='门店' then 0 else 1 end,参保地
       ,就医地, case when nb_flag=1 then '城乡居民基本医疗保险' else '职工基本医疗保险' end,case when nb_flag=1 then '农保' else '医保' end;


select count(*) from D_ZHYB_WRH  a  WHERE a.销售日期 > DATE'2024-01-01' AND a.参保地 <> '浙江省省本级'
              and a.异地标志 = '非异地'
              and a.BUSNO=84577 and a.销售日期 < DATE'2024-08-01'
             and JSLX like '%门诊特病%';
select sum(YB_PER_NUM) as 人次,sum(YB_PER_HEADNUM) as 人头,sum(TOTAL_AMOUNT) as 列支费用
from dm_yb_md_head_sum_qc where WERKS_ID=4577 and YEAR_YB=2024;

select * from dm_yb_md_head_sum_qc where INSURE_REGION_NAME like '%杭州%' ;
select case
             when CITY_AREA_NAME in ('杭州市拱墅区',
                                    '杭州市上城区',
                                    '杭州市西湖区',
                                    '杭州市钱塘区',
                                    '杭州市滨江区') then '上城区'
             else CITY_AREA_NAME end  as 区域,count(*) from DWB_YB_HEAD_DTL_QC a

where CITY_AREA_NAME like '%杭州%' and YEAR_YB=2024 and WERKS_ID<>'4577' group by case
             when CITY_AREA_NAME in ('杭州市拱墅区',
                                    '杭州市上城区',
                                    '杭州市西湖区',
                                    '杭州市钱塘区',
                                    '杭州市滨江区') then '上城区'
             else CITY_AREA_NAME end;
select case
             when INSURE_REGION_NAME in ('杭州市拱墅区',
                                    '杭州市上城区',
                                    '杭州市西湖区',
                                    '杭州市钱塘区',
                                    '杭州市滨江区') then '主城区'
             else INSURE_REGION_NAME end  as 区域,sum(YB_PER_NUM) as 人次,sum(YB_PER_HEADNUM) as 人头,sum(TOTAL_AMOUNT) as 列支费用 from dm_yb_md_head_sum_qc a

         where INSURE_REGION_NAME like '%杭州%' and WERKS_ID<>'4577' and YEAR_YB=2024 group by
                                                                    case
             when INSURE_REGION_NAME in ('杭州市拱墅区',
                                    '杭州市上城区',
                                    '杭州市西湖区',
                                    '杭州市钱塘区',
                                    '杭州市滨江区') then '主城区'
             else INSURE_REGION_NAME end ;
select sum(YB_PER_NUM),sum(YB_PER_HEADNUM),sum(TOTAL_AMOUNT) from dm_yb_md_head_sum_qc a
where WERKS_ID='4577' and YEAR_YB=2024
delete from dm_yb_md_head_sum_qc where INSURE_REGION_NAME like '%杭州%';;
select * from dm_yb_md_head_sum_qc;

select 参保地,tb2.CLASSNAME from  D_ZHYB_WRH a
                   join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
               join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                   WHERE a.销售日期 > DATE'2023-01-01' and a.销售日期 < DATE'2024-01-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --去掉省本级
              AND a.参保地 <> '浙江省省本级'
              and a.异地标志 = '非异地'
              and a.BUSNO not in
                  ('84577', '81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
--     and a.BUSNO=84557
--   and a.结算类型<>'门诊特病'--and a.参保地 like '%杭州市%'
              and a.JSLX <> '门诊特病'
                   group by 参保地,tb2.CLASSNAME;


select 参保地,就医地 from d_zjys_wl2023xse group by 参保地,就医地;

select *
from dm_yb_md_head_sum_qc where CITY_AREA_NAME like '%杭州%' ;
delete from dm_yb_md_head_sum_qc where CITY_AREA_NAME like '%杭州%';
select CITY_AREA_NAME, INSURE_REGION_NAME
from dm_yb_md_head_sum_qc
group by CITY_AREA_NAME, INSURE_REGION_NAME;
select *
from DWB_YB_HEAD_DTL_QC;
-- delete from DWB_YB_HEAD_DTL_QC where RECEIPT_DATE>=date'2024-08-01';
-- select max(RECEIPT_DATE) from DWB_YB_HEAD_DTL_QC;
select *
from D_ZHYB_WRH;
select max(销售日期)
from D_ZHYB_WRH where BUSNO=84577;
select *
from D_ZHYB_WRH;