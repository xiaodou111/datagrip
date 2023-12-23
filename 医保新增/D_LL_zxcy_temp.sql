insert into D_LL_zxcy_temp(busno,saleno,Accdate,Zxcy,Zxcyed,Zxcydtp,Zxcydtped,zyyp,zyyped,Qt,qted,gtje,gtjeed)
  select busno,saleno,max(创建时间) as 创建时间,
  sum(zxcy) as zxcy,
  sum(zxcyed) as zxcyed,
  sum(zxcydtp) as zxcydtp,
  sum(zxcydtped) as zxcydtped,
  sum(zyyp) as zyyp,
  sum(zyyped) as zyyped,
  sum(qt) as qt,
  sum(qted) as qted,
  sum(gtje) as gtje,
  sum(gtjeed) as gtjeed
   from(
  select h.机构编码 as busno,ERP销售号 as saleno,创建时间,
  sum(case when substring(c.classcode,1,4) in ('0110','0111') and d.classcode not in('12105','12116') and a.ext_char08<>1 and g.pzfl in ('国谈品种','双通道品种') then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  zxcy,
  sum(case when substring(c.classcode,1,4) in ('0110','0111') and d.classcode not in('12105','12116') and a.ext_char08<>1 and g.pzfl in ('国谈品种','双通道品种') then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  zxcyed,
  sum(case when substring(c.classcode,1,4) in ('0110','0111') and d.classcode in ('12105','12116') and g.pzfl in ('国谈品种','双通道品种') and a.ext_char08<>1  then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  zxcydtp,
  sum(case when substring(c.classcode,1,4) in ('0110','0111') and d.classcode in ('12105','12116') and g.pzfl in ('国谈品种','双通道品种') and a.ext_char08<>1  then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  zxcydtped,
  sum(case when substring(c.classcode,1,4) ='0112' and a.ext_char08<>1 then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  zyyp,
  sum(case when substring(c.classcode,1,4) ='0112' and a.ext_char08<>1 then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  zyyped,
  sum(case when substring(c.classcode,1,4) not in('0110','0111','0112') and a.ext_char08<>1  then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  qt,
  sum(case when substring(c.classcode,1,4) not in('0110','0111','0112') and a.ext_char08<>1  then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as  qted,
  case when sum(case when g.pzfl in ('国谈品种','双通道品种') then 0 else  (case when h.医疗费用总额<0 then -1 else 1 end)*amount end)=0 then 0
  else sum(case when g.pzfl in ('国谈品种','双通道品种') then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else  null end) end as gtje,
  sum(case when g.pzfl in ('国谈品种','双通道品种') then (case when h.医疗费用总额<0 then -1 else 1 end)*amount else 0 end) as gtjeed
  from t_yby_order_d a
  join t_yby_order_h oh on a.orderno=oh.orderno
  join v_zjys_zxcy h on h.ERP销售号=oh.erpsaleno
  --left join t_ware_class_base b on a.warecode=b.wareid and b.classgroupno='810' and b.compid=1000
  left join t_ware_class_base c on a.warecode=c.wareid and c.classgroupno='01' and c.compid=1000
  left join t_ware_class_base d on a.warecode=d.wareid and d.classgroupno='12' and d.compid=1000
  join t_busno_class_set ts on h.机构编码=ts.busno and ts.classgroupno ='320' and ts.classcode in ('320100','320104')
  join t_busno_class_set ts1 on h.机构编码=ts1.busno and ts1.classgroupno ='305' join t_busno_class_base tb1 on ts1.classgroupno=tb1.classgroupno and ts1.classcode=tb1.classcode
  left join d_ll_gtml g on case when ts1.classcode='30510' then '药店' else '诊所' end = g.ydzs and a.warecode=g.wareid and h.创建时间>g.begindate and h.创建时间<g.enddate+1
  where h.创建时间<date'2022-06-01'
  and trunc(h.创建时间)>=date'2022-01-01'
  and ERP销售号 is not null
  
  group by h.机构编码,ERP销售号,创建时间
  ) aaa
  
  group by busno,saleno;
  
  delete from D_LL_zxcy_temp where SALENO in (select  ERPSALENO from t_yby_order_h where TOTALAMOUNT<0)
  delete from D_LL_zxcy_temp a where SALENO in (select RETSALENO from t_sale_return_h 
    where saleno in(select ERPSALENO from t_yby_order_h where TOTALAMOUNT<0))
   
  select count(*)  from  D_LL_zxcy_temp a
  
  insert into D_LL_ZXCY_TEMP_2 select a.* from  D_LL_zxcy_temp a
  left join (select ERP销售单号,统筹支付数,公补基金支付数,个人当年帐户支付数,医疗费用总额 from  d_zhyb_hz_cyb
          union select ERP销售号,统筹金额,公务员补助支付,当年账户支付,医疗总费用  from tmp_wlybjs_cyb) cyb ON a.SALENO=cyb.erp销售单号 --AND d_zhyb_hz_cyb.异地标志='非异地'
  WHERE 
  --国谈条件
    nvl(cyb.统筹支付数,0)+nvl(cyb.公补基金支付数,0)+nvl(cyb.个人当年帐户支付数,0)<>0
and cyb.医疗费用总额 - nvl(gtjeed,0)<>0

delete from D_LL_ZXCY_TEMP_2  where saleno in (select saleno from d_ll_zxcy_22)



 select b.医保所在地编号,b.所在地名称,tb2.classname,
  case when nvl(人员类别,' ') in ('2511','40','41','2811','52') then '城乡居民基本医疗保险' else '职工基本医疗保险' end
  from D_LL_ZXCY_TEMP_2 a 
   join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
   join  tmp_wlybjs_cyb b on a.saleno=b.erp销售号
   --where a.accdate between date'2022-11-21' and date'2022-12-26' 
  group by tb2.classname,b.医保所在地编号,b.所在地名称,
  case when nvl(人员类别,' ') in ('2511','40','41','2811','52') then '城乡居民基本医疗保险' else '职工基本医疗保险' end

select to_char(RECEIPTDATE,'yyyy-mm'),count(*)  from D_YB_NEW_CUS_2023_09 group by to_char(RECEIPTDATE,'yyyy-mm')
select * from D_YB_NEW_CUS_2023_09  where erpsaleno='2201021031071929'
select * from D_LL_ZXCY_TEMP_2 where saleno='2201021031071929'
select max(RECEIPTDATE) from D_YB_NEW_CUS_2023_09
select max(accdate) from D_LL_ZXCY_TEMP_2

select BUSNO,SALENO,ACCDATE,GTJEED from d_ll_zxcy where accdate between date'2022-11-21' and date'2022-11-25' 
select ERP销售号,统筹金额,公务员补助支付,当年账户支付,医疗总费用  from tmp_wlybjs_cyb 
where 创建时间 between date'2022-11-21' and date'2022-11-30' 
select * from d_zjys_wl2023xse where 创建时间  between date'2022-11-21' and date'2022-11-25' 
select * from  d_zhyb_hz_cyb where 销售日期  between date'2022-11-21' and date'2022-11-25' 
select max(创建时间) from tmp_wlybjs_cyb
select * from D_YB_NEW_CUS_2023_09 where RECEIPTDATE between date'2022-11-21' and date'2022-11-25'


select * from d_zjys_wl2023xse where ERP销售号='2202061031090036' --有

select * from d_ll_zxcy where SALENO='2202061031090036' -- 无
select * from D_LL_ZXCY_TEMP_2 where SALENO='2202061031090036' --有

select * from  d_zhyb_hz_cyb where ERP销售单号='2202061031090036' --无
select ERP销售号,统筹金额,公务员补助支付,当年账户支付,医疗总费用 from  tmp_wlybjs_cyb where ERP销售号='2202061031090036' --有
select * from D_YB_NEW_CUS_2023_09  where IDENTITYNO='331004199409210921'
select GTJEED from D_LL_zxcy_temp where SALENO='2202061031090036'
