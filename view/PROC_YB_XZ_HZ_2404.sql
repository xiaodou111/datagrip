create PROCEDURE proc_yb_xz_hz_2404(p_begin IN DATE,
                                          p_end IN DATE,
                                          p_sql OUT SYS_REFCURSOR )
IS


BEGIN
 OPEN p_sql FOR


 WITH
 a AS(
 SELECT d_yb_new_cus_2024_04.busno FROM d_yb_new_cus_2024_04
 join t_busno_class_set ts3 on d_yb_new_cus_2024_04.busno=ts3.busno and ts3.classgroupno ='305'
 AND ts3.classcode='30511'
 GROUP BY d_yb_new_cus_2024_04.busno
 UNION ALL
 SELECT s.zmdz1 FROM d_yb_new_cus_2024_04
  JOIN s_busi s ON  d_yb_new_cus_2024_04.busno=s.busno
  GROUP BY  s.zmdz1
 ),
 a1 AS(
 --诊所医保农保当前数量
 SELECT
  a.busno,
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb,
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
 SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='0' THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='1' THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbstzy
FROM
  d_yb_new_cus_2024_04 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30511'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
WHERE
  a.receiptdate BETWEEN p_begin AND p_end+1
GROUP BY
  a.busno
 ),
 a2 AS(
 --药店医保农保当前数量
  SELECT
  s.zmdz1,
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb,
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
 SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='0' THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='1' THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbstzy
FROM
  d_yb_new_cus_2024_04 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30510'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
  JOIN s_busi s ON a.busno=s.busno
WHERE
  a.receiptdate BETWEEN p_begin AND p_end+1
GROUP BY
  s.zmdz1
 ),
 a3 AS(
 --诊所医保农保去年数量
  SELECT
  a.busno,
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb,
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
 SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='0' THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='1' THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbstzy
FROM
  d_yb_new_cus_2024_04 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30511'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
WHERE
  a.receiptdate BETWEEN  add_months(p_begin,-12) AND add_months(p_end+1,-12)
GROUP BY
  a.busno
 ),
 a4 AS(
 --药店医保农保去年数量
  SELECT
  s.zmdz1,
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb,
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
 SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='0' THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='1' THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbstzy
FROM
  d_yb_new_cus_2024_04 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30510'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
  JOIN s_busi s ON a.busno=s.busno
WHERE
  a.receiptdate BETWEEN add_months(p_begin,-12) AND add_months(p_end+1,-12)
GROUP BY
  s.zmdz1
 ),
 a5 AS(
 --诊所医保农保环比数量
  SELECT
  a.busno,
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb,
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
 SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='0' THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='1' THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbstzy
FROM
  d_yb_new_cus_2024_04 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30511'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
WHERE
  a.receiptdate BETWEEN add_months(p_begin,-1) AND add_months(p_end+1,-1)
GROUP BY
  a.busno
 ),
 a6 AS(
 --药店医保农保环比数量
  SELECT
  s.zmdz1,
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb,
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
 SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='0' THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='0' THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX='0' AND a.nb_flag='1' THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX='1' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX='2' AND a.nb_flag='1' THEN 1 ELSE 0 END)AS  nbstzy
FROM
  d_yb_new_cus_2024_04 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30510'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
  JOIN s_busi s ON a.busno=s.busno
WHERE
  a.receiptdate BETWEEN add_months(p_begin,-1) AND add_months(p_end+1,-1)
