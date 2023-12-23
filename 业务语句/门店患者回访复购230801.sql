with a as (
select a.*,row_number() over(partition by a.�˿����� order by a.�����) as ʱ����ڵڼ������� from(
SELECT a.accdate as �����,a.saleno as ���۵���,a.saler as ����Ա������,su.username as Ա������,tr.cfno as �������,
a.wareid,
nvl(tr.ext_str7,f.ext_str7) as ���ʱ��,
nvl(tr.USERNAME,f.uname) as �˿�����,
nvl(tr.IDCARDNO,f.idcard) as IDCARDNO,
nvl(tr.PHONE,f.mobile) as phone,
b.hf_day as �ط�����,
case when hf_zt=1 then a.accdate+b.hf_day else  a.accdate+(b.hf_day+3)*a.wareqty-3 end as �´���ҩʱ��,
  nvl(tr.ext_str7,f.ext_str7)+b.hf_day as �´��������
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
 WHERE  exists (select 1 from d_sjzl_db_ware c WHERE b.wareid=c.wareid) and username is not null and status=4 and trim(username)<>'����' and b.wareqty>0
 group by a.cfno,a.createtime,trim(a.username) ) oo
 on  trim(tr.username)=oo.kk and tr.cfno=oo.cfno
 WHERE a.accdate between trunc(add_months(sysdate,-7)) and trunc(sysdate)
 and (  a.accdate >= to_date('2023-06-01', 'yyyy-MM-dd')
 and a.accdate < to_date('2023-08-02', 'yyyy-MM-dd') and  a.saler =10003465  )
)a  ),
--ÿ��Ա����������
t_total  as (
select a.����Ա������,count(distinct ���۵���) as ���� from a
group by  a.����Ա������
),
--ÿ��Ա����������
t_complete as
(select a.����Ա������,count(distinct ���۵���) as  ����� from a
 where ���ʱ��<=�´���ҩʱ��
 group by  a.����Ա������),
--ÿ�����۵��ŵ���Ϣ
t_saleno as (
select a.���۵���,max(a.�����) as �����,max(a.����Ա������) as ����Ա������ ,max(a.�������) as �������,
max(a.phone) as phone,max(a.�˿�����) as �˿�����,max(a.�´���ҩʱ��) as �´���ҩʱ��,max(a.wareid)as wareid
from a group by ���۵���
),
--���������۵�����Ϣ
t_fg as(
select * from (
select tr.cfno,sa.�������,aa.saler,aa.accdate,aa.wareid,tr.USERNAME,sa.�´���ҩʱ��,
row_number() over(partition by sa.������� order by aa.accdate) as rn
FROM t_sale_d aa
join t_sale_h th on aa.saleno=th.saleno
left join  t_remote_prescription_h tr ON substr(th.notes,0,decode(instr(th.notes,' '),0,length(th.notes)+1,instr(th.notes,' '))-1)=tr.cfno
join t_saleno sa on aa.saler=sa.����Ա������ 
where tr.USERNAME=sa.�˿����� and aa.accdate>sa.�´���ҩʱ�� and aa.wareid=sa.wareid)
where rn=1
 --where username='�ս���'
)
 select * from t_total
 --select a.����Ա������,a.����,nvl(b.�����,0) from t_total a
 --left join   t_complete  b on a.����Ա������=b.����Ա������

--Ҷ���� 230601112406111   230622112407356 230713112403202 230803112404418
