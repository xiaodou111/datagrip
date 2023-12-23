create table d_o2o_perfor_month
(
busno number,
mt  varchar2(100),
ele varchar2(100),
cpsl  varchar2(100),
ycsl  varchar2(100),
ycyyysc varchar2(100),
dykhf varchar2(100)
)

select a.busno,s.orgname,tb.classname as city ,tb1.classname as pq,tb326.classname as xlsdj,kl.lks,
a.mt,a.ele,a.cpsl,a.ycsl,a.ycyyysc,a.dykhf,
dx.pzs_kc,
case when dx.pzs_mz_z=0 then 0 else dx.pzs_mz/dx.pzs_mz_z end as O2O重点品种满足数,
case when dx.dxpzs_o2o=0 then 0 else dx.pzs_o2o_qh/dx.dxpzs_o2o  end as O2O商品缺货率
 from d_o2o_perfor_month a
join  s_busi s on a.busno=s.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='324'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode
join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
join t_busno_class_base tb1 on ts1.classgroupno=tb1.classgroupno and ts1.classcode=tb1.classcode
join t_busno_class_set ts326 on a.busno=ts326.busno and ts326.classgroupno ='326'
join t_busno_class_base tb326 on ts326.classgroupno=tb326.classgroupno and ts326.classcode=tb326.classcode
left join (select busno,sum(lks_o2o) as lks from  d_busi_saler_tj where 
 accdate between trunc(ADD_MONTHS(SYSDATE,-1)) and trunc(sysdate)
 group by busno) kl on a.busno=kl.busno
 left join D_O2O_DX_TJ dx on a.busno=dx.busno
