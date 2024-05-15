
-- 统计2023.4.1-2024.3.31 会员销售次数 根据会员销售决策报表的客流量字段(勾选会员卡号)
select kll,count(*) from (
select membercardno,sum(g.salecount) as kll  from  t_rpt_sale_memcard_sum g where g.accdate >=date'2023-05-01' and g.ACCDATE<date'2024-04-30'
and exists(select 1 from t_busno_class_set a where classgroupno ='303' and CLASSCODE between '303100' and '303106'
            and g.BUSNO=a.BUSNO )
group by membercardno ) group by kll;



select * from S_COMPANY;

select * from t_rpt_sale_memcard_sum;

-- >100的客流量会员号
select membercardno,sum(g.salecount) as kll,sum(NETSUM) as NETSUM  from  t_rpt_sale_memcard_sum g where g.accdate >=date'2023-05-01' and g.ACCDATE<date'2024-04-30'
and exists(select 1 from t_busno_class_set a where classgroupno ='303' and CLASSCODE between '303100' and '303106'
            and g.BUSNO=a.BUSNO )
group by membercardno having sum(g.salecount)>=100;

select  'HER2阳' as syz from dual  union all select  'HER2低表达' as syz from dual  union all select  '早期辅助治疗' as syz from dual  union all select  '晚期一线治疗' as syz from dual  union all select  '晚期二线治疗' as syz from dual  union all select  '晚期肺癌' as syz from dual
