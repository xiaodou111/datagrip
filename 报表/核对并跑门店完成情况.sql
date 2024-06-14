drop table d_rrtprod_memorder;
create table d_rrtprod_memorder
(
    order_date        date,          -- ��������
    create_dtme       date,-- ����ʱ��
    tml_num_id        varchar2(100),-- ���۵���
    type_num_id       varchar2(100),-- ���۵����ͣ�1
    source_tml_num_id varchar2(100),-- ԭ���۵���
    so_from_type      varchar2(100),-- ������Դ(17
    item_num_id       number,-- ��Ʒ����
    pro_code_old      varchar2(100),-- ����Ʒ����
    item_name         varchar2(100),-- ��Ʒ����
    batch_id          varchar2(100),-- ����
    deduct_amount     number(14, 4),-- ���۽��
    retail_price      number(14, 4),-- ԭ���ۣ����ۼ�
    retail_amount     number(14, 4),-- ԭ���
    trade_price       number(14, 4),-- �ۼۣ���˰��
    qty               number(14, 4),-- ����
    tax_rate          number,-- ˰�ʣ����
    f_amount          number(14, 4),-- ���۽��
    expiry_date       date,-- Ч��
    series            varchar2(100),-- ���۵��к�
    cort_num_id       varchar2(100),-- ��˾����
    sub_unit_num_id   varchar2(100),
    old_sub_unit_id   varchar2(100),
    vip_no            varchar2(100), -- ��Ա���
    CREATE_USER_ID    varchar2(100),  -- ����Ա����
    MANAGER_CODE      varchar2(50) --�ŵ������
)
select order_date as ��������, create_dtme as ����ʱ��, tml_num_id as ���۵���, type_num_id as ���۵�����,
       source_tml_num_id as ԭ���۵���, so_from_type as ������Դ, item_num_id as ��Ʒ����, pro_code_old as ����Ʒ����,
       item_name as ��Ʒ����, batch_id as ����, deduct_amount as ���۽��, retail_price as ԭ�������ۼ�,
       retail_amount as ԭ���,
       trade_price as �ۼ�, qty as ����, tax_rate as ˰��, f_amount as ���۽��,
       expiry_date as Ч��, series as ���۵��к�, cort_num_id as ��˾����, sub_unit_num_id,
       old_sub_unit_id, vip_no as ��Ա���, CREATE_USER_ID as ����Ա����
from d_rrtprod_memorder
where sub_unit_num_id in ('4507', '4506', '3047', '3010', '1559', '3062', '3211', '3311', '3612', '4048', '5021')
select * from d_rrtprod_memorder where order_date=trunc(sysdate-1);
-- and sub_unit_num_id='3047' and pro_code_old='10114843,10115183,81003997'
;


-- select * from D_RRT_QY_COMPID_BUSNO;


--todo ������ǰһ�������
--������5.29�����
with new as (select order_date, MANAGER_CODE, tml_num_id
             from d_rrtprod_memorder
             where sub_unit_num_id in
                   (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select BUSNO from D_BP_BUSNO))
               and order_date >= trunc(sysdate - 2) and order_date<trunc(sysdate)
             group by order_date, MANAGER_CODE, tml_num_id),

     old as (select s.ZMDZ1, h.ACCDATE, h.SALENO
             from t_sale_h h
                      join t_sale_d d on h.SALENO = d.SALENO
                      join t_ware_base w on d.WAREID = w.WAREID
                      left join s_busi s on h.BUSNO = s.BUSNO
             where s.busno in (select BUSNO from D_BP_BUSNO)
               and h.ACCDATE >= trunc(sysdate - 2) and h.accdate<trunc(sysdate)
               and not exists(select 1
                              from t_sale_pay p
                              where p.saleno = h.saleno and p.paytype in
                                                            ('Z022', 'Z025', 'Z027', 'Z030', 'Z032', 'Z034', 'Z077',
                                                             'Z081', 'Z098', 'Z100', 'Z101', 'Z084', 'Z102', 'Z107')
                                and p.netsum <> 0)
               and not exists(select 1 from T_SALE_RETURN_H th where th.SALENO=h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_H th2 where th2.RETSALENO=h.SALENO)
               and not exists(select 1 from t_internal_sale_h ngd where SHIFTDATE>=date'2024-05-20' and ngd.NEWSALENO=h.SALENO)
               and not exists(select 1 from d_bp_exclude_sale exc where exc.SALENO=h.SALENO)

             group by s.ZMDZ1, h.ACCDATE, h.SALENO),
     new_hz as (select order_date, MANAGER_CODE, count(tml_num_id) sumsl
                from new
                group by order_date, MANAGER_CODE),
     old_hz as (select ZMDZ1, ACCDATE, count(SALENO) sumsl from old group by ZMDZ1, ACCDATE),
     re as (select a.ZMDZ1, ACCDATE, nvl(a.sumsl, 0) as ��ϵͳ���۵���, order_date, MANAGER_CODE,
                   nvl(b.sumsl, 0) as ��ϵͳ����,
                   case
                       when nvl(a.sumsl, 0) = 0 then 0
                       else
                           case
                               when nvl(b.sumsl, 0) >= 50 then 1
                               else
                            case when  b.sumsl>a.sumsl then 1 else
                                   round(nvl(b.sumsl, 0) / a.sumsl, 3) end end end as bl
            from old_hz a
                     left join new_hz b on substr(a.ZMDZ1, 2, 4) = b.MANAGER_CODE
                and a.ACCDATE = b.order_date
            order by a.ZMDZ1, a.ACCDATE)
