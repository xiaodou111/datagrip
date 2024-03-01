create procedure proc_monthly_copy_md
as


v_sql    varchar2(1000);
    begin
 for res in(SELECT REGEXP_REPLACE(zlkdm, 'sale', 'kc', 1, 0, 'i') AS zlkdm
FROM t_sjzl_wh
WHERE REGEXP_LIKE(ZLKDM, '[0-9]{4}$') AND REGEXP_LIKE(ZLKDM, 'sale', 'i')
     --and ZLKDM='v_sale_syss_81182'
     )

 loop

   v_sql :=
    'INSERT INTO D_KCVIEW_HIS_MD(viewname,KCRQ, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, INVALIDATE, FILENO) ' ||
    'SELECT  ''' || res.zlkdm ||''', trunc(sysdate)-1, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, INVALIDATE, FILENO ' ||
    'FROM ' || res.zlkdm;
     BEGIN
     EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
    v_sql :=
    'INSERT INTO D_KCVIEW_HIS_MD(viewname,KCRQ, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, INVALIDATE, FILENO) ' ||
    'SELECT  ''' || res.zlkdm ||''', trunc(sysdate)-1, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, INVALIDATE, null ' ||
    'FROM ' || res.zlkdm;
     BEGIN
     EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
    v_sql :=
    'INSERT INTO D_KCVIEW_HIS_MD(viewname,KCRQ, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, INVALIDATE, FILENO) ' ||
    'SELECT  ''' || res.zlkdm ||''', trunc(sysdate)-1, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, null, FILENO ' ||
    'FROM ' || res.zlkdm;
     BEGIN
     EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
    v_sql :=
    'INSERT INTO D_KCVIEW_HIS_MD(viewname,KCRQ, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, FACTORYNAME, INVALIDATE, FILENO) ' ||
    'SELECT  ''' || res.zlkdm ||''', trunc(sysdate)-1, GSMC, CPDM, CPMC, CPGG, PH, SL, DJ, JE, DW, CJSJ, null, null, null ' ||
    'FROM ' || res.zlkdm;
     BEGIN
     EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('view'||'---'||res.zlkdm);
--      DBMS_OUTPUT.PUT_LINE('v_sql'||'---'||v_sql||'---'||res.zlkdm);
     end;
     end;
    end;
    end;
     --select NAME1, WAREID, SCQY, SL, CPMC, CPGG, DW, FILENO, PH from V_KC_NH_P001_ZJ
 end loop;
   commit ;
end;
/

