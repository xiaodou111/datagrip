SELECT a.*,b.ERP销售单号,b.busno  from (
SELECT a.*,b.zmdz1,ts.classcode FROM D_YB_NEW_CUS_2023 a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
) a
JOIN (
SELECT a.*,b.zmdz1,ts.classcode FROM d_zhyb_hz_cyb a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
) b ON a.identityno=b.身份证号 AND a.receiptdate=TRUNC(b.销售日期)  AND a.classcode<>b.classcode
AND a.receiptdate=DATE'2023-07-10' AND a.jslx=0 AND b.结算类型 IN('普通门诊','定点药店购药','门诊慢病') 
332622
AND a.erpsaleno='2307101072044006'

SELECT * from D_YB_NEW_CUS_2023 a WHERE a.erpsaleno='2307101244052463'
SELECT a.身份证号,TRUNC(a.销售日期),ts.classcode,a.结算类型 from d_zhyb_hz_cyb a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
WHERE ERP销售单号='2307101244052463'
SELECT * from d_zhyb_hz_cyb WHERE 身份证号='331081199311039110'

SELECT a.erpsaleno,identityno,receiptdate,decode(ts.classcode,30510,'药店','诊所') 门店类型,DECODE(jslx,0,'普通门诊') 结算类型,a.busno from D_YB_NEW_CUS_2023 a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
 WHERE  identityno='331081199311039110'
