select count(*) from DWB_YB_HEAD_DTL_QC where CITY_AREA_NAME in ('�ϳ���','��ƽ��','�ຼ��','������','������','��ɽ��','������','Ǯ����')
select * from DWB_YB_HEAD_DTL_QC where ORDER_NO='2407075038182520';
delete from DWB_YB_HEAD_DTL_QC where CITY_AREA_NAME in ('�ϳ���','��ƽ��','�ຼ��','������','������','��ɽ��','������','Ǯ����');
-- 167596
--����23����ͷ��ϸ
insert into DWB_YB_HEAD_DTL_QC(TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, MD_TYPE,
                               CITY_AREA_NAME)
select TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, md_type, CITY_AREA_NAME

from (
select 'rrt' as TENANT_ID,2023 as YEAR_YB, substr(a.BUSNO,2,4) as WERKS_ID, �������� as RECEIPT_DATE, a.ERP���۵��� as ORDER_NO,
       a.���֤�� as IDENTITY_NO,case
                       when �α���Ա��� like '%����%' OR �α���Ա��� like '%ѧ%' or �α���Ա��� like '%������%'
                           then 'ũ��'
                       else 'ҽ��' end as PER_YB_TYPE,
    case when a.BUSNO=84577 then '����' else '���µ�' end as md_type,substr(tb2.CLASSNAME,4,3)  as CITY_AREA_NAME,
    ROW_NUMBER() OVER (PARTITION BY ���֤��,tb1.CLASSNAME ORDER BY �������� ASC) rn
       from D_ZHYB_WRH a
join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
where tb.classcode IN ('303106')
and a.�������� >= DATE'2023-01-01' and a.�������� < DATE'2024-01-01'
AND a.�α��� <> '�㽭ʡʡ����'
and a.��ر�־ = '�����'
and a.BUSNO not in('81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
and a.JSLX <> '�����ز�'
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP���۵���)
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP���۵���) ) a where rn=1;

--����24����ͷ��ϸ
insert into DWB_YB_HEAD_DTL_QC(TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, MD_TYPE,
                               CITY_AREA_NAME)
select TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE, md_type, CITY_AREA_NAME

from (
select 'rrt' as TENANT_ID,2024 as YEAR_YB, substr(a.BUSNO,2,4) as WERKS_ID, �������� as RECEIPT_DATE, a.ERP���۵��� as ORDER_NO,
       a.���֤�� as IDENTITY_NO,case
                       when �α���Ա��� like '%����%' OR �α���Ա��� like '%ѧ%' or �α���Ա��� like '%������%'
                           then 'ũ��'
                       else 'ҽ��' end as PER_YB_TYPE,
    case when a.BUSNO=84577 then '����' else '���µ�' end as md_type,substr(tb2.CLASSNAME,4,3) as CITY_AREA_NAME,
    ROW_NUMBER() OVER (PARTITION BY ���֤��,tb1.CLASSNAME ORDER BY �������� ASC) rn
       from D_ZHYB_WRH a
join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
where tb.classcode IN ('303106')
and a.�������� >= DATE'2024-01-01' and a.�������� < DATE'2024-08-01'
AND a.�α��� <> '�㽭ʡʡ����'
and a.��ر�־ = '�����'
and a.BUSNO not in('81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
and a.JSLX <> '�����ز�'
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP���۵���)
AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP���۵���) ) a where rn=1;



