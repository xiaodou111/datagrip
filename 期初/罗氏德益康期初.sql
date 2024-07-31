--dtp订单表
with a1 as (select 'RT' as 创建所属区域编号, '瑞人堂' as 创建所属区域名称, qy.NBUSNO as 创建药房编号,
                   s.ORGNAME as 创建药房名称,
                   th.IDCARDNO as 患者身份证,  trim(th.USERNAME) as 患者姓名,trim(th.phone) as 患者手机号, h.SALENO as POS订单号, null as 创建人,
                   h.STARTTIME as 创建时间,
                   case when rh.RETSALENO is null then 0 else 1 end as 订单类型,
                   rh.RETSALENO as 原销售单号, null as 已退货数量, null as 购买方式, trunc(h.NETSUM, 2) as 总金额,
                   null as 收费人,
                   h.FINALTIME as 收费时间, trunc(h.NETSUM, 2) as 收款金额,
                   case
                       when row_number() over (partition by trim(th.USERNAME),trim(th.phone) order by h.STARTTIME) = 1 then '是'
                       else '否' end as 是否首次订单,
                   row_number() over (partition by trim(th.USERNAME),trim(th.phone) order by h.STARTTIME) 第几次购药,
                   null as 本年度首次购药时间,
--        count(distinct trunc(STARTTIME,'yyyy')) over ( partition by th.IDCARDNO) as  第几年度,
                   dense_rank() over (partition by trim(th.USERNAME),trim(th.phone) order by trunc(STARTTIME, 'yyyy')) as 第几年度,
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
                         where d.WAREID in (10601875,10502445,10600308)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废' and th.PHONE is not null
              and s.BUSNO < 89000),
     a2 as (select POS订单号, 创建时间,  a1.患者姓名,患者手机号,
                   rank() over (partition by 患者姓名,患者手机号 order by 创建时间) as 本年度第几次购药
            from a1
            where 创建时间 >= date'2024-01-01')
 select 创建所属区域编号, 创建所属区域名称, 创建药房编号, 创建药房名称,  a1.患者姓名,a1.患者手机号,患者身份证,a1.POS订单号, 创建人, a1.创建时间, 订单类型, 原销售单号,
       已退货数量, 购买方式, 总金额, 收费人, 收费时间, 收款金额, 是否首次订单, 第几次购药,
       a2.本年度第几次购药,
--        null as 本年度首次购药时间,
       第几年度,
       订单次数, 是否医保, 参保人员类别
from a1 left join a2 on a1.患者姓名=a2.患者姓名 and a1.POS订单号=a2.POS订单号 ;
--订单明细表
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
         left join t_sale_h h on d.SALENO = h.SALENO
         left join s_busi s on h.BUSNO = s.BUSNO
         left join t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where d.WAREID in (10601875,10502445,10600308)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废' and th.PHONE is not null
  and s.BUSNO < 89000;
--处方表
select h.SALENO, th.CFNO, null as 处方签号, th.DOCTORNAME as 医院名称, null as 科室, DOCTOR as 医生名称,
       th.DOCTORTIME as 处方时间,
       th.ZDCONT as 病种, CHECKER_YISHI as 审核医师, th.CHECKTIME_YISHI as 医师审核时间, CHECKER_YAOSHI as 审核药师,
       th.CHECKTIME_YAOSHI as 药师审核时间, DEPLOYER as 调配人, null as 调配时间, th.CHECKUSER as 复核人,
       null as 复核时间,
       th.CREATETIME as 创建时间
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
             where d.WAREID in (10601875,10502445,10600308)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
              and th.PHONE is not null
  and s.BUSNO < 89000
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
             where d.WAREID in (10601875,10502445,10600308)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废' and th.PHONE is not null
  and s.BUSNO < 89000;

