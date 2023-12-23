WITH a1 AS(
SELECT d.wareid,SUM(d.WAREQTY) AS �˲�����  from t_dist_h h
JOIN t_dist_d d ON h.DISTNO=d.DISTNO
 WHERE h.srcbusno=89063 AND H.billcode='DIR'
   GROUP BY d.wareid
),
a2 AS(
 SELECT d.wareid,SUM(d.WAREQTY) AS ��������  from t_dist_h h
JOIN t_dist_d d ON h.DISTNO=d.DISTNO
 WHERE h.objbusno=89063  AND H.billcode='DIS'
  GROUP BY d.wareid
),
a3 AS(
SELECT d.wareid,SUM((WAREQTYA-WAREQTYB)) AS �������� from t_abnormity_h h
JOIN t_abnormity_d d ON h.ABNORMITYNO=d.ABNORMITYNO
 WHERE h.busno=89063 AND d.WAREQTYA<>d.WAREQTYB
 GROUP BY d.wareid
),
a4 AS(
SELECT d.wareid,SUM(d.wareqty) AS �������� FROM t_sale_h h 
JOIN t_sale_d d ON h.SALENO=d.SALENO
 where h.busno=89063
 GROUP BY d.wareid
),
a5 AS(
SELECT wareid,SUM(WAREQTY) AS �������  FROM t_store_d WHERE busno=89063 AND WAREQTY<>0
GROUP BY wareid
),
a6 AS(
SELECT  a1.wareid FROM a1
UNION SELECT a2.wareid FROM a2
UNION SELECT a3.wareid FROM a3
UNION SELECT a4.wareid FROM a4
UNION SELECT a5.wareid FROM a5
) 
SELECT a6.wareid,a2.��������,a1.�˲�����,a3.��������,a4.��������,a5.�������
FROM a6
LEFT join a1 ON a6.wareid=a1.wareid
LEFT join a2 ON a6.wareid=a2.wareid
LEFT join a3 ON a6.wareid=a3.wareid
LEFT join a4 ON a6.wareid=a4.wareid
LEFT join a5 ON a6.wareid=a5.wareid
 
