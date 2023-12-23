DECLARE

v_ct1 pls_integer;   --个数
v_ct2 pls_integer;

v_wareqty1 d_hr_slfp.sl%type;  --数量
v_wareqty2 d_hr_slfp.sl%type;
BEGIN
  for res in (SELECT matnr,zdate,ZSCQYMC,sum(ls) as ls,PH,DW  FROM (
             SELECT zdate,matnr,sum(ls) as ls ,max(ZSCQYMC) as ZSCQYMC,PH,DW
             FROM   V_ACCEPT_GLS_P001
             WHERE  lgort in ('P888','P006')  
             and zdate=date'2023-04-19'
             --and zdate>=date'2023-04-01'
             group by MATNR,zdate,PH,DW) 
             group by  matnr,zdate,ZSCQYMC,PH,DW) LOOP
             
   if abs(res.ls)>=5880 then
      INSERT INTO d_gls_pjfp (MATNR,zdate,ls,orgname,ZSCQYMC,PH,MSEH6)
      select res.matnr,res.zdate,case when res.ls<0 then floor(res.ls/294)-1 else floor(res.ls/294)+1 end,orgname,res.ZSCQYMC,res.PH,res.DW
      from d_gls_busno
      WHERE id<=mod(abs(res.ls),294)
      union all
      select res.matnr,res.zdate,floor(res.ls/294),orgname,res.ZSCQYMC,res.PH,res.DW
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
END;

--SELECT * from d_gls_pjfp WHERE matnr=10100568


