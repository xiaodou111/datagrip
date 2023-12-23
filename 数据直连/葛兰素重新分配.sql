declare 
 v_ct1 NUMBER;
 v_ct2 NUMBER;
 v_ct3 number;
 v_ct4 number;
 v_time date:=date'2023-09-01' ;

begin
  
SELECT count(*)
  into v_ct1
  FROM stock_in o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001')
  and matnr  in (select wareid from d_gls_ware_py)
  AND zdate>=v_time;
--and zdate>=date'2023-04-01';

---判断当天有没有移仓  SELECT * FROM stock_out WHERE  ZODERTYPE=3
 SELECT count(*)
  into v_ct2
  FROM stock_out o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001')
  and matnr  in (select wareid from d_gls_ware_py)
  AND zdate>=v_time;
  --AND zdate>=trunc(
   --and a.zdate>=date'2023-04-01'  ;
  SELECT count(*)
  into v_ct3
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.CHARG=c.CHARG
   WHERE a.zodertype=3
   and a.matnr  in (select wareid from d_gls_ware_py)
  AND  a.lgort in('P888','P006') AND c.lgort='P001'
  AND a.zdate>=v_time;

  SELECT count(*)
  into v_ct4
  FROM  stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph and a.CHARG=c.CHARG
   WHERE a.zodertype=3
   and a.matnr  in (select wareid from d_gls_ware_py)
  AND  a.lgort='P001'  AND c.lgort in('P888','P006')
  AND a.zdate>=v_time;
if v_ct1+v_ct2+v_ct3+v_ct4=0 then
   return ;
  end if ;
  
  for res in (
            SELECT matnr,zdate,ZSCQYMC,sum(ls) as ls,PH,DW  FROM (
            --同一天数量对冲
             SELECT zdate,matnr,sum(ls) as ls ,max(ZSCQYMC) as ZSCQYMC,PH,DW
             FROM   V_ACCEPT_GLS_P001
             WHERE  lgort in ('P888','P006')  
             and zdate>=v_time
             --and zdate>=date'2023-04-01'
             group by MATNR,zdate,PH,DW

             union all

              select a.zdate,a.matnr,sum( decode(a.lgort,'P001',a.menge,-a.menge) ) as ls,max(a.ZSCQYMC) as ZSCQYMC,a.zgysph,a.MSEH6
             from stock_out a
             INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph
             WHERE
             ((a.lgort ='P001' AND c.lgort='P888') OR (a.lgort ='P001' AND c.lgort='P006')
              OR  (a.lgort ='P888' AND c.lgort='P001') OR (a.lgort ='P006' AND c.lgort='P001')
              )
              and a.ZODERTYPE=3 and  a.lifnr IN ('110093','110116','110388','110673')
              and  a.matnr in (select wareid from d_gls_ware_py)
              and a.zdate>=v_time
              --and  a.zdate>=date'2023-04-01'
              group by a.matnr,a.zdate,a.zgysph,a.MSEH6
              )  a
              group by  matnr,zdate,ZSCQYMC,PH,DW
             )  loop
    if abs(res.ls)>=5880 then
      INSERT INTO d_gls_pjfp (MATNR,zdate,ls,orgname,ZSCQYMC,PH,MSEH6)
      select res.matnr,res.zdate,case when res.ls<0 then ceil(res.ls/294)-1 else floor(res.ls/294)+1 end,orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id<=mod(abs(res.ls),294)
      union all
      select res.matnr,res.zdate,case when res.ls<0 then ceil(res.ls/294) else  floor(res.ls/294) end,orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id>mod(abs(res.ls),294)  ;
    end if ;

    if abs(res.ls)<5880 and  abs(res.ls)>1000 then
      INSERT INTO d_gls_pjfp (MATNR,zdate,ls,orgname,ZSCQYMC,PH,MSEH6)
      select res.matnr,res.zdate,case when res.ls<0 then -20 else 20 end ,orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id<=floor(abs(res.ls)/20)
      union all
      select res.matnr,res.zdate,mod(res.ls,20),orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id=floor(abs(res.ls)/20)+1 and mod(res.ls,20)<>0   ;
    end if ;

    if  abs(res.ls)<=1000 then
      INSERT INTO d_gls_pjfp (MATNR,zdate,ls,orgname,ZSCQYMC,PH,MSEH6)
      select res.matnr,res.zdate,case when res.ls<0 then -10 else 10 end ,orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id<=floor(abs(res.ls)/10)
      union all
      select res.matnr,res.zdate,mod(res.ls,10),orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id=floor(abs(res.ls)/10)+1 and mod(res.ls,10)<>0 ;
    end if ;
  end loop ;


end;