GROUP BY
  s.zmdz1
 ),
 bb AS(
 SELECT tb.classname AS syb,tb1.classname AS pq,tb2.classname AS qy, a.busno,s.orgname,tb3.classname lx,
 NVL(a3.zsyb,a4.zsyb) AS qnybsl,NVL(a5.zsyb,a6.zsyb) AS syybsl,
 NVL(a3.zsnb,a4.zsnb) qnnbsl,NVL(a5.zsnb,a6.zsnb) AS synbsl,
 NVL(a3.ybptmz,a4.ybptmz) AS qnybptmz,NVL(a5.ybptmz,a6.ybptmz) AS syybptmz,
 NVL(a3.nbptmz,a4.nbptmz)qnnbptmz,NVL(a5.nbptmz,a6.nbptmz)synbptmz,
 NVL(a3.ybmztb,a4.ybmztb)qnybmztb,NVL(a5.ybmztb,a6.ybmztb)syybmztb,
 NVL(a3.nbmztb,a4.nbmztb)qnnbmztb,NVL(a5.nbmztb,a6.nbmztb)synbmztb,
 NVL(a3.ybstzy,a4.ybstzy)qnybstzy,NVL(a5.ybstzy,a6.ybstzy)syybstzy,
 NVL(a3.nbstzy,a4.nbstzy)qnnbstzy,NVL(a5.nbstzy,a6.nbstzy)synbstzy,
NVL(a1.zsyb,a2.zsyb) ybsl,--医保数量
(NVL(a1.zsyb,a2.zsyb)-NVL(a3.zsyb,a4.zsyb))/decode(NVL(a3.zsyb,a4.zsyb),0,NULL,NVL(a3.zsyb,a4.zsyb))ybtb ,--医保同比,
(NVL(a1.zsyb,a2.zsyb)-NVL(a5.zsyb,a6.zsyb))/decode(NVL(a5.zsyb,a6.zsyb),0,NULL,NVL(a5.zsyb,a6.zsyb))ybhb ,--医保环比,
NVL(a1.zsnb,a2.zsnb)nbsl,--农保数量             decode(,0,null,)
(NVL(a1.zsnb,a2.zsnb)-NVL(a3.zsnb,a4.zsnb))/decode(NVL(a3.zsnb,a4.zsnb),0,null,NVL(a3.zsnb,a4.zsnb))nbtb,--农保同比,
(NVL(a1.zsnb,a2.zsnb)-NVL(a5.zsnb,a6.zsnb))/decode(NVL(a5.zsnb,a6.zsnb),0,null,NVL(a5.zsnb,a6.zsnb))nbhb,--农保环比,
NVL(a1.ybptmz,a2.ybptmz)ybptmz,--医保普通门诊
(NVL(a1.ybptmz,a2.ybptmz)-NVL(a3.ybptmz,a4.ybptmz))/decode(NVL(a3.ybptmz,a4.ybptmz),0,null,NVL(a3.ybptmz,a4.ybptmz))ybptmztb  ,--医保普通门诊同比
(NVL(a1.ybptmz,a2.ybptmz)-NVL(a5.ybptmz,a6.ybptmz))/decode(NVL(a5.ybptmz,a6.ybptmz),0,null,NVL(a5.ybptmz,a6.ybptmz))ybptmzhb ,--医保普通门诊环比
NVL(a1.nbptmz,a2.nbptmz)nbptmz,--农保普通门诊
(NVL(a1.nbptmz,a2.nbptmz)-NVL(a3.nbptmz,a4.nbptmz))/decode(NVL(a3.nbptmz,a4.nbptmz),0,null,NVL(a3.nbptmz,a4.nbptmz))nbptmztb  ,--农保普通门诊同比
(NVL(a1.nbptmz,a2.nbptmz)-NVL(a5.nbptmz,a6.nbptmz))/decode(NVL(a5.nbptmz,a6.nbptmz),0,null,NVL(a5.nbptmz,a6.nbptmz))nbptmzhb ,--农保普通门诊环比
NVL(a1.ybmztb,a2.ybmztb)ybmztb,--医保门诊特病
(NVL(a1.ybmztb,a2.ybmztb)-NVL(a3.ybmztb,a4.ybmztb))/decode(NVL(a3.ybmztb,a4.ybmztb),0,null,NVL(a3.ybmztb,a4.ybmztb))ybmztbtb ,--医保门诊特病同比
(NVL(a1.ybmztb,a2.ybmztb)-NVL(a5.ybmztb,a6.ybmztb))/decode(NVL(a5.ybmztb,a6.ybmztb),0,null,NVL(a5.ybmztb,a6.ybmztb))ybmztbhb ,--医保门诊特病环比
NVL(a1.nbmztb,a2.nbmztb)nbmztb,--农保门诊特病
(NVL(a1.nbmztb,a2.nbmztb)-NVL(a3.nbmztb,a4.nbmztb))/decode(NVL(a3.nbmztb,a4.nbmztb),0,null,NVL(a3.nbmztb,a4.nbmztb))nbmztbtb ,--农保门诊特病同比
(NVL(a1.nbmztb,a2.nbmztb)-NVL(a5.nbmztb,a6.nbmztb))/decode(NVL(a5.nbmztb,a6.nbmztb),0,null,NVL(a5.nbmztb,a6.nbmztb))nbmztbhb ,--农保门诊特病环比
NVL(a1.ybstzy,a2.ybstzy)ybstzy,--医保双通道
(NVL(a1.ybstzy,a2.ybstzy)-NVL(a3.ybstzy,a4.ybstzy))/decode(NVL(a3.ybstzy,a4.ybstzy),0,null,NVL(a3.ybstzy,a4.ybstzy))ybstzytb ,--医保双通道同比
(NVL(a1.ybstzy,a2.ybstzy)-NVL(a5.ybstzy,a6.ybstzy))/decode(NVL(a5.ybstzy,a6.ybstzy),0,null,NVL(a5.ybstzy,a6.ybstzy))ybstzyhb ,--医保双通道环比
NVL(a1.nbstzy,a2.nbstzy)nbstzy,--农保双通道
(NVL(a1.nbstzy,a2.nbstzy)-NVL(a3.nbstzy,a4.nbstzy))/decode(NVL(a3.nbstzy,a4.nbstzy),0,null,NVL(a3.nbstzy,a4.nbstzy))nbstzytb ,--农保双通道同比
(NVL(a1.nbstzy,a2.nbstzy)-NVL(a5.nbstzy,a6.nbstzy))/decode(NVL(a5.nbstzy,a6.nbstzy),0,null,NVL(a5.nbstzy,a6.nbstzy))nbstzyhb --农保双通道环比

FROM a
LEFT join a1 ON a.busno=a1.busno
LEFT join a2 ON a.busno=a2.zmdz1
LEFT join a3 ON a.busno=a3.busno
LEFT join a4 ON a.busno=a4.zmdz1
LEFT join a5 ON a.busno=a5.busno
LEFT join a6 ON a.busno=a6.zmdz1
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
    join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
    join t_busno_class_base tb1 on ts1.classgroupno=ts1.classgroupno and ts1.classcode=tb1.classcode
    join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts3 on a.busno=ts3.busno and ts3.classgroupno ='305'
    join t_busno_class_base tb3 on ts3.classgroupno=ts3.classgroupno and ts3.classcode=tb3.classcode
 JOIN s_busi s ON a.busno=s.busno)

 SELECT bb.syb,bb.pq,bb.qy,bb.busno,bb.orgname,bb.lx,
 bb.ybsl,bb.ybtb,bb.ybhb,
 bb.nbsl,bb.nbtb,bb.nbhb,
 bb.ybptmz,bb.ybptmztb,bb.ybptmzhb,
 bb.nbptmz,bb.nbptmztb,bb.nbptmzhb,
 bb.ybmztb,bb.ybmztbtb,bb.ybmztbhb,
 bb.nbmztb,bb.nbmztbtb,bb.nbmztbhb,
 bb.ybstzy,bb.ybstzytb,bb.ybstzyhb,
 bb.nbstzy,bb.nbstzytb,bb.nbstzyhb
 FROM bb

