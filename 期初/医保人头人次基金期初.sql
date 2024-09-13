--proc_zeys_rt_syb24
    call proc_zeys_rt24
--�˴���a2,��������a1
select * from dm_yb_md_head_sum_qc;
-- ��� 2023||2024	year_yb
-- �����-yyyy-mm-dd	receipt_date
-- ��ͨ�ŵ����	werks_id
-- �ŵ�����  ����||ҩ��	md_type
-- ��ҽ��	city_area_name
-- �α���	insure_region_name
-- ��������	insurance_type
-- ҽ������  ũ��||ҽ��	per_yb_type
-- �˴�	yb_per_num
-- ��ͷ	yb_per_headnum
-- ��ͷ����	head_fund_amount
-- �ܷ���	total_amount
-- �ܶ��	total_quota
-- ҽ�Ʒ����Է��ܶ�	personal_pay_amount
-- ҽ�Ʒ��������ܶ�	self_charge_amount
-- ��̸���	gt_quota
-- ����ҽ��ͳ��֧��	overall_pay
-- �����˻�֧��	current_account_pay
-- ����Ա����ͳ��֧��	public_fund_pay
-- �󲡱���֧��	illness_subsidy_amount
-- �����˻�֧��	history_account_pay
-- �ֽ�֧��	personal_cash_amount

select CITY_AREA_NAME from DM_YB_MD_HEAD_SUM_QC group by CITY_AREA_NAME;
delete from DM_YB_MD_HEAD_SUM_QC;
select count(*) from DM_YB_MD_HEAD_SUM_QC  where RECEIPT_DATE BETWEEN '2023-01-01' AND '2023-12-31';
insert into DM_YB_MD_HEAD_SUM_QC select * from DM_YB_MD_HEAD_SUM_QC AS OF TIMESTAMP SYSDATE - (1/24);
insert into  DM_YB_MD_HEAD_SUM_QC
with base as (
  select d_zjys_wl2023xse.erp���ۺ�,sfzs,��ҵ��,d_zjys_wl2023xse.���֤��,����ʱ��,
           ����,��������,
           case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end  as ��ҽ��,
           case when ����='ְ������ҽ�Ʊ���' then 'ҽ��' else 'ũ��' end as ҽ������,
           v_saleno_zed.zed,--��̸���

                   nvl(�Էѷ���,0) as �Էѷ���,
                   nvl(����ҽ��ͳ��֧��, 0) as ����ҽ��ͳ��֧��,
                   nvl(����Ա����ͳ��֧��, 0) as ����Ա����ͳ��֧��,
                   nvl(�����˻�֧��, 0) as �����˻�֧��,
                   nvl(�󲡽��, 0) as �󲡽��,
                   nvl(����ҽ��ͳ��֧��, 0) + nvl(����Ա����ͳ��֧��, 0) + nvl(�����˻�֧��, 0) as zed1,
                   nvl(�ֽ���, 0) as �ֽ���,
                   nvl(�����˻�֧��, 0) as �����˻�֧��,
                   nvl(ҽ�Ʒ����ܶ�, 0) as ҽ�Ʒ����ܶ�,
                   0 as ҽ�Ʒ��������ܶ�,
                   d_zjys_wl2023xse.�α���,
                   case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.�������� = s_busi.BUSNO
                     left join v_saleno_zed on d_zjys_wl2023xse.ERP���ۺ� = v_saleno_zed.erp���ۺ�
            where
                trunc(����ʱ��) BETWEEN date'2024-01-01' AND date'2024-07-31'
                and s_busi.ZMDZ1=81499
--                and d_zjys_wl2023xse.�������� in ('85027','85034','85036','85037','85039','85040','85041','85042','85064','85067','85069','85074','85083','85084','89074','89075')
              and not exists (select 1 from T_SALE_RETURN_H a where a.RETSALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
              and not exists (select 1 from T_SALE_RETURN_H a2 where a2.SALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
),
    base2 as (
    select 2023 as ���,trunc(����ʱ��) as �����, �������� as ��ͨ�ŵ����,sfzs as �ŵ�����,
       ��ҽ��,�α���,���� as ��������, ҽ������,
       ROW_NUMBER() over (partition by ���֤��,to_char(����ʱ��, 'yyyy-mm-dd'),����,sfzs,jyd order by ����ʱ��) as ord,--�˴�
       case
                 when ROW_NUMBER() over (partition by ���֤��,����,sfzs,��ҽ��,
                     case
                         when ���� = 'ְ������ҽ�Ʊ���' and �α��� in ('�б���', '������', '·����') then '�б���'
                         when ���� = '����������ҽ�Ʊ���' and �α��� in ('�б���') then '�б���'
                         else �α��� end
                     order by ����ʱ��) > 1
                     then 0
                 else
                     ROW_NUMBER() over (partition by ���֤��,����,sfzs,��ҽ��,
                         case
                             when ���� = 'ְ������ҽ�Ʊ���' and �α��� in ('�б���', '������', '·����') then '�б���'
                             when ���� = '����������ҽ�Ʊ���' and �α��� in ('�б���') then '�б���'
                             else �α��� end
                         order by ����ʱ��) end as ord2,--��ͷ
       '(�ܶ��-��̽���)/��ͷ' as ��ͷ����, ҽ�Ʒ����ܶ� as �ܷ���,
       zed1 as �ܶ��,
       �Էѷ��� as ҽ�Ʒ����Է��ܶ�,
       0 AS ҽ�Ʒ��������ܶ�,
       zed as ��̸���,
        ����ҽ��ͳ��֧��, �����˻�֧��, ����Ա����ͳ��֧��,�󲡽�� AS �󲡱���֧��,�����˻�֧��, �ֽ���
from base)
select 2024 as ���, �����, ��ͨ�ŵ����, �ŵ�����, ��ҽ��, �α���, ��������, ҽ������,
       --ord,
       sum(case when ord > 1 then 0 else ord end) as �˴�,
       sum(ord2) as ��ͷ,
       case when sum(ord2)=0 then 0 else
       (sum(�ܶ��)-sum(��̸���))/sum(ord2) end as ��ͷ����,

       sum(�ܷ���), sum(�ܶ��),
       sum(ҽ�Ʒ����Է��ܶ�), sum(ҽ�Ʒ��������ܶ�), sum(��̸���), sum(����ҽ��ͳ��֧��), sum(�����˻�֧��), sum(����Ա����ͳ��֧��), sum(�󲡱���֧��),
       sum(�����˻�֧��), sum(�ֽ���)
from base2
-- where �����=date'2024-06-04' and ��ҽ�� like'%������%'
group by �����, ��ͨ�ŵ����, �ŵ�����, ��ҽ��, �α���, ��������, ҽ������;

update dm_yb_md_head_sum_qc set RECEIPT_DATE=TO_CHAR(
           TO_DATE(RECEIPT_DATE, 'DD-MON-RR'),
           'YYYY-MM-DD'
       );


