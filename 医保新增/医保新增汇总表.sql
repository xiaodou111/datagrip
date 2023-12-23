SELECT a.busno,zsyb,zsnb,ydyb,ydnb,tb.classname,tb1.classname,tb2.classname FROM (SELECT busno FROM D_YB_NEW_CUS_2023 GROUP BY  busno) a
LEFT join (
SELECT a.busno,COUNT(IDENTITYNO) zsyb from  D_YB_NEW_CUS_2023 a
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode='30511'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
WHERE  a.receiptdate BETWEEN DATE'2023-01-01' AND DATE'2023-03-10' AND a.nb_flag=0
GROUP BY  a.busno
) a2 ON a.busno=a2.busno
LEFT join (
SELECT a.busno,COUNT(IDENTITYNO) zsnb from  D_YB_NEW_CUS_2023 a
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode='30511'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
WHERE  a.receiptdate BETWEEN DATE'2023-01-01' AND DATE'2023-03-10' AND a.nb_flag=1
GROUP BY  a.busno 
) a3 ON a.busno=a3.busno
LEFT join (
SELECT s.zmdz1,COUNT(IDENTITYNO) ydyb from  D_YB_NEW_CUS_2023 a
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode='30510'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
LEFT join s_busi s ON a.busno=s.busno
WHERE  a.receiptdate BETWEEN DATE'2023-01-01' AND DATE'2023-03-10' AND a.nb_flag=0
GROUP BY  s.zmdz1
) a4 ON a.busno=a4.zmdz1
LEFT join (
SELECT s.zmdz1,COUNT(IDENTITYNO) ydnb from  D_YB_NEW_CUS_2023 a
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode='30510'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
LEFT join s_busi s ON a.busno=s.busno
WHERE  a.receiptdate BETWEEN DATE'2023-01-01' AND DATE'2023-03-10' AND a.nb_flag=1
GROUP BY  s.zmdz1
) a5 ON a.busno=a5.zmdz1
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
    join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
    join t_busno_class_base tb1 on ts1.classgroupno=ts1.classgroupno and ts1.classcode=tb1.classcode
    join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode 


SELECT COUNT(*) from D_YB_NEW_CUS_2023 WHERE NB_FLAG=1   --1农保 0医保
