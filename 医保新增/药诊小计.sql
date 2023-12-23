--单药店
WITH a1 AS(
SELECT
  CBDNAME,
  SUM(CASE WHEN a.JSLX=0 AND a.nb_flag=0 THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX=0 AND a.nb_flag=1 THEN 1 ELSE 0 END) AS nbptmz
  FROM
  D_YB_NEW_CUS_2023 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30510'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
  JOIN s_busi s ON a.busno=s.busno
  JOIN d_zmdz1_yz zs ON s.zmdz1=zs.zmdz1
WHERE
  a.receiptdate<DATE'2023-01-01'
 GROUP BY
  CBDNAME),
  a2 AS(
  --诊所医保农保数量
 SELECT
  CBDNAME,
  SUM(CASE WHEN a.JSLX=0 AND a.nb_flag=0 THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX=0 AND a.nb_flag=1 THEN 1 ELSE 0 END) AS nbptmz
  
FROM
  D_YB_NEW_CUS_2023 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30511'
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
  JOIN s_busi s ON a.busno=s.busno
  JOIN d_zmdz1_yz zs ON s.zmdz1=zs.zmdz1
WHERE
  a.receiptdate<DATE'2023-01-01'
 GROUP BY
  CBDNAME
  ),
  a5 AS(
  SELECT CBDNAME,
   SUM(CASE WHEN a.JSLX=0 AND a.nb_flag=0 THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX=0 AND a.nb_flag=1 THEN 1 ELSE 0 END) AS nbptmz
from D_YB_NEW_CUS_2023 a
JOIN  t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode IN(30511)
JOIN s_busi s ON a.busno=s.busno
JOIN d_zmdz1_yz zs ON s.zmdz1=zs.zmdz1
WHERE a.RECEIPTDATE<DATE'2023-01-01'
AND  EXISTS(
SELECT 1 FROM D_YB_NEW_CUS_2023 b
JOIN  t_busno_class_set ts2 on b.busno=ts2.busno and ts2.classgroupno ='305' AND ts2.classcode IN(30510)
JOIN s_busi s2 ON b.busno=s2.busno
JOIN d_zmdz1_yz zs ON s2.zmdz1=zs.zmdz1
 WHERE b.RECEIPTDATE<DATE'2023-01-01' AND b.IDENTITYNO=a.Identityno
AND b.CBDNAME=a.CBDNAME

  )GROUP BY CBDNAME
  ),
  a6 AS (
  SELECT a2.CBDNAME,
 a1.ybptmz AS mdybptmz ,a2.ybptmz AS zsybptmz,a5.ybptmz AS cdybptmz,
 a1.nbptmz AS mdnbptmz,a2.nbptmz AS zsnbptmz,
 a5.nbptmz AS cdnbptmz FROM a2

 LEFT join a1 ON a1.CBDNAME=a2.CBDNAME
 LEFT join a5 ON a2.CBDNAME=a5.CBDNAME
 ),
