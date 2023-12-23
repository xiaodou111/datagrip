create or replace procedure proc_nh_bussjfp

--D_BAIER_CGSLFP D_BAIER_CGCKFP D_BAIER_YCSLFP D_BAIER_YCSLFP_temp

is
-----诺华普药的分配规则2023.11.1后
v_busnum number;
v_ct1 pls_integer;   --个数
v_ct2 pls_integer;
v_ct3 pls_integer;
v_ct4 pls_integer;
--v_time date:=date'2023-09-01';
v_time date:=trunc(sysdate)-1;
v_wareqty1 d_hr_slfp.sl%type;  --数量
--10111858,10111859,10114011 配送到指定门店（详见附件门店明细）各3合或3合以上（前提必须指定门店全能配送到位的前提下）
--10111871,10115988 配送到指定门店（详见附件门店明细）各4合或4合以上（前提必须指定门店全能配送到位的前提下）

begin
  --判断当天有没有 入库
   SELECT count(*)
  into v_ct1
  FROM stock_in o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001','D010')
  and matnr  in (select wareid from d_nh_py_ware)
  AND zdate>=v_time
  --AND zdate>=trunc(sysdate)-1
  --and zdate>=DATE'2023-08-01'
  ;
   --判断当天有没有 退货
   SELECT count(*)
  into v_ct1
  FROM stock_out o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001','D010')
  and matnr  in (select wareid from d_nh_py_ware)
  AND zdate>=v_time
  --AND zdate>=trunc(sysdate)-1
  --and zdate>=DATE'2023-08-01'
  ;
  --判断有没有p888或p006移仓到p001
  SELECT count(*)
  into v_ct3
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.CHARG=c.CHARG
   WHERE a.zodertype=3
   and a.matnr  in (select wareid from d_nh_py_ware)
  AND  a.lgort in('P888','P006') AND c.lgort='P001'
  AND a.zdate>=v_time;
  --and a.zdate>=DATE'2023-08-01';

  SELECT count(*)
  into v_ct4
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.CHARG=c.CHARG
   WHERE a.zodertype=3
   and a.matnr  in (select wareid from d_nh_py_ware)
  AND  a.lgort='P001'  AND c.lgort in('P888','P006')
  AND a.zdate>=v_time;
  --and a.zdate>=DATE'2023-08-01';

 if v_ct1+v_ct2+v_ct3+v_ct4=0 then
    return ;
  end if ;

  select count(*)
  into v_busnum
  from T_NH_BUS_FP;

if v_ct1>0 then
 ---'P888','P006'入库的分配    配送
 for res in (SELECT matnr,ZGYSPH as ph,zdate,DMBTR as dj,SUM(MSEH6) sl
             FROM   stock_in
             WHERE  lgort in ('P888','P006') and  zodertype='1' and werks in ('D001','D010')
                    and matnr  in (select wareid from d_nh_py_ware)
                    AND zdate>=v_time
  --and zdate>=DATE'2023-08-01'
             group by matnr,ZGYSPH,zdate,DMBTR
    )  loop
   if trim(res.matnr) NOT in (10111858,10111859,10114011,10111871,10115988)   then


   insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,1
     from T_NH_BUS_FP;
   end if;

   if trim(res.matnr) in (10111858,10111859,10114011)   then
      if res.sl<v_busnum*3 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/3)-1 then 3 else 3+mod(res.sl,3) end as sl,res.dj,1
     from T_NH_BUS_FP where id<=floor(res.sl/3)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,1
     from T_NH_BUS_FP;
      end if;
      end if;
 
   if trim(res.matnr) in (10111871,10115988)   then
     if res.sl<v_busnum*4 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/4)-1 then 4 else 4+mod(res.sl,4) end as sl,res.dj,1
     from T_NH_BUS_FP where id<=floor(res.sl/4)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,1
     from T_NH_BUS_FP;
      end if;
      end if;


  end loop ;
 end if ;

