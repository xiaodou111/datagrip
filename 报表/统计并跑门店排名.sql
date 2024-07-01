delete from  d_bp_pjwcl;
select * from d_bp_pjwcl;
insert into d_bp_pjwcl
with new as (select order_date, MANAGER_CODE, tml_num_id
             from d_rrtprod_memorder
             where MANAGER_CODE in
                   (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select zmdz from d_jl_mdz))
               and order_date between date'2024-05-26' and trunc(sysdate) - 1 and
                 order_date not in (date'2024-05-31', date'2024-06-08', date'2024-06-09', date'2024-06-10')
               and not exists(select 1
                              from d_rrtprod_memorder ex1
                              WHERE ex1.order_date >= date'2024-06-13' and ex1.create_user_id <= 1
                                and ex1.series = d_rrtprod_memorder.series)
--              group by order_date, SUB_UNIT_NUM_ID, tml_num_id
),
     old as (select s.ZMDZ1, h.ACCDATE, h.SALENO
             from t_sale_h h
                      join t_sale_d d on h.SALENO = d.SALENO
                      join t_ware_base w on d.WAREID = w.WAREID
                      left join s_busi s on h.BUSNO = s.BUSNO
             where s.ZMDZ1 in (select zmdz from d_jl_mdz)
               and h.ACCDATE between date'2024-05-26' and trunc(sysdate) - 1 and
                 h.ACCDATE not in (date'2024-05-31', date'2024-06-08', date'2024-06-09', date'2024-06-10')
               and not exists(select 1
                              from t_sale_pay p
                              where p.saleno = h.saleno and p.paytype in
                                                            ('Z022', 'Z025', 'Z027', 'Z030', 'Z032', 'Z034', 'Z077',
                                                             'Z081', 'Z098', 'Z100', 'Z101', 'Z084', 'Z102', 'Z107')
                                and p.netsum <> 0)
               and not exists(select 1 from T_SALE_RETURN_H th where th.SALENO = h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_H th2 where th2.RETSALENO = h.SALENO)
               and not exists(select 1
                              from t_internal_sale_h ngd
                              where SHIFTDATE >= date'2024-05-20' and ngd.NEWSALENO = h.SALENO)
               and not exists(select 1 from d_bp_exclude_sale exc where exc.SALENO = h.SALENO)
--              group by h.BUSNO, h.ACCDATE, h.SALENO
     ),
     new_hz as (select order_date, MANAGER_CODE, count(tml_num_id) sumsl
                from new
                group by order_date, MANAGER_CODE),
     old_hz as (select ZMDZ1, ACCDATE, count(SALENO) sumsl from old group by ZMDZ1, ACCDATE),
     re as (select bs.ZMDZ, a.ACCDATE as ACCDATE, nvl(a.sumsl, 0) as 老系统销售单数, order_date, MANAGER_CODE,
                   nvl(b.sumsl, 0) as 新系统数量,
                   case
                       when nvl(a.sumsl, 0) = 0 then 0
                       else
                           case
                               when nvl(b.sumsl, 0) >= 50 then 1
                               else
                                   case
                                       when b.sumsl > a.sumsl then 1
                                       else
                                           round(nvl(b.sumsl, 0) / a.sumsl, 3) end end end as bl
            from d_jl_mdz bs
                     left join old_hz a on bs.ZMDZ = a.ZMDZ1
                     left join new_hz b on substr(a.ZMDZ1, 2, 4) = b.MANAGER_CODE
                and a.ACCDATE = b.order_date
            )
--             order by a.BUSNO, a.ACCDATE)
select q.ACCDATE as 日期,
       case when q.新系统数量 < 10 then 1 else 0 end as 低于10笔记录,
       case when q.新系统数量 < 50 then 1 else 0 end as 低于50笔记录,
       1 as 计入,
       tb2.CLASSNAME as 店型, q.ZMDZ as 业务机构编码, s.ORGNAME as 门店名称, tb.CLASSNAME as 事业部,
       tb1.CLASSNAME as 片区, q.老系统销售单数,
       q.新系统数量, q.bl as 录单比率
from re q
         left join s_busi s on q.ZMDZ = s.BUSNO
         join t_busno_class_set ts on q.ZMDZ = ts.busno and ts.classgroupno = '303'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on q.ZMDZ = ts1.busno and ts1.classgroupno = '304'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
         join t_busno_class_set ts2 on q.ZMDZ = ts2.busno and ts2.classgroupno = '305'
         join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode;




select 业务机构编码, 门店名称,b.rn as 门店批次,sum(录单比率),
       case when b.rn=1 then (trunc(sysdate) - 1 - date'2024-05-26' - 4)
                       else case when b.rn=2 then (trunc(sysdate) - 1 - date'2024-05-31' - 4)
                           else case when b.rn=3 then (trunc(sysdate) - 1 - date'2024-06-05' - 4)
                               else case when b.rn=4 then (trunc(sysdate) - 1 - date'2024-06-13' - 4)  end  end end end as 天数,
       sum(录单比率) / case when b.rn=1 then (trunc(sysdate) - 1 - date'2024-05-26' - 4)
                       else case when b.rn=2 then (trunc(sysdate) - 1 - date'2024-05-31' - 4)
                           else case when b.rn=3 then (trunc(sysdate) - 1 - date'2024-06-05' - 4)
                               else case when b.rn=4 then (trunc(sysdate) - 1 - date'2024-06-13' - 4)  end  end end end as 录单比率,
       row_number() over (partition by b.rn order by sum(录单比率) / (trunc(sysdate) - 1 - date'2024-05-26' - 4) desc) as rn
from d_bp_pjwcl a
left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ
group by 业务机构编码, 门店名称,b.rn;

select a.业务机构编码,b.RN as 门店批次,a.新系统数量
from d_bp_pjwcl a
left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ;

select * from d_bp_pjwcl where 业务机构编码=81072;

select * from d_jl_mdz;
select max(日期) from d_bp_pjwcl;