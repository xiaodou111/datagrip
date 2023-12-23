with a as (
select a.*,row_number() over(partition by a.顾客姓名 order by a.会计日) as 时间段内第几个单号 from(
SELECT a.accdate as 会计日,a.saleno as 销售单号,a.saler as 销售员工工号,su.username as 员工姓名,tr.cfno as 处方编号,
a.wareid,
nvl(tr.ext_str7,f.ext_str7) as 随访时间,
nvl(tr.USERNAME,f.uname) as 顾客姓名,
nvl(tr.IDCARDNO,f.idcard) as IDCARDNO,
nvl(tr.PHONE,f.mobile) as phone,
b.hf_day as 回访周期,
case when hf_zt=1 then a.accdate+b.hf_day else  a.accdate+(b.hf_day+3)*a.wareqty-3 end as 下次用药时间,
  nvl(tr.ext_str7,f.ext_str7)+b.hf_day as 下次随访日期
FROM t_sale_d a
inner join t_sale_h th on a.saleno=th.saleno
inner join d_sjzl_db_ware b on a.wareid=b.wareid
left join s_busi c on a.busno=c.busno
left join t_ware_base d on a.wareid=d.wareid
left join t_factory e on d.factoryid=e.factoryid
left join  t_remote_prescription_h tr ON substr(th.notes,0,decode(instr(th.notes,' '),0,length(th.notes)+1,instr(th.notes,' '))-1)=tr.cfno
left join d_sjzl_db_cfxx f on a.saleno=f.saleno
left join s_user_base su on a.saler=su.userid
left join   t_sale_pay pay on a.saleno=pay.saleno and pay.paytype in('Z064','Z062','Z060','Z061','Z063','Z066','809084','Z089')
left join ( SELECT a.cfno,a.createtime,trim(a.username) as kk,row_number() over(partition by trim(a.username) order by a.createtime) as rn FROM t_remote_prescription_h  a
 inner join t_remote_prescription_d b on a.cfno=b.cfno
 WHERE  exists (select 1 from d_sjzl_db_ware c WHERE b.wareid=c.wareid) and username is not null and status=4 and trim(username)<>'作废' and b.wareqty>0
 group by a.cfno,a.createtime,trim(a.username) ) oo
 on  trim(tr.username)=oo.kk and tr.cfno=oo.cfno
 WHERE a.accdate between trunc(add_months(sysdate,-7)) and trunc(sysdate)
 and (  a.accdate >= to_date('2023-06-01', 'yyyy-MM-dd')
 and a.accdate < to_date('2023-08-02', 'yyyy-MM-dd') and  a.saler =10003465  )
)a  ),
--每个员工销售总数
t_total  as (
select a.销售员工工号,count(distinct 销售单号) as 总数 from a
group by  a.销售员工工号
),
--每个员工完成随访数
t_complete as
(select a.销售员工工号,count(distinct 销售单号) as  完成数 from a
 where 随访时间<=下次用药时间
 group by  a.销售员工工号),
--每个销售单号的信息
t_saleno as (
select a.销售单号,max(a.会计日) as 会计日,max(a.销售员工工号) as 销售员工工号 ,max(a.处方编号) as 处方编号,
max(a.phone) as phone,max(a.顾客姓名) as 顾客姓名,max(a.下次用药时间) as 下次用药时间,max(a.wareid)as wareid
from a group by 销售单号
),
--复购的销售单号信息
t_fg as(
select * from (
select tr.cfno,sa.处方编号,aa.saler,aa.accdate,aa.wareid,tr.USERNAME,sa.下次用药时间,
row_number() over(partition by sa.处方编号 order by aa.accdate) as rn
FROM t_sale_d aa
join t_sale_h th on aa.saleno=th.saleno
left join  t_remote_prescription_h tr ON substr(th.notes,0,decode(instr(th.notes,' '),0,length(th.notes)+1,instr(th.notes,' '))-1)=tr.cfno
join t_saleno sa on aa.saler=sa.销售员工工号 
where tr.USERNAME=sa.顾客姓名 and aa.accdate>sa.下次用药时间 and aa.wareid=sa.wareid)
where rn=1
 --where username='颜娇云'
)
 select * from t_total
 --select a.销售员工工号,a.总数,nvl(b.完成数,0) from t_total a
 --left join   t_complete  b on a.销售员工工号=b.销售员工工号

--叶春富 230601112406111   230622112407356 230713112403202 230803112404418
