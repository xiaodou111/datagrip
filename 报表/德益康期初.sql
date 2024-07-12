--dtp订单表 a1获取除 本年度首次购药时间以外所有字段
--已退货数量,购买方式,收费人 需要去明细表里看,本年度首次购药时间a2表用excel关联
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
                         where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废' and th.PHONE is not null
              and s.BUSNO < 89000),
     a2 as (select POS订单号, 创建时间,  a1.患者姓名,患者手机号,
                   rank() over (partition by 患者姓名,患者手机号 order by 创建时间) as 本年度第几次购药
            from a1
            where 创建时间 >= date'2024-01-01')
 select 创建所属区域编号, 创建所属区域名称, 创建药房编号, 创建药房名称,  患者姓名,患者手机号,患者身份证, POS订单号, 创建人, 创建时间, 订单类型, 原销售单号,
       已退货数量, 购买方式, 总金额, 收费人, 收费时间, 收款金额, 是否首次订单, 第几次购药,null as 本年度首次购药时间, 第几年度,
       订单次数, 是否医保, 参保人员类别
from a1  ;
-- select POS订单号, 创建时间, 患者姓名,患者手机号, 本年度第几次购药
-- from a2 where 本年度第几次购药=1;

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
         left join t_sale_h h on d.SALENO = h.SALENO
         left join s_busi s on h.BUSNO = s.BUSNO
         left join t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
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
             where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废'
              and th.PHONE is not null
  and s.BUSNO < 89000;

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
       d.WAREQTY * w.HFTS as 上次结束用药时间
from t_sale_d d
         left join t_sale_h h on d.SALENO = h.SALENO
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
         left join d_dtp_yysj w on d.WAREID = w.WAREID
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = d.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO = d.SALENO)
  and h.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '作废' and th.PHONE is not null
  and h.BUSNO < 89000;



--患者表 字段都取第一次↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
delete
from d_hz_firstcfno;
insert into d_hz_firstcfno
select trim(th1.USERNAME) as USERNAME, trim(th1.PHONE) as PHONE, min(th1.CFNO) as cfno
from t_remote_prescription_h th1
         join t_remote_prescription_d td on th1.CFNO = td.CFNO
         left join s_busi s on th1.BUSNO = s.BUSNO
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = td.WAREID) and th1.USERNAME is not null
  and th1.USERNAME <> '作废' and th1.PHONE is not null and s.COMPID <> 1900 and s.BUSNO < 89000
group by trim(th1.USERNAME), trim(th1.PHONE);


select 'RT' as 创建所属区域编号, '瑞人堂' as 创建所属区域名称, qy.NBUSNO as 创建药房编号, s.ORGNAME as 创建药房名称,
       th.USERNAME, th.SEX as 性别, th.IDCARDNO as 身份证号, th.BIRTHDAY as 生日,
       TRUNC(MONTHS_BETWEEN(SYSDATE, birthday) / 12) AS 年龄, th.PHONE as 手机号, th.ADDRESS as 地址, th.ZDCONT as 病种,
       cyb.卡号 as 医保卡号,nvl(th.EXT_STR6,f.EXT_STR6) as 不良反应
from t_remote_prescription_h th
         left join s_busi s on th.BUSNO = s.BUSNO
         left join S_COMPANY sc on s.COMPID = sc.COMPID
         left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
         left join t_sale_h h ON substr(h.notes, 0,
                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                               instr(h.notes, ' ')) - 1) = th.cfno
         left join D_ZHYB_HZ_CYB cyb on h.SALENO = cyb.ERP销售单号
         left join  d_sjzl_db_cfxx f on h.saleno=f.saleno
where exists(select 1 from d_hz_firstcfno a1 where a1.cfno = th.cfno);
--患者表 字段都取第一次↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑



 -- 患者用药周期表  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--患者每个药第一次购买的处方号
drop table D_HZ_firstwareCFNO;
create table D_HZ_firstwareCFNO
(
    USERNAME VARCHAR2(200),
    PHONE    VARCHAR2(200),
    wareid   number,
    CFNO     VARCHAR2(40) not null
);

insert into D_HZ_firstwareCFNO
select trim(th1.USERNAME) as USERNAME, trim(th1.PHONE) as PHONE,td.WAREID, min(th1.CFNO) as cfno
from t_remote_prescription_h th1
         join t_remote_prescription_d td on th1.CFNO = td.CFNO
         left join s_busi s on th1.BUSNO = s.BUSNO
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = td.WAREID) and th1.USERNAME is not null
  and th1.USERNAME <> '作废' and th1.PHONE is not null and s.COMPID <> 1900 and s.BUSNO < 89000
