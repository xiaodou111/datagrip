

select BUSNO,f_get_busno_classname('303',busno) syb,f_get_busno_classname('304',busno) pq,max(orgname),max(zb) as 指标 ,
sum(sl) 合计件数,
round(sum(wcl2),4)*100||'%'  完成率,
sum( case when wcl2>=1 and wcl2<2  then 2*floor(sl)
     when wcl2>=2 then 4*floor(sl)
     when wcl2<1 then 0 end  ) as jf  from 
(
select a.accdate,zb.BUSNO,b.orgname,zb.ZB_NETSUM_CJH zb ,a.sl,sl/decode(ZB_NETSUM_CJH,0,null,ZB_NETSUM_CJH) wcl2,
round(sl/decode(ZB_NETSUM_CJH,0,null,ZB_NETSUM_CJH),4)*100||'%' wcl from d_xcc_zb zb
left join 
(
select b.zmdz1,sum(a.NETSUM)/100 sl,a.accdate
from t_rpt_sale a 
left join s_busi b on a.busno=b.busno 
where a.accdate>=date'2023-03-01'  and a.wareid in (
select wareid   from  v_ware where factoryname like '%中智%' group by wareid 
)  group by  b.zmdz1,a.accdate
) a on zb.busno=a.zmdz1
left join s_busi b on zb.busno=b.busno 
where  zb.period=202303
) a where  accdate between date'2023-03-01'  and date'2023-03-08' group by BUSNO

--and zb.BUSNO=81001 