--患者用药明细表,用法用量让phc匹配
select d.SALENO as POS订单号, qy.NWAREID as 中台药品编码, d.WAREQTY as 商品数量, trim(th.USERNAME) as 患者姓名,
       trim(th.PHONE) as 患者手机号, null as 用法用量,
       w.HFTS as 用药天数,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) AS 开始用药时间,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) + d.WAREQTY * w.HFTS as 结束用药时间,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) AS 上次开始用药时间,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) +
       d.WAREQTY * w.HFTS as 上次结束用药时间,th.CFNO as POS处方编码
from t_sale_d d
         left join t_sale_h h on d.SALENO = h.SALENO
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
         left join d_dtp_yysj w on d.WAREID = w.WAREID
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where d.WAREID in (10601875,10502445,10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = d.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO = d.SALENO)
  and h.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废' and th.PHONE is not null
  and h.BUSNO < 89000;

--患者用药周期表
with first as (
select th.cfno as 首次处方号, trim(th.USERNAME) as 患者姓名,th.IDCARDNO,
       trim(th.PHONE) as 患者手机号,qy.NBUSNO as 中台门店编码,td.WAREID, h.ACCDATE as 首次购药时间, th.DOCTORNAME as 首次处方医院,
       null as 首次处方科室, th.DOCTOR as 首次医生, th.CREATETIME as 创建时间
from t_remote_prescription_h th
-- left join t_remote_prescription_d td on th.CFNO = td.CFNO
         left join s_busi s on th.BUSNO = s.BUSNO
         left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
-- left join d_rrt_qy_ware qyw  on qyw.owareid=td.wareid
         left join t_sale_h h ON substr(h.notes, 0,
                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                               instr(h.notes, ' ')) - 1) = th.cfno
         join t_remote_prescription_d td on th.CFNO = td.CFNO
where exists(select 1 from D_HZ_firstwareCFNO a1 where a1.cfno = th.cfno)),
-- and td.WAREID in (10601875,10502445,10600308)),
--USERNAME,PHONE,NWAREID 累计购药数量	累计购药金额
sum as (   select
    trim(th.USERNAME) as 患者姓名,
       trim(th.PHONE) as 患者手机号,
       td.WAREID,
       sum(td.WAREQTY) as 累计购药数量,
       sum(td.NETPRICE*td.WAREQTY)  as 累计购药金额,
       nvl(max(th.EXT_STR4),max(f.EXT_STR4)) as 未按计划原因,
       max(th.IDCARDNO) as idcardno
from t_remote_prescription_d td

         LEFT JOIN t_remote_prescription_h th ON td.CFNO = th.cfno
         left join t_sale_h h ON substr(h.notes, 0,
                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                               instr(h.notes, ' ')) - 1) = th.cfno
         left join d_sjzl_db_cfxx f on h.saleno=f.saleno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = td.WAREID)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = h.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh2 where rh2.SALENO = h.SALENO)
  and th.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
  and th.BUSNO < 89000 group by trim(th.USERNAME),trim(th.PHONE),td.WAREID )
select 首次处方号, first.患者姓名 as 患者姓名, sum.IDCARDNO as 身份证, first.患者手机号 as 患者手机号, 中台门店编码 ,qy.NWAREID as 中台药品编码,首次购药时间,
       累计购药数量,累计购药金额,null as 患者用药状态,NVL(NVL(px.CFSF, jm.CFSF), 未按计划原因) as 未按计划原因,
       首次处方医院, 首次处方科室, 首次医生, 创建时间
from first
left join sum on first.患者姓名=sum.患者姓名 and first.患者手机号=sum.患者手机号 and first.WAREID=sum.WAREID
left join d_rrt_qy_ware qy on first.WAREID = qy.OWAREID
left join d_luoshi_px_hf px on px.IDCARD= sum.idcardno
left join d_luoshi_jm_hf jm on jm.IDCARD=sum.idcardno
where qy.OWAREID in (10601875,10502445,10600308);

 -- 患者用药周期表  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

select * from d_rrt_qy_ware where OWAREID in (10601875,10502445,10600308);
select * from T_REMOTE_PRESCRIPTION_d where CFNO='240118112402026';