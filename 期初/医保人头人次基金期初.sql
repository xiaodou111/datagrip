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
select count(*) from DM_YB_MD_HEAD_SUM_QC  where RECEIPT_DATE BETWEEN '2023-01-01' AND '2023-12-31';
delete from DM_YB_MD_HEAD_SUM_QC where CITY_AREA_NAME not in
('�������ϳ���','��������ƽ��','�������ຼ��','�������б���','�����н�����','�����й�����','������ͩ®��','�����д�����','�����б�����','��������ɽ��','������������','������Ǯ����')
-- and RECEIPT_DATE >= '2024-01-01'
insert into DM_YB_MD_HEAD_SUM_QC select * from DM_YB_MD_HEAD_SUM_QC AS OF TIMESTAMP SYSDATE - (1/24);
insert into  DM_YB_MD_HEAD_SUM_QC(YEAR_YB, RECEIPT_DATE, WERKS_ID, MD_TYPE, CITY_AREA_NAME, INSURE_REGION_NAME, INSURANCE_TYPE, PER_YB_TYPE,
       YB_PER_NUM, YB_PER_HEADNUM, HEAD_FUND_AMOUNT, TOTAL_AMOUNT, TOTAL_QUOTA, PERSONAL_PAY_AMOUNT, SELF_CHARGE_AMOUNT,
       GT_QUOTA, OVERALL_PAY, CURRENT_ACCOUNT_PAY, PUBLIC_FUND_PAY, ILLNESS_SUBSIDY_AMOUNT, HISTORY_ACCOUNT_PAY,
       PERSONAL_CASH_AMOUNT)
