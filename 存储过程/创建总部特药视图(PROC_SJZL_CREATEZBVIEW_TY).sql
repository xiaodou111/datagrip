create procedure proc_sjzl_createzbview_ty (p_name in varchar2,
                                              p_waretable in VARCHAR2--,
                                              --p_lifnr IN VARCHAR2


                                          --    p_jm in in varchar2(100),
                                           --   ds in in varchar2(100),
                                             )
    is
        v_accept VARCHAR2(50);
        v_kc VARCHAR2(50);
        v_sale VARCHAR2(50);
        v_wareids varchar2(300);
        v_lifnrs varchar2(300);
        v_kk   varchar2(3000);
        v_kk1   varchar2(3000);
        v_kk2   varchar2(6000);

     begin
       v_accept := 'V_ACCEPT_' || p_name || '_P001_TY';
       v_kc := 'V_KC_' || p_name || '_P001_TY';
       v_sale := 'V_SALE_' || p_name || '_P001_TY';


       /*SELECT f_get_sjzl_rename(p_wareids)
      into v_wareids
       FROM dual ;*/
      /* SELECT f_get_sjzl_rename(p_lifnr)
      into v_lifnrs
       FROM dual ;*/


  --创建accept视图

   /*   v_kk:='CREATE  VIEW '|| v_accept ||' AS
SELECT nvl(l.name1_snf,i.name1) as XSFMC,null as cgfdm,decode(i.werks,''D001'',''台州瑞人堂药业有限公司'',''浙江瑞人堂药业有限公司'')  as cgfmc,i.matnr as cpdm,i.maktx as cpmc,i.zguig as cpgg,
       i.mseh6 as dw,i.zgysph as ph,sum(i.menge) as sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.zdate as cjsj,i.VFDAT AS yxq,i.LGOBE AS CKMC,t.fileno AS fileno,i.zscqymc AS zscqymc
from stock_in i left join customer_list l on l.kunnr = i.bupa
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
where i.werks in(''D001'',''D010'')  and i.zodertype=1  and   zdate between trunc(add_months(sysdate,-3)) and trunc(sysdate)
      and i.matnr in('||v_wareids||') and i.LIFNR in ('||v_lifnrs||')
group by nvl(l.name1_snf,i.name1) ,i.matnr,i.maktx,i.zguig,i.mseh6,i.zgysph,i.zdate,i.dmbtr ,i.dmbtr*i.menge,i.VFDAT,i.LGOBE,t.fileno,i.zscqymc,i.werks
UNION ALL
SELECT o.name1 AS XSFMC,null as cgfdm,''台州瑞人堂药业有限公司'' as cgfmc,o.matnr AS CPDM,o.maktx AS CPMC,o.zguig as cpgg,o.mseh6 AS DW,o.zgysph as ph,-sum(o.menge) AS sl,o.dmbtr as dj,- o.dmbtr*o.menge  as je,o.zdate as cjsj,
o.VFDAT AS yxq,o.LGOBE AS CKMC,t.fileno AS fileno,o.zscqymc AS zscqymc
FROM stock_out o
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
 WHERE zodertype=1 AND o.werks in(''D001'',''D010'') AND o.matnr in('||v_wareids||')
 and o.LIFNR in ('||v_lifnrs||')
 and  zdate between trunc(add_months(sysdate,-3)) and trunc(sysdate)
group by  o.name1,o.matnr,o.maktx,o.zguig,o.mseh6,o.zgysph,o.zdate,o.dmbtr ,-o.dmbtr*o.menge,o.VFDAT,o.LGOBE,t.fileno,o.zscqymc';*/
 
 
 v_kk:='CREATE  VIEW '|| v_accept ||' AS
select i.name1 as xsfmc ,'''' as cgfdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as cgfmc,
i.matnr as cpdm,i.maktx as cpmc,i.zguig as cpgg,
        i.mseh6 as dw,i.zgysph as ph,i.menge as sl,i.dmbtr as dj, i.dmbtr*i.menge  as je,i.zdate as cjsj,i.VFDAT AS yxq,i.LGOBE AS CKMC,t.fileno AS fileno,i.zscqymc,i.lgobe,i.ZNAME1
from stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
where i.werks in (''D001'',''D002'',''D010'')  and i.zodertype =1 and i.matnr in(select wareid from '||p_waretable||')
and zdate between  date''2023-01-01'' and  trunc(sysdate)
UNION ALL
SELECT o.name1 AS XSFMC,'''' as cgfdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'') as cgfmc,
o.matnr AS CPDM,o.maktx AS CPMC,o.zguig as cpgg,o.mseh6 AS DW,o.zgysph as ph,-o.menge AS sl,o.dmbtr as dj,- o.dmbtr*o.menge  as je,o.zdate as cjsj,o.VFDAT
 AS yxq,o.LGOBE AS CKMC,t.fileno AS fileno,o.zscqymc,o.lgobe,o.ZNAME1
