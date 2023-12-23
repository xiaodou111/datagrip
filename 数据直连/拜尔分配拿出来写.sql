declare
v_ct1 pls_integer;   --个数
v_ct2 pls_integer;
v_ct3 pls_integer;
v_ct4 pls_integer;

begin
  
 SELECT count(*)
  into v_ct1
  FROM v_accept_baier_temp
  WHERE lgort in ('P888','P006') and  ls>0
  and matnr  in (10100419,10116148,10500177,10100254,10108615,10300170,10111664,10111682,10111683,10502516)
  --AND zdate=trunc(sysdate)-1
  and zdate>=DATE'2023-05-01'
  ;

   --判断当天有没有 退货
   SELECT count(*)
  into v_ct2
  FROM v_accept_baier_temp
  WHERE  lgort in ('P888','P006','P030')  and  ls<0
  and matnr  in (10100419,10116148,10500177,10100254,10108615,10300170,10111664,10111682,10111683,10502516)
  --AND zdate=trunc(sysdate)-1
  and zdate>=DATE'2023-05-01'
  ;
  --判断有没有p888或p006移仓到p001
  SELECT count(*)
  into v_ct3
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph
   WHERE a.zodertype=3
   AND   exists(
   select 1 from D_BAIER_cgspml b where a.matnr=b.wareid
   )   
  AND  a.lgort in('P888','P006') AND c.lgort='P001'
  --AND a.zdate=trunc(sysdate)-1
  and a.zdate>=DATE'2023-05-01';
  
  SELECT count(*)
  into v_ct4
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph
   WHERE a.zodertype=3
   AND   exists(
   select 1 from D_BAIER_cgspml b where a.matnr=b.wareid
   )   
  AND  a.lgort='P001'  AND c.lgort in('P888','P006')
  --AND a.zdate=trunc(sysdate)-1;
  and a.zdate>=DATE'2023-05-01'

 if v_ct1+v_ct2+v_ct3+v_ct4=0 then
    return ;
  end if ;
  
if v_ct1>0 then
 ---'P888','P006'入库的分配    配送
 for res in (SELECT matnr,ph,zdate,dj,SUM(ls) sl
             FROM   v_accept_baier_temp
             WHERE  lgort in ('P888','P006') and ls>0 and 
             matnr  in (10100419,10116148,10500177,10100254,10108615,10300170,10111664,10111682,10111683,10502516)
             --AND zdate=trunc(sysdate)-1
  and zdate>=DATE'2023-05-01'
             group by matnr,ph,ZDATE,dj     
    )  loop
   if trim(res.matnr) in (10100419,10116148,10500177,10100254,10108615,10300170)   then          
   
   
   insert into  d_baier_cgslfp_temp (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,385) then floor(res.sl/385)+1 else floor(res.sl/385) end as sl,res.dj,1
     from T_BAIER_BUS_taizhou  ;
   end if;  
      
    -- delete from D_BAIER_CGSLFP where sl=0;
   if trim(res.matnr) in (10111664,10111682,10111683)   then  
   
   
   insert into  d_baier_cgslfp_temp (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,3) then floor(res.sl/3)+1 else floor(res.sl/3) end as sl,res.dj,1
     from T_BAIER_BUS_brt  ;
    end if; 
    
   if trim(res.matnr) in (10502516)   then  
   
   
    insert into  d_baier_cgslfp_temp (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,11) then floor(res.sl/11)+1 else floor(res.sl/11) end as sl,res.dj,1
     from T_BAIER_BUS_ysm  ;
   end if;    
     delete from d_baier_cgslfp_temp where sl=0;
   
  end loop ;
 end if ;
 
if v_ct2>0 then
  --'P888','P006'出库的分配 退货 ,取负数和再取负数,插入数据为整数,rksl 直接取分配的数量和cksl为0
  for res in (SELECT matnr,ph,zdate,dj,-SUM(ls) sl
             FROM   v_accept_baier_temp
             WHERE  lgort in ('P888','P006') and ls<0 and 
             matnr  in (10100419,10116148,10500177,10100254,10108615,10300170,10111664,10111682,10111683,10502516)
             --AND zdate=trunc(sysdate)-1
  and zdate>=DATE'2023-05-01'
             group by matnr,ph,ZDATE,dj     
    )  loop
 if trim(res.matnr) in (10100419,10116148,10500177,10100254,10108615,10300170)   then          
   
   
   insert into  d_baier_cgslfp_temp (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,385) then floor(res.sl/385)+1 else floor(res.sl/385) end as sl,res.dj,1
     from T_BAIER_BUS_taizhou  ;
   end if;  
      
    -- delete from D_BAIER_CGSLFP where sl=0;
   if trim(res.matnr) in (10111664,10111682,10111683)   then  
   
   
   insert into  d_baier_cgslfp_temp (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,3) then floor(res.sl/3)+1 else floor(res.sl/3) end as sl,res.dj,1
     from T_BAIER_BUS_brt  ;
    end if; 
    
   if trim(res.matnr) in (10502516)   then  
   
   
    insert into  d_baier_cgslfp_temp (zdate ,busno ,wareid ,ph ,sl,dj,ZORDER)
     SELECT res.zdate,busno,trim(res.matnr),res.ph,
     case when ID<= mod(res.sl,11) then floor(res.sl/11)+1 else floor(res.sl/11) end as sl,res.dj,1
     from T_BAIER_BUS_ysm  ;
   end if;    
     delete from D_BAIER_CGSLFP where sl=0;
   
  end loop ;
 end if ;   
end;
