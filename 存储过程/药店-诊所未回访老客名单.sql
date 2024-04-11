create or replace PROCEDURE proc_ybcust_ydzs
IS


BEGIN
    --插入前一天的医保记录 d_zhyb_year_2023 min(EXECDATE)=2023/1/1 7:03:11
  /*INSERT INTO d_zhyb_year_2023
         SELECT 销售日期,姓名,身份证号,参保地编码,参保地,busno,ERP销售单号,参保人员类别 FROM (
            SELECT 销售日期,姓名,身份证号,参保地编码,参保地,busno,ERP销售单号,参保人员类别, ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 销售日期 DESC) rn
           FROM v_zhybjsjlb WHERE 参保地 LIKE '台州%' AND 销售日期 between trunc(SYSDATE)-1
         AND trunc(SYSDATE))
         WHERE rn=1;
         --D_ZHYB_YEAR_2023_1 (d_zhyb_year_2022_1+d_zhyb_year_2023+取最后消费时间)*/
         
       /*在这个作业里更新了  'H2.药店诊所未回访基础数据更新',
                                job_type            => 'STORED_PROCEDURE',
                                job_action          => 'proc_d_zhyb_year_2023',*/
   
  --D_ZHYB_YEAR_2023_1   获取所有销售记录中每个身份证 2023年药店所在地和参保地对应的 药店或诊所最后一次的记录
   delete from D_ZHYB_YEAR_2024_1;
   --.获取所有销售记录中每个身份证 2024年药店所在地和参保地对应的 药店或诊所最后一次的记录
   insert into D_ZHYB_YEAR_2024_1
   select execdate, customer, idcard, cbdid, cbd, busno, saleno, cbrylx 
   from (
   select execdate, customer, idcard, cbdid, cbd, a.busno, saleno, cbrylx, 
   ROW_NUMBER() OVER (PARTITION BY idcard,ts.classcode ORDER BY execdate DESC) rn
   from d_zhyb_year_2023 a
   JOIN t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305'
   JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
   where 
   --取参保地和药店所在地对应的数据
    CASE WHEN a.cbd IN ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
  --not like '%居民%'医保
  and CBRYLX not like '%居民%'  THEN '医保市本级' 
  when a.cbd IN ('台州市本级','台州市椒江区') and CBRYLX like '%居民%'  THEN '农保市本级'
  else a.cbd end 
    = case when replace(tb2.classname,'台州市玉环市','台州市玉环县')  in ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
    and CBRYLX not like '%居民%'  THEN '医保市本级' 
    when replace(tb2.classname,'台州市玉环市','台州市玉环县') IN ('台州市本级','台州市椒江区') and CBRYLX like '%居民%'  THEN '农保市本级'
      else  replace(tb2.classname,'台州市玉环市','台州市玉环县') end 
   and a.EXECDATE>=date'2024-01-01' and a.EXECDATE<date'2024-01-01') WHERE rn = 1;
   
 
   
 /*  MERGE INTO D_ZHYB_YEAR_2023_1 a
   USING (SELECT execdate, customer, idcard, cbdid, cbd, busno, saleno, cbrylx
   FROM d_zhyb_year_2023 WHERE EXECDATE between trunc(SYSDATE)-1 AND trunc(SYSDATE)
    ) b
   ON (a.IDCARD = b.IDCARD)
   WHEN MATCHED THEN
   UPDATE SET
   a.EXECDATE = b.EXECDATE,
   a.CUSTOMER = b.CUSTOMER,
   a.CBDID = b.CBDID,
   a.CBD = b.CBD,
   a.BUSNO = b.BUSNO,
   a.SALENO = b.SALENO,
   a.CBRYLX = b.CBRYLX
  WHEN NOT MATCHED THEN
   INSERT (execdate, customer, idcard, cbdid, cbd, busno, saleno, cbrylx)
   VALUES (b.execdate, b.customer, b.idcard, b.cbdid, b.cbd, b.busno, b.saleno, b.cbrylx);*/

 /* INSERT INTO D_ZHYB_YEAR_2023_1
SELECT aa.execdate, customer, idcard, cbdid, cbd, busno, saleno, cbrylx FROM (
SELECT a.*,ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn  FROM
 (
SELECT * from d_zhyb_year_2023
UNION ALL SELECT * FROM d_zhyb_year_2022_1) a )aa WHERE rn=1*/


    /*INSERT INTO d_zhyb_year_2023_zs
SELECT a.execdate,a.customer,a.idcard,a.cbdid,a.cbd,a.busno FROM(
SELECT a.execdate,a.customer,a.idcard,a.cbdid,a.cbd,a.busno,
ROW_NUMBER() OVER (PARTITION BY a.idcard ORDER BY a.execdate DESC) rn
 from d_zhyb_year_2023 a
JOIN t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode=30511) a
WHERE rn=1*/
    --刷新医保来诊所的顾客最后一次消费记录
    /*DELETE from d_zhyb_year_2023_zs a WHERE EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2023_1 b WHERE a.idcard=b.idcard
    AND b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE) );*/
    
    --每个身份证24年开始最后一次在 药店所在地和参保地对应的 诊所消费的记录
    delete from d_zhyb_year_2023_zs;
    INSERT INTO d_zhyb_year_2023_zs (execdate,customer,idcard,cbdid,cbd,busno)
    SELECT execdate,customer,idcard,cbdid,cbd,busno  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM d_zhyb_year_2023 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30511'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate >= DATE '2024-01-01'
  and 
   --取参保地和药店所在地对应的数据
    CASE WHEN a.cbd IN ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
  --not like '%居民%'医保
  and CBRYLX not like '%居民%'  THEN '医保市本级' 
  when a.cbd IN ('台州市本级','台州市椒江区') and CBRYLX like '%居民%'  THEN '农保市本级'
  else a.cbd end 
    = case when replace(tb2.classname,'台州市玉环市','台州市玉环县')  in ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
    and CBRYLX not like '%居民%'  THEN '医保市本级' 
    when replace(tb2.classname,'台州市玉环市','台州市玉环县') IN ('台州市本级','台州市椒江区') and CBRYLX like '%居民%'  THEN '农保市本级'
      else  replace(tb2.classname,'台州市玉环市','台州市玉环县') end
) WHERE rn = 1;


    --每个身份证24年开始最后一次在 药店所在地和参保地对应的 药店消费的记录
   delete from d_zhyb_year_2023_yd;
  INSERT INTO d_zhyb_year_2023_yd (execdate,customer,idcard,cbdid,cbd,busno)
     SELECT execdate,customer,idcard,cbdid,cbd,busno  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM d_zhyb_year_2023 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30510'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate >= DATE '2024-01-01'
  and 
   --取参保地和药店所在地对应的数据
    CASE WHEN a.cbd IN ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
  --not like '%居民%'医保
  and CBRYLX not like '%居民%'  THEN '医保市本级' 
  when a.cbd IN ('台州市本级','台州市椒江区') and CBRYLX like '%居民%'  THEN '农保市本级'
  else a.cbd end 
    = case when replace(tb2.classname,'台州市玉环市','台州市玉环县')  in ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
    and CBRYLX not like '%居民%'  THEN '医保市本级' 
    when replace(tb2.classname,'台州市玉环市','台州市玉环县') IN ('台州市本级','台州市椒江区') and CBRYLX like '%居民%'  THEN '农保市本级'
      else  replace(tb2.classname,'台州市玉环市','台州市玉环县') end 
) WHERE rn = 1;


