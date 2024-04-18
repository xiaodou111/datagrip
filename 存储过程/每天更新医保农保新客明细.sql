create PROCEDURE proc_yb_first_md_new1

IS
/*rows_updated NUMBER;
rows_added   NUMBER;
rows_deleted NUMBER;*/
begin


  --DELETE from D_YB_NEW_CUS_2023_09 WHERE RECEIPTDATE>=date'2023-01-01';
  INSERT INTO D_YB_NEW_CUS_2023_09 
(erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno)
SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,
jslx,orderno
FROM (    
SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno,a.nb_flag, a.cbd, a.cbdname, 
a.netsum, a.status, a.yg_flag,a.jslx,
a.orderno,a.cbrylb,
ROW_NUMBER() OVER (PARTITION BY 
  CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '324331001'
    ELSE tb2.classcode
  END,
  tb22.classcode, 
a.IDENTITYNO,a.nb_flag ORDER BY a.receiptdate ASC) rn
 FROM d_yb_first_cus a
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
    --加上国谈条件
    join d_zjys_wl2023xse xse on xse.ERP销售号=a.erpsaleno 
    JOIN d_zhyb_hz_cyb cyb ON a.erpsaleno=cyb.erp销售单号 --AND d_zhyb_hz_cyb.异地标志='非异地'
    JOIN d_ll_zxcy ON cyb.erp销售单号=d_ll_zxcy.saleno 
    WHERE a.RECEIPTDATE >= DATE'2024-01-01'
    AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001')  
    --国谈条件
    AND nvl(cyb.统筹支付数,0)+nvl(cyb.公补基金支付数,0)+nvl(cyb.个人当年帐户支付数,0)<>0
and cyb.医疗费用总额 - nvl(gtjeed,0)<>0
  ) WHERE rn=1 and receiptdate between trunc(sysdate)-1 and trunc(sysdate);
  --杭州新增人头
  
 -- DELETE from  D_YB_NEW_CUS_2023_hz;
  INSERT INTO D_YB_NEW_CUS_2023_hz 
(erpsaleno, receiptdate, busno, saler, username,identityno)
  SELECT ERP销售单号, 销售日期, busno, saler, username,身份证号
FROM ( 
SELECT ERP销售单号, 销售日期, a.busno, d.saler, su.username, 身份证号,
ROW_NUMBER() OVER (PARTITION BY  
CASE
    WHEN tb2.classcode IN ('324330102','324330106','324330105','324330108','324330187') THEN '324330102'
      when  tb2.classcode IN ('324330186','324330110','324330109') then '324330186'
    ELSE tb2.classcode
  END,  
身份证号 ORDER BY 销售日期 ASC) rn
 FROM d_zhyb_hz_cyb a
 join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON a.ERP销售单号=d.saleno
  left join s_user_base su on d.saler=su.userid
 --事业部
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303106')
--销售片区
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
--门店类型
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
  WHERE a.销售日期 >= DATE'2024-01-01'
  --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
  --去掉省本级
  AND a.参保地<>'浙江省省本级' and a.异地标志='非异地' --and a.参保地 like '%杭州市%'
  ) WHERE rn=1 and 销售日期 between trunc(sysdate)-1 and trunc(sysdate);
  
  
    INSERT INTO D_YB_NEW_CUS_2023_tiantai 
(erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno)
SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,
jslx,orderno
FROM (    
SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno,a.nb_flag, a.cbd, a.cbdname, 
a.netsum, a.status, a.yg_flag,a.jslx,
a.orderno,a.cbrylb,
ROW_NUMBER() OVER (PARTITION BY 
  a.busno,
  tb22.classcode, 
a.IDENTITYNO,a.nb_flag ORDER BY a.receiptdate ASC) rn
 FROM d_yb_first_cus a
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
    --加上国谈条件
    join d_zjys_wl2023xse xse on xse.ERP销售号=a.erpsaleno 
    JOIN d_zhyb_hz_cyb cyb ON a.erpsaleno=cyb.erp销售单号 --AND d_zhyb_hz_cyb.异地标志='非异地'
    JOIN d_ll_zxcy ON cyb.erp销售单号=d_ll_zxcy.saleno 
    WHERE a.RECEIPTDATE >= DATE'2024-01-01'
    AND a.CBD IN('331023')  
    --国谈条件
    AND nvl(cyb.统筹支付数,0)+nvl(cyb.公补基金支付数,0)+nvl(cyb.个人当年帐户支付数,0)<>0
and cyb.医疗费用总额 - nvl(gtjeed,0)<>0
  ) WHERE rn=1 and receiptdate between trunc(sysdate)-1 and trunc(sysdate);
  
 begin proc_zeys_rt_qygd() ; end;
 begin proc_zeys_rt_qygd24() ; end;
  /*DELETE from  D_YB_NEW_CUS_2023_hz;
  INSERT INTO D_YB_NEW_CUS_2023_hz 
(erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno)
  SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,
jslx,orderno
FROM ( 
SELECT erpsaleno, receiptdate, a.busno, saler, username, customername, identityno, nb_flag, a.cbd, cbdname, netsum, status, yg_flag,jslx,
a.orderno,cbrylb,
ROW_NUMBER() OVER (PARTITION BY  

IDENTITYNO ORDER BY receiptdate ASC) rn
 FROM d_yb_first_cus a
 --事业部
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303106')
--销售片区
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
--门店类型
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
  WHERE a.RECEIPTDATE >= DATE'2023-01-01'
  --AND a.CBD IN(330102,330127,330109,330122,330105,330110,330108,330106,330182)
  --去掉省本级
  AND a.cbd<>('339900')
  ) WHERE rn=1;*/
  
  

  --SELECT COUNT(*) FROM D_YB_NEW_CUS_2023 WHERE RECEIPTDATE>=DATE'2022-02-25'--1045822 
  
  /*MERGE INTO D_YB_NEW_CUS_2023 a
USING (SELECT ERP销售号,身份证号,MAX(人员类别) 人员类别 from tmp_wlybjs_cyb GROUP BY ERP销售号,身份证号) b
ON (a.ERPSALENO = b.ERP销售号 AND a.IDENTITYNO = b.身份证号)
WHEN MATCHED THEN
  UPDATE SET a.CBRYLB = b.人员类别;*/
      /*rows_updated := SQL%ROWCOUNT;


  DBMS_OUTPUT.PUT_LINE('Rows updated: ' || rows_updated);*/
  --医保23年新客(集团)
  
/*DELETE from  D_YB_NEW_CUS_2023_JT;
INSERT into D_YB_NEW_CUS_2023_JT 
 (erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno)
SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno
FROM (    
SELECT erpsaleno, receiptdate, a.busno, saler, username, customername, identityno, nb_flag, a.cbd, cbdname, netsum, status, yg_flag,
a.jslx,
a.orderno,
ROW_NUMBER() OVER (PARTITION BY identityno ORDER BY receiptdate ASC ) rn
FROM d_yb_first_cus a 
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN(303100,303101,303102)

WHERE  a.CBD IN(331082,331004,331083,331024,331081,331023,331022,331003,331002,331099)
AND a.receiptdate>=DATE'2023-01-01'
  ) WHERE rn=1  ;*/
 /* DELETE from  D_YB_NEW_CUS_2023_JT;
INSERT into D_YB_NEW_CUS_2023_JT 
 (erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno)
SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,jslx,orderno
FROM (    
SELECT erpsaleno, receiptdate, a.busno, saler, username, customername, identityno, nb_flag, a.cbd, cbdname, netsum, status, yg_flag,
CASE WHEN a.JSLX IN ('普通住院外检外购','随同住院报销') THEN '2'
       WHEN a.JSLX='门诊特病' THEN '1' ELSE '0' END AS jslx,
a.orderno,
ROW_NUMBER() OVER (PARTITION BY identityno ORDER BY receiptdate ASC ) rn
FROM tmp_YB_FIRST_CUS a
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN(303100,303101,303102)

WHERE  a.CBD IN(331082,331004,331083,331024,331081,331023,331022,331003,331002,331099)
AND NOT EXISTS(SELECT 1 FROM
D_YB_NEW_CUS_2023_JT b 
WHERE b.receiptdate>date'2023-01-01'AND b.receiptdate<a.receiptdate AND a.identityno=b.identityno
)
  ) WHERE rn=1  ;*/

--22年10开始门店组新增统计
  /*  INSERT INTO D_YB_FIRST_CUS_202210
      (erpsaleno, 
      receiptdate, 
      busno, 
      saler, 
      username, 
      customername, 
      identityno, 
      nb_flag, 
      cbd, 
      cbdname, 
      netsum, 
      status, 
      yg_flag
      )
SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno, 
a.nb_flag, a.cbd, a.cbdname, a.netsum, a.status, a.yg_flag 
FROM (
SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno, 
a.nb_flag, a.cbd, a.cbdname, a.netsum, a.status, a.yg_flag,
ROW_NUMBER() OVER (PARTITION BY receiptdate,IDENTITYNO ORDER BY NETSUM) AS rn
from tmp_YB_FIRST_CUS  a 
INNER JOIN s_busi s ON a.busno=s.busno
WHERE
NOT EXISTS
(select 1 from D_YB_FIRST_CUS_202210 b  
INNER JOIN s_busi s2 ON b.busno=s2.busno
WHERE b.receiptdate>date'2022-10-01'AND b.receiptdate<a.receiptdate AND a.identityno=b.identityno
AND s.zmdz1=s2.zmdz1
)
--AND s.zmdz1=81086 AND a.RECEIPTDATE=DATE'2023-04-01'
 ) a WHERE a.rn=1;*/

 -- COMMIT;
end;
/

