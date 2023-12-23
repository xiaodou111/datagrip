--诊所医保农保当前数量
SELECT 
  a.busno, 
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb, 
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
  SUM(CASE WHEN a.JSLX not IN('门诊特病','普通住院外检外购','随同住院报销') AND a.nb_flag=0 THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX IN('门诊特病') AND a.nb_flag=0 THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX IN('普通住院外检外购','随同住院报销') AND a.nb_flag=0 THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX not IN('门诊特病','普通住院外检外购','随同住院报销') AND a.nb_flag=1 THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX IN('门诊特病') AND a.nb_flag=1 THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX IN('普通住院外检外购','随同住院报销') AND a.nb_flag=1 THEN 1 ELSE 0 END)AS  ybstzy
FROM 
  D_YB_NEW_CUS_2023 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30511' 
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode  
WHERE 
  a.receiptdate BETWEEN DATE'2022-01-01' AND DATE'2022-12-31'
GROUP BY 
  a.busno
--药店医保农保当前数量 
UNION ALL
  SELECT 
  s.zmdz1, 
  SUM(CASE WHEN a.nb_flag=0 THEN 1 ELSE 0 END) AS zsyb, 
  SUM(CASE WHEN a.nb_flag=1 THEN 1 ELSE 0 END) AS zsnb,
  SUM(CASE WHEN a.JSLX not IN('门诊特病','普通住院外检外购','随同住院报销') AND a.nb_flag=0 THEN 1 ELSE 0 END) AS ybptmz,
  SUM(CASE WHEN a.JSLX IN('门诊特病') AND a.nb_flag=0 THEN 1 ELSE 0 END)AS  ybmztb,
  SUM(CASE WHEN a.JSLX IN('普通住院外检外购','随同住院报销') AND a.nb_flag=0 THEN 1 ELSE 0 END)AS  ybstzy,
  SUM(CASE WHEN a.JSLX not IN('门诊特病','普通住院外检外购','随同住院报销') AND a.nb_flag=1 THEN 1 ELSE 0 END) AS nbptmz,
  SUM(CASE WHEN a.JSLX IN('门诊特病') AND a.nb_flag=1 THEN 1 ELSE 0 END)AS  nbmztb,
  SUM(CASE WHEN a.JSLX IN('普通住院外检外购','随同住院报销') AND a.nb_flag=1 THEN 1 ELSE 0 END)AS  ybstzy
FROM 
  D_YB_NEW_CUS_2023 a
  JOIN t_busno_class_set ts ON a.busno=ts.busno AND ts.classgroupno='305' AND ts.classcode='30510' 
  JOIN t_busno_class_base tb ON ts.classgroupno=ts.classgroupno AND ts.classcode=tb.classcode
  JOIN s_busi s ON a.busno=s.busno  
WHERE 
  a.receiptdate BETWEEN DATE'2022-01-01' AND DATE'2022-12-31' 
GROUP BY 
  s.zmdz1
