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
--                and order_date=trunc(sysdate) - 1 and
                 order_date not in (date'2024-05-31', date'2024-06-08', date'2024-06-09', date'2024-06-10',date'2024-06-15', date'2024-06-16', date'2024-06-18')
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
--                and h.ACCDATE  = trunc(sysdate) - 1 and
                 h.ACCDATE not in (date'2024-05-31', date'2024-06-08', date'2024-06-09', date'2024-06-10',date'2024-06-15', date'2024-06-16', date'2024-06-18')
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
                           else case when b.rn=3 then (trunc(sysdate) - 1 - date'2024-06-05' - 3)
                               else case when b.rn=4 then (trunc(sysdate) - 1 - date'2024-06-13' )  end  end end end as 天数,
       sum(录单比率) / case when b.rn=1 then (trunc(sysdate) - 1 - date'2024-05-26' - 4)
                       else case when b.rn=2 then (trunc(sysdate) - 1 - date'2024-05-31' - 4)
                           else case when b.rn=3 then (trunc(sysdate) - 1 - date'2024-06-05' - 3)
                               else case when b.rn=4 then (trunc(sysdate) - 1 )  end  end end end as 录单比率,
       row_number() over (partition by b.rn order by sum(录单比率) / (trunc(sysdate) - 1 - date'2024-05-26' - 4) desc) as rn
from d_bp_pjwcl a
left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ
where  (b.rn = 1 AND a.日期 >= DATE '2024-05-26') OR
  (b.rn = 2 AND a.日期 >= DATE '2024-05-31') OR
  (b.rn = 3 AND a.日期 >= DATE '2024-06-05') OR
  (b.rn = 4 AND a.日期 >= DATE '2024-06-13')
group by 业务机构编码, 门店名称,b.rn;

--瑞人堂并跑排名
with a1 as (
    select 业务机构编码, 门店名称,b.rn as 门店批次,sum(录单比率) 总录单比率,
       case when b.rn=1 then (date'2024-06-26'  - date'2024-05-26' - 6)
                       else case when b.rn=2 then (date'2024-06-26'  - date'2024-05-31' - 6)
                           else case when b.rn=3 then (date'2024-06-26' - date'2024-06-05' - 5)
                               else case when b.rn=4 then (date'2024-06-26' - date'2024-06-13'-2 )  end  end end end as 天数,
        sum(新系统数量) as 新系统数量
from d_bp_pjwcl a
left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ
where ( (b.rn = 1 AND a.日期 >= DATE '2024-05-26') OR
  (b.rn = 2 AND a.日期 >= DATE '2024-05-31') OR
  (b.rn = 3 AND a.日期 >= DATE '2024-06-05') OR
  (b.rn = 4 AND a.日期 >= DATE '2024-06-13') ) and 日期<=date'2024-06-26'
  and b.RN<>1
   group by 业务机构编码, 门店名称,b.rn
)
select 业务机构编码,门店名称, 门店批次, 总录单比率, 天数,trunc(总录单比率/天数,5) as 平均录单率,新系统数量,
       row_number() over ( order by 总录单比率 / 天数 desc) as 排名
from a1;
;
--瑞人堂并跑明细
select a.*,row_number() over (partition by a.业务机构编码,a.日期 order by 业务机构编码,日期 ) rn
from d_bp_pjwcl a
 left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ
where ( (b.rn = 1 AND a.日期 >= DATE '2024-05-26') OR
  (b.rn = 2 AND a.日期 >= DATE '2024-05-31') OR
  (b.rn = 3 AND a.日期 >= DATE '2024-06-05') OR
  (b.rn = 4 AND a.日期 >= DATE '2024-06-13') ) and 日期<=date'2024-06-26'
  and b.RN<>1;

