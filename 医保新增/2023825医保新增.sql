 insert into tmp_YB_FIRST_CUS(
      erpsaleno,
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
      yg_flag,
      JSLX,
      ORDERNO
      )
     SELECT a.erpsaleno,a.RECEIPTDATE,h.busno,d.saler,su.username,a.customername,a.IDENTITYNO,
    case when a.ext_char01 like '%居民%' OR a.ext_char01 like '%学%' OR a.ext_char01 like '%新生儿%' then 1 else 0 end nb_flag,
    a.ext_char12 AS 参保地,cbd.classname,h.netsum,2 AS status,
    case when a.ext_char04 like '%瑞人堂%' or a.ext_char04 like '%康康%' or a.ext_char04 like '%方同仁%'
    or a.ext_char04 like '%康盛堂%' then  1 else 0 end yg_flag,xse.就诊类型,a.orderno
    
    FROM
    t_yby_order_h a
    INNER JOIN t_sale_h h ON
    a.erpsaleno=h.saleno
    INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
    h.saleno=d.saleno
    left join s_user_base su on d.saler=su.userid
    LEFT join d_cbd cbd ON a.ext_char12= cbd.cbd
  
    --v_zjys_wl2023xse已经对退单和被退单的进行过滤了d_zjys_wl2023xse是把v_zjys_wl2023xse的所有数据插入进来
    join d_zjys_wl2023xse xse on a.erpsaleno=xse.erp销售号
    --left join d_yb_zdlx ry on ry.type='rylb' and b.PSNTYPE=trim(ry.code)
    WHERE a.RECEIPTDATE=trunc(SYSDATE)-1
    -->=date'2022-01-01'
    --;

      --删除退单数据
  /*  delete tmp_YB_FIRST_CUS a where exists(select 1 from tmp_YB_FIRST_CUS b  where a.ERPSALENO=b.ERPSALENO
    AND b.netsum<=0 AND b.RECEIPTDATE=trunc(SYSDATE)-1) ;

    delete from tmp_YB_FIRST_CUS a where ERPSALENO in (select RETSALENO from t_sale_return_h 
    where saleno in(select ERPSALENO from tmp_YB_FIRST_CUS where netsum<=0 and RECEIPTDATE=trunc(SYSDATE)-1));*/

     insert into d_yb_first_cus(
        erpsaleno,
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
        yg_flag,
        JSLX,
        ORDERNO
      )
     SELECT erpsaleno,
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
      yg_flag,
      CASE WHEN JSLX='住院双通道' THEN '2'
       WHEN JSLX='门诊特病' THEN '1' ELSE '0' END AS jslx  ,
      ORDERNO
      FROM tmp_YB_FIRST_CUS;
 
 
 DELETE from D_YB_NEW_CUS_2023_09 WHERE RECEIPTDATE>=date'2023-01-01';
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
    --
    
  WHERE a.RECEIPTDATE >= DATE'2023-01-01'
  AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001')
  
    --国谈条件
   AND nvl(cyb.统筹支付数,0)+nvl(cyb.公补基金支付数,0)+nvl(cyb.个人当年帐户支付数,0)<>0
and cyb.医疗费用总额 - nvl(gtjeed,0)<>0
  ) WHERE rn=1;
  
  delete from D_YB_NEW_CUS_2023_09 a 
  where not exists (select 1 from d_zjys_wl2023xse b where a.erpsaleno=b.erp销售号)