if v_ct2>0 then
  --'P888','P006'出库的分配 退货 ,取负数和再取负数,插入数据为整数,rksl 直接取分配的数量和cksl为0
  for res in (SELECT matnr,ZGYSPH as ph,zdate,DMBTR as dj,-SUM(MSEH6) sl
             FROM   stock_out o
             WHERE  lgort in ('P888','P006') and  zodertype='1' and werks in ('D001','D010')
                    and matnr  in (select wareid from d_nh_py_ware)
                    AND zdate>=v_time
  --and zdate>=DATE'2023-08-01'
             group by matnr,ZGYSPH,zdate,DMBTR
    )  loop
 if trim(res.matnr) not in (10111858,10111859,10114011,10111871,10115988)   then


   insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,2
     from T_NH_BUS_FP  ;
   end if;

    -- delete from D_BAIER_CGSLFP where sl=0;
   if trim(res.matnr) in (10111858,10111859,10114011)   then
      if res.sl<v_busnum*3 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/3)-1 then 3 else 3+mod(res.sl,3) end as sl,res.dj,2
     from T_NH_BUS_FP where id<=floor(res.sl/3)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,2
     from T_NH_BUS_FP;
      end if;
      end if;
 
   if trim(res.matnr) in (10111871,10115988)   then
     if res.sl<v_busnum*4 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/4)-1 then 4 else 4+mod(res.sl,4) end as sl,res.dj,2
     from T_NH_BUS_FP where id<=floor(res.sl/4)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,2
     from T_NH_BUS_FP;
      end if;
      end if;


  end loop ;
 end if ;


if v_ct3>0 then
 ---P888,P006移仓给P001,退货入库单
  for res in (SELECT a.matnr,a.ZGYSPH as ph,a.zdate,a.DMBTR as dj,SUM(a.menge) as sl
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.CHARG=c.CHARG
   WHERE a.zodertype=3
   and a.matnr  in (select wareid from d_nh_py_ware)

   AND a.lgort in('P888','P006') AND c.lgort='P001'

  AND a.zdate>=v_time
  --and a.zdate>=DATE'2023-08-01'
  group by a.matnr,a.ZGYSPH,a.ZDATE,a.DMBTR) LOOP


   if trim(res.matnr) not in (10111858,10111859,10114011,10111871,10115988)   then

   insert into   D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,3
     from T_NH_BUS_FP  ;
   end if;

   if trim(res.matnr) in (10111858,10111859,10114011)   then
      if res.sl<v_busnum*3 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/3)-1 then 3 else 3+mod(res.sl,3) end as sl,res.dj,3
     from T_NH_BUS_FP where id<=floor(res.sl/3)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,3
     from T_NH_BUS_FP;
      end if;
      end if;
 
   if trim(res.matnr) in (10111871,10115988)   then
     if res.sl<v_busnum*4 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/4)-1 then 4 else 4+mod(res.sl,4) end as sl,res.dj,3
     from T_NH_BUS_FP where id<=floor(res.sl/4)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,3
     from T_NH_BUS_FP;
      end if;
      end if;
  

 end loop ;
 end if;

 delete from D_BAIER_YCSLFP_temp;

 if v_ct4>0 then
     ---P001 移仓给P888,P006,批发出库单
  for res in (SELECT a.matnr,a.ZGYSPH as ph,a.zdate,a.DMBTR as dj,SUM(a.menge) as sl
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.CHARG=c.CHARG
   WHERE a.zodertype=3
   and a.matnr  in (select wareid from d_nh_py_ware)
   AND a.lgort='P001' AND c.lgort in('P888','P006')
  AND a.zdate>=v_time
  --and a.zdate>=DATE'2023-08-01'
  group by a.matnr,a.ZGYSPH,a.ZDATE,a.DMBTR) LOOP
   if trim(res.matnr) not in (10111858,10111859,10114011,10111871,10115988)   then

   insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,4
     from T_NH_BUS_FP  ;
   end if;

   if trim(res.matnr) in (10111858,10111859,10114011)   then
      if res.sl<v_busnum*3 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/3)-1 then 3 else 3+mod(res.sl,3) end as sl,res.dj,4
     from T_NH_BUS_FP where id<=floor(res.sl/3)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,4
     from T_NH_BUS_FP;
      end if;
      end if;
 
   if trim(res.matnr) in (10111871,10115988)   then
     if res.sl<v_busnum*4 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/4)-1 then 4 else 4+mod(res.sl,4) end as sl,res.dj,4
     from T_NH_BUS_FP where id<=floor(res.sl/4)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,4
     from T_NH_BUS_FP;
      end if;
      end if;
      
      
    end loop ;
    end if;
    delete from D_NH_BUSSLFP where sl=0;
    
    --假如待分配的为769<640*3
/*select floor(769/3) from dual --256
select mod(769,3) from dual --1
select (256-1)*3+1*(3+1) from dual 

--前 floor(769/3)-1家店分到3,第floor(769/3)家店分到3+mod(769,3)


--假如待分配的为3000>640*3
select  floor(3000/640) from dual --4
select mod(3000,640)  from dual --440
select 5*440+200*4 from dual --3000*/

--前mod(3000,640)家店分到floor(3000/640)+1个,剩下的分到floor(3000/640)个
 end ;
