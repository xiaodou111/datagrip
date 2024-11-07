select sum(YB_PER_HEADNUM) from dm_yb_md_head_sum_qc
                      where CITY_AREA_NAME like '%����%';
delete from dm_yb_md_head_sum_qc where CITY_AREA_NAME like '%����%' ;
delete from dm_yb_md_head_sum_qc where WERKS_ID='4577';
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP���۵���, ��������, a.BUSNO, ���֤��,
                   ROW_NUMBER() OVER (PARTITION BY ���֤�� ORDER BY �������� ASC) ��ͷ,
                   ROW_NUMBER() OVER (PARTITION BY ���֤��,trunc(��������) ORDER BY �������� ASC) �˴�,
                   ҽ�Ʒ����ܶ� - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY as ��֧����,
                   case
                       when �α���Ա��� like '%����%' OR �α���Ա��� like '%ѧ%' or �α���Ա��� like '%������%'
                           then 1
                       else 0 end as nb_flag, -- --ҽ��0/ũ��1
                   tb1.CLASSNAME as mdlx,�α���,tb2.CLASSNAME as ��ҽ��
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.�������� >= DATE'2023-01-01' and a.�������� < DATE'2024-01-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --ȥ��ʡ����
              AND a.�α��� <> '�㽭ʡʡ����'
              and a.��ر�־ = '�����'
              and a.BUSNO not in
                  ('84577', '81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
--     and a.BUSNO=84557
--   and a.��������<>'�����ز�'--and a.�α��� like '%������%'
              and a.JSLX <> '�����ز�'
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP���۵���)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP���۵���)
            )
select to_char(��������,'YYYY'),to_char(��������,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='�ŵ�' then 0 else 1 end as �ŵ�����, ��ҽ��,�α���,
       case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end as ��������,
       case when nb_flag=1 then 'ũ��' else 'ҽ��' end as ҽ������,
       sum(case when �˴� = 1 then 1 else 0 end) as �˴κ�,
       sum(case when ��ͷ = 1 then 1 else 0 end) as ��ͷ��,
       sum(��֧����)
from a1
group by to_char(��������,'YYYY'), to_char(��������,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='�ŵ�' then 0 else 1 end,�α���
       ,��ҽ��, case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end,case when nb_flag=1 then 'ũ��' else 'ҽ��' end;;
--24���ŵ�
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP���۵���, ��������, a.BUSNO, ���֤��,
                   ROW_NUMBER() OVER (PARTITION BY ���֤�� ORDER BY �������� ASC) ��ͷ,
                   ROW_NUMBER() OVER (PARTITION BY ���֤��,trunc(��������) ORDER BY �������� ASC) �˴�,
                   ҽ�Ʒ����ܶ� - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY as ��֧����,
                   case
                       when �α���Ա��� like '%����%' OR �α���Ա��� like '%ѧ%' or �α���Ա��� like '%������%'
                           then 1
                       else 0 end as nb_flag, -- --ҽ��0/ũ��1
                   tb1.CLASSNAME as mdlx,�α���,tb2.CLASSNAME as ��ҽ��
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.�������� >= DATE'2024-01-01' and a.�������� < DATE'2024-08-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --ȥ��ʡ����
              AND a.�α��� <> '�㽭ʡʡ����'
              and a.��ر�־ = '�����'
              and a.BUSNO not in
                  ('84577', '81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
--     and a.BUSNO=84557
--   and a.��������<>'�����ز�'--and a.�α��� like '%������%'
              and a.JSLX <> '�����ز�'
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP���۵���)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP���۵���)
            )
