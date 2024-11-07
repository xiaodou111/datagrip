select count(*) from DWB_YB_HEAD_DTL_QC where CITY_AREA_NAME in ('上城区','临平区','余杭区','拱墅区','滨江区','萧山区','西湖区','钱塘区')
select * from DWB_YB_HEAD_DTL_QC where ORDER_NO='2407075038182520';
delete from DWB_YB_HEAD_DTL_QC where CITY_AREA_NAME in ('上城区','临平区','余杭区','拱墅区','滨江区','萧山区','西湖区','钱塘区');
-- 167596
--杭州23年人头明细
insert into DWB_YB_HEAD_DTL_QC(TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, MD_TYPE,
                               CITY_AREA_NAME)
select TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, md_type, CITY_AREA_NAME

from (
select 'rrt' as TENANT_ID,2023 as YEAR_YB, substr(a.BUSNO,2,4) as WERKS_ID, 销售日期 as RECEIPT_DATE, a.ERP销售单号 as ORDER_NO,
       a.身份证号 as IDENTITY_NO,case
                       when 参保人员类别 like '%居民%' OR 参保人员类别 like '%学%' or 参保人员类别 like '%新生儿%'
                           then '农保'
                       else '医保' end as PER_YB_TYPE,
    case when a.BUSNO=84577 then '门诊' else '线下店' end as md_type,substr(tb2.CLASSNAME,4,3)  as CITY_AREA_NAME,
    ROW_NUMBER() OVER (PARTITION BY 身份证号,tb1.CLASSNAME ORDER BY 销售日期 ASC) rn
       from D_ZHYB_WRH a
join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
where tb.classcode IN ('303106')
and a.销售日期 >= DATE'2023-01-01' and a.销售日期 < DATE'2024-01-01'
AND a.参保地 <> '浙江省省本级'
and a.异地标志 = '非异地'
and a.BUSNO not in('81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
and a.JSLX <> '门诊特病'
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP销售单号)
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP销售单号) ) a where rn=1;

--杭州24年人头明细
insert into DWB_YB_HEAD_DTL_QC(TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, MD_TYPE,
                               CITY_AREA_NAME)
select TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, md_type, CITY_AREA_NAME

from (
select 'rrt' as TENANT_ID,2024 as YEAR_YB, substr(a.BUSNO,2,4) as WERKS_ID, 销售日期 as RECEIPT_DATE, a.ERP销售单号 as ORDER_NO,
       a.身份证号 as IDENTITY_NO,case
                       when 参保人员类别 like '%居民%' OR 参保人员类别 like '%学%' or 参保人员类别 like '%新生儿%'
                           then '农保'
                       else '医保' end as PER_YB_TYPE,
    case when a.BUSNO=84577 then '门诊' else '线下店' end as md_type,substr(tb2.CLASSNAME,4,3) as CITY_AREA_NAME,
    ROW_NUMBER() OVER (PARTITION BY 身份证号,tb1.CLASSNAME ORDER BY 销售日期 ASC) rn
       from D_ZHYB_WRH a
join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
where tb.classcode IN ('303106')
and a.销售日期 >= DATE'2024-01-01' and a.销售日期 < DATE'2024-08-01'
AND a.参保地 <> '浙江省省本级'
and a.异地标志 = '非异地'
and a.BUSNO not in('81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
and a.JSLX <> '门诊特病'
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP销售单号)
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP销售单号) ) a where rn=1;



