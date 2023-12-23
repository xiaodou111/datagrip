alter table d_zhyb_year_2022_yd add saleno VARCHAR2(50); 
alter table d_zhyb_year_2022_yd add CBRYLX varchar2(200); 
alter table d_zhyb_year_2022_zs add saleno VARCHAR2(50); 
alter table d_zhyb_year_2022_zs add CBRYLX varchar2(200); 
select * from 
D_ZHYB_YEAR_2022_ZS

 --每个身份证22年 药店所在地和参保地对应的 最后一次在诊所消费的记录
    delete from D_ZHYB_YEAR_2022_ZS;
    INSERT INTO D_ZHYB_YEAR_2022_ZS (execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx)
    SELECT execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,saleno,cbrylx,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM v_zhyb_year_2022 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30511'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate < DATE '2023-01-01'
  and 
   --取参保地和药店所在地对应的数据
    CASE WHEN a.cbd IN ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
 
  and CBRYLX='医保'  THEN '医保市本级' 
  when a.cbd IN ('台州市本级','台州市椒江区') and CBRYLX='农保'  THEN '农保市本级'
    else a.cbd end 
      =
      case when replace(tb2.classname,'台州市玉环市','台州市玉环县')  in ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
    and CBRYLX='医保'  THEN '医保市本级' 
    when replace(tb2.classname,'台州市玉环市','台州市玉环县') IN ('台州市本级','台州市椒江区') and CBRYLX='农保'  THEN '农保市本级'
      else  replace(tb2.classname,'台州市玉环市','台州市玉环县') end
) WHERE rn = 1;
--每个身份证22年 药店所在地和参保地对应的 最后一次在药店消费的记录
 delete from d_zhyb_year_2022_yd;
   INSERT INTO d_zhyb_year_2022_yd (execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx)
     SELECT execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,saleno,cbrylx,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM d_zhyb_year_2022 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30510'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate < DATE '2023-01-01'
  and 
   --取参保地和药店所在地对应的数据
    CASE WHEN a.cbd IN ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
 
  and CBRYLX='医保'  THEN '医保市本级' 
  when a.cbd IN ('台州市本级','台州市椒江区') and CBRYLX='农保'  THEN '农保市本级'
    else a.cbd end 
      =
      case when replace(tb2.classname,'台州市玉环市','台州市玉环县')  in ('台州市本级','台州市椒江区','台州市黄岩区','台州市路桥区')
    and CBRYLX='医保'  THEN '医保市本级' 
    when replace(tb2.classname,'台州市玉环市','台州市玉环县') IN ('台州市本级','台州市椒江区') and CBRYLX='农保'  THEN '农保市本级'
      else  replace(tb2.classname,'台州市玉环市','台州市玉环县') end
) WHERE rn = 1;

 delete from d_zhyb_year_2022_notyd where execdate < DATE '2023-01-01'
 
   INSERT into d_zhyb_year_2022_notyd(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT a.*,'2022核心药店会员'  FROM d_zhyb_year_2022_yd  a
WHERE NOT EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2023_1 b WHERE a.idcard=b.idcard)

delete from d_zhyb_year_2022_notzs where execdate < DATE '2023-01-01'
   INSERT into d_zhyb_year_2022_notzs(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT a.*,'2022核心诊所会员'  FROM d_zhyb_year_2022_zs  a
WHERE NOT EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2023_1 b WHERE a.idcard=b.idcard)


 MERGE INTO d_zhyb_year_2022_notyd a
   USING (SELECT ERP销售单号,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP销售单号 is not null and EXT_CHAR04 is not null 
   group by  ERP销售单号,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP销售单号)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;

 MERGE INTO d_zhyb_year_2022_notzs a
   USING (SELECT ERP销售单号,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP销售单号 is not null and EXT_CHAR04 is not null 
   group by  ERP销售单号,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP销售单号)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;
   
 merge into d_zhyb_year_2022_notyd
   
   /*select count(*) from d_zhyb_year_2022_notzs
   select count(*) from d_zhyb_year_2022_notyd
   
   
  SELECT count(*)   FROM d_zhyb_year_2022_1  a
JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30511'
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023 b WHERE a.idcard=b.idcard)*/

select * from d_zhyb_year_2023 where idcard='331081199302080023'
select * from v_zhybjsjlb WHERE 身份证号='331081199302080023'
delete from d_zhyb_year_2022_notyd where execdate<date'2023-01-01'