-- 瑞人堂试点排名
with a1 as (
    select 业务机构编码, 门店名称,b.rn as 门店批次,sum(录单比率) 总录单比率,
       case when b.rn=1 then (date'2024-06-26'  - date'2024-05-26' - 6)
                       else case when b.rn=2 then (date'2024-06-26'  - date'2024-05-31' - 6)
                           else case when b.rn=3 then (date'2024-06-26' - date'2024-06-05' - 5)
                               else case when b.rn=4 then (date'2024-06-26' - date'2024-06-13'-2 )  end  end end end as 天数,
        sum(新系统数量) as 新系统数量
from d_bp_pjwcl a
left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ
where ( (b.rn = 1 AND a.日期 >= DATE '2024-05-26') OR
  (b.rn = 2 AND a.日期 >= DATE '2024-05-31') OR
  (b.rn = 3 AND a.日期 >= DATE '2024-06-05') OR
  (b.rn = 4 AND a.日期 >= DATE '2024-06-13') ) and 日期<=date'2024-06-26'
  and b.RN=1
   group by 业务机构编码, 门店名称,b.rn
)
select 业务机构编码,门店名称, 门店批次, 总录单比率, 天数,trunc(总录单比率/天数,5) as 平均录单率,新系统数量,
       row_number() over ( order by 总录单比率 / 天数 desc) as 排名
from a1;

-- 瑞人堂试点明细
select a.*,row_number() over (partition by a.业务机构编码,a.日期 order by 业务机构编码,日期 ) rn
from d_bp_pjwcl a
 left join d_jl_mdz b on a.业务机构编码 = b.ZMDZ
where ( (b.rn = 1 AND a.日期 >= DATE '2024-05-26') OR
  (b.rn = 2 AND a.日期 >= DATE '2024-05-31') OR
  (b.rn = 3 AND a.日期 >= DATE '2024-06-05') OR
  (b.rn = 4 AND a.日期 >= DATE '2024-06-13') ) and 日期<=date'2024-06-26'
  and b.RN=1;

--桐乡并跑排名
with a1 as (
    select 业务机构编码, 门店名称,sum(录单比率) 总录单比率,
       date'2024-06-26'  - date'2024-05-26' - 6 as 天数,
        sum(新系统数量) as 新系统数量
from D_BP_TXPJWCL a
where 业务机构编码 not in ('86202','86204','86212','86254','86260')
and   日期<=date'2024-06-26'
   group by 业务机构编码, 门店名称
)
select 业务机构编码,门店名称,  总录单比率, 天数,trunc(总录单比率/天数,5) as 平均录单率,新系统数量,
       row_number() over (order by 总录单比率 / 天数 desc) as 排名
from a1;

--桐乡并跑明细
select a.*,row_number() over (partition by a.业务机构编码,a.日期 order by 业务机构编码,日期 ) rn
from D_BP_TXPJWCL a
where 业务机构编码 not in ('86202','86204','86212','86254','86260') and 日期<=date'2024-06-26';


--桐乡试点排名
with a1 as (
    select 业务机构编码, 门店名称,sum(录单比率) 总录单比率,
       date'2024-06-26'  - date'2024-05-26' - 6 as 天数,
        sum(新系统数量) as 新系统数量
from D_BP_TXPJWCL a
where 业务机构编码  in ('86202','86204','86212','86254','86260')
and   日期<=date'2024-06-26'
   group by 业务机构编码, 门店名称
)
select 业务机构编码,门店名称,  总录单比率, 天数,trunc(总录单比率/天数,5) as 平均录单率,新系统数量,
       row_number() over (order by 总录单比率 / 天数 desc) as 排名
from a1;

--桐乡试点明细
select a.*,row_number() over (partition by a.业务机构编码,a.日期 order by 业务机构编码,日期 ) rn
from D_BP_TXPJWCL a
where 业务机构编码  in ('86202','86204','86212','86254','86260') and 日期<=date'2024-06-26';


update     t_payee_check_list  a set status='1'
        WHERE  a.status = 0  AND  createdate<trunc(sysdate);