with base as (
  select d_zjys_wl2023xse.erp���ۺ�,sfzs,��ҵ��,d_zjys_wl2023xse.���֤��,����ʱ��,
           ����,��������,
            decode(��ҽ��,'������','��������','�б���','��������',��ҽ��) as ��ҽ��,
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
                   decode(d_zjys_wl2023xse.�α���,'�б���','��·�Ʊ���',�α���) as �α���
--                    case when ��ҽ�� = '�б���' then '������' else ��ҽ�� end jyd
            from d_zjys_wl2023xse
                     left join s_busi
                               on d_zjys_wl2023xse.�������� = s_busi.BUSNO
                     left join v_saleno_zed on d_zjys_wl2023xse.ERP���ۺ� = v_saleno_zed.erp���ۺ�
            where
--                 trunc(����ʱ��) BETWEEN date'2024-01-01' AND date'2024-07-31'
                trunc(����ʱ��) BETWEEN date'2023-01-01' AND date'2023-12-31'
--                 and ��ҽ�� not in ('�������ϳ���','��������ƽ��','�������ຼ��','�������б���','�����н�����','�����й�����','������ͩ®��','�����д�����','�����б�����','��������ɽ��','������������','������Ǯ����')
                and ��ҽ�� in ('������','�ٺ���','�ɾ���','��̨��','������','�б���','������','����','����','·����','������')
--                 and s_busi.ZMDZ1=81499
--                and d_zjys_wl2023xse.�������� in ('85027','85034','85036','85037','85039','85040','85041','85042','85064','85067','85069','85074','85083','85084','89074','89075')
              and not exists (select 1 from T_SALE_RETURN_H a where a.RETSALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
              and not exists (select 1 from T_SALE_RETURN_H a2 where a2.SALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
),
    base2 as (
    select null as ���,trunc(����ʱ��) as �����, �������� as ��ͨ�ŵ����,sfzs as �ŵ�����,
       ��ҽ��,�α���,���� as ��������, ҽ������,
       ROW_NUMBER() over (partition by ���֤��,to_char(����ʱ��, 'yyyy-mm-dd'),SFZS,����,��ҽ�� order by ����ʱ��) as ord,--�˴�
--       case when nvl(xzrt.IDENTITY_NO,'0')='0' then 0 else
       case when ROW_NUMBER() OVER (PARTITION BY
                 CASE
                     WHEN ���� = 'ְ������ҽ�Ʊ���' and  �α��� IN ('������','·����','�б���')
                         THEN '�б���'
                     WHEN ���� = '����������ҽ�Ʊ���' and �α��� IN ('�б���') THEN '�б���'
                     ELSE �α���
                     END,
                 ��ҽ�� ,
                 ���֤��,���� ORDER BY ����ʱ�� ASC) > 1
                     then 0
                 else
                     1 end  as ord2, --��ͷ
--                      ROW_NUMBER() OVER (PARTITION BY
--                  CASE
--                      WHEN ���� = 'ְ������ҽ�Ʊ���' and  �α��� IN ('������','·����','�б���')
--                          THEN '�б���'
--                      WHEN ���� = '����������ҽ�Ʊ���' and �α��� IN ('�б���') THEN '�б���'
--                      ELSE �α���
--                      END,
--                   ��ҽ�� ,
--                  ���֤��,���� ORDER BY ����ʱ�� ASC) end   as ord2,--��ͷ
       '(�ܶ��-��̽���)/��ͷ' as ��ͷ����, ҽ�Ʒ����ܶ� as �ܷ���,
       zed1 as �ܶ��,
       �Էѷ��� as ҽ�Ʒ����Է��ܶ�,
       0 AS ҽ�Ʒ��������ܶ�,
       zed as ��̸���,
        ����ҽ��ͳ��֧��, �����˻�֧��, ����Ա����ͳ��֧��,�󲡽�� AS �󲡱���֧��,�����˻�֧��, �ֽ���
from base
-- left join  DWB_YB_HEAD_DTL_QC  xzrt
-- on ���֤�� = xzrt.IDENTITY_NO
-- and trunc(����ʱ��) = trunc(xzrt.RECEIPT_DATE)
-- and case when ���� = 'ְ������ҽ�Ʊ���' then '0' else '1' end =case when xzrt.PER_YB_TYPE ='ҽ��' then 0 else 1 end
-- and to_char(��������) = 8||to_char(xzrt.WERKS_ID)
)
select 2023 as ���, to_char(�����,'YYYY-MM-DD'), substr(��ͨ�ŵ����,2,4), �ŵ�����, ��ҽ��, �α���, ��������, ҽ������,
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
group by �����, substr(��ͨ�ŵ����,2,4), �ŵ�����, ��ҽ��, �α���, ��������, ҽ������;

--������ͷ�����ܱ�
MERGE INTO DM_YB_MD_HEAD_SUM_QC T1
USING
(
select to_char(RECEIPT_DATE,'YYYY-MM-DD') as RECEIPT_DATE,WERKS_ID,PER_YB_TYPE,count(*) as sl from DWB_YB_HEAD_DTL_QC
-- where CITY_AREA_NAME like '%·��%' and YEAR_YB=2023 and PER_YB_TYPE='ҽ��'
                                                               group by to_char(RECEIPT_DATE,'YYYY-MM-DD'),WERKS_ID,PER_YB_TYPE
)  T2
ON ( T1.RECEIPT_DATE=T2.RECEIPT_DATE and t1.WERKS_ID=t2.WERKS_ID and t1.PER_YB_TYPE=t2.PER_YB_TYPE)
WHEN MATCHED THEN
UPDATE SET T1.YB_PER_HEADNUM= T2.sl;
--ûƥ�䵽��������ͷ��0,�����Ѻ��ݵĸ���,��Ҫ��ˢ
UPDATE DM_YB_MD_HEAD_SUM_QC T1
SET T1.YB_PER_HEADNUM = 0
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        select to_char(RECEIPT_DATE, 'YYYY-MM-DD') as RECEIPT_DATE, WERKS_ID, PER_YB_TYPE, count(*) as sl
        from DWB_YB_HEAD_DTL_QC
--         where CITY_AREA_NAME like '%·��%'
--           and YEAR_YB = 2023
--           and PER_YB_TYPE = 'ҽ��'
        group by to_char(RECEIPT_DATE, 'YYYY-MM-DD'), WERKS_ID, PER_YB_TYPE
    ) T2
    WHERE T1.RECEIPT_DATE = T2.RECEIPT_DATE AND T1.WERKS_ID = T2.WERKS_ID AND T1.PER_YB_TYPE = T2.PER_YB_TYPE
);


update dm_yb_md_head_sum_qc set RECEIPT_DATE=TO_CHAR(
           TO_DATE(RECEIPT_DATE, 'DD-MON-RR'),
           'YYYY-MM-DD'
       );
