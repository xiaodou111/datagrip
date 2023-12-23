with base_22 as (
 select a.identityno,tb22.classname as mdlx,a.nb_flag, CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '台州市本级'
    ELSE tb2.classname
  END as mdfw,count(distinct trunc(receiptdate)) as sl--,count(*) as sumsksl 
 from d_yb_first_cus a
 --303事业部
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 --324 门店区域
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  --门店类型(药店诊所)  
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
     join d_zjys_wl2023xse xse on xse.ERP销售号=a.erpsaleno 
    JOIN (select ERP销售单号,统筹支付数,公补基金支付数,个人当年帐户支付数,医疗费用总额 from  d_zhyb_hz_cyb
          union select ERP销售号,统筹金额,公务员补助支付,当年账户支付,医疗总费用  from tmp_wlybjs_cyb) cyb ON a.erpsaleno=cyb.erp销售单号 --AND d_zhyb_hz_cyb.异地标志='非异地'
   JOIN (select BUSNO,SALENO,ACCDATE,GTJEED from d_ll_zxcy
         union 
         select busno,saleno,accdate,gtjeed from D_LL_ZXCY_TEMP_2) d_ll_zxcy  ON cyb.erp销售单号=d_ll_zxcy.saleno
 
 where a.RECEIPTDATE between DATE'2022-01-01' and date'2022-10-31'
 AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001') 
  AND nvl(cyb.统筹支付数,0)+nvl(cyb.公补基金支付数,0)+nvl(cyb.个人当年帐户支付数,0)<>0
and cyb.医疗费用总额 - nvl(gtjeed,0)<>0
 --and  identityno='332623193301011416'
 group by a.identityno,tb22.classname,a.nb_flag,CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '台州市本级'
    ELSE tb2.classname
  END ),
  --根据上一张表统计每个区域,医保类型,药店类型 sl分为为1,2,3,>3的顾客的数量
sksl_22 as (
  select mdfw,nb_flag,mdlx,case when sl<=3 then sl else 4 end as sl,count(identityno) as onedaysl
  from base_22 
  --where sl=1 and nb_flag=1 and mdlx='门店'  
  group by mdfw,nb_flag,mdlx,case when sl<=3 then sl else 4 end ),
  --给上面的五种结果行转列
sksl_22_PIVOT as ( SELECT *
  FROM
  sksl_22
  PIVOT
  (
  max(onedaysl)
  FOR sl IN (1 AS onedaysl, 2 AS twodaysl, 3 AS threedaysl, 4 AS moredaysl)
  )
  ),
  --合计刷卡数量
sksl_22_sum as (
  select mdfw,nb_flag,mdlx,sum(sl) as sumsksl
  from base_22 
  --where sl=1 and nb_flag=1 and mdlx='门店'  
  group by mdfw,nb_flag,mdlx)
 
 select aa.*,sum22.sumsksl as 合计刷卡数量,sum22.sumsksl/(aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL) as 人均刷卡天数,
 aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL as 人头数,
 (aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL)/(aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL) as 三天内占比
  from sksl_22_PIVOT  aa
  left join sksl_22_sum sum22 on aa.mdfw=sum22.mdfw and  aa.NB_FLAG=sum22.NB_FLAG and aa.MDLX=sum22.MDLX
  where aa.NB_FLAG=1 and aa.MDLX='门店'  and  aa.MDFW='台州市临海市'
