drop table d_rrtprod_memorder;
create table d_rrtprod_memorder
(
order_date date,                           -- 销售日期
    create_dtme date,-- 销售时间
    tml_num_id varchar2(100),-- 销售单号
    type_num_id varchar2(100),-- 销售单类型（1
    source_tml_num_id varchar2(100),-- 原销售单号
    so_from_type  varchar2(100),-- 订单来源(17
    item_num_id number,-- 商品编码
    pro_code_old varchar2(100),-- 旧商品编码
    item_name  varchar2(100),-- 商品名称
    batch_id   varchar2(100),-- 批号
    deduct_amount number(14,4),-- 打折金额
    retail_price  number(14,4),-- 原单价（零售价
    retail_amount number(14,4),-- 原金额
    trade_price  number(14,4),-- 售价（含税）
    qty   number(14,4),-- 销量
    tax_rate number,-- 税率（销项）
    f_amount  number(14,4),-- 销售金额
    expiry_date date,-- 效期
    series  varchar2(100),-- 销售单行号
    cort_num_id  varchar2(100),-- 公司编码
    sub_unit_num_id varchar2(100),
    old_sub_unit_id  varchar2(100),
    vip_no varchar2(100), -- 会员编号
    CREATE_USER_ID varchar2(100) -- 收银员工号
)
select order_date as 销售日期, create_dtme as 销售时间, tml_num_id as 销售单号, type_num_id as 销售单类型,
       source_tml_num_id as 原销售单号, so_from_type as 订单来源, item_num_id as 商品编码, pro_code_old as 旧商品编码,
       item_name as 商品名称, batch_id as  批号, deduct_amount as 打折金额, retail_price as 原单价零售价, retail_amount as 原金额,
       trade_price as 售价, qty as 销量, tax_rate as 税率, f_amount as 销售金额,
       expiry_date as 效期, series as 销售单行号 , cort_num_id as 公司编码, sub_unit_num_id ,
       old_sub_unit_id , vip_no as 会员编号, CREATE_USER_ID as  收银员工号
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
select a.BUSNO, ACCDATE, nvl(a.sumsl,0) as 老系统销售单数, order_date, sub_unit_num_id, nvl(b.sumsl,0) as 新系统数量,
       case  when  nvl(a.sumsl,0)=0 then 0 else
           case when nvl(b.sumsl,0)>=50 then 1 else
       round(nvl(b.sumsl,0)/a.sumsl,3) end end as bl
from old_hz a
    left join new_hz b on substr(a.BUSNO,2,4)=b.sub_unit_num_id
--1317  --广场南路
    --83009
and a.ACCDATE=b.order_date
order by a.BUSNO,a.ACCDATE)
select q.ACCDATE as 日期, q.BUSNO as 门店编码, s.ORGNAME as 门店名称, q.老系统销售单数,
--        q.order_date, q.sub_unit_num_id,
       q.新系统数量, q.bl as 录单比率
from re q
  left join s_busi s on q.BUSNO=s.BUSNO;

select * from d_rrtprod_memorder;

select h.BUSNO,h.ACCDATE,h.STARTTIME,h.SALENO,d.WAREID,w.WARENAME,d.WAREQTY,d.NETPRICE
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
where h.BUSNO in (84507,84506,83047,83010,81559,83062,83211,83311,83612,84048,85021)
and h.ACCDATE between date'2024-05-26' and date'2024-05-27'

select busno,ORGNAME from S_BUSI where ORGNAME like '%彩屏%';
;
select * from t_sale_d where SALENO='2405263047173362';
select * from ;



select h.BUSNO,h.ACCDATE,h.SALENO,d.WAREID,d.WAREQTY
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
where h.BUSNO in (83009,81317,83047,83010,81559,83062,83211,83311,83612,84048,85021)
and h.ACCDATE between date'2024-05-26' and date'2024-05-27'
-- group by h.BUSNO,h.ACCDATE,h.SALENO,d.WAREID

select order_date,sub_unit_num_id,tml_num_id,item_num_id,pro_code_old,deduct_amount as 打折金额, retail_price as 原单价零售价, retail_amount as 原金额,
       trade_price as 售价, qty as 销量, tax_rate as 税率, f_amount as 销售金额 from d_rrtprod_memorder
where sub_unit_num_id in ('3009','1317','3047','3010','1559','3062','3211','3311','3612','4048','5021')
and order_date between date'2024-05-26' and date'2024-05-27'
--  group by order_date,sub_unit_num_id,tml_num_id

with a1 as (
    select 1 as id ,10114843 as wareid from dual
    union all
    select 2,10224593 from dual
),
    a2 as (
     select 1 as id,'10232807,10114843,10229689' as wareid from dual 
    )
 select * from a1 join a2 on a1.wareid=a2.wareid;

WITH a1 AS (
    SELECT 1 AS id, 10114843 AS wareid FROM DUAL
    UNION ALL
    SELECT 2, 10224593 FROM DUAL
),
a2_base AS (
    SELECT 1 AS id, '10232807,10114843,10229689' AS wareid FROM DUAL
),
a2_split AS (
    SELECT id,
           REGEXP_SUBSTR(wareid, '[^,]+', 1, LEVEL) AS single_wareid
    FROM a2_base
    CONNECT BY REGEXP_SUBSTR(wareid, '[^,]+', 1, LEVEL) IS NOT NULL
)
SELECT a1.*, a2_split.single_wareid
FROM a1
JOIN a2_split ON a1.wareid = TO_NUMBER(a2_split.single_wareid);

delete from d_rrtprod_memorder ;

--桐乡并跑
with new  as (
select order_date,b.OBUSNO as sub_unit_num_id, tml_num_id from d_rrtprod_memorder a
                                               left join D_RRT_QY_COMPID_BUSNO b on a.sub_unit_num_id=b.NBUSNO
where sub_unit_num_id in ('X001','X002','X003','X004','X005','X009','X011','X012','X014','X017','X018','X019','X020','X056','X060')
and order_date between date'2024-05-22' and date'2024-05-27'
 group by order_date,b.OBUSNO,tml_num_id),

    old as (
select h.BUSNO,h.ACCDATE,h.SALENO
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
where h.BUSNO in (86201,86202,86203,86204,86205,86209,86211,86212,86214,86217,86218,86219,86220,86256,86260)
and h.ACCDATE between date'2024-05-22' and date'2024-05-27'
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
select a.BUSNO, ACCDATE, nvl(a.sumsl,0) as 老系统销售单数, order_date, sub_unit_num_id, nvl(b.sumsl,0) as 新系统数量,
       case  when  nvl(a.sumsl,0)=0 then 0 else
           case when nvl(b.sumsl,0)>=50 then 1 else
       round(nvl(b.sumsl,0)/a.sumsl,3) end end as bl
from old_hz a
    left join new_hz b on a.BUSNO=b.sub_unit_num_id
--1317  --广场南路
    --83009
and a.ACCDATE=b.order_date
order by a.BUSNO,a.ACCDATE)
select q.ACCDATE as 日期, q.BUSNO as 门店编码, s.ORGNAME as 门店名称, q.老系统销售单数,
--        q.order_date, q.sub_unit_num_id,
       q.新系统数量, q.bl as 录单比率
from re q
  left join s_busi s on q.BUSNO=s.BUSNO;

