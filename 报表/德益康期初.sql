--dtp订单表 a1获取除 本年度首次购药时间以外所有字段
with a1 as (select qy.NCOMPID, sc.COMPNAME, qy.NBUSNO as 创建药房编号, s.ORGNAME as 创建药房名称,
                   th.IDCARDNO as 患者身份证, th.USERNAME as 患者姓名, h.SALENO as POS订单号, null as 创建人,
                   h.STARTTIME as 创建时间,
                   case when rh.RETSALENO is null then 0 else 1 end as 订单类型,
                   rh.RETSALENO as 原销售单号, null as 已退货数量, null as 购买方式, trunc(h.NETSUM, 2) as 总金额,
                   null as 收费人,
                   h.FINALTIME as 收费时间, trunc(h.NETSUM, 2) as 收款金额,
                   case
                       when row_number() over (partition by th.IDCARDNO order by h.STARTTIME) = 1 then '是'
                       else '否' end as 是否首次订单,
                   row_number() over (partition by th.IDCARDNO order by h.STARTTIME) 第几次购药,
                   null as 本年度首次购药时间,
--        count(distinct trunc(STARTTIME,'yyyy')) over ( partition by th.IDCARDNO) as  第几年度,
                   dense_rank() over (partition by th.IDCARDNO order by trunc(STARTTIME, 'yyyy')) as 第几年度,
                   count(th.IDCARDNO) over (partition by th.IDCARDNO) as 订单次数,
                   case when cyb.ERP销售单号 is null then '否' else '是' end as 是否医保,
                   cyb.参保人员类别
            from t_sale_h h
                     left join s_busi s on h.BUSNO = s.BUSNO
                     left join S_COMPANY sc on s.COMPID = sc.COMPID
                     left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
                     LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                                    decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                                           instr(h.notes, ' ')) - 1) = th.cfno
                     left join T_SALE_RETURN_H rh on rh.SALENO = h.SALENO
                     left join D_ZHYB_HZ_CYB cyb on h.SALENO = cyb.ERP销售单号
            where exists(select 1
                         from t_sale_d d
                         where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
              and s.BUSNO < 89000),
     a2 as (select POS订单号, 创建时间, a1.患者身份证, a1.患者姓名,
                   rank() over (partition by 患者身份证 order by 创建时间) rank

            from a1
            where 创建时间 >= date'2024-01-01')
-- select NCOMPID, COMPNAME, 创建药房编号, 创建药房名称, 患者身份证, 患者姓名, POS订单号, 创建人, 创建时间, 订单类型, 原销售单号,
--        已退货数量, 购买方式, 总金额, 收费人, 收费时间, 收款金额, 是否首次订单, 第几次购药,null as 本年度首次购药时间, 第几年度,
--        订单次数, 是否医保, 参保人员类别
-- from a1;
select POS订单号, 创建时间, 患者身份证, 患者姓名, rank
from a2;

--明细表
select d.SALENO as POS订单号, qy.NWAREID as 中台药品编码,
       round(((d.wareqty + (CASE
                                WHEN d.stdtomin = 0 THEN
                                    0
                                ELSE
                                    d.minqty / d.stdtomin
           END)) * d.times), 2) as 数量, d.STDPRICE as 单价, d.NETPRICE as 折后单价,
       d.NETAMT as 折后总价,
       null as 批号ID, d.MAKENO as 批号, d.INVALIDATE as 效期, d.BATID as 批次ID,
       case when rh.RETSALENO is null then 0 else 1 end as 订单类型,
       case
           when rh.SALENO is not null then round(((d.wareqty + (CASE
                                                                    WHEN d.stdtomin = 0 THEN
                                                                        0
                                                                    ELSE
                                                                        d.minqty / d.stdtomin
               END)) * d.times), 2)
           else null end as 退货数量, d.SALER as 销货员工号,
       su.USERNAME as 销货员姓名
from t_sale_d d
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID);

--订单收费表
select h.SALENO as POS订单号, s_dddw_list.DDDWLISTDISPLAY as 收费方式, pay.NETSUM as 收费金额
from t_sale_h h
         left join s_busi s on h.BUSNO = s.BUSNO
         left join S_COMPANY sc on s.COMPID = sc.COMPID
         left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
         left join T_SALE_RETURN_H rh on rh.SALENO = h.SALENO
         left join t_sale_pay pay on h.SALENO = pay.SALENO
--          left join s_dddw_list on pay.PAYTYPE = s_dddw_list.dddwlistdata and s_dddw_list.dddwliststatus = 1 AND
--                                   s_dddw_list.dddwname = '222'
          left join (select dddwlistdata, DDDWLISTDISPLAY
                    from s_dddw_list
                    where dddwname = '222'
                    group by dddwlistdata, DDDWLISTDISPLAY) s_dddw_list on pay.PAYTYPE = s_dddw_list.dddwlistdata
where exists(select 1
             from t_sale_d d
             where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
  and s.BUSNO < 89000;


--患者用药明细表
select d.SALENO as POS订单号, qy.NWAREID as 中台药品编码, d.WAREQTY as 商品数量, th.USERNAME as 患者姓名,
       th.PHONE as 患者手机号,
       w.HF_DAY as 用药天数,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) AS 开始用药时间,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) + d.WAREQTY * w.HF_DAY as 结束用药时间,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) AS 上次开始用药时间,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) +
       d.WAREQTY * w.HF_DAY as 上次结束用药时间
from t_sale_d d
         left join t_sale_h h on d.SALENO = h.SALENO
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
         left join D_SJZL_DB_WARE w on d.WAREID = w.WAREID
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = d.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO = d.SALENO)
and h.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
              and h.BUSNO < 89000;


--处方表
select qy.NCOMPID, sc.COMPNAME, qy.NBUSNO as 创建药房编号, s.ORGNAME as 创建药房名称,
                   th.IDCARDNO as 患者身份证, th.USERNAME as 患者姓名, h.SALENO as POS订单号, null as 创建人,
                   h.STARTTIME as 创建时间,
                   case when rh.RETSALENO is null then 0 else 1 end as 订单类型,
                   rh.RETSALENO as 原销售单号, null as 已退货数量, null as 购买方式, trunc(h.NETSUM, 2) as 总金额,
                   null as 收费人,
                   h.FINALTIME as 收费时间, trunc(h.NETSUM, 2) as 收款金额,
                   case
                       when row_number() over (partition by th.IDCARDNO order by h.STARTTIME) = 1 then '是'
                       else '否' end as 是否首次订单,
                   row_number() over (partition by th.IDCARDNO order by h.STARTTIME) 第几次购药,
                   null as 本年度首次购药时间,
--        count(distinct trunc(STARTTIME,'yyyy')) over ( partition by th.IDCARDNO) as  第几年度,
                   dense_rank() over (partition by th.IDCARDNO order by trunc(STARTTIME, 'yyyy')) as 第几年度,
                   count(th.IDCARDNO) over (partition by th.IDCARDNO) as 订单次数,
                   case when cyb.ERP销售单号 is null then '否' else '是' end as 是否医保,
                   cyb.参保人员类别
            from t_sale_h h
                     left join s_busi s on h.BUSNO = s.BUSNO
                     left join S_COMPANY sc on s.COMPID = sc.COMPID
                     left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
                     LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                                    decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                                           instr(h.notes, ' ')) - 1) = th.cfno
                     left join T_SALE_RETURN_H rh on rh.SALENO = h.SALENO
                     left join D_ZHYB_HZ_CYB cyb on h.SALENO = cyb.ERP销售单号
            where exists(select 1
                         from t_sale_d d
                         where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
              and s.BUSNO < 89000







