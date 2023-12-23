delete from D_ZHYB_YEAR_2023_1;
   --.获取所有销售记录中每个身份证 药店所在地和参保地对应的 药店或诊所最后一次的记录
   insert into D_ZHYB_YEAR_2023_1 
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
   ) WHERE rn = 1;

--每个身份证23年开始最后一次在 药店所在地和参保地对应 诊所消费的记录
 delete from d_zhyb_year_2023_zs where execdate >= DATE '2023-01-01';
    INSERT INTO d_zhyb_year_2023_zs (execdate,customer,idcard,cbdid,cbd,busno)
    SELECT execdate,customer,idcard,cbdid,cbd,busno  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM d_zhyb_year_2023 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30511'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate >= DATE '2023-01-01'
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

    --每个身份证23年开始最后一次在 药店所在地和参保地对应 药店消费的记录
   delete from d_zhyb_year_2023_yd where execdate >= DATE '2023-01-01';
   INSERT INTO d_zhyb_year_2023_yd (execdate,customer,idcard,cbdid,cbd,busno)
     SELECT execdate,customer,idcard,cbdid,cbd,busno  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM d_zhyb_year_2023 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30510'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate >= DATE '2023-01-01'
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

delete from d_zhyb_year_2022_notzs where execdate>= DATE '2023-01-01'
INSERT into d_zhyb_year_2022_notzs(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT a.*,'诊所核心会员'  FROM D_ZHYB_YEAR_2023_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard)
and a.execdate>= DATE '2023-01-01' ;

delete from d_zhyb_year_2022_notyd where execdate>= DATE '2023-01-01'
INSERT into d_zhyb_year_2022_notyd(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT a.*,'药店核心会员'  FROM D_ZHYB_YEAR_2023_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b WHERE a.idcard=b.idcard)
and a.execdate>= DATE '2023-01-01' ;
--补参保单位
 MERGE INTO d_zhyb_year_2022_notyd a
   USING (SELECT ERP销售单号,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP销售单号 is not null and EXT_CHAR04 is not null 
   group by  ERP销售单号,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP销售单号)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;
--补参保单位
 MERGE INTO d_zhyb_year_2022_notzs a
   USING (SELECT ERP销售单号,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP销售单号 is not null and EXT_CHAR04 is not null 
   group by  ERP销售单号,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP销售单号)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;
   
 
DROP TRIGGER tr_d_zhyb_year_2022_notzs;
DROP TRIGGER tr_d_zhyb_year_2022_notyd;







    MERGE INTO d_zhyb_year_2022_notzs a
    USING(select IDCARD,HFRY,JTQK,GKYYXX,HFJL,PQCC,MGBCC,LASTTIME from d_zhyb_year_2022_notzs_1
    where HFRY is not null  and GKYYXX is not null and execdate>=date'2023-01-01') b
    on ( a.IDCARD=b.IDCARD)
    WHEN MATCHED THEN
   UPDATE SET
   a.HFRY=b.HFRY,
   a.JTQK=b.JTQK,
   a.GKYYXX=b.GKYYXX,
   a.PQCC=b.PQCC,
   a.MGBCC=b.MGBCC,
   a.LASTTIME=b.LASTTIME

   
    MERGE INTO d_zhyb_year_2022_notyd a
    USING(select IDCARD,HFRY,JTQK,GKYYXX,HFJL,PQCC,MGBCC,LASTTIME from d_zhyb_year_2022_notyd_1
    where HFRY is not null  and GKYYXX is not null and execdate>=date'2023-01-01') b
    on ( a.IDCARD=b.IDCARD)
    WHEN MATCHED THEN
   UPDATE SET
   a.HFRY=b.HFRY,
   a.JTQK=b.JTQK,
   a.GKYYXX=b.GKYYXX,
   a.PQCC=b.PQCC,
   a.MGBCC=b.MGBCC,
   a.LASTTIME=b.LASTTIME
   
   
   MERGE INTO d_zhyb_year_2022_notzs a
    USING(select IDCARD,max(HFRY) HFRY ,max(JTQK) jtqk,max(GKYYXX) GKYYXX ,max(HFJL) hfjt,max(PQCC) pqcc,max(MGBCC) MGBCC,max(LASTTIME) LASTTIME 
    from d_zhyb_year_2022_not_new
    where HFRY is not null  and GKYYXX is not null and execdate<date'2023-01-01'
    group by IDCARD ) b
    on ( a.IDCARD=b.IDCARD)
    WHEN MATCHED THEN
   UPDATE SET
   a.HFRY=b.HFRY,
   a.JTQK=b.JTQK,
   a.GKYYXX=b.GKYYXX,
   a.PQCC=b.PQCC,
   a.MGBCC=b.MGBCC,
   a.LASTTIME=b.LASTTIME
   
   MERGE INTO d_zhyb_year_2022_notyd a
    USING(select IDCARD,max(HFRY) HFRY ,max(JTQK) jtqk,max(GKYYXX) GKYYXX ,max(HFJL) hfjt,max(PQCC) pqcc,max(MGBCC) MGBCC,max(LASTTIME) LASTTIME 
    from d_zhyb_year_2022_not_new
    where HFRY is not null  and GKYYXX is not null and execdate<date'2023-01-01'
    group by IDCARD) b
    on ( a.IDCARD=b.IDCARD)
    WHEN MATCHED THEN
   UPDATE SET
   a.HFRY=b.HFRY,
   a.JTQK=b.JTQK,
   a.GKYYXX=b.GKYYXX,
   a.PQCC=b.PQCC,
   a.MGBCC=b.MGBCC,
   a.LASTTIME=b.LASTTIME


   
   create or replace trigger tr_d_zhyb_year_2022_notzs
