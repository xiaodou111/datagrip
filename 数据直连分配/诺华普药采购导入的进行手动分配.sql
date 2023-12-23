declare

v_busnum number;
v_time date:=date'2023-09-01';
v_wareqty1 d_hr_slfp.sl%type;

begin

select count(*)
  into v_busnum
  from T_NH_BUS_FP;

 ---'P888','P006'»Îø‚µƒ∑÷≈‰    ≈‰ÀÕ
 for res in (SELECT  zdate,wareid as matnr,sum(sl) as sl,ph, null as dj
    from D_NH_CG_fp
    group by zdate,wareid,ph
    )  loop
   if trim(res.matnr) NOT in (10111858,10111859,10114011,10111871,10115988)   then


   insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER,compname)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,1,compname
     from T_NH_BUS_FP;
   end if;

   if trim(res.matnr) in (10111858,10111859,10114011)   then
      if res.sl<v_busnum*3 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER,compname)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/3)-1 then 3 else 3+mod(res.sl,3) end as sl,res.dj,1,compname
     from T_NH_BUS_FP where id<=floor(res.sl/3)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER,compname)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,1,compname
     from T_NH_BUS_FP;
      end if;
      end if;
 
   if trim(res.matnr) in (10111871,10115988)   then
     if res.sl<v_busnum*4 then
       insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER,compname)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=floor(res.sl/4)-1 then 4 else 4+mod(res.sl,4) end as sl,res.dj,1,compname
     from T_NH_BUS_FP where id<=floor(res.sl/4)  ;
      else
      insert into  D_NH_BUSSLFP (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER,compname)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<=mod(res.sl,v_busnum) then floor(res.sl/v_busnum)+1 else floor(res.sl/v_busnum) end as sl,res.dj,1,compname
     from T_NH_BUS_FP;
      end if;
      end if;


  end loop ;
  delete from D_NH_BUSSLFP where sl=0;
 end ;
 
 --select * from D_NH_BUSSLFP where wareid in (10500050,10500204,10111939,10502338,10500189,10502282,10502614)
