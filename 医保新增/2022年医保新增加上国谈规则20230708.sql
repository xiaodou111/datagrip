SELECT COUNT(*)  FROM tmp_wlybjs_cyb a
JOIN d_ll_zxcy b ON a.ERP销售号=b.saleno
WHERE  nvl(基本医疗统筹支付,0)+nvl(公务员补助统筹支付,0)+nvl(当年账户支付,0)<>0
and 医疗总费用 - nvl(gtjeed,0)<>0 

SELECT MIN(RECEIPTDATE),MAX(RECEIPTDATE) from d_yb_first_cus a
JOIN d_zhyb_hz_cyb b ON a.erpsaleno=b.ERP销售单号
JOIN d_ll_zxcy gt ON b.erp销售单号=gt.saleno
WHERE nvl(统筹支付数,0)+nvl(公补基金支付数,0)+nvl(个人当年帐户支付数,0)<>0
and 医疗费用总额 - nvl(gtjeed,0)<>0 
-------------

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
--