/*INSERT into d_zhyb_year_2022_notzs
SELECT a.*  FROM D_ZHYB_YEAR_2023_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard)*/

   --前一天来过的顾客从 22年顾客今年没来诊所的表里删除
 /*  DELETE from d_zhyb_year_2022_notzs  a
   WHERE EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b
   WHERE a.idcard=b.idcard AND b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE) );
   --前一天来过的顾客从 22年顾客今年没来药店的表里删除
   DELETE from d_zhyb_year_2022_notyd a
   WHERE EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b
   WHERE a.idcard=b.idcard AND b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE) );*/
   
--d_zhyb_year_2022_notzs:有在药店消费,诊所未消费,诊所消费后去除
DELETE from d_zhyb_year_2022_notzs a
WHERE EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b
   WHERE a.idcard=b.idcard AND b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE));
DELETE from d_zhyb_year_2022_notyd a
WHERE EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b
   WHERE a.idcard=b.idcard AND b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE) );







--插入前一天数据中 没在诊所消费的数据(在药店消费的数据)  并把表中原先有身份证的删除
INSERT into d_zhyb_year_2022_notzs(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT EXECDATE, CUSTOMER, IDCARD, CBDID, CBD, BUSNO, SALENO, CBRYLX,'诊所核心会员'  FROM D_ZHYB_YEAR_2023_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard)
and a.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE) ;

--前一天新增进表里的用身份证删除以前的数据
delete from d_zhyb_year_2022_notzs a where exists(
select 1 from d_zhyb_year_2022_notzs b
where b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE)
and a.idcard=b.idcard and not a.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE)
);


