with a1 as (
select ERP���۵���,tb.CLASSNAME as �ŵ�����,����,a.BUSNO,s.ORGNAME,�������� as ĩ����������,���֤��,�α���,EXT_CHAR04 as �α���λ,
       case when �α���Ա��� like '%����%' then 'ũ��' else 'ҽ��' end as  �α���Ա���,
       h.MEMBERCARDNO as ��Ա����,mem.MOBILE as �ֻ���,mem.CARDHOLDER as �ֿ���,
       row_number() over (partition by tb.CLASSNAME,���֤��,�α���,case when �α���Ա��� like '%����%' then 'ũ��' else 'ҽ��' end,
           EXT_CHAR04 order by �������� desc ) rn
from d_zhyb_hz_cyb a
left join s_busi s on a.BUSNO=s.busno
left join t_sale_h h on a.ERP���۵���=h.saleno
left join t_memcard_reg mem on h.MEMBERCARDNO=mem.MEMCARDNO
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode
where ��������>=trunc(sysdate)-120
and tb.CLASSCODE in ('30510','30511')),
a2 as ( select
            case when rn=1 and ĩ���������� between trunc(sysdate)-60 and trunc(sysdate)-30 then '30-60��δ�ط�'
             when rn=1 and ĩ���������� between trunc(sysdate)-90 and trunc(sysdate)-60 then '60-90��δ�ط�'
             when rn=1 and ĩ���������� between trunc(sysdate)-120 and trunc(sysdate)-90 then '90-120��δ�ط�' else '0' end as δ�ط�����,
            a1.* from a1)
select *
from a2 where δ�ط����� in('30-60��δ�ط�','60-90��δ�ط�','90-120��δ�ط�');