a7 AS(
 SELECT
 a6.CBDNAME,

 a6.mdybptmz,
 a6.zsybptmz,
 NVL(a6.mdybptmz,0)+NVL(a6.zsybptmz,0)-NVL(a6.cdybptmz,0) AS ybrtslhj,
 a6.cdybptmz,
 CASE WHEN nvl(a6.cdybptmz,0)=0 OR nvl(a6.mdybptmz,0)=0 THEN 0 ELSE a6.cdybptmz/a6.mdybptmz END AS ydybzb,
 CASE WHEN nvl(a6.cdybptmz,0)=0 OR nvl(a6.zsybptmz,0)=0 THEN 0 ELSE a6.cdybptmz/a6.zsybptmz END AS zsybzb,
 a6.mdybptmz-a6.cdybptmz AS mdybfcd,
 a6.zsybptmz-cdybptmz AS zsybfcd,
 A6.mdybptmz+a6.zsybptmz-2*a6.cdybptmz AS ybfcdhj,
 a6.mdnbptmz,a6.zsnbptmz,
 NVL(a6.mdnbptmz,0)+NVL(a6.zsnbptmz,0)-NVL(a6.cdnbptmz,0) AS nbrtslhj,
 a6.cdnbptmz,
 CASE WHEN nvl(a6.cdnbptmz,0)=0 OR nvl(a6.mdnbptmz,0)=0 THEN 0 ELSE a6.cdnbptmz/a6.mdnbptmz END AS ydnbzb,
 CASE WHEN nvl(a6.cdnbptmz,0)=0 OR nvl(a6.zsnbptmz,0)=0 THEN 0 ELSE a6.cdnbptmz/a6.zsnbptmz END AS zsnbzb,
 a6.mdnbptmz-a6.cdnbptmz AS mdnbfcd ,
 a6.zsnbptmz-a6.cdnbptmz AS zsnbfcd ,
 a6.mdnbptmz+a6.zsnbptmz-2*a6.cdnbptmz AS nbfcdhj
 FROM A6

),
a8 AS(
 SELECT a7.CBDNAME,a7.mdybptmz AS 医保人头数量药店,a7.zsybptmz AS 医保人头数量诊所,
 a7.ybrtslhj AS 医保人头数量合计,a7.cdybptmz AS 医保人头数量重叠值,
 NVL(a7.mdybptmz,0)-NVL(a7.cdybptmz,0) AS 医保人头数量药店单独,
NVL(a7.zsybptmz,0)-NVL(a7.cdybptmz,0) AS 医保人头数量诊所单独,

--(a7.mdybptmz-a7.cdybptmz)/ybrtslhj AS 医保人头数量药店单独占比,
--(a7.zsybptmz-a7.cdybptmz)/ybrtslhj AS 医保人头数量诊所单独占比,
--a7.mdybfcd,a7.zsybfcd,a7.ybfcdhj,
a7.mdnbptmz AS 农保人头数量药店,
a7.zsnbptmz AS 农保人头数量诊所,
a7.nbrtslhj AS 农保人头数量合计,a7.cdnbptmz AS 农保人头数量重叠值,
NVL(a7.mdnbptmz,0)-NVL(a7.cdnbptmz,0) AS 农保人头数量药店单独,
NVL(a7.zsnbptmz,0)-NVL(a7.cdnbptmz,0) AS 农保人头数量诊所单独
--(a7.mdnbptmz-a7.cdnbptmz)/nbrtslhj AS 农保人头数量药店单独占比,
--(a7.zsnbptmz-a7.cdnbptmz)/nbrtslhj AS 农保人头数量诊所单独占比,
--a7.mdnbfcd,a7.zsnbfcd,a7.nbfcdhj
FROM a7
 )
 SELECT CBDNAME,医保人头数量药店,医保人头数量诊所,医保人头数量合计,医保人头数量重叠值,医保人头数量药店单独,医保人头数量诊所单独,
 CASE WHEN 医保人头数量合计=0 THEN 0 ELSE 医保人头数量重叠值/医保人头数量合计 END AS 医保人头重叠占比,
 CASE WHEN 医保人头数量合计=0 THEN 0 ELSE 医保人头数量药店单独/医保人头数量合计 end AS 医保人头数量药店单独占比,
 CASE WHEN 医保人头数量合计=0 THEN 0 ELSE 医保人头数量诊所单独/医保人头数量合计 END AS 医保人头数量诊所单独占比,

 农保人头数量药店,农保人头数量诊所,农保人头数量合计,农保人头数量重叠值,农保人头数量药店单独,农保人头数量诊所单独,

 CASE WHEN 农保人头数量合计=0 THEN 0 ELSE 农保人头数量重叠值/农保人头数量合计 END AS 农保人头重叠占比,
 CASE WHEN 农保人头数量合计=0 THEN 0 ELSE 农保人头数量药店单独/农保人头数量合计 end AS 农保人头数量药店单独占比,
 CASE WHEN 农保人头数量合计=0 THEN 0 ELSE 农保人头数量诊所单独/农保人头数量合计 END AS 农保人头数量诊所单独占比
 FROM a8
