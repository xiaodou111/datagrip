SELECT a.EXECDATE,a.wareid,b.warename,a.����,a.��������,a.distno FROM
(SELECT h.EXECDATE,d.wareid,d.WAREQTY AS ����,'�˲ֵ�' AS �������� ,h.distno  from t_dist_h h
JOIN t_dist_d d ON h.DISTNO=d.DISTNO
 WHERE h.srcbusno=89063 AND H.billcode='DIR'
 UNION ALL
 SELECT h.EXECDATE,d.wareid,d.WAREQTY AS ��������,'���͵�' AS �������� ,h.distno  from t_dist_h h
JOIN t_dist_d d ON h.DISTNO=d.DISTNO
 WHERE h.objbusno=89063 AND H.billcode='DIS'
 UNION all
SELECT h.EXECDATE,d.wareid,(WAREQTYA-WAREQTYB) AS ��������,'���浥',h.ABNORMITYNO from t_abnormity_h h
JOIN t_abnormity_d d ON h.ABNORMITYNO=d.ABNORMITYNO
 WHERE h.busno=89063 AND d.WAREQTYA<>d.WAREQTYB
 UNION ALL 
SELECT h.accdate,d.wareid,d.wareqty AS ��������,'���۵�',h.saleno FROM t_sale_h h 
JOIN t_sale_d d ON h.SALENO=d.SALENO
 where h.busno=89063) a
 JOIN t_ware_base b ON a.wareid=b.wareid

 


/*
DSSM ��������  DSSC �繫˾����  
DIS ���͵�  DIR �˲ֵ�
APP �������뵥 RAP �˲����뵥
*/
