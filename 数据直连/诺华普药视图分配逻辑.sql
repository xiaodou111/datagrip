create or replace procedure proc_nh_bussjfp

--D_BAIER_CGSLFP D_BAIER_CGCKFP D_BAIER_YCSLFP D_BAIER_YCSLFP_temp

is
-----ŵ����ҩ�ķ������2023.11.1��
v_busnum number;
v_ct1 pls_integer;   --����
v_ct2 pls_integer;
v_ct3 pls_integer;
v_ct4 pls_integer;
--v_time date:=date'2023-09-01';
v_time date:=trunc(sysdate)-1;
v_wareqty1 d_hr_slfp.sl%type;  --����
--10111858,10111859,10114011 ���͵�ָ���ŵ꣨��������ŵ���ϸ����3�ϻ�3�����ϣ�ǰ�����ָ���ŵ�ȫ�����͵�λ��ǰ���£�
--10111871,10115988 ���͵�ָ���ŵ꣨��������ŵ���ϸ����4�ϻ�4�����ϣ�ǰ�����ָ���ŵ�ȫ�����͵�λ��ǰ���£�

begin
  --�жϵ�����û�� ���
   SELECT count(*)
  into v_ct1
  FROM stock_in o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001','D010')
  and matnr  in (select wareid from d_nh_py_ware)
  AND zdate>=v_time
  --AND zdate>=trunc(sysdate)-1
  --and zdate>=DATE'2023-08-01'
  ;
   --�жϵ�����û�� �˻�
   SELECT count(*)
  into v_ct1
  FROM stock_out o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001','D010')
  and matnr  in (select wareid from d_nh_py_ware)
  AND zdate>=v_time
  --AND zdate>=trunc(sysdate)-1
  --and zdate>=DATE'2023-08-01'
  ;
  --�ж���û��p888��p006�Ʋֵ�p001
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
 ---'P888','P006'���ķ���    ����
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
  --'P888','P006'����ķ��� �˻� ,ȡ��������ȡ����,��������Ϊ����,rksl ֱ��ȡ�����������ckslΪ0
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
 ---P888,P006�Ʋָ�P001,�˻���ⵥ
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
     ---P001 �Ʋָ�P888,P006,�������ⵥ
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
    
    --����������Ϊ769<640*3
/*select floor(769/3) from dual --256
select mod(769,3) from dual --1
select (256-1)*3+1*(3+1) from dual 

--ǰ floor(769/3)-1�ҵ�ֵ�3,��floor(769/3)�ҵ�ֵ�3+mod(769,3)


--����������Ϊ3000>640*3
select  floor(3000/640) from dual --4
select mod(3000,640)  from dual --440
select 5*440+200*4 from dual --3000*/

--ǰmod(3000,640)�ҵ�ֵ�floor(3000/640)+1��,ʣ�µķֵ�floor(3000/640)��
 end ;