FROM stock_out o
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE zodertype=1 AND o.werks  in (''D001'',''D002'',''D010'') AND o.matnr in(select wareid from '||p_waretable||')
 and zdate between  date''2023-01-01''and  trunc(sysdate)';

       dbms_output.put_line(v_kk);
       execute immediate  v_kk ;
       
       
   v_kk1:='CREATE  VIEW '|| v_kc ||' AS 
  select sysdate as kcrq,'''' as gsdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'')  as gsmc,
s.matnr as cpdm,s.maktx as cpmc,s.zguig as cpgg,s.mseh6 as dw,s.zgysph as ph,
 sum(s.menge) as sl,0 as dj,0 as je,s.zdate as cjsj,S.vfdat AS yxq,S.lgobe AS CKMC ,t.fileno AS fileno,s.zscqyms as zscqymc
from stock s
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=s.matnr
where s.werks in (''D001'',''D002'',''D010'') and lgort not in (''P888'',''P006'')  
AND S.MATNR IN(select wareid from '||p_waretable||')
group by s.matnr,s.maktx,s.zguig,s.mseh6,s.zgysph,s.zdate,S.vfdat,S.lgobe ,t.fileno,s.zscqyms,werks';

       dbms_output.put_line(v_kk1);
       execute immediate  v_kk1 ;
       
 v_kk2:='CREATE  VIEW '|| v_sale ||' AS      
select o.zodertype||o.zorder as billno,'''' as xsfdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as xsfmc,
case when o.zodertype in (''4'',''5'') then o.zodertype
       else  o.bupa end as cgfdm,
case WHEN o.zodertype in (''4'',''5'') THEN ''盘亏''
else o.name1  end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o left join customer_list l on l.kunnr = o.bupa
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN (''2'',''4'',''5'') and werks in (''D001'',''D002'',''D010'') and lgort not in (''P888'',''P006'')
and o.matnr in  (select wareid from '||p_waretable||')
and   zdate>=date''2023-01-01''

UNION ALL
SELECT i.zodertype||i.zorder as billno,'''' as xsfdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as xsfmc,
case when i.zodertype in (''4'',''5'') then i.zodertype
       else  i.bupa end as cgfdm,
case WHEN i.zodertype in (''4'',''5'') THEN ''盘盈''
       else  i.name1 end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-i.menge AS sl,i.dmbtr as dj,- i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN (''2'',''4'',''5'') AND  i.werks in (''D001'',''D002'',''D010'') and lgort not in (''P888'',''P006'')
AND i.matnr IN (select wareid from '||p_waretable||')
and   zdate>=date''2023-01-01''
--P888,P006采购退货即入库
union all
select o.zodertype||o.zorder as billno,'''' as xsfdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as xsfmc,
case when o.zodertype in (''4'',''5'') then o.zodertype
       else  ''1072'' end as cgfdm,
case WHEN o.zodertype in (''4'',''5'') THEN ''盘亏''
else ''瑞人堂医药集团股份有限公司温岭龙泉药店''  end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,-o.menge as sl,o.dmbtr as dj,
      -o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,''正常仓'' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,''P001''
from stock_out o left join customer_list l on l.kunnr = o.bupa
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN (''1'') and werks in (''D001'',''D002'',''D010'') and lgort in (''P888'',''P006'')
and o.matnr in  (select wareid from '||p_waretable||')
and   zdate>=date''2023-01-01''
--P888,P006采购入库即出库
union all
SELECT i.zodertype||i.zorder as billno,'''' as xsfdm,
DECODE(werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as xsfmc,
case when i.zodertype in (''4'',''5'') then i.zodertype
       else  ''1072'' end as cgfdm,
case WHEN i.zodertype in (''4'',''5'') THEN ''盘盈''
       else  ''瑞人堂医药集团股份有限公司温岭龙泉药店'' end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,i.menge AS sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,''P001''
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN (''1'') AND  i.werks in (''D001'',''D002'',''D010'')  and lgort in (''P888'',''P006'')
AND i.matnr IN (select wareid from '||p_waretable||')
and   zdate>=date''2023-01-01''
--P888,P006移到P001,显示负数
union all
select o.zodertype||o.zorder as billno,'''' as xsfdm,
DECODE(o.werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as xsfmc,
 ''1072''  as cgfdm,
 ''瑞人堂医药集团股份有限公司温岭龙泉药店''  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,-o.menge as sl,o.dmbtr as dj,
      -o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,''正常仓'' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,''P001''
from stock_out o left join customer_list l on l.kunnr = o.bupa
join stock_in i  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in(''P888'',''P006'') AND i.lgort=''P001'' and o.zodertype IN (''3'') and o.werks in (''D001'',''D002'',''D010'')
and o.matnr in  (select wareid from '||p_waretable||')
and   o.zdate>=date''2023-01-01''
union all
--P001移到P888,P006,显示正数出库
select o.zodertype||o.zorder as billno,'''' as xsfdm,
DECODE(o.werks,''D001'',''台州瑞人堂药业有限公司'',''D002'',''瑞人堂医药集团股份有限公司'',''D010'',''浙江瑞人堂医药连锁有限公司'',''D008'',''杭州瑞人堂医药连锁有限公司'') as xsfmc,
 ''1072''  as cgfdm,
 ''瑞人堂医药集团股份有限公司温岭龙泉药店''  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,''正常仓'' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,''P001''
from stock_out i left join customer_list l on l.kunnr = i.bupa
join stock_in o  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in(''P888'',''P006'') AND i.lgort=''P001'' and o.zodertype IN (''3'') and o.werks in (''D001'',''D002'',''D010'')
and o.matnr in  (select wareid from '||p_waretable||')
and   o.zdate>=date''2023-01-01''';
   dbms_output.put_line(v_kk2);
       execute immediate  v_kk2 ;
   
    end ;
/

