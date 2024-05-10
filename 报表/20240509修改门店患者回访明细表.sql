SELECT to_char(a.accdate,'yyyymm') as amonth,a.accdate ,a.saleno,a.wareid,d.warename,d.warespec,e.factoryname,
a.saler,su.username as salername,a.wareqty,a.netprice,a.netamt,a.invalidate,th.membercardno,tr.cfno,
nvl(tr.ext_str4,f.ext_str4) as ext_str4,nvl(tr.ext_str5,f.ext_str5) as ext_str5,
nvl(nvl(th.ext_str1,tr.doctorname),f.cfyy) as cfyy,nvl(tr.DOCTOR,f.doctor) as doctor,nvl(tr.ZDCONT,f.syz) as ZDCONT,
nvl(tr.allergy,f.gms) as gms,nvl(tr.ext_str6,f.ext_str6) as ext_str6,
nvl(tr.ext_str7,f.ext_str7) as ext_str7,
 a.accdate+b.hf_day-3  as next_sfday,
nvl(tr.USERNAME,f.uname) as USERNAME,nvl(tr.address,f.address) as address,nvl(tr.SEX,f.sex) as sex,nvl(tr.CAGE,f.age) as cage,nvl(tr.PHONE,f.mobile) as phone,
nvl(tr.IDCARDNO,f.idcard) as IDCARDNO,a.busno,c.orgname,--tb.classname as syb,tb1.classname as pq,
oo.rn,
b.hf_day,
 a.accdate+b.hf_day  as next_day,a.makeno,a.rowno,
nvl(tr.lastmodify,f.lastmodify) as lastmodify,nvl(tr.lasttime,f.lasttime) as lasttime,case when  pay.saleno is null then 0 else 1 end as ifyb,nvl(tr.iffugou,f.iffugou) as iffugou,
nvl(tr.NOFG_REASON,f.NOFG_REASON) as  NOFG_REASON FROM t_sale_d a 
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
WHERE  exists (select 1 from d_sjzl_db_ware c WHERE b.wareid=c.wareid) and username is not null and status=4 and trim(username)<>'×÷·Ï' and b.wareqty>0
group by a.cfno,a.createtime,trim(a.username) ) oo 
on  trim(tr.username)=oo.kk and tr.cfno=oo.cfno