INSERT into d_zhyb_year_2022_notyd(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT EXECDATE, CUSTOMER, IDCARD, CBDID, CBD, BUSNO, SALENO, CBRYLX,'药店核心会员'  FROM D_ZHYB_YEAR_2023_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b WHERE a.idcard=b.idcard)
and a.execdate  between trunc(SYSDATE)-1 AND trunc(SYSDATE);

delete from d_zhyb_year_2022_notyd a where exists(
select 1 from d_zhyb_year_2022_notyd b
where b.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE)
and a.idcard=b.idcard  and not a.execdate between trunc(SYSDATE)-1 AND trunc(SYSDATE)
);

--补参保单位
 MERGE INTO d_zhyb_year_2022_notyd a
   USING (SELECT ERP销售单号,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP销售单号 is not null and EXT_CHAR04 is not null and 销售日期 between trunc(SYSDATE)-2 AND trunc(SYSDATE)
   group by  ERP销售单号,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP销售单号)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;

 MERGE INTO d_zhyb_year_2022_notzs a
   USING (SELECT ERP销售单号,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP销售单号 is not null and EXT_CHAR04 is not null and 销售日期 between trunc(SYSDATE)-2 AND trunc(SYSDATE)
   group by  ERP销售单号,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP销售单号)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;



 ----更新 隐藏数据  d_zhyb_year_2022_not_new
/*update  d_zhyb_year_2022_not_new a   set  bj=1
WHERE   type like '%药店%'  and bj=0
and  exists(select 1 from     t_yby_order_h b WHERE    a.idcard=b.identityno  and RECEIPTDATE=trunc(sysdate-1)   and b.INSTITUTIONNAME  not like '%诊%'      )

;

update  d_zhyb_year_2022_not_new a   set  bj=1
WHERE   type like '%诊所%'  and bj=0
and  exists(select 1 from     t_yby_order_h b WHERE    a.idcard=b.identityno  and RECEIPTDATE=trunc(sysdate-1)   and b.INSTITUTIONNAME   like '%诊%'      )
;*/


  COMMIT;
  END;
/


--重新统计运行
-- --2024药店有消费,诊所未消费--诊所核心会员
-- INSERT into d_zhyb_year_2022_notzs(EXECDATE, CUSTOMER, IDCARD, CBDID, CBD, BUSNO, SALENO, CBRYLX, TYPE)
-- SELECT a.EXECDATE, a.CUSTOMER, a.IDCARD, a.CBDID, a.CBD, a.BUSNO, a.SALENO, a.CBRYLX,'诊所核心会员'
-- FROM D_ZHYB_YEAR_2024_1  a
-- WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard);
--
-- --2023年11-12月有到诊所消费且24年未消费的--2023核心诊所会员
-- INSERT into d_zhyb_year_2022_notzs(EXECDATE, CUSTOMER, IDCARD, CBDID, CBD, BUSNO, SALENO, CBRYLX, TYPE)
-- SELECT a.EXECDATE, a.CUSTOMER, a.IDCARD, a.CBDID, a.CBD, a.BUSNO, a.SALENO, a.CBRYLX,'2023核心诊所会员'
-- FROM D_ZHYB_YEAR_2023_1  a
-- where a.EXECDATE>=date'2023-11-01' and a.EXECDATE<date'2024-01-01'
--   and a.mdlx=30511
-- and NOT EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2024_1 b WHERE a.idcard=b.idcard);
--
-- --2024诊所有消费,药店未消费--药店核心会员
-- delete from  d_zhyb_year_2022_notyd;
-- INSERT into d_zhyb_year_2022_notyd(EXECDATE, CUSTOMER, IDCARD, CBDID, CBD, BUSNO, SALENO, CBRYLX, TYPE)
-- SELECT a.EXECDATE, a.CUSTOMER, a.IDCARD, a.CBDID, a.CBD, a.BUSNO, a.SALENO, a.CBRYLX,'药店核心会员'
-- FROM D_ZHYB_YEAR_2024_1  a
-- WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b WHERE a.idcard=b.idcard);
-- --2023年11-12月有到药店消费且24年未消费的--2023核心药店会员
-- INSERT into d_zhyb_year_2022_notyd(EXECDATE, CUSTOMER, IDCARD, CBDID, CBD, BUSNO, SALENO, CBRYLX, TYPE)
-- SELECT a.EXECDATE, a.CUSTOMER, a.IDCARD, a.CBDID, a.CBD, a.BUSNO, a.SALENO, a.CBRYLX,'2023核心药店会员'
-- FROM D_ZHYB_YEAR_2023_1  a
-- where a.EXECDATE>=date'2023-11-01' and a.EXECDATE<date'2024-01-01'
--   and a.mdlx=30510
-- and NOT EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2024_1 b WHERE a.idcard=b.idcard);