select to_char(��������,'YYYY'),to_char(��������,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='�ŵ�' then 0 else 1 end as �ŵ�����, ��ҽ��,�α���,
       case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end as ��������,
       case when nb_flag=1 then 'ũ��' else 'ҽ��' end as ҽ������,
       sum(case when �˴� = 1 then 1 else 0 end) as �˴κ�,
       sum(case when ��ͷ = 1 then 1 else 0 end) as ��ͷ��,
       sum(��֧����)
from a1
group by to_char(��������,'YYYY'), to_char(��������,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='�ŵ�' then 0 else 1 end,�α���
       ,��ҽ��, case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end,case when nb_flag=1 then 'ũ��' else 'ҽ��' end;
--23������
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP���۵���, ��������, a.BUSNO, ���֤��,
                   ROW_NUMBER() OVER (PARTITION BY ���֤�� ORDER BY �������� ASC) ��ͷ,
                   ROW_NUMBER() OVER (PARTITION BY ���֤��,trunc(��������) ORDER BY �������� ASC) �˴�,
                   case when JSLX='�����ز�' then 0 else ҽ�Ʒ����ܶ� - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY end as ��֧����,
                   case
                       when �α���Ա��� like '%����%' OR �α���Ա��� like '%ѧ%' or �α���Ա��� like '%������%'
                           then 1
                       else 0 end as nb_flag, -- --ҽ��0/ũ��1
                   tb1.CLASSNAME as mdlx,�α���,tb2.CLASSNAME as ��ҽ��
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.�������� >= DATE'2023-01-01' and a.�������� < DATE'2024-01-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --ȥ��ʡ����
              AND a.�α��� <> '�㽭ʡʡ����'
              and a.��ر�־ = '�����'
              and a.BUSNO=84577
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP���۵���)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP���۵���)
              )
select to_char(��������,'YYYY'),to_char(��������,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='�ŵ�' then 0 else 1 end as �ŵ�����, ��ҽ��,�α���,
       case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end as ��������,
       case when nb_flag=1 then 'ũ��' else 'ҽ��' end as ҽ������,
       sum(case when �˴� = 1 then 1 else 0 end) as �˴κ�,
       sum(case when ��ͷ = 1 then 1 else 0 end) as ��ͷ��,
       sum(��֧����)
from a1
group by to_char(��������,'YYYY'), to_char(��������,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='�ŵ�' then 0 else 1 end,�α���
       ,��ҽ��, case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end,case when nb_flag=1 then 'ũ��' else 'ҽ��' end;

--24������
insert into dm_yb_md_head_sum_qc(YEAR_YB,RECEIPT_DATE,WERKS_ID,MD_TYPE,CITY_AREA_NAME,INSURE_REGION_NAME,INSURANCE_TYPE,
                                 PER_YB_TYPE,YB_PER_NUM,YB_PER_HEADNUM,TOTAL_AMOUNT)
with a1 as (select ERP���۵���, ��������, a.BUSNO, ���֤��,
                   ROW_NUMBER() OVER (PARTITION BY ���֤�� ORDER BY �������� ASC) ��ͷ,
                   ROW_NUMBER() OVER (PARTITION BY ���֤��,trunc(��������) ORDER BY �������� ASC) �˴�,
                   case when JSLX='�����ز�' then 0 else ҽ�Ʒ����ܶ� - PRESELFPAYAMT - FULAMTOWNPAYAMT - OVERLMTSELFPAY end as ��֧����,
                   case
                       when �α���Ա��� like '%����%' OR �α���Ա��� like '%ѧ%' or �α���Ա��� like '%������%'
                           then 1
                       else 0 end as nb_flag, -- --ҽ��0/ũ��1
                   tb1.CLASSNAME as mdlx,�α���,tb2.CLASSNAME as ��ҽ��
            from D_ZHYB_WRH a
                     join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                     join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '305'
                     join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                     join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
                     join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                AND tb.classcode IN ('303106')
            WHERE a.�������� >= DATE'2024-01-01' and a.�������� < DATE'2024-08-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --ȥ��ʡ����
              AND a.�α��� <> '�㽭ʡʡ����'
              and a.��ر�־ = '�����'
              and a.BUSNO=84577
            AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.ERP���۵���)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.ERP���۵���)
              )
select to_char(��������,'YYYY'),to_char(��������,'YYYY-MM-DD'),substr(BUSNO,2,4),
       case when mdlx='�ŵ�' then 0 else 1 end as �ŵ�����, ��ҽ��,�α���,
       case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end as ��������,
       case when nb_flag=1 then 'ũ��' else 'ҽ��' end as ҽ������,
       sum(case when �˴� = 1 then 1 else 0 end) as �˴κ�,
       sum(case when ��ͷ = 1 then 1 else 0 end) as ��ͷ��,
       sum(��֧����)
from a1
group by to_char(��������,'YYYY'), to_char(��������,'YYYY-MM-DD'), substr(BUSNO,2,4),case when mdlx='�ŵ�' then 0 else 1 end,�α���
       ,��ҽ��, case when nb_flag=1 then '����������ҽ�Ʊ���' else 'ְ������ҽ�Ʊ���' end,case when nb_flag=1 then 'ũ��' else 'ҽ��' end;


