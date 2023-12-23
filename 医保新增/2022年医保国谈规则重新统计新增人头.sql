/*DELETE from d_zjys_wl2022_xs
INSERT INTO  d_zjys_wl2022_xs SELECT * FROM v_zjys_wl2022_xs;
INSERT INTO  d_zjys_wl2022_xs
select ERP销售号 AS erpsaleno,TRUNC(创建时间) AS receiptdate ,机构编码,d.saler,su.username,a.姓名,a.身份证号,
case when nvl(人员类别,' ') in ('2511','40','41','2811','52') then '1' else '0' END AS nb_flag,
医保所在地编号 AS cbd ,
CASE WHEN replace(所在地名称,'玉环县','玉环市') IN ('市本级','椒江区') THEN '市本级' ELSE replace(所在地名称,'玉环县','玉环市') END as cbdname,总金额 AS netsum,2 AS status,
case when info.COMPANYNAME like '%瑞人堂%' or info.COMPANYNAME like '%康康%' or info.COMPANYNAME like '%方同仁%'
 or info.COMPANYNAME like '%康盛堂%' then 1 else 0 end yg_flag,
case when nvl(就诊类型,' ')='1' then '1' when nvl(就诊类型,' ') in('33','34','39') then '2' else '0' END
 AS jslx,a.用户端就诊序号 AS orderno ,cy.参保人员类别 AS cbrylb
from tmp_wlybjs_cyb a
--
JOIN d_ll_zxcy b ON a.ERP销售号=b.saleno
--
INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
a.ERP销售号=d.saleno
left join s_user_base su on d.saler=su.userid
join hydee_taizhou.taizhou_personal_info info on info.IDNUMBER=a.身份证号
LEFT join D_ZHYB_HZ_CYB cy ON a.erp销售号=cy.erp销售单号 AND a.身份证号=cy.身份证号
WHERE 创建时间>=date'2022-01-01' AND 创建时间<date'2022-03-01'
--
AND nvl(基本医疗统筹支付,0)+nvl(公务员补助统筹支付,0)+nvl(当年账户支付,0)<>0
and 医疗总费用 - nvl(gtjeed,0)<>0 

SELECT CBDNAME FROM d_zjys_wl2022_xs GROUP BY CBDNAME
UPDATE d_zjys_wl2022_xs SET CBDNAME='台州市' ||CBDNAME WHERE LENGTH(CBDNAME)=3
 UPDATE d_zjys_wl2022_xs SET CBDNAME ='台州市市本级'  WHERE CBDNAME='台州市本级';
UPDATE d_zjys_wl2022_xs SET CBDNAME ='台州市玉环市' WHERE CBDNAME='台州市玉环县'*/
 
DELETE from D_YB_NEW_CUS_2023_09 WHERE RECEIPTDATE<date'2023-01-01'; 
INSERT INTO D_YB_NEW_CUS_2023_09
(erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno)
SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,
jslx,orderno
FROM (    

SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno,a.nb_flag, a.cbd, a.cbdname, 
a.netsum, a.status, a.yg_flag,a.jslx,a.orderno,a.cbrylb,
ROW_NUMBER() OVER (PARTITION BY 
 CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '324331001'
    ELSE tb2.classcode
  END,
 -- tb2.classcode,
  tb22.classcode, 
IDENTITYNO,nb_flag ORDER BY receiptdate ASC) rn
 --FROM d_zjys_wl2022_xs a
 from d_yb_first_cus a
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
   --加上国谈条件
    join d_zjys_wl2023xse xse on xse.ERP销售号=a.erpsaleno 
    JOIN (select ERP销售单号,统筹支付数,公补基金支付数,个人当年帐户支付数,医疗费用总额 from  d_zhyb_hz_cyb
          union select ERP销售号,统筹金额,公务员补助支付,当年账户支付,医疗总费用  from tmp_wlybjs_cyb) cyb ON a.erpsaleno=cyb.erp销售单号 --AND d_zhyb_hz_cyb.异地标志='非异地'
   JOIN (select BUSNO,SALENO,ACCDATE,GTJEED from d_ll_zxcy
         union 
         select busno,saleno,accdate,gtjeed from D_LL_ZXCY_TEMP_2) d_ll_zxcy  ON cyb.erp销售单号=d_ll_zxcy.saleno
    --
  WHERE a.RECEIPTDATE < DATE'2023-01-01'
  AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001')
  --
  --国谈条件
   AND nvl(cyb.统筹支付数,0)+nvl(cyb.公补基金支付数,0)+nvl(cyb.个人当年帐户支付数,0)<>0
and cyb.医疗费用总额 - nvl(gtjeed,0)<>0
 ) WHERE rn=1;
  

 
 /*from tmp_wlybjs_cyb a
--
JOIN d_ll_zxcy b ON a.ERP销售号=b.saleno
--
INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
a.ERP销售号=d.saleno
left join s_user_base su on d.saler=su.userid
join hydee_taizhou.taizhou_personal_info info on info.IDNUMBER=a.身份证号
LEFT join D_ZHYB_HZ_CYB cy ON a.erp销售号=cy.erp销售单号 AND a.身份证号=cy.身份证号
WHERE 创建时间>=date'2022-01-01' AND 创建时间<date'2022-03-01'
--
AND nvl(基本医疗统筹支付,0)+nvl(公务员补助统筹支付,0)+nvl(当年账户支付,0)<>0
and 医疗总费用 - nvl(gtjeed,0)<>0
 
 
  case 
    when tb2.classcode in('324331081','324331082','324331083','324331024','324331022','324331023') 
    then d_zhyb_hz_cyb.异地标志='非异地'  
    when tb2.classcode  IN ('324331001','324331002','324331003','324331004')
    then cbd in ('331099','331002','331003','331004') end 
  
  
  delete from D_YB_NEW_CUS_2023_09 a 
  where not exists (select 1 from d_zjys_wl2023xse b where a.erpsaleno=b.erp销售号)
  --SELECT * from D_YB_NEW_CUS_2023 WHERE receiptdate<DATE'2022-03-01'*/
 
  