select q.ACCDATE as ����, q.ZMDZ1 as �ŵ������, s.ORGNAME as �ŵ�����, q.��ϵͳ���۵���,
       q.��ϵͳ����, q.bl as ¼������
from re q
         left join s_busi s on q.ZMDZ1 = s.BUSNO;

--todo ͩ��ǰһ�������

with new  as (
select order_date,s.ZMDZ1 as MANAGER_CODE,tml_num_id from d_rrtprod_memorder a
                                               left join D_RRT_QY_COMPID_BUSNO b on a.sub_unit_num_id=b.NBUSNO
                                               left join s_busi s on s.busno=b.OBUSNO
where sub_unit_num_id in (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select busno from s_busi where COMPID=1900))
and order_date >= trunc(sysdate - 2) and order_date<trunc(sysdate)
 group by order_date,s.ZMDZ1,tml_num_id),

    old as (
select s.ZMDZ1,h.ACCDATE,h.SALENO
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
       left join s_busi s on h.BUSNO = s.BUSNO
where s.BUSNO in (select busno from s_busi where COMPID=1900)
and h.ACCDATE >= trunc(sysdate - 2) and h.accdate<trunc(sysdate)
 and not exists(select 1
                              from t_sale_pay p
                              where p.saleno = h.saleno and p.paytype in
                                                            ('Z022', 'Z025', 'Z027', 'Z030', 'Z032', 'Z034', 'Z077',
                                                             'Z081', 'Z098', 'Z100', 'Z101', 'Z084', 'Z102', 'Z107')
                                and p.netsum <> 0)
               and not exists(select 1 from T_SALE_RETURN_H th where th.SALENO=h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_H th2 where th2.RETSALENO=h.SALENO)
               and not exists(select 1 from t_internal_sale_h ngd where SHIFTDATE>=date'2024-05-20' and ngd.NEWSALENO=h.SALENO)
               and not exists(select 1 from d_bp_exclude_sale exc where exc.SALENO=h.SALENO)
group by s.ZMDZ1,h.ACCDATE,h.SALENO
    ),
    new_hz as (
        select order_date,MANAGER_CODE,count(tml_num_id) sumsl from new
                                                                group by order_date,MANAGER_CODE
    ),
    old_hz as (
        select ZMDZ1,ACCDATE,count(SALENO) sumsl from old group by ZMDZ1,ACCDATE
    ),

    re as (
select a.ZMDZ1, ACCDATE, nvl(a.sumsl,0) as ��ϵͳ���۵���, order_date, MANAGER_CODE, nvl(b.sumsl,0) as ��ϵͳ����,
       case  when  nvl(a.sumsl,0)=0 then 0 else
           case when nvl(b.sumsl,0)>=50 then 1 else
               case when b.sumsl>a.sumsl then 1 else
       round(nvl(b.sumsl,0)/a.sumsl,3) end end end as bl
from old_hz a
    left join new_hz b on a.ZMDZ1=b.MANAGER_CODE
--1317  --�㳡��·
    --83009
and a.ACCDATE=b.order_date
order by a.ZMDZ1,a.ACCDATE)
select q.ACCDATE as ����, q.ZMDZ1 as �ŵ������, s.ORGNAME as �ŵ�����, q.��ϵͳ���۵���,
--        q.order_date, q.sub_unit_num_id,
       q.��ϵͳ����, q.bl as ¼������
from re q
  left join s_busi s on q.ZMDZ1=s.BUSNO;

