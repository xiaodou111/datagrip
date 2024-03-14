create procedure proc_sjzl_createzbview (p_name in varchar2,
                                              p_waretable in VARCHAR2,
                                              p_lifnr IN VARCHAR2 
                                              

                                          --    p_jm in in varchar2(100),
                                           --   ds in in varchar2(100),
                                             )
    is
   /*
     v_ck   varchar2(100);

     v_lifnr varchar2(300);
     v_hw varchar2(300);*/



        v_accept VARCHAR2(50);
        v_kc VARCHAR2(50);
        v_sale VARCHAR2(50);
        v_wareids varchar2(300);
        v_lifnrs varchar2(300);
        v_kk   varchar2(3000);
        v_kk1   varchar2(3000);
        v_kk2   varchar2(6000);
       -- v_busno  varchar2(300);
        --v_accept NUMBER;
        --v_kc NUMBER;
        --v_sale NUMBER;
        --v_busnos varchar2(300);
        --v_werks varchar2(300);
     begin
       v_accept := 'V_ACCEPT_' || p_name || '_P001';
       v_kc := 'V_KC_' || p_name || '_P001';
       v_sale := 'V_SALE_' || p_name || '_P001';
  --  f_get_sjzl_rename

       /*SELECT f_get_sjzl_rename(p_wareids)
      into v_wareids
       FROM dual ;*/
       SELECT f_get_sjzl_rename(p_lifnr)
      into v_lifnrs
       FROM dual ;
     /*  SELECT f_get_sjzl_rename(p_werks)
      into v_werks
       FROM dual ; */
      /*  SELECT f_get_sjzl_rename(p_busno)
      into v_busno
       FROM dual ;*/
    --   v_xsfmc:=''''||p_xsfmc||'''';
    ----

       --创建accept视图

      v_kk:='CREATE OR REPLACE  VIEW '|| v_accept ||' AS
SELECT nvl(l.name1_snf,i.name1) as XSFMC,null as cgfdm,decode(i.werks,''D001'',''台州瑞人堂药业有限公司'',''浙江瑞人堂药业有限公司'')  as cgfmc,i.matnr as cpdm,i.maktx as cpmc,i.zguig as cpgg,
       i.mseh6 as dw,i.zgysph as ph,sum(i.menge) as sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.zdate as cjsj,i.VFDAT AS yxq,i.LGOBE AS CKMC,t.fileno AS fileno,i.zscqymc AS zscqymc
from stock_in i left join customer_list l on l.kunnr = i.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
where i.werks in(''D001'',''D010'')  and i.zodertype=1  and   zdate between trunc(add_months(sysdate,-3)) and trunc(sysdate)
      and i.matnr in(select wareid from '||p_waretable||') and i.LIFNR in ('||v_lifnrs||')
group by nvl(l.name1_snf,i.name1) ,i.matnr,i.maktx,i.zguig,i.mseh6,i.zgysph,i.zdate,i.dmbtr ,i.dmbtr*i.menge,i.VFDAT,i.LGOBE,t.fileno,i.zscqymc,i.werks
UNION ALL
SELECT o.name1 AS XSFMC,null as cgfdm,''台州瑞人堂药业有限公司'' as cgfmc,o.matnr AS CPDM,o.maktx AS CPMC,o.zguig as cpgg,o.mseh6 AS DW,o.zgysph as ph,-sum(o.menge) AS sl,o.dmbtr as dj,- o.dmbtr*o.menge  as je,o.zdate as cjsj,
o.VFDAT AS yxq,o.LGOBE AS CKMC,t.fileno AS fileno,o.zscqymc AS zscqymc
FROM stock_out o
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
 WHERE zodertype=1 AND o.werks in(''D001'',''D010'') AND o.matnr in(select wareid from '||p_waretable||')
 and o.LIFNR in ('||v_lifnrs||')
 and  zdate between trunc(add_months(sysdate,-3)) and trunc(sysdate) 
group by  o.name1,o.matnr,o.maktx,o.zguig,o.mseh6,o.zgysph,o.zdate,o.dmbtr ,-o.dmbtr*o.menge,o.VFDAT,o.LGOBE,t.fileno,o.zscqymc';

       dbms_output.put_line(v_kk);
       execute immediate  v_kk ;

       --创建kc视图

        v_kk1:='CREATE OR REPLACE  VIEW '|| v_kc ||' AS
