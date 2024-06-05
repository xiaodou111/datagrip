--proc_zeys_rt_syb24
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
select sfzs, ��ҵ��, ����, ��������, �α���, jyd,
       sum(case when ord > 1 then 0 else ord end) as �˴�,
       round(sum(zed), 2) as ��̸�ܶ��,
       round(sum(zed1), 2) as �ܶ��,
       sum(nvl(����ҽ��ͳ��֧��, 0)) as ����ҽ��ͳ��֧��,
       sum(nvl(����Ա����ͳ��֧��, 0)) as ����Ա����ͳ��֧��,
       sum(nvl(�����˻�֧��, 0)) as �����˻�֧��,
       sum(nvl(�󲡽��, 0)) as �󲡽��,
       sum(nvl(ҽ�Ʒ����ܶ�, 0)) as ҽ�Ʒ����ܶ�,
       sum(nvl(�����˻�֧��, 0)) as �����˻�֧��,
       sum(nvl(�ֽ���, 0)) as �ֽ���,
       round((sum(zed1) - sum(zed)) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
             2) as ����̸��ָ��,
       round(sum(zed1) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
             2) as ��ָ��
from (select bbb1.*,
             ROW_NUMBER() over (partition by ���֤��,to_char(����ʱ��, 'yyyy-mm-dd'),����,sfzs,jyd order by ����ʱ��) as ord,
             --todo  ��ͷ
             case
                 when ROW_NUMBER() over (partition by ���֤��,����,sfzs,jyd,
                     case
                         when ���� = 'ְ������ҽ�Ʊ���' and �α��� in ('�б���', '������', '·����') then '�б���'
                         when ���� = '����������ҽ�Ʊ���' and �α��� in ('�б���') then '�б���'
                         else �α��� end
                     order by ����ʱ��) > 1
                     then 0
                 else
                     ROW_NUMBER() over (partition by ���֤��,����,sfzs,jyd,
                         case
                             when ���� = 'ְ������ҽ�Ʊ���' and �α��� in ('�б���', '������', '·����') then '�б���'
                             when ���� = '����������ҽ�Ʊ���' and �α��� in ('�б���') then '�б���'
                             else �α��� end
                         order by ����ʱ��) end as ord2 --��ͷ
      from (select erp���ۺ�,sfzs,��ҵ��,���֤��,����ʱ��,����,'1' as ��������,gtje,
                   sum(case
                           when (SFZS = '1' and gtml.PZFL = '��̸Ʒ��') or
                                (SFZS = '0' and gtml.PZFL in ('��̸Ʒ��', '˫ͨ��Ʒ��'))
                               then
                               nvl(detail.����ͳ��֧����, 0) * detail.������ϸҽ������ +
                               nvl(detail.������������֧����, 0) *
                               detail.������ϸҽ������ +
                               nvl(detail.�������˵����ʻ�֧����, 0) * detail.������ϸҽ������
                           else 0
                       end) as zed, --��̸+ҩ��˫ͨ�����
                   nvl(����ҽ��ͳ��֧��, 0) as ����ҽ��ͳ��֧��,
                   nvl(����Ա����ͳ��֧��, 0) as ����Ա����ͳ��֧��,
                   nvl(�����˻�֧��, 0) as �����˻�֧��,
                   nvl(�󲡽��, 0) as �󲡽��,
                   nvl(����ҽ��ͳ��֧��, 0) + nvl(����Ա����ͳ��֧��, 0) + nvl(�����˻�֧��, 0) as zed1,
                   nvl(�ֽ���, 0) as �ֽ���,
                   nvl(�����˻�֧��, 0) as �����˻�֧��,
                   nvl(ҽ�Ʒ����ܶ�, 0) as ҽ�Ʒ����ܶ�,
                   �α���,
                   case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.�������� = s_busi.BUSNO
                     left join D_YBZD_detail detail
                               on D_ZJYS_WL2023XSE.ERP���ۺ� = detail.SALENO
                     left join d_ll_gtml gtml
                               on gtml.WAREID = detail.wareid
                                   and
                                  D_ZJYS_WL2023XSE.����ʱ�� between gtml.BEGINDATE and gtml.ENDDATE
            where trunc(����ʱ��) BETWEEN date'2024-01-01' AND date'2024-02-01'
              and not exists (select 1
                              from T_SALE_RETURN_H a
                              where a.RETSALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
            group by erp���ۺ�,
                     sfzs,
                     ���֤��,
                     ����ʱ��,
                     ����, ����ҽ��ͳ��֧��, ����Ա����ͳ��֧��, �����˻�֧��, �󲡽��,
                     �ֽ���, �����˻�֧��, ҽ�Ʒ����ܶ�, �α���,
                     case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end, gtje, ��ҵ��) bbb1) bbb
group by sfzs, ��ҵ��, ����, ��������, �α���, jyd


with base as (
    select erp���ۺ�,sfzs,��ҵ��,���֤��,����ʱ��,
           ����,��������,
           case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end  as ��ҽ��
           ,
           case when ����='ְ������ҽ�Ʊ���' then 'ҽ��' else 'ũ��' end as ҽ������,
                   sum(case
                           when (SFZS = '1' and gtml.PZFL = '��̸Ʒ��') or
                                (SFZS = '0' and gtml.PZFL in ('��̸Ʒ��', '˫ͨ��Ʒ��'))
                               then
                               nvl(detail.����ͳ��֧����, 0) * detail.������ϸҽ������ +
                               nvl(detail.������������֧����, 0) *
                               detail.������ϸҽ������ +
                               nvl(detail.�������˵����ʻ�֧����, 0) * detail.������ϸҽ������
                           else 0
                       end) as zed, --��̸+ҩ��˫ͨ�����
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
                   �α���,
                   case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.�������� = s_busi.BUSNO
                     left join D_YBZD_detail detail
                               on D_ZJYS_WL2023XSE.ERP���ۺ� = detail.SALENO
                     left join d_ll_gtml gtml
                               on gtml.WAREID = detail.wareid
                                   and
                                  D_ZJYS_WL2023XSE.����ʱ�� between gtml.BEGINDATE and gtml.ENDDATE
            where trunc(����ʱ��) BETWEEN date'2024-01-01' AND date'2024-02-01'
              and not exists (select 1
                              from T_SALE_RETURN_H a
                              where a.RETSALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
            group by erp���ۺ�,
                     sfzs,
                     ���֤��,
                     ����ʱ��,
                     ����, ����ҽ��ͳ��֧��, ����Ա����ͳ��֧��, �����˻�֧��, �󲡽��,
                     �ֽ���, �����˻�֧��, ҽ�Ʒ����ܶ�, �α���,
                     case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end, gtje, ��ҵ��,��������,�Էѷ���
)
select 2024 as ���,trunc(����ʱ��) as �����, �������� as ��ͨ�ŵ����,sfzs as �ŵ�����, 
       ��ҽ��,�α���,���� as ��������, ҽ������,'' as �˴�,'' as ��ͷ,
       '(�ܶ��-��̽���)/��ͷ' as ��ͷ����, ҽ�Ʒ����ܶ� as �ܷ���,
       zed1 as �ܶ��,
       �Էѷ��� as ҽ�Ʒ����Է��ܶ�,
       0 AS ҽ�Ʒ��������ܶ�,
       zed as ��̸���,
        ����ҽ��ͳ��֧��, �����˻�֧��, ����Ա����ͳ��֧��,�󲡽�� AS �󲡱���֧��,�����˻�֧��, �ֽ���
from base;

select ���� from d_zjys_wl2023xse group by ����;
select * from d_zjys_wl2023xse where ERP���ۺ�='2301011001123976';
select * from D_ZHYB_HZ_CYB where ��������>=date'2023-01-01' and ERP���۵���='2301011001123976';