select * from T_SALE_PAY where SALENO='2407041097002820';
select * from T_DISTAPPLY_H where APPLYNO='240703454361';

select * from ALL_TAB_COLUMNS where TABLE_NAME='s_busi';
delete from  D_BP_TXPJWCL;
insert into D_BP_TXPJWCL
with new as (select order_date, s.ZMDZ1, tml_num_id
             from d_rrtprod_memorder a
             left join D_RRT_QY_COMPID_BUSNO b on a.sub_unit_num_id=b.NBUSNO
             left join s_busi s on s.busno=b.OBUSNO
             where sub_unit_num_id in (select NBUSNO
                    from D_RRT_QY_COMPID_BUSNO
                    where OBUSNO in (select busno from s_busi where COMPID=1900))
               and order_date between date'2024-05-26' and trunc(sysdate) - 1 and
--                and order_date=trunc(sysdate) - 1 and
                 order_date not in (date'2024-05-31', date'2024-06-08', date'2024-06-09', date'2024-06-10',date'2024-06-15', date'2024-06-16', date'2024-06-18')
               and not exists(select 1
                              from d_rrtprod_memorder ex1
                              WHERE ex1.order_date >= date'2024-06-13' and ex1.create_user_id <= 1
                                and ex1.series = a.series)
--              group by order_date, SUB_UNIT_NUM_ID, tml_num_id
),
     old as (select s.ZMDZ1, h.ACCDATE, h.SALENO
             from t_sale_h h
                      join t_sale_d d on h.SALENO = d.SALENO
                      join t_ware_base w on d.WAREID = w.WAREID
                      left join s_busi s on h.BUSNO = s.BUSNO
             where s.COMPID=1900
               and h.ACCDATE between date'2024-05-26' and trunc(sysdate) - 1 and
--                and h.ACCDATE  = trunc(sysdate) - 10 and
                 h.ACCDATE not in (date'2024-05-31', date'2024-06-08', date'2024-06-09', date'2024-06-10',date'2024-06-15', date'2024-06-16', date'2024-06-18')
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
     new_hz as (select order_date, ZMDZ1, count(tml_num_id) sumsl
                from new
                group by order_date, ZMDZ1),
     old_hz as (select ZMDZ1, ACCDATE, count(SALENO) sumsl from old group by ZMDZ1, ACCDATE),
     re as (select bs.ZMDZ1, a.ACCDATE as ACCDATE, nvl(a.sumsl, 0) as 老系统销售单数, order_date, b.ZMDZ1 as ydtzmdz1,
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
            from s_busi bs
                     left join old_hz a on bs.busno = a.ZMDZ1
                     left join new_hz b on bs.busno  = b.ZMDZ1
                and a.ACCDATE = b.order_date
            where bs.COMPID=1900
            )
--             order by a.BUSNO, a.ACCDATE)
select q.ACCDATE as 日期,
       case when q.新系统数量 < 10 then 1 else 0 end as 低于10笔记录,
       case when q.新系统数量 < 50 then 1 else 0 end as 低于50笔记录,
       1 as 计入,
       tb2.CLASSNAME as 店型, q.ZMDZ1 as 业务机构编码, s.ORGNAME as 门店名称, tb.CLASSNAME as 事业部,
       tb1.CLASSNAME as 片区, q.老系统销售单数,
       q.新系统数量, q.bl as 录单比率
from re q
         left join s_busi s on q.ZMDZ1 = s.BUSNO
         join t_busno_class_set ts on q.ZMDZ1 = ts.busno and ts.classgroupno = '303'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on q.ZMDZ1 = ts1.busno and ts1.classgroupno = '304'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
         join t_busno_class_set ts2 on q.ZMDZ1 = ts2.busno and ts2.classgroupno = '305'
         join t_busno_class_base tb2 on ts2.classgroupno = tb2.classgroupno and ts2.classcode = tb2.classcode;