group by trim(th1.USERNAME), trim(th1.PHONE),td.WAREID;




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
left join d_luoshi_jm_hf jm on jm.IDCARD=sum.idcardno;

 -- 患者用药周期表  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑



--23年之后需要补手机号的处方
-- select h.CFNO, h.BUSNO, s.ORGNAME, h.USERNAME, d.WAREID, w.WARENAME
-- from t_remote_prescription_h h
--          left join t_remote_prescription_d d on h.CFNO = d.CFNO
--          left join s_busi s on h.BUSNO = s.BUSNO
--          left join t_ware_base w on d.WAREID = w.WAREID
-- where CREATETIME >= date'2023-01-01' and PHONE is null
--   and exists(select 1
--              from t_remote_prescription_d d
--              where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
--                and d.CFNO = h.CFNO);
-- select EXT_STR4 from t_remote_prescription_h ;
-- select * from d_sjzl_db_cfxx;

-- SELECT to_char(a.accdate,'yyyymm') as amonth,a.accdate ,a.saleno,a.wareid,d.warename,d.warespec,e.factoryname,
-- a.saler,su.username as salername,a.wareqty,a.netprice,a.netamt,a.invalidate,th.membercardno,tr.cfno,
-- nvl(tr.ext_str4,f.ext_str4) as ext_str4,nvl(tr.ext_str5,f.ext_str5) as ext_str5,
-- nvl(nvl(th.ext_str1,tr.doctorname),f.cfyy) as cfyy,nvl(tr.DOCTOR,f.doctor) as doctor,nvl(tr.ZDCONT,f.syz) as ZDCONT,
-- nvl(tr.allergy,f.gms) as gms,nvl(tr.ext_str6,f.ext_str6) as ext_str6,
-- nvl(tr.ext_str7,f.ext_str7) as ext_str7,
--  a.accdate+b.hf_day*sum(a.WAREQTY) over ( partition by a.SALENO,a.WAREID)-3  as next_sfday,
-- nvl(tr.USERNAME,f.uname) as USERNAME,nvl(tr.address,f.address) as address,nvl(tr.SEX,f.sex) as sex,nvl(tr.CAGE,f.age) as cage,nvl(tr.PHONE,f.mobile) as phone,
-- nvl(tr.IDCARDNO,f.idcard) as IDCARDNO,a.busno,c.orgname,--tb.classname as syb,tb1.classname as pq,
-- oo.rn,
-- b.hf_day,
--  a.accdate+b.hf_day*sum(a.WAREQTY) over ( partition by a.SALENO,a.WAREID)  as next_day,a.makeno,a.rowno,
-- nvl(tr.lastmodify,f.lastmodify) as lastmodify,nvl(tr.lasttime,f.lasttime) as lasttime,case when  pay.saleno is null then 0 else 1 end as ifyb,nvl(tr.iffugou,f.iffugou) as iffugou,
-- nvl(tr.NOFG_REASON,f.NOFG_REASON) as  NOFG_REASON,tr.syz FROM t_sale_d a
-- inner join t_sale_h th on a.saleno=th.saleno
-- inner join d_sjzl_db_ware b on a.wareid=b.wareid
-- left join s_busi c on a.busno=c.busno
-- left join t_ware_base d on a.wareid=d.wareid
-- left join t_factory e on d.factoryid=e.factoryid
-- left join  t_remote_prescription_h tr ON substr(th.notes,0,decode(instr(th.notes,' '),0,length(th.notes)+1,instr(th.notes,' '))-1)=tr.cfno
-- left join d_sjzl_db_cfxx f on a.saleno=f.saleno
-- left join s_user_base su on a.saler=su.userid
-- left join   t_sale_pay pay on a.saleno=pay.saleno and pay.paytype in('Z064','Z062','Z060','Z061','Z063','Z066','809084','Z089')
-- left join ( SELECT a.cfno,a.createtime,trim(a.username) as kk,row_number() over(partition by trim(a.username) order by a.createtime) as rn FROM t_remote_prescription_h  a
-- inner join t_remote_prescription_d b on a.cfno=b.cfno
-- WHERE  exists (select 1 from d_sjzl_db_ware c WHERE b.wareid=c.wareid) and username is not null and status=4 and trim(username)<>'作废' and b.wareqty>0
-- group by a.cfno,a.createtime,trim(a.username) ) oo
-- on  trim(tr.username)=oo.kk and tr.cfno=oo.cfno WHERE a.saleno = '2406101030047339' AND EXISTS (SELECT 1 FROM S_USER_BUSI WHERE S_USER_BUSI.STATUS=1 AND S_USER_BUSI.USERID=50002418 AND S_USER_BUSI.BUSNO=th.busno)
--






