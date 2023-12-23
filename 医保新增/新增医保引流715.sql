WITH a AS (
SELECT a.erpsaleno,a.receiptdate,a.busno,a.saler,a.username,a.customername,a.identityno,a.nb_flag,a.cbd,a.cbdname,a.netsum, 
a.status,a.yg_flag,a.jslx,a.orderno,a.cbrylb
,b.zmdz1,ts.classcode FROM D_YB_NEW_CUS_2023 a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
WHERE a.receiptdate>=DATE'2023-01-01'
),
b AS (
SELECT a.*,b.zmdz1,ts.classcode FROM d_zhyb_hz_cyb a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
WHERE 医疗费用总额<>0 AND 销售日期>=DATE'2023-01-01'
),
--关联
a3 AS(
SELECT a.*,b.ERP销售单号,b.busno AS ylbusno,b.销售日期
FROM a JOIN b ON a.identityno=b.身份证号 AND a.receiptdate=TRUNC(b.销售日期)  AND a.classcode<>b.classcode
AND a.jslx=0 AND b.结算类型 IN('普通门诊','定点药店购药','门诊慢病') 
)
SELECT erpsaleno,receiptdate,busno,saler,username,customername,identityno,
jslx,orderno,cbrylb,ZMDZ1 AS 新增门店门店组,DECODE(CLASSCODE,30510,'门店',30511,'诊所') AS 新增门店类型,
ERP销售单号 AS 引流单号,YLBUSNO AS 引流门店编码,销售日期    FROM a3 
