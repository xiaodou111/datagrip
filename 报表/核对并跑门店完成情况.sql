drop table d_rrtprod_memorder;
create table d_rrtprod_memorder
(
    order_date        date,          -- 销售日期
    create_dtme       date,-- 销售时间
    tml_num_id        varchar2(100),-- 销售单号
    type_num_id       varchar2(100),-- 销售单类型（1
    source_tml_num_id varchar2(100),-- 原销售单号
    so_from_type      varchar2(100),-- 订单来源(17
    item_num_id       number,-- 商品编码
    pro_code_old      varchar2(100),-- 旧商品编码
    item_name         varchar2(100),-- 商品名称
    batch_id          varchar2(100),-- 批号
    deduct_amount     number(14, 4),-- 打折金额
    retail_price      number(14, 4),-- 原单价（零售价
    retail_amount     number(14, 4),-- 原金额
    trade_price       number(14, 4),-- 售价（含税）
    qty               number(14, 4),-- 销量
    tax_rate          number,-- 税率（销项）
    f_amount          number(14, 4),-- 销售金额
    expiry_date       date,-- 效期
    series            varchar2(100),-- 销售单行号
    cort_num_id       varchar2(100),-- 公司编码
    sub_unit_num_id   varchar2(100),
    old_sub_unit_id   varchar2(100),
    vip_no            varchar2(100), -- 会员编号
    CREATE_USER_ID    varchar2(100),  -- 收银员工号
    MANAGER_CODE      varchar2(50) --门店组编码
)
select order_date as 销售日期, create_dtme as 销售时间, tml_num_id as 销售单号, type_num_id as 销售单类型,
       source_tml_num_id as 原销售单号, so_from_type as 订单来源, item_num_id as 商品编码, pro_code_old as 旧商品编码,
       item_name as 商品名称, batch_id as 批号, deduct_amount as 打折金额, retail_price as 原单价零售价,
       retail_amount as 原金额,
       trade_price as 售价, qty as 销量, tax_rate as 税率, f_amount as 销售金额,
       expiry_date as 效期, series as 销售单行号, cort_num_id as 公司编码, sub_unit_num_id,
       old_sub_unit_id, vip_no as 会员编号, CREATE_USER_ID as 收银员工号
from d_rrtprod_memorder
where sub_unit_num_id in ('4507', '4506', '3047', '3010', '1559', '3062', '3211', '3311', '3612', '4048', '5021')
select * from d_rrtprod_memorder where order_date=trunc(sysdate-1);
-- and sub_unit_num_id='3047' and pro_code_old='10114843,10115183,81003997'
;


-- select * from D_RRT_QY_COMPID_BUSNO;


--todo 瑞人堂前一天完成率
--瑞人堂5.29完成率
with new as (select order_date, MANAGER_CODE, tml_num_id
             from d_rrtprod_memorder
             where sub_unit_num_id in
                   (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select BUSNO from D_BP_BUSNO))
               and order_date = trunc(sysdate - 1)
             group by order_date, MANAGER_CODE, tml_num_id),

     old as (select s.ZMDZ1, h.ACCDATE, h.SALENO
             from t_sale_h h
                      join t_sale_d d on h.SALENO = d.SALENO
                      join t_ware_base w on d.WAREID = w.WAREID
                      left join s_busi s on h.BUSNO = s.BUSNO
             where s.busno in (select BUSNO from D_BP_BUSNO)
               and h.ACCDATE = trunc(sysdate - 1)
               and not exists(select 1
                              from t_sale_pay p
                              where p.saleno = h.saleno and p.paytype in
                                                            ('Z022', 'Z025', 'Z027', 'Z030', 'Z032', 'Z034', 'Z077',
                                                             'Z081', 'Z098', 'Z100', 'Z101', 'Z084', 'Z102', 'Z107')
                                and p.netsum <> 0)
               and not exists(select 1 from T_SALE_RETURN_H th where th.SALENO=h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_H th2 where th2.RETSALENO=h.SALENO)
             group by s.ZMDZ1, h.ACCDATE, h.SALENO),
     new_hz as (select order_date, MANAGER_CODE, count(tml_num_id) sumsl
                from new
                group by order_date, MANAGER_CODE),
     old_hz as (select ZMDZ1, ACCDATE, count(SALENO) sumsl from old group by ZMDZ1, ACCDATE),
     re as (select a.ZMDZ1, ACCDATE, nvl(a.sumsl, 0) as 老系统销售单数, order_date, MANAGER_CODE,
                   nvl(b.sumsl, 0) as 新系统数量,
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
select q.ACCDATE as 日期, q.ZMDZ1 as 门店组编码, s.ORGNAME as 门店名称, q.老系统销售单数,
       q.新系统数量, q.bl as 录单比率
from re q
         left join s_busi s on q.ZMDZ1 = s.BUSNO;

--todo 桐乡前一天完成率

with new  as (
select order_date,s.ZMDZ1 as MANAGER_CODE,tml_num_id from d_rrtprod_memorder a
                                               left join D_RRT_QY_COMPID_BUSNO b on a.sub_unit_num_id=b.NBUSNO
                                               left join s_busi s on s.busno=b.OBUSNO
where sub_unit_num_id in (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select busno from s_busi where COMPID=1900))
and order_date= trunc(sysdate - 1)
 group by order_date,s.ZMDZ1,tml_num_id),

    old as (
select s.ZMDZ1,h.ACCDATE,h.SALENO
       from t_sale_h h join t_sale_d d on h.SALENO=d.SALENO
       join t_ware_base w on d.WAREID=w.WAREID
       left join s_busi s on h.BUSNO = s.BUSNO
where s.BUSNO in (select busno from s_busi where COMPID=1900)
and h.ACCDATE= trunc(sysdate - 1)
 and not exists(select 1
                              from t_sale_pay p
                              where p.saleno = h.saleno and p.paytype in
                                                            ('Z022', 'Z025', 'Z027', 'Z030', 'Z032', 'Z034', 'Z077',
                                                             'Z081', 'Z098', 'Z100', 'Z101', 'Z084', 'Z102', 'Z107')
                                and p.netsum <> 0)
               and not exists(select 1 from T_SALE_RETURN_H th where th.SALENO=h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_H th2 where th2.RETSALENO=h.SALENO)
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
select a.ZMDZ1, ACCDATE, nvl(a.sumsl,0) as 老系统销售单数, order_date, MANAGER_CODE, nvl(b.sumsl,0) as 新系统数量,
       case  when  nvl(a.sumsl,0)=0 then 0 else
           case when nvl(b.sumsl,0)>=50 then 1 else
               case when b.sumsl>a.sumsl then 1 else
       round(nvl(b.sumsl,0)/a.sumsl,3) end end end as bl
from old_hz a
    left join new_hz b on a.ZMDZ1=b.MANAGER_CODE
--1317  --广场南路
    --83009
and a.ACCDATE=b.order_date
order by a.ZMDZ1,a.ACCDATE)
select q.ACCDATE as 日期, q.ZMDZ1 as 门店组编码, s.ORGNAME as 门店名称, q.老系统销售单数,
--        q.order_date, q.sub_unit_num_id,
       q.新系统数量, q.bl as 录单比率
from re q
  left join s_busi s on q.ZMDZ1=s.BUSNO;