select count(*) from D_ZHYB_WRH  a  WHERE a.�������� > DATE'2024-01-01' AND a.�α��� <> '�㽭ʡʡ����'
              and a.��ر�־ = '�����'
              and a.BUSNO=84577 and a.�������� < DATE'2024-08-01'
             and JSLX like '%�����ز�%';
select sum(YB_PER_NUM) as �˴�,sum(YB_PER_HEADNUM) as ��ͷ,sum(TOTAL_AMOUNT) as ��֧����
from dm_yb_md_head_sum_qc where WERKS_ID=4577 and YEAR_YB=2024;

select * from dm_yb_md_head_sum_qc where INSURE_REGION_NAME like '%����%' ;
select case
             when CITY_AREA_NAME in ('�����й�����',
                                    '�������ϳ���',
                                    '������������',
                                    '������Ǯ����',
                                    '�����б�����') then '�ϳ���'
             else CITY_AREA_NAME end  as ����,count(*) from DWB_YB_HEAD_DTL_QC a

where CITY_AREA_NAME like '%����%' and YEAR_YB=2024 and WERKS_ID<>'4577' group by case
             when CITY_AREA_NAME in ('�����й�����',
                                    '�������ϳ���',
                                    '������������',
                                    '������Ǯ����',
                                    '�����б�����') then '�ϳ���'
             else CITY_AREA_NAME end;
select case
             when INSURE_REGION_NAME in ('�����й�����',
                                    '�������ϳ���',
                                    '������������',
                                    '������Ǯ����',
                                    '�����б�����') then '������'
             else INSURE_REGION_NAME end  as ����,sum(YB_PER_NUM) as �˴�,sum(YB_PER_HEADNUM) as ��ͷ,sum(TOTAL_AMOUNT) as ��֧���� from dm_yb_md_head_sum_qc a

         where INSURE_REGION_NAME like '%����%' and WERKS_ID<>'4577' and YEAR_YB=2024 group by
                                                                    case
             when INSURE_REGION_NAME in ('�����й�����',
                                    '�������ϳ���',
                                    '������������',
                                    '������Ǯ����',
                                    '�����б�����') then '������'
             else INSURE_REGION_NAME end ;
select sum(YB_PER_NUM),sum(YB_PER_HEADNUM),sum(TOTAL_AMOUNT) from dm_yb_md_head_sum_qc a
where WERKS_ID='4577' and YEAR_YB=2024
delete from dm_yb_md_head_sum_qc where INSURE_REGION_NAME like '%����%';;
select * from dm_yb_md_head_sum_qc;

select �α���,tb2.CLASSNAME from  D_ZHYB_WRH a
                   join t_busno_class_set ts2 on a.busno = ts2.busno and ts2.classgroupno = '324'
               join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode
                   WHERE a.�������� > DATE'2023-01-01' and a.�������� < DATE'2024-01-01'
              --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
              --ȥ��ʡ����
              AND a.�α��� <> '�㽭ʡʡ����'
              and a.��ر�־ = '�����'
              and a.BUSNO not in
                  ('84577', '81517', '84590', '85062', '85063', '85066', '85070', '86402', '87001', '89059', '89063')
--     and a.BUSNO=84557
--   and a.��������<>'�����ز�'--and a.�α��� like '%������%'
              and a.JSLX <> '�����ز�'
                   group by �α���,tb2.CLASSNAME;


select �α���,��ҽ�� from d_zjys_wl2023xse group by �α���,��ҽ��;

select *
from dm_yb_md_head_sum_qc where CITY_AREA_NAME like '%����%' ;
delete from dm_yb_md_head_sum_qc where CITY_AREA_NAME like '%����%';
select CITY_AREA_NAME, INSURE_REGION_NAME
from dm_yb_md_head_sum_qc
group by CITY_AREA_NAME, INSURE_REGION_NAME;
select *
from DWB_YB_HEAD_DTL_QC;
-- delete from DWB_YB_HEAD_DTL_QC where RECEIPT_DATE>=date'2024-08-01';
-- select max(RECEIPT_DATE) from DWB_YB_HEAD_DTL_QC;
select *
from D_ZHYB_WRH;
select max(��������)
from D_ZHYB_WRH where BUSNO=84577;
select *
from D_ZHYB_WRH;