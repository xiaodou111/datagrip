call proc_v_spjxq ()
f_get_busno_classname
select a.ZMDZ1,s.orgname,a.DRZB,b.sumavaqty sumavaqty03 ,b.sumje sumje03,c.sumavaqty sumavaqty46,c.sumje sumje46
,d.sumavaqty sumavaqty79,d.sumje sumje79,e.sumwareqty sumwareqty03,e.sumstdsum sumstdsum03
,f.sumwareqty sumwareqty46,f.sumstdsum sumstdsum46,
g.sumwareqty sumwareqty79,g.sumstdsum sumstdsum79,e.sumstdsum+f.sumstdsum*0.7+g.sumstdsum*0.3,
(e.sumstdsum+f.sumstdsum*0.7+g.sumstdsum*0.3)/decode(a.DRZB,0,null,a.DRZB)
 from  S_JXQ_ZMDZ1 a 
left join t_spjxq03 b on a.ZMDZ1=b.zmdz1
left join t_spjxq46 c on a.ZMDZ1=c.zmdz1
left join t_spjxq79 d on a.ZMDZ1=d.zmdz1
left join T_SPJXQXSE03 e on a.ZMDZ1=e.zmdz1
left join T_SPJXQXSE46 f on a.ZMDZ1=f.zmdz1
left join T_SPJXQXSE79 g on a.ZMDZ1=g.zmdz1
left join s_busi s on a.zmdz1=s.busno
left join t_busno_class_set 


select * from S_JXQ_ZMDZ1 order by ZMDZ1 asc  for update
insert into S_JXQ_ZMDZ1(ZMDZ1)  select ZMDZ1 from s_busi where 
busno not like '82%' and busno not like '89%' and busno not like '86%' and ZMDZ1 is not null group by  ZMDZ1

 


