
-- ͳ��2023.4.1-2024.3.31 ��Ա���۴��� ���ݻ�Ա���۾��߱���Ŀ������ֶ�(��ѡ��Ա����)
select kll,count(*) from (
select membercardno,sum(g.salecount) as kll  from  t_rpt_sale_memcard_sum g where g.accdate >=date'2023-05-01' and g.ACCDATE<date'2024-04-30'
and exists(select 1 from t_busno_class_set a where classgroupno ='303' and CLASSCODE between '303100' and '303106'
            and g.BUSNO=a.BUSNO )
group by membercardno ) group by kll;



select * from S_COMPANY;

select * from t_rpt_sale_memcard_sum;

-- >100�Ŀ�������Ա��
select membercardno,sum(g.salecount) as kll,sum(NETSUM) as NETSUM  from  t_rpt_sale_memcard_sum g where g.accdate >=date'2023-05-01' and g.ACCDATE<date'2024-04-30'
and exists(select 1 from t_busno_class_set a where classgroupno ='303' and CLASSCODE between '303100' and '303106'
            and g.BUSNO=a.BUSNO )
group by membercardno having sum(g.salecount)>=100;

select  'HER2��' as syz from dual  union all select  'HER2�ͱ��' as syz from dual  union all select  '���ڸ�������' as syz from dual  union all select  '����һ������' as syz from dual  union all select  '���ڶ�������' as syz from dual  union all select  '���ڷΰ�' as syz from dual