UNION ALL
SELECT '事业部汇总：',syb,qy,NULL,NULL,lx,
SUM(ybsl) AS ybsl,
CASE WHEN SUM(ybsl)=0 OR SUM(qnybsl)=0 THEN 0 ELSE (SUM(ybsl)-SUM(qnybsl))/SUM(qnybsl) END AS ybtb,
CASE WHEN SUM(ybsl)=0 OR SUM(syybsl)=0 THEN 0 ELSE (SUM(ybsl)-SUM(syybsl))/SUM(syybsl) END AS ybhb,
SUM(nbsl) AS nbsl,
CASE WHEN SUM(nbsl)=0 OR SUM(qnnbsl)=0 THEN 0 ELSE (SUM(nbsl)-SUM(qnnbsl))/SUM(qnnbsl) END AS nbtb,
CASE WHEN SUM(nbsl)=0 OR SUM(synbsl)=0 THEN 0 ELSE (SUM(nbsl)-SUM(synbsl))/SUM(synbsl) END AS nbhb,
SUM(ybptmz) AS ybptmzsl,
CASE WHEN SUM(ybptmz)=0 OR SUM(qnybptmz)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(qnybptmz))/SUM(qnybptmz) END AS ybptmztb,
CASE WHEN SUM(ybptmz)=0 OR SUM(syybptmz)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(syybptmz))/SUM(syybptmz) END AS ybptmzhb,
SUM(nbptmz) AS nbptmzsl,
CASE WHEN SUM(nbptmz)=0 OR SUM(qnnbptmz)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(qnnbptmz))/SUM(qnnbptmz) END AS nbptmztb,
CASE WHEN SUM(nbptmz)=0 OR SUM(synbptmz)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(synbptmz))/SUM(synbptmz) END AS nbptmzhb,
SUM(ybmztb) AS ybmztbsl,
CASE WHEN SUM(ybmztb)=0 OR SUM(qnybmztb)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(qnybmztb))/SUM(qnybmztb) END AS ybmztbtb,
CASE WHEN SUM(ybmztb)=0 OR SUM(syybmztb)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(syybmztb))/SUM(syybmztb) END AS ybmztbhb,
SUM(nbmztb) AS nbmztbsl,
CASE WHEN SUM(nbmztb)=0 OR SUM(qnnbmztb)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(qnnbmztb))/SUM(qnnbmztb) END AS nbmztbtb,
CASE WHEN SUM(nbmztb)=0 OR SUM(synbmztb)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(synbmztb))/SUM(synbmztb) END AS nbmztbhb,
SUM(ybstzy) AS ybstzysl,
CASE WHEN SUM(ybstzy)=0 OR SUM(qnybstzy)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(qnybstzy))/SUM(qnybstzy) END AS ybstzytb,
CASE WHEN SUM(ybstzy)=0 OR SUM(syybstzy)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(syybstzy))/SUM(syybstzy) END AS ybstzyhb,
SUM(nbstzy) AS nbstzy,
CASE WHEN SUM(nbstzy)=0 OR SUM(qnnbstzy)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(qnnbstzy))/SUM(qnnbstzy) END AS nbstzytb,
CASE WHEN SUM(nbstzy)=0 OR SUM(synbstzy)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(synbstzy))/SUM(synbstzy) END AS nbstzyhb
FROM  bb  GROUP BY syb,qy,lx

