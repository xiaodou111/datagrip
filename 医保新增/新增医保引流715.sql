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
WHERE ҽ�Ʒ����ܶ�<>0 AND ��������>=DATE'2023-01-01'
),
--����
a3 AS(
SELECT a.*,b.ERP���۵���,b.busno AS ylbusno,b.��������
FROM a JOIN b ON a.identityno=b.���֤�� AND a.receiptdate=TRUNC(b.��������)  AND a.classcode<>b.classcode
AND a.jslx=0 AND b.�������� IN('��ͨ����','����ҩ�깺ҩ','��������') 
)
SELECT erpsaleno,receiptdate,busno,saler,username,customername,identityno,
jslx,orderno,cbrylb,ZMDZ1 AS �����ŵ��ŵ���,DECODE(CLASSCODE,30510,'�ŵ�',30511,'����') AS �����ŵ�����,
ERP���۵��� AS ��������,YLBUSNO AS �����ŵ����,��������    FROM a3 
