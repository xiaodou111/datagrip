SELECT a.*,b.ERP���۵���,b.busno  from (
SELECT a.*,b.zmdz1,ts.classcode FROM D_YB_NEW_CUS_2023 a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
) a
JOIN (
SELECT a.*,b.zmdz1,ts.classcode FROM d_zhyb_hz_cyb a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
) b ON a.identityno=b.���֤�� AND a.receiptdate=TRUNC(b.��������)  AND a.classcode<>b.classcode
AND a.receiptdate=DATE'2023-07-10' AND a.jslx=0 AND b.�������� IN('��ͨ����','����ҩ�깺ҩ','��������') 
332622
AND a.erpsaleno='2307101072044006'

SELECT * from D_YB_NEW_CUS_2023 a WHERE a.erpsaleno='2307101244052463'
SELECT a.���֤��,TRUNC(a.��������),ts.classcode,a.�������� from d_zhyb_hz_cyb a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
WHERE ERP���۵���='2307101244052463'
SELECT * from d_zhyb_hz_cyb WHERE ���֤��='331081199311039110'

SELECT a.erpsaleno,identityno,receiptdate,decode(ts.classcode,30510,'ҩ��','����') �ŵ�����,DECODE(jslx,0,'��ͨ����') ��������,a.busno from D_YB_NEW_CUS_2023 a
JOIN s_busi b ON a.busno=b.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode in('30510','30511')
 WHERE  identityno='331081199311039110'