select sysdate as kcrq,'''' as gsdm,decode(s.werks,''D001'',''台州瑞人堂药业有限公司'',''浙江瑞人堂药业有限公司'') as gsmc,s.matnr as cpdm,s.maktx as cpmc,s.zguig as cpgg,s.mseh6 as dw,s.zgysph as ph,
  s.menge as sl,0 as dj,0 as je,s.zdate as cjsj,S.vfdat AS yxq,S.lgobe AS CKMC,t.fileno AS fileno,s.zscqyms AS zscqymc
from stock s
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=s.matnr
where s.werks  IN (''D001'',''D010'') and s.LIFNR in ('||v_lifnrs||')
      AND S.MATNR in (select wareid from '||p_waretable||')' ;

       dbms_output.put_line(v_kk1);
       execute immediate  v_kk1 ;


      --创建sale视图
  
       
       v_kk2:='CREATE  OR REPLACE view '|| v_sale ||' AS
--D001 D010 out
select o.zodertype||o.zorder as billno,o.werks as xsfdm,
decode(o.werks,''D001'',''台州瑞人堂药业有限公司'',''D010'',''浙江瑞人堂药业有限公司'') as xsfmc,
case when o.zodertype in (4,5) then o.zodertype
       else  o.bupa end as cgfdm,
case WHEN o.zodertype in (4,5 ) THEN ''盘亏''

  ELSE o.name1 END AS CGFMC,
    o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,o.dmbtr*o.menge  as je,o.zdate as cjsj,
       o.VFDAT AS yxq,o.LGOBE AS CKMC,t.fileno AS fileno,o.zscqymc AS  zscqymc,o.lgobe
from stock_out o
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
where o.zodertype IN (''2'',''4'',''5'')  AND  o.werks IN (''D001'',''D010'')
and lgort not in(''P888'',''P006'')
and     o.LIFNR in ('||v_lifnrs||') and o.matnr in  (select wareid from '||p_waretable||')
       and zdate >=DATE ''2023-01-01''
--D001 D010 in       
UNION ALL
SELECT i.zodertype||i.zorder as billno,i.werks as xsfdm,
decode(i.werks,''D001'',''台州瑞人堂药业有限公司'',''D010'',''浙江瑞人堂药业有限公司'') as xsfmc,
case when i.zodertype in (4,5) then i.zodertype
       else  i.bupa end as cgfdm,
case WHEN i.zodertype in (4,5 ) THEN ''盘盈''
  ELSE i.name1 END AS CGFMC,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-i.menge AS sl,i.dmbtr as dj,- i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.vfdat AS yxq,i.LGOBE AS CKMC,t.fileno AS fileno,i.zscqymc AS zscqymc,i.lgobe
 FROM stock_in i
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.werks IN ( ''D001'',''D010'') and lgort not in(''P888'',''P006'') AND i.zodertype IN (2,4,5)
AND i.matnr IN (select wareid from '||p_waretable||')  AND i.LIFNR in (select wareid from '||p_waretable||')
 and zdate >=DATE ''2023-01-01''
--D001 P001移仓给P888、P006,出库数量不为0，单据类型改为批发出库单，再配送到瑞人堂龙泉药店（西药D）；入库数量不为0，单据类型改为批发退货单，从瑞人堂龙泉药店（西药D）退回。
UNION ALL
SELECT a.zodertype||a.zorder as billno,a.werks as xsfdm,
''瑞人堂医药集团股份有限公司'' as xsfmc,
 a.bupa  as cgfdm,
''移仓移入'' AS CGFMC,
    a.matnr as cpdm,a.maktx as cpmc,a.zguig as cpgg,a.mseh6 as dw,a.zgysph as ph,-a.menge as sl,a.dmbtr as dj,-a.dmbtr*a.menge  as je,a.zdate as cjsj,
       NULL AS yxq,a.LGOBE AS CKMC,t.fileno AS fileno,a.zscqymc AS  zscqymc,a.lgobe
from stock_in a
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
WHERE zodertype=3
AND matnr in  (select wareid from '||p_waretable||')
AND zdate>=trunc(add_months(sysdate,-3))
UNION ALL
SELECT a.zodertype||a.zorder as billno,a.werks as xsfdm,
''瑞人堂医药集团股份有限公司'' as xsfmc,
 a.bupa  as cgfdm,
''移仓移出'' AS CGFMC,
    a.matnr as cpdm,a.maktx as cpmc,a.zguig as cpgg,a.mseh6 as dw,a.zgysph as ph,a.menge as sl,a.dmbtr as dj,a.dmbtr*a.menge  as je,a.zdate as cjsj,
       NULL AS yxq,a.LGOBE AS CKMC,t.fileno AS fileno,a.zscqymc AS  zscqymc,a.lgobe
from stock_out a
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=a.matnr
WHERE zodertype=3
AND matnr in  (select wareid from '||p_waretable||')
AND zdate>=trunc(add_months(sysdate,-3))';





/*UNION ALL        
select o.zodertype||o.zorder as billno,i.werks as xsfdm,
decode(o.werks,''D001'',''台州瑞人堂药业有限公司'',''D010'',''浙江瑞人堂药业有限公司'') as xsfmc,
case when o.zodertype in (4,5) then o.zodertype
       else ''1516'' end as cgfdm,
case WHEN o.zodertype in (4,5 ) THEN ''盘亏''
  ELSE ''瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'' END AS CGFMC,
    o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,o.dmbtr*o.menge  as je,o.zdate as cjsj,
       o.VFDAT AS yxq,o.LGOBE AS CKMC,t.fileno AS fileno,o.zscqymc AS  zscqymc
FROM  stock_out o
  INNER JOIN stock_in i ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
   WHERE o.zodertype=3
and o.werks IN (''D001'',''D010'')   and o.matnr in ('||v_wareids||')
and  o.lgort =''P001'' AND i.lgort IN(''P888'',''P006'') 
and i.LIFNR in ('||v_lifnrs||')
and o.zdate >=DATE ''2023-01-01''
--D001 P888、P006的采购入库单,改为p001入库，再配送到瑞人堂龙泉药店（西药D）
UNION ALL
SELECT i.zodertype||i.zorder as billno,i.werks as xsfdm,
decode(i.werks,''D001'',''台州瑞人堂药业有限公司'',''D010'',''浙江瑞人堂药业有限公司'') as xsfmc,
case when i.zodertype in (4,5) then i.zodertype
       else  ''1516'' end as cgfdm,
case WHEN i.zodertype in (4,5 ) THEN ''盘盈''
  ELSE ''瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'' END AS CGFMC,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,i.menge AS sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.vfdat AS yxq,''正常仓'',t.fileno AS fileno,i.zscqymc AS zscqymc
 FROM stock_in i
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.werks IN ( ''D001'',''D010'') AND i.lgort in (''P888'',''P006'') AND I.zodertype=1
AND i.matnr IN ('||v_wareids||') AND i.LIFNR in ('||v_lifnrs||')
 and zdate >=DATE ''2023-01-01''
--P888 P006 采购退货
UNION ALL
SELECT i.zodertype||i.zorder as billno,i.werks as xsfdm,
decode(i.werks,''D001'',''台州瑞人堂药业有限公司'',''D010'',''浙江瑞人堂药业有限公司'') as xsfmc,
case when i.zodertype in (4,5) then i.zodertype
       else  ''1516'' end as cgfdm,
case WHEN i.zodertype in (4,5 ) THEN ''盘亏''
  ELSE ''瑞人堂医药集团股份有限公司温岭龙泉药店（西药D）'' END AS CGFMC,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-i.menge AS sl,i.dmbtr as dj,-i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.vfdat AS yxq,''正常仓'',t.fileno AS fileno,i.zscqymc AS zscqymc
 FROM stock_out i
  LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.werks IN ( ''D001'',''D010'') AND i.lgort in (''P888'',''P006'') AND I.zodertype=1
AND i.matnr IN ('||v_wareids||') AND i.LIFNR in ('||v_lifnrs||')
 and zdate >=DATE ''2023-01-01'''
 ;*/

       dbms_output.put_line(v_kk2);
       execute immediate  v_kk2 ; 

     end ;
/

