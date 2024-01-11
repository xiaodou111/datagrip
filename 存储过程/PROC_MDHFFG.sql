create PROCEDURE proc_mdhffg(p_begin IN DATE,
                             p_end IN DATE,
                             p_sql OUT SYS_REFCURSOR)
    IS


BEGIN
    OPEN p_sql FOR
        with a as (select a.*, row_number() over (partition by a.顾客姓名 order by a.会计日) as 时间段内第几个单号
                   from (SELECT a.accdate as 会计日, a.saleno as 销售单号, a.saler as 销售员工工号,
                                su.username as 员工姓名, tr.cfno as 处方编号,
                                a.wareid, a.busno,
                                nvl(tr.ext_str7, f.ext_str7) as 随访时间,
                                nvl(tr.USERNAME, f.uname) as 顾客姓名,
                                nvl(tr.IDCARDNO, f.idcard) as IDCARDNO,
                                nvl(tr.PHONE, f.mobile) as phone,
                                b.hf_day as 回访周期,
                                a.accdate + b.hf_day as 下次用药时间,
                                a.accdate + b.hf_day - 3 as 下次随访日期,
                                tr.nofg_reason
                         FROM t_sale_d a
                                  inner join t_sale_h th on a.saleno = th.saleno
                                  inner join d_sjzl_db_ware b on a.wareid = b.wareid
                                  left join s_busi c on a.busno = c.busno
                                  left join t_ware_base d on a.wareid = d.wareid
                                  left join t_factory e on d.factoryid = e.factoryid
                                  left join t_remote_prescription_h tr ON substr(th.notes, 0,
                                                                                 decode(instr(th.notes, ' '), 0,
                                                                                        length(th.notes) + 1,
                                                                                        instr(th.notes, ' ')) - 1) =
                                                                          tr.cfno
                                  left join d_sjzl_db_cfxx f on a.saleno = f.saleno
                                  left join s_user_base su on a.saler = su.userid
                                  left join t_sale_pay pay on a.saleno = pay.saleno and pay.paytype in
                                                                                        ('Z064', 'Z062', 'Z060', 'Z061',
                                                                                         'Z063', 'Z066', '809084',
                                                                                         'Z089')
                                  left join (SELECT a.cfno, a.createtime, trim(a.username) as kk,
                                                    row_number() over (partition by trim(a.username) order by a.createtime) as rn
                                             FROM t_remote_prescription_h a
                                                      inner join t_remote_prescription_d b on a.cfno = b.cfno
                                             WHERE exists (select 1 from d_sjzl_db_ware c WHERE b.wareid = c.wareid)
                                               and username is not null and status = 4 and trim(username) <> '作废'
                                               and b.wareqty > 0
                                             group by a.cfno, a.createtime, trim(a.username)) oo
                                            on trim(tr.username) = oo.kk and tr.cfno = oo.cfno
                         WHERE a.accdate between p_begin AND p_end
                           and a.accdate + b.hf_day - 3 between last_day(add_months(p_begin, -1)) + 1 and last_day(p_begin)
                            --and a.busno in(81499,81501)
                            --应复购人数根据下次用药时间  ,如果填写了无复购原因就算进实际复购人数中
                            /*trunc(add_months(sysdate,-7)) and trunc(sysdate)
                            and (  a.accdate >= to_date('2023-07-01', 'yyyy-MM-dd')
                            and a.accdate < to_date('2023-08-02', 'yyyy-MM-dd')  )*/
                        ) a),
--每个员工销售总数
             t_total as (select a.busno, a.销售员工工号, max(a.员工姓名) as 员工姓名, count(distinct 销售单号) as 总数
                         from a
                         group by a.销售员工工号, a.busno),

--每个员工完成随访数
             t_complete as
                 (select a.busno, a.销售员工工号, count(distinct 销售单号) as 完成数
                  from a
                  where 随访时间 <= 下次用药时间
                  group by a.销售员工工号, a.busno),
--每个销售单号的信息
             t_saleno as (select a.销售单号, max(a.会计日) as 会计日, max(a.销售员工工号) as 销售员工工号,
                                 max(a.处方编号) as 处方编号,
                                 max(a.phone) as phone, max(a.顾客姓名) as 顾客姓名,
                                 max(a.下次用药时间) as 下次用药时间, max(a.wareid) as wareid
                          from a
                          group by 销售单号),
--复购的销售单号信息
             t_fg as (select *
                      from (select tr.cfno, sa.处方编号, aa.saler, aa.accdate, aa.wareid, tr.USERNAME, sa.下次用药时间,
                                   aa.busno,
                                   row_number() over (partition by sa.处方编号 order by aa.accdate) as rn
                            FROM t_sale_d aa
                                     join t_sale_h th on aa.saleno = th.saleno
                                     left join t_remote_prescription_h tr ON substr(th.notes, 0,
                                                                                    decode(instr(th.notes, ' '), 0,
                                                                                           length(th.notes) + 1,
                                                                                           instr(th.notes, ' ')) - 1) =
                                                                             tr.cfno
                                     join t_saleno sa on aa.saler = sa.销售员工工号
                            where tr.USERNAME = sa.顾客姓名 and aa.accdate > sa.下次用药时间 and aa.wareid = sa.wareid)
                      where rn = 1
                 --where username='颜娇云'
             ),
             t_fgnum as (select t_fg.saler, t_fg.busno, count(*) as 复购数 from t_fg group by t_fg.saler, t_fg.busno),
--应复购人数 根据下次用药时间
             t_shouldfg as (select a.busno, a.销售员工工号, max(a.员工姓名) as 员工姓名,
                                   count(distinct 销售单号) as 应复购人数
                            from a
                            where 下次用药时间 between last_day(add_months(p_begin, -1)) + 1 and last_day(p_begin)
                            group by a.销售员工工号, a.busno),
--填写了未复购原因的数量,需要把这部分加进实际复购人数中
             t_wfgreason as (select a.busno, a.销售员工工号, max(a.员工姓名) as 员工姓名,
                                    count(distinct 销售单号) as 填写了未复购原因的单数
                             from a
                             where nvl(a.nofg_reason, 0) > 0
                             group by a.销售员工工号, a.busno),
             result as (select a.busno, a.销售员工工号, a.员工姓名, a.总数 as 应回访人数,
                               nvl(b.完成数, 0) as 实际回访人数,
                               nvl(c.复购数, 0) + nvl(e.填写了未复购原因的单数, 0) as 实际复购人数,
                               nvl(d.应复购人数, 0) as 应复购人数
                        from t_total a
                                 left join t_complete b on a.销售员工工号 = b.销售员工工号 and a.busno = b.busno
                                 left join t_fgnum c on a.销售员工工号 = c.saler and a.busno = c.busno
                                 left join t_shouldfg d on a.销售员工工号 = d.销售员工工号 and a.busno = d.busno
                                 left join t_wfgreason e on a.销售员工工号 = e.销售员工工号 and a.busno = e.busno)
        select a.busno, s.orgname, tb.classname, tb1.classname, 销售员工工号, 员工姓名, 应回访人数, 实际回访人数,
               case when 应回访人数 = 0 or 实际回访人数 = 0 then 0 else 实际回访人数 / 应回访人数 end as 回访完成率,
               应复购人数, 实际复购人数,
               case when 应复购人数 = 0 or 实际复购人数 = 0 then 0 else 实际复购人数 / 应复购人数 end as 复购完成率

        from result a
                 left join s_busi s on a.busno = s.busno
                 join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '303'
                 join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                 join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '304'
                 join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode;


END;
/