--��һ��
with  a1 as(
select ��ϵͳ����, ��ϵͳ���۵���,����,�ŵ������,
       sum(case when ��ϵͳ����>50 then 50 else ��ϵͳ���� end) over ( partition by �ŵ������ ) as  ��ϵͳ������,
       sum(case when ��ϵͳ���۵���>50 then 50 else ��ϵͳ���۵��� end) over ( partition by �ŵ������ ) as  ��ϵͳ���۵�����
       from d_rrtprod_memorder_temp where  ����>=date'2024-05-26' and ���� not in (date'2024-05-31',date'2024-06-08',date'2024-06-09',date'2024-06-10') and ����=1),
a2 as (select ��ϵͳ������, ��ϵͳ���۵�����, ����, �ŵ������, case when ��ϵͳ���۵�����=0 then 0 else
    case when ��ϵͳ������>��ϵͳ���۵����� then 1 else
    ��ϵͳ������/��ϵͳ���۵����� end end as ¼����
from a1),
a3 as (
select a2.�ŵ������,bb.RN,¼����,case when a2.¼����>0.8 then 1 else 0 end as �Ƿ񳬰ٷ�֮80,
 case when a2.¼����<=0.1 then 1 else 0 end as �Ƿ���ڰٷ�֮10
from a2

left join D_BP_BUSNO bb on a2.�ŵ������=bb.BUSNO ),
a4 as (select �ŵ������, RN, max(�Ƿ񳬰ٷ�֮80) as �Ƿ񳬰ٷ�֮80,max(�Ƿ���ڰٷ�֮10) as �Ƿ���ڰٷ�֮10
       from a3
       group by �ŵ������, RN) select rn,sum(�Ƿ񳬰ٷ�֮80) as �Ƿ񳬰ٷ�֮80,sum(�Ƿ���ڰٷ�֮10) as �Ƿ���ڰٷ�֮10  from a4 group by  RN;
--�ڶ���
with  a1 as(
select ��ϵͳ����, ��ϵͳ���۵���,����,�ŵ������,
       sum(case when ��ϵͳ����>50 then 50 else ��ϵͳ���� end) over ( partition by �ŵ������ ) as  ��ϵͳ������,
       sum(case when ��ϵͳ���۵���>50 then 50 else ��ϵͳ���۵��� end) over ( partition by �ŵ������ ) as  ��ϵͳ���۵�����
       from d_rrtprod_memorder_temp where  ����>=date'2024-05-31' and ���� not in (date'2024-05-31',date'2024-06-08',date'2024-06-09',date'2024-06-10') and ����=2),
a2 as (select ��ϵͳ������, ��ϵͳ���۵�����, ����, �ŵ������, case when ��ϵͳ���۵�����=0 then 0 else
    case when ��ϵͳ������>��ϵͳ���۵����� then 1 else
    ��ϵͳ������/��ϵͳ���۵����� end end as ¼����
from a1),
a3 as (
select a2.�ŵ������,bb.RN,¼����,case when a2.¼����>0.8 then 1 else 0 end as �Ƿ񳬰ٷ�֮80,
 case when a2.¼����<=0.1 then 1 else 0 end as �Ƿ���ڰٷ�֮10
from a2

left join D_BP_BUSNO bb on a2.�ŵ������=bb.BUSNO ),
a4 as (select �ŵ������, RN, max(�Ƿ񳬰ٷ�֮80) as �Ƿ񳬰ٷ�֮80,max(�Ƿ���ڰٷ�֮10) as �Ƿ���ڰٷ�֮10
       from a3
       group by �ŵ������, RN) select rn,sum(�Ƿ񳬰ٷ�֮80) as �Ƿ񳬰ٷ�֮80,sum(�Ƿ���ڰٷ�֮10) as �Ƿ���ڰٷ�֮10  from a4 group by  RN;

--������
with  a1 as(
select ��ϵͳ����, ��ϵͳ���۵���,����,�ŵ������,
       sum(case when ��ϵͳ����>50 then 50 else ��ϵͳ���� end) over ( partition by �ŵ������ ) as  ��ϵͳ������,
       sum(case when ��ϵͳ���۵���>50 then 50 else ��ϵͳ���۵��� end) over ( partition by �ŵ������ ) as  ��ϵͳ���۵�����
       from d_rrtprod_memorder_temp where  ����>=date'2024-06-06' and ���� not in (date'2024-05-31',date'2024-06-08',date'2024-06-09',date'2024-06-10') and ����=3),