UNION ALL
SELECT '片区汇总：',PQ,qy,NULL,NULL,lx,
SUM(ybsl) AS ybsl,
CASE WHEN SUM(ybsl)=0 OR SUM(qnybsl)=0 THEN 0 ELSE (SUM(ybsl)-SUM(qnybsl))/SUM(qnybsl) END AS ybtb,
CASE WHEN SUM(ybsl)=0 OR SUM(syybsl)=0 THEN 0 ELSE (SUM(ybsl)-SUM(syybsl))/SUM(syybsl) END AS ybhb,
SUM(nbsl) AS nbsl,
CASE WHEN SUM(nbsl)=0 OR SUM(qnnbsl)=0 THEN 0 ELSE (SUM(nbsl)-SUM(qnnbsl))/SUM(qnnbsl) END AS nbtb,
CASE WHEN SUM(nbsl)=0 OR SUM(synbsl)=0 THEN 0 ELSE (SUM(nbsl)-SUM(synbsl))/SUM(synbsl) END AS nbhb,
SUM(ybptmz) AS ybptmzsl,
CASE WHEN SUM(ybptmz)=0 OR SUM(qnybptmz)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(qnybptmz))/SUM(qnybptmz) END AS ybptmztb,
CASE WHEN SUM(ybptmz)=0 OR SUM(syybptmz)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(syybptmz))/SUM(syybptmz) END AS ybptmzhb,
SUM(nbptmz) AS nbptmzsl,
CASE WHEN SUM(nbptmz)=0 OR SUM(qnnbptmz)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(qnnbptmz))/SUM(qnnbptmz) END AS nbptmztb,
CASE WHEN SUM(nbptmz)=0 OR SUM(synbptmz)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(synbptmz))/SUM(synbptmz) END AS nbptmzhb,
SUM(ybmztb) AS ybmztbsl,
CASE WHEN SUM(ybmztb)=0 OR SUM(qnybmztb)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(qnybmztb))/SUM(qnybmztb) END AS ybmztbtb,
CASE WHEN SUM(ybmztb)=0 OR SUM(syybmztb)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(syybmztb))/SUM(syybmztb) END AS ybmztbhb,
SUM(nbmztb) AS nbmztbsl,
CASE WHEN SUM(nbmztb)=0 OR SUM(qnnbmztb)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(qnnbmztb))/SUM(qnnbmztb) END AS nbmztbtb,
CASE WHEN SUM(nbmztb)=0 OR SUM(synbmztb)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(synbmztb))/SUM(synbmztb) END AS nbmztbhb,
SUM(ybstzy) AS ybstzysl,
CASE WHEN SUM(ybstzy)=0 OR SUM(qnybstzy)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(qnybstzy))/SUM(qnybstzy) END AS ybstzytb,
CASE WHEN SUM(ybstzy)=0 OR SUM(syybstzy)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(syybstzy))/SUM(syybstzy) END AS ybstzyhb,
SUM(nbstzy) AS nbstzy,
CASE WHEN SUM(nbstzy)=0 OR SUM(qnnbstzy)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(qnnbstzy))/SUM(qnnbstzy) END AS nbstzytb,
CASE WHEN SUM(nbstzy)=0 OR SUM(synbstzy)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(synbstzy))/SUM(synbstzy) END AS nbstzyhb
FROM  bb GROUP BY PQ,lx,qy
UNION ALL
SELECT '区域汇总：',qy,NULL,NULL,NULL,lx,
SUM(nvl(ybsl,0)) AS ybsl,
CASE WHEN nvl(SUM(ybsl),0)=0 OR nvl(SUM(qnybsl),0)=0 THEN 0 ELSE (SUM(ybsl)-SUM(qnybsl))/SUM(qnybsl) END AS ybtb,
CASE WHEN nvl(SUM(ybsl),0)=0 OR nvl(SUM(syybsl),0)=0 THEN 0 ELSE (SUM(ybsl)-SUM(syybsl))/SUM(syybsl) END AS ybhb,
SUM(nvl(nbsl,0)) AS nbsl,
CASE WHEN nvl(SUM(nbsl),0)=0 OR nvl(SUM(qnnbsl),0)=0 THEN 0 ELSE (SUM(nbsl)-SUM(qnnbsl))/SUM(qnnbsl) END AS nbtb,
CASE WHEN nvl(SUM(nbsl),0)=0 OR nvl(SUM(synbsl),0)=0 THEN 0 ELSE (SUM(nbsl)-SUM(synbsl))/SUM(synbsl) END AS nbhb,
SUM(nvl(ybptmz,0)) AS ybptmzsl,
CASE WHEN nvl(SUM(ybptmz),0)=0 OR nvl(SUM(qnybptmz),0)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(qnybptmz))/SUM(qnybptmz) END AS ybptmztb,
CASE WHEN nvl(SUM(ybptmz),0)=0 OR nvl(SUM(syybptmz),0)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(syybptmz))/SUM(syybptmz) END AS ybptmzhb,
SUM(nvl(nbptmz,0)) AS nbptmzsl,
CASE WHEN nvl(SUM(nbptmz),0)=0 OR nvl(SUM(qnnbptmz),0)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(qnnbptmz))/SUM(qnnbptmz) END AS nbptmztb,
CASE WHEN nvl(SUM(nbptmz),0)=0 OR nvl(SUM(synbptmz),0)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(synbptmz))/SUM(synbptmz) END AS nbptmzhb,
SUM(nvl(ybmztb,0)) AS ybmztbsl,
CASE WHEN nvl(SUM(ybmztb),0)=0 OR nvl(SUM(qnybmztb),0)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(qnybmztb))/SUM(qnybmztb) END AS ybmztbtb,
CASE WHEN nvl(SUM(ybmztb),0)=0 OR nvl(SUM(syybmztb),0)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(syybmztb))/SUM(syybmztb) END AS ybmztbhb,
SUM(nvl(nbmztb,0)) AS nbmztbsl,
CASE WHEN nvl(SUM(nbmztb),0)=0 OR nvl(SUM(qnnbmztb),0)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(qnnbmztb))/SUM(qnnbmztb) END AS nbmztbtb,
CASE WHEN nvl(SUM(nbmztb),0)=0 OR nvl(SUM(synbmztb),0)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(synbmztb))/SUM(synbmztb) END AS nbmztbhb,
SUM(nvl(ybstzy,0)) AS ybstzysl,
CASE WHEN nvl(SUM(ybstzy),0)=0 OR nvl(SUM(qnybstzy),0)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(qnybstzy))/SUM(qnybstzy) END AS ybstzytb,
CASE WHEN nvl(SUM(ybstzy),0)=0 OR nvl(SUM(syybstzy),0)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(syybstzy))/SUM(syybstzy) END AS ybstzyhb,
SUM(nvl(nbstzy,0)) AS nbstzy,
CASE WHEN nvl(SUM(nbstzy),0)=0 OR nvl(SUM(qnnbstzy),0)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(qnnbstzy))/SUM(qnnbstzy) END AS nbstzytb,
CASE WHEN nvl(SUM(nbstzy),0)=0 OR nvl(SUM(synbstzy),0)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(synbstzy))/SUM(synbstzy) END AS nbstzyhb
FROM  bb  GROUP BY qy,lx
UNION ALL
SELECT '台州事业部汇总：',null,NULL,NULL,NULL,lx,
SUM(ybsl) AS ybsl,
CASE WHEN SUM(ybsl)=0 OR SUM(qnybsl)=0 THEN 0 ELSE (SUM(ybsl)-SUM(qnybsl))/SUM(qnybsl) END AS ybtb,
CASE WHEN SUM(ybsl)=0 OR SUM(syybsl)=0 THEN 0 ELSE (SUM(ybsl)-SUM(syybsl))/SUM(syybsl) END AS ybhb,
SUM(nbsl) AS nbsl,
CASE WHEN SUM(nbsl)=0 OR SUM(qnnbsl)=0 THEN 0 ELSE (SUM(nbsl)-SUM(qnnbsl))/SUM(qnnbsl) END AS nbtb,
CASE WHEN SUM(nbsl)=0 OR SUM(synbsl)=0 THEN 0 ELSE (SUM(nbsl)-SUM(synbsl))/SUM(synbsl) END AS nbhb,
SUM(ybptmz) AS ybptmzsl,
CASE WHEN SUM(ybptmz)=0 OR SUM(qnybptmz)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(qnybptmz))/SUM(qnybptmz) END AS ybptmztb,
CASE WHEN SUM(ybptmz)=0 OR SUM(syybptmz)=0 THEN 0 ELSE (SUM(ybptmz)-SUM(syybptmz))/SUM(syybptmz) END AS ybptmzhb,
SUM(nbptmz) AS nbptmzsl,
CASE WHEN SUM(nbptmz)=0 OR SUM(qnnbptmz)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(qnnbptmz))/SUM(qnnbptmz) END AS nbptmztb,
CASE WHEN SUM(nbptmz)=0 OR SUM(synbptmz)=0 THEN 0 ELSE (SUM(nbptmz)-SUM(synbptmz))/SUM(synbptmz) END AS nbptmzhb,
SUM(ybmztb) AS ybmztbsl,
CASE WHEN SUM(ybmztb)=0 OR SUM(qnybmztb)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(qnybmztb))/SUM(qnybmztb) END AS ybmztbtb,
CASE WHEN SUM(ybmztb)=0 OR SUM(syybmztb)=0 THEN 0 ELSE (SUM(ybmztb)-SUM(syybmztb))/SUM(syybmztb) END AS ybmztbhb,
SUM(nbmztb) AS nbmztbsl,
CASE WHEN SUM(nbmztb)=0 OR SUM(qnnbmztb)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(qnnbmztb))/SUM(qnnbmztb) END AS nbmztbtb,
CASE WHEN SUM(nbmztb)=0 OR SUM(synbmztb)=0 THEN 0 ELSE (SUM(nbmztb)-SUM(synbmztb))/SUM(synbmztb) END AS nbmztbhb,
SUM(ybstzy) AS ybstzysl,
CASE WHEN SUM(ybstzy)=0 OR SUM(qnybstzy)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(qnybstzy))/SUM(qnybstzy) END AS ybstzytb,
CASE WHEN SUM(ybstzy)=0 OR SUM(syybstzy)=0 THEN 0 ELSE (SUM(ybstzy)-SUM(syybstzy))/SUM(syybstzy) END AS ybstzyhb,
SUM(nbstzy) AS nbstzy,
CASE WHEN SUM(nbstzy)=0 OR SUM(qnnbstzy)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(qnnbstzy))/SUM(qnnbstzy) END AS nbstzytb,
CASE WHEN SUM(nbstzy)=0 OR SUM(synbstzy)=0 THEN 0 ELSE (SUM(nbstzy)-SUM(synbstzy))/SUM(synbstzy) END AS nbstzyhb
FROM  bb GROUP BY lx
;

 END;
/

