--todo ������ͷ���(�α���Ϊ�����ҩ����������ͷ��ʱ��ϲ�)
     select �ŵ�����,qy,sum(zed1) as �ܶ�� ,sum(zed) as ��̸�ܶ��,count(���֤��) as ��ͷ from (
    select a.ERP���ۺ�,a.����ʱ��,a.��������,a.���֤��,a.����,a.�α���, nvl(����ҽ��ͳ��֧��, 0) + nvl(����Ա����ͳ��֧��, 0) + nvl(�����˻�֧��, 0) as zed1,
           tb2.CLASSNAME as qy,TB22.CLASSNAME as �ŵ�����,
           case
                when (SFZS = '1' and gtml.PZFL = '��̸Ʒ��') or
                                (SFZS = '0' and gtml.PZFL in ('��̸Ʒ��', '˫ͨ��Ʒ��'))
                               then
                               nvl(detail.ͳ��֧����,0)+nvl(detail.��������֧����,0)+nvl(detail.���˵����ʻ�֧����,0)
                           else 0
                       end as zed,
           ROW_NUMBER() OVER (PARTITION BY
                CASE
                     WHEN a.����='ְ������ҽ�Ʊ���' and TB2.CLASSCODE IN ('324331001', '324331002','324331003','324331004') THEN '324331001'
                     WHEN a.����='����������ҽ�Ʊ���' and TB2.CLASSCODE IN ('324331001', '324331002') THEN '324331002'
                     ELSE TB2.CLASSCODE
                     END,
                  case when a.�α���='331081' then '30510' else TB22.CLASSCODE end ,
                 A.���֤��,A.���� ORDER BY A.����ʱ�� )rn  from d_zjys_wl2023xse a
                 left join d_ybsp_jsmx detail
                   on a.ERP���ۺ� = detail.SALENO
                  left join d_ll_gtml gtml
                   on gtml.WAREID = detail.wareid and a.����ʱ�� between gtml.BEGINDATE and gtml.ENDDATE
    JOIN T_BUSNO_CLASS_SET TS ON A.�������� = TS.BUSNO AND TS.CLASSGROUPNO = '303'
    JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
    AND TB.CLASSCODE IN ('303100', '303101', '303102')
    JOIN T_BUSNO_CLASS_SET TS2 ON A.�������� = TS2.BUSNO AND TS2.CLASSGROUPNO = '324'
    JOIN T_BUSNO_CLASS_BASE TB2 ON TS2.CLASSGROUPNO = TB2.CLASSGROUPNO AND TS2.CLASSCODE = TB2.CLASSCODE
    JOIN T_BUSNO_CLASS_SET TS22 ON A.�������� = TS22.BUSNO AND TS22.CLASSGROUPNO = '305'
    JOIN T_BUSNO_CLASS_BASE TB22 ON TS22.CLASSGROUPNO = TB22.CLASSGROUPNO AND TS22.CLASSCODE = TB22.CLASSCODE
    WHERE A.����ʱ�� >= DATE'2023-01-01' and A.����ʱ��<=date'2024-01-01'
  AND A.�α��� ='������'
    AND EXISTS(SELECT 1
FROM (SELECT A.SALENO
FROM d_ybsp_jsmx A
         JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
         JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
WHERE TB.CLASSCODE = '30510'
  AND NVL(ͳ��֧����, 0) + NVL(���˵����ʻ�֧����, 0) + NVL(��������֧����, 0) <> 0
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1
FROM D_LL_GTML GT
WHERE GT.WAREID = A.WAREID
  AND A.RECEIPTDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
  AND GT.PZFL IN ('˫ͨ��Ʒ��', '��̸Ʒ��'))
UNION ALL
SELECT A.SALENO
FROM d_ybsp_jsmx A
         JOIN T_BUSNO_CLASS_SET TS ON A.BUSNO = TS.BUSNO AND TS.CLASSGROUPNO = '305'
         JOIN T_BUSNO_CLASS_BASE TB ON TS.CLASSGROUPNO = TB.CLASSGROUPNO AND TS.CLASSCODE = TB.CLASSCODE
WHERE TB.CLASSCODE = '30511'
  AND NVL(ͳ��֧����, 0) + NVL(���˵����ʻ�֧����, 0) + NVL(��������֧����, 0) <> 0
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T1 WHERE T1.SALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1 FROM T_SALE_RETURN_H T2 WHERE T2.RETSALENO = A.SALENO)
  AND NOT EXISTS(SELECT 1
FROM D_LL_GTML GT
WHERE GT.WAREID = A.WAREID
  AND A.RECEIPTDATE BETWEEN GT.BEGINDATE AND GT.ENDDATE
  AND GT.PZFL IN ('��̸Ʒ��'))) aaa where aaa.SALENO=a.ERP���ۺ�  ))
WHERE RN = 1 group by qy,�ŵ�����;

--�ڳ�����㷨
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
                trunc(����ʱ��) BETWEEN date'2023-01-01' AND date'2023-12-31'
--                and d_zjys_wl2023xse.�������� in ('85027','85034','85036','85037','85039','85040','85041','85042','85064','85067','85069','85074','85083','85084','89074','89075')
              and not exists (select 1 from T_SALE_RETURN_H a where a.RETSALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
              and not exists (select 1 from T_SALE_RETURN_H a2 where a2.SALENO = D_ZJYS_WL2023XSE.ERP���ۺ�)
),
    base2 as (
    select 2024 as ���,trunc(����ʱ��) as �����, �������� as ��ͨ�ŵ����,sfzs as �ŵ�����,
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
select 2023 as ���, �����, ��ͨ�ŵ����, �ŵ�����, ��ҽ��, �α���, ��������, ҽ������,
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