a2 as (select ��ϵͳ������, ��ϵͳ���۵�����, ����, �ŵ������, case when ��ϵͳ���۵�����=0 then 0 else
    case when ��ϵͳ������>��ϵͳ���۵����� then 1 else
    ��ϵͳ������/��ϵͳ���۵����� end end as ¼����
from a1),
a3 as (
select a2.�ŵ������,bb.RN,¼����,case when a2.¼����>0.8 then 1 else 0 end as �Ƿ񳬰ٷ�֮80,
 case when a2.¼����<=0.1 then 1 else 0 end as �Ƿ���ڰٷ�֮10
from a2

left join D_BP_BUSNO bb on a2.�ŵ������=bb.BUSNO ),
a4 as (select �ŵ������, RN, max(�Ƿ񳬰ٷ�֮80) as �Ƿ񳬰ٷ�֮80,max(�Ƿ���ڰٷ�֮10) as �Ƿ���ڰٷ�֮10
       from a3
       group by �ŵ������, RN) select rn,sum(�Ƿ񳬰ٷ�֮80) as �Ƿ񳬰ٷ�֮80,sum(�Ƿ���ڰٷ�֮10) as �Ƿ���ڰٷ�֮10  from a4 group by  RN;


--ͳ������������
with new as (select order_date, MANAGER_CODE, tml_num_id
             from d_rrtprod_memorder
             where sub_unit_num_id in
                   (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select BUSNO from D_BP_BUSNO))
               and order_date >= date'2024-05-28' and order_date<trunc(sysdate)
             group by order_date, MANAGER_CODE, tml_num_id),

     old as (select s.ZMDZ1, h.ACCDATE, h.SALENO
             from t_sale_h h
                      join t_sale_d d on h.SALENO = d.SALENO
                      join t_ware_base w on d.WAREID = w.WAREID
                      left join s_busi s on h.BUSNO = s.BUSNO
             where s.busno in (select BUSNO from D_BP_BUSNO)
               and h.ACCDATE >= date'2024-05-28' and h.accdate<trunc(sysdate)
               and not exists(select 1
                              from t_sale_pay p
                              where p.saleno = h.saleno and p.paytype in
                                                            ('Z022', 'Z025', 'Z027', 'Z030', 'Z032', 'Z034', 'Z077',
                                                             'Z081', 'Z098', 'Z100', 'Z101', 'Z084', 'Z102', 'Z107')
                                and p.netsum <> 0)
               and not exists(select 1 from T_SALE_RETURN_H th where th.SALENO=h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_H th2 where th2.RETSALENO=h.SALENO)
               and not exists(select 1 from t_internal_sale_h ngd where SHIFTDATE>=date'2024-05-20' and ngd.NEWSALENO=h.SALENO)
               and not exists(select 1 from d_bp_exclude_sale exc where exc.SALENO=h.SALENO)

             group by s.ZMDZ1, h.ACCDATE, h.SALENO),
     new_hz as (select order_date, MANAGER_CODE, count(tml_num_id) sumsl
                from new
                group by order_date, MANAGER_CODE),
     old_hz as (select ZMDZ1, ACCDATE, count(SALENO) sumsl from old group by ZMDZ1, ACCDATE),
     re as (select a.ZMDZ1, ACCDATE, nvl(a.sumsl, 0) as ��ϵͳ���۵���, order_date, MANAGER_CODE,
                   nvl(b.sumsl, 0) as ��ϵͳ����,
                   case
                       when nvl(a.sumsl, 0) = 0 then 0
                       else
                           case
                               when nvl(b.sumsl, 0) >= 50 then 1
                               else
                            case when  b.sumsl>a.sumsl then 1 else
                                   round(nvl(b.sumsl, 0) / a.sumsl, 3) end end end as bl
            from old_hz a
                     left join new_hz b on substr(a.ZMDZ1, 2, 4) = b.MANAGER_CODE
                and a.ACCDATE = b.order_date
            order by a.ZMDZ1, a.ACCDATE)
select q.ACCDATE as ����, q.ZMDZ1 as �ŵ������, s.ORGNAME as �ŵ�����, q.��ϵͳ���۵���,
       q.��ϵͳ����, q.bl as ¼������,case when q.bl >= 0.8 then 1 else 0 end as �Ƿ񳬰ٷ�֮80,
       sum(case when q.bl >= 0.8 then 1 else 0 end) over (partition by q.ZMDZ1) as ���ٷ�֮80����
from re q
         left join s_busi s on q.ZMDZ1 = s.BUSNO
--where q.ZMDZ1 in (81053,81054)
order by q.ZMDZ1, q.ACCDATE;