after update of JTQK  on d_zhyb_year_2022_notzs
for each row

declare
  v_qh1 t_cash_coupon_info.coupon_no%type;
 v_cnt integer ;
   v_begin date;
  v_end date;
    v_mobile t_memcard_reg.mobile%type;
v_MEMBERCARDNO VARCHAR2(30);

begin
  if :new.JTQK is null or :new.HFRY is null  or :new.GKYYXX is null   then
    raise_application_error(-20001,'回访人员,接听情况,顾客用药信息必填',true);
    return ;
 end if  ;
 
select MEMBERCARDNO
into  v_MEMBERCARDNO
from t_sale_h where saleno=:new.SALENO;

 /*SELECT COUNT(*)
  into v_cnt
  FROM T_CASH_COUPON_INFO
  WHERE card_no=v_MEMBERCARDNO;*/

  -----接通了就发券
 if :new.JTQK  in ('接通','家人接听')  then
   SELECT seq_memcard_ymh_cashno.nextval
    into  v_qh1
     FROM  dual ;   ---6yuan
     v_begin:=trunc(sysdate) ;
     v_end:=trunc(sysdate)+30;
     SELECT nvl(mobile ,tel)
     into v_mobile
     FROM t_memcard_reg
     WHERE memcardno=v_MEMBERCARDNO ;
     
INSERT INTO T_CASH_COUPON_INFO
        (COUPON_NO,ISSUING_DATE,COMPID,BUSNOS,COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,
         CARD_NO, MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,CREATEUSER,CREATETIME,COUPON_KIND,
         ADVANCE_PAYAMT, --预约金
         CREATE_BUSNO,
         CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
         BAK4, BAK6,BAK7,BAK9 --券类型1折扣、2满减、3礼品券

         )
        SELECT v_qh1,SYSDATE,0,BUSNOS,COUPON_VALUES,LEAST_SALES,
             COUPON_TYPE,COUPON_TYPE_DESC,v_MEMBERCARDNO,v_mobile,
       v_begin as  starttime,
       v_end as  endtime, 0,1,:new.type,'168',SYSDATE,
             COUPON_KIND,0,null,2,CLASSCODES,null,COUPON_TYPE_DESC, 2
       FROM T_CASH_COUPON_TYPE    WHERE COUPON_TYPE='核心会员礼品券' ;
  end if;

end ;





create or replace trigger tr_d_zhyb_year_2022_notyd
after update of JTQK  on d_zhyb_year_2022_notyd
for each row

declare
  v_qh1 t_cash_coupon_info.coupon_no%type;
 v_cnt integer ;
   v_begin date;
  v_end date;
    v_mobile t_memcard_reg.mobile%type;
v_MEMBERCARDNO VARCHAR2(30);

begin
  if :new.JTQK is null or :new.HFRY is null  or :new.GKYYXX is null   then
    raise_application_error(-20001,'回访人员,接听情况,顾客用药信息必填',true);
    return ;
 end if  ;
 
select MEMBERCARDNO
into  v_MEMBERCARDNO
from t_sale_h where saleno=:new.SALENO;

 /*SELECT COUNT(*)
  into v_cnt
  FROM T_CASH_COUPON_INFO
  WHERE card_no=v_MEMBERCARDNO;*/

  -----接通了就发券
 if :new.JTQK  in ('接通','家人接听')  then
   SELECT seq_memcard_ymh_cashno.nextval
    into  v_qh1
     FROM  dual ;   ---6yuan
     v_begin:=trunc(sysdate) ;
     v_end:=trunc(sysdate)+30;
     SELECT nvl(mobile ,tel)
     into v_mobile
     FROM t_memcard_reg
     WHERE memcardno=v_MEMBERCARDNO ;
     
INSERT INTO T_CASH_COUPON_INFO
        (COUPON_NO,ISSUING_DATE,COMPID,BUSNOS,COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,
         CARD_NO, MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,CREATEUSER,CREATETIME,COUPON_KIND,
         ADVANCE_PAYAMT, --预约金
         CREATE_BUSNO,
         CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
         BAK4, BAK6,BAK7,BAK9 --券类型1折扣、2满减、3礼品券

         )
        SELECT v_qh1,SYSDATE,0,BUSNOS,COUPON_VALUES,LEAST_SALES,
             COUPON_TYPE,COUPON_TYPE_DESC,v_MEMBERCARDNO,v_mobile,
       v_begin as  starttime,
       v_end as  endtime, 0,1,:new.type,'168',SYSDATE,
             COUPON_KIND,0,null,2,CLASSCODES,null,COUPON_TYPE_DESC, 2
       FROM T_CASH_COUPON_TYPE    WHERE COUPON_TYPE='核心会员礼品券' ;
  end if;

end ;

 
