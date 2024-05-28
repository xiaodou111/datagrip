drop table d_rrtprod_memorder;
create table d_rrtprod_memorder
(
order_date date,                           -- ��������
    create_dtme date,-- ����ʱ��
    tml_num_id varchar2(100),-- ���۵���
    type_num_id varchar2(100),-- ���۵����ͣ�1
    source_tml_num_id varchar2(100),-- ԭ���۵���
    so_from_type  varchar2(100),-- ������Դ(17
    item_num_id number,-- ��Ʒ����
    pro_code_old varchar2(100),-- ����Ʒ����
    item_name  varchar2(100),-- ��Ʒ����
    batch_id   varchar2(100),-- ����
    deduct_amount number(14,4),-- ���۽��
    retail_price  number(14,4),-- ԭ���ۣ����ۼ�
    retail_amount number(14,4),-- ԭ���
    trade_price  number(14,4),-- �ۼۣ���˰��
    qty   number(14,4),-- ����
    tax_rate number,-- ˰�ʣ����
    f_amount  number(14,4),-- ���۽��
    expiry_date date,-- Ч��
    series  varchar2(100),-- ���۵��к�
    cort_num_id  varchar2(100),-- ��˾����
    sub_unit_num_id varchar2(100),
    old_sub_unit_id  varchar2(100),
    vip_no varchar2(100), -- ��Ա���
    CREATE_USER_ID varchar2(100) -- ����Ա����
)
select order_date as ��������, create_dtme as ����ʱ��, tml_num_id as ���۵���, type_num_id as ���۵�����,
       source_tml_num_id as ԭ���۵���, so_from_type as ������Դ, item_num_id as ��Ʒ����, pro_code_old as ����Ʒ����,
       item_name as ��Ʒ����, batch_id as  ����, deduct_amount as ���۽��, retail_price as ԭ�������ۼ�, retail_amount as ԭ���,
       trade_price as �ۼ�, qty as ����, tax_rate as ˰��, f_amount as ���۽��,
       expiry_date as Ч��, series as ���۵��к� , cort_num_id as ��˾����, sub_unit_num_id ,
       old_sub_unit_id , vip_no as ��Ա���, CREATE_USER_ID as  ����Ա����
from d_rrtprod_memorder where sub_unit_num_id in ('4507','4506','3047','3010','1559','3062','3211','3311','3612','4048','5021')
-- and sub_unit_num_id='3047' and pro_code_old='10114843,10115183,81003997'
;

with new  as (
select order_date,sub_unit_num_id,tml_num_id from d_rrtprod_memorder
where sub_unit_num_id in ('3009','1317','3047','3010','1559','3062','3211','3311','3612','4048','5021')
and order_date between date'2024-05-26' and date'2024-05-27'
 group by order_date,sub_unit_num_id,tml_num_id),

    old as (
select h.BUSNO,h.ACCDATE,h.SALENO
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
where h.BUSNO in (83009,81317,83047,83010,81559,83062,83211,83311,83612,84048,85021)
and h.ACCDATE between date'2024-05-26' and date'2024-05-27'
group by h.BUSNO,h.ACCDATE,h.SALENO
    ),
    new_hz as (
        select order_date,sub_unit_num_id,count(tml_num_id) sumsl from new
                                                                group by order_date,sub_unit_num_id
    ),
    old_hz as (
        select BUSNO,ACCDATE,count(SALENO) sumsl from old group by BUSNO,ACCDATE
    ),
    re as (
select a.BUSNO, ACCDATE, nvl(a.sumsl,0) as ��ϵͳ���۵���, order_date, sub_unit_num_id, nvl(b.sumsl,0) as ��ϵͳ����,
       case  when  nvl(a.sumsl,0)=0 then 0 else
           case when nvl(b.sumsl,0)>=50 then 1 else
       round(nvl(b.sumsl,0)/a.sumsl,3) end end as bl
from old_hz a
    left join new_hz b on substr(a.BUSNO,2,4)=b.sub_unit_num_id
--1317  --�㳡��·
    --83009
and a.ACCDATE=b.order_date
order by a.BUSNO,a.ACCDATE)
select q.BUSNO, s.ORGNAME, q.ACCDATE, q.��ϵͳ���۵���, q.order_date, q.sub_unit_num_id, q.��ϵͳ����, q.bl
from re q
  left join s_busi s on q.BUSNO=s.BUSNO;

select * from d_rrtprod_memorder;

select h.BUSNO,h.ACCDATE,h.STARTTIME,h.SALENO,d.WAREID,w.WARENAME,d.WAREQTY,d.NETPRICE
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
where h.BUSNO in (84507,84506,83047,83010,81559,83062,83211,83311,83612,84048,85021)
and h.ACCDATE between date'2024-05-26' and date'2024-05-27'

select busno,ORGNAME from S_BUSI where ORGNAME like '%����%';
;
select * from t_sale_d where SALENO='2405263047173362';
select * from ;

4507,4506,3047,3010,1559,3062,3211,3311,3612,4048,5021

'4507','4506','3047','3010','1559','3062','3211','3311','3612','4048','5021'


select * from t_sale_h;

delete from  d_rrtprod_memorder;