-- �α����б���Ҫ��������Ϊ��·�Ʊ���
-- ��ҽ��̨���б�����̨���н���������Ϊ��������
select count(*) from DWB_YB_HEAD_DTL_QC where (CITY_AREA_NAME like '%̨��%' or CITY_AREA_NAME='��������');
delete from DWB_YB_HEAD_DTL_QC where CITY_AREA_NAME like '%̨��%';
--�ڳ���ϸ
insert into DWB_YB_HEAD_DTL_QC(TENANT_ID, YEAR_YB, WERKS_ID, RECEIPT_DATE, ORDER_NO, IDENTITY_NO, PER_YB_TYPE
                               , MD_TYPE,
                               CITY_AREA_NAME)
select tenant_id, year_yb, substr(to_number(��������),2,4), ����ʱ��, ERP���ۺ�, ���֤��, case when ����='ְ������ҽ�Ʊ���' then 'ҽ��' else 'ũ��' end, �ŵ�����, ��ҽ��
from (
select 'rrt' as tenant_id,2024 as year_yb,a.��������,a.����ʱ��,a.ERP���ۺ�,a.���֤��,a.����,tb22.CLASSNAME as �ŵ�����,
       decode(TB2.CLASSNAME,'̨���б���','��������','̨���н�����','��������',TB2.CLASSNAME) as ��ҽ��,ROW_NUMBER() OVER (PARTITION BY
                 CASE
                     WHEN a.���� = 'ְ������ҽ�Ʊ���' and  a.�α��� IN ('������','·����','�б���')
                         THEN '�б���'
                     WHEN a.���� = '����������ҽ�Ʊ���' and a.�α��� IN ('�б���') THEN '�б���'
                     ELSE a.�α���
                     END,
                  decode(TB2.CLASSNAME,'̨���б���','��������','̨���н�����','��������',TB2.CLASSNAME),
                 A.���֤��,A.���� ORDER BY A.����ʱ�� ASC) RN from d_zjys_wl2023xse a
JOIN T_BUSNO_CLASS_SET TS ON to_char(A.��������) = TS.BUSNO AND TS.CLASSGROUPNO = '303'
               JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
          AND TB.CLASSCODE IN ('303100', '303101', '303102')
               JOIN T_BUSNO_CLASS_SET TS2 ON to_char(A.��������) = TS2.BUSNO AND TS2.CLASSGROUPNO = '324'
               JOIN T_BUSNO_CLASS_BASE TB2 ON TS2.CLASSGROUPNO = TB2.CLASSGROUPNO AND TS2.CLASSCODE = TB2.CLASSCODE
               JOIN T_BUSNO_CLASS_SET TS22 ON to_char(A.��������) = TS22.BUSNO AND TS22.CLASSGROUPNO = '305'
               JOIN T_BUSNO_CLASS_BASE TB22 ON TS22.CLASSGROUPNO = TB22.CLASSGROUPNO AND TS22.CLASSCODE = TB22.CLASSCODE
 WHERE A.����ʱ�� > date'2024-01-01' and  A.����ʱ��<date'2024-08-01'
        AND A.�α��� IN
           ('����','�ɾ���','������','������','�б���','��̨��','�ٺ���','������','·����')
AND EXISTS(SELECT 1
                   FROM (SELECT A.SALENO
                         FROM D_YB_SPXX_DETAIL A
                                  JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
                                  JOIN T_BUSNO_CLASS_BASE TB
                                       ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
                         WHERE TB.CLASSCODE = '30510'
                           AND NVL(ͳ��֧����, 0) + NVL(���˵����ʻ�֧����, 0) + NVL(��������֧����, 0) <> 0
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1
                                          FROM D_LL_GTML GT
                                          WHERE GT.WAREID = A.WAREID
                                            AND A.ACCDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
                                            AND GT.PZFL IN ('˫ͨ��Ʒ��', '��̸Ʒ��'))
                         UNION ALL
                         SELECT A.SALENO
                         FROM D_YB_SPXX_DETAIL A
                                  JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
                                  JOIN T_BUSNO_CLASS_BASE TB
                                       ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
                         WHERE TB.CLASSCODE = '30511'
                           AND NVL(ͳ��֧����, 0) + NVL(���˵����ʻ�֧����, 0) + NVL(��������֧����, 0) <> 0
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
                           AND NOT EXISTS(SELECT 1
                                          FROM D_LL_GTML GT
                                          WHERE GT.WAREID = A.WAREID
                                            AND A.ACCDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
                                            AND GT.PZFL IN ('��̸Ʒ��'))) aaa
                   where aaa.SALENO = a.ERP���ۺ�)) where rn=1;

