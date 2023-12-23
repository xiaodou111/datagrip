create table d_o2o_basic(
busno number primary key,
mtfwname varchar2(200),
mtfwno varchar2(200),
busfwname varchar2(200),
busfwno varchar2(200),
elefwname varchar2(200),
elefwno varchar2(200),
jdfwname varchar2(200),
jdfwno varchar2(200),
xlsyydj varchar2(200)
)


select a.busno,s.orgname,mtfwname,mtfwno,busfwname,busfwno,elefwname,elefwno,jdfwname,tb.classname as 新零售门店等级铺货,jdfwno,xlsyydj
from
d_o2o_basic a
left join s_busi s on a.busno=s.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='3261'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode

left join (select busno,sum(lks_o2o) as lks from  d_busi_saler_tj where 
 accdate between trunc(ADD_MONTHS(SYSDATE,-1)) and trunc(sysdate)
 group by busno)k30 on s.busno=k30.busno
left join (select busno,sum(lks_o2o) as lks from  d_busi_saler_tj where 
 accdate between trunc(SYSDATE)-7 and trunc(sysdate)
 group by busno)k7 on s.busno=k7.busno
