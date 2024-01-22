create or replace procedure proc_monthly_copy
as


v_sql    varchar2(1000);
    begin
 for res in(SELECT zlkdm
FROM t_sjzl_wh@hydee_zy
WHERE REGEXP_LIKE(ZLKDM, 'kc.*p001|p001.*kc', 'i')
     )

 loop

    v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, CJSJ, YXQ, CKMC, FILENO, ZSCQYMS) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate),GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, null, YXQ, CKMC, FILENO, ZSCQYMS ' ||
             'FROM ' || res.zlkdm;
    --DBMS_OUTPUT.PUT_LINE('v_sql'||'---'||v_sql||'---'||res.zlkdm);
     BEGIN

     EXECUTE IMMEDIATE v_sql;

     EXCEPTION
      WHEN OTHERS THEN
     v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, CJSJ, YXQ, CKMC, FILENO, ZSCQYMS) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate), NAME1, WAREID,CPMC, CPGG, DW, PH, SL,null,null,null,null,null, FILENO, SCQY ' ||
             'FROM ' || res.zlkdm;
     --DBMS_OUTPUT.PUT_LINE('´íÎóµÄv_kcview'||'---'||res.zlkdm);
     begin
     EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
     v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, CJSJ, YXQ, CKMC, FILENO, ZSCQYMS) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate),GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, null, YXQ, CKMC, FILENO, ZSCQYMC ' ||
             'FROM ' || res.zlkdm;
     begin
     EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
    v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, CJSJ, YXQ, CKMC, FILENO, ZSCQYMS) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate),GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, null, YXQ, null,null,null ' ||
             'FROM ' || res.zlkdm;
    begin
    EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
    v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, CJSJ, YXQ, CKMC, FILENO, ZSCQYMS) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate),null, CPDM, CPMC, CPGG, DW, PH, SL, null, null, null, null, null,null,null ' ||
             'FROM ' || res.zlkdm;

    begin
    EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
    v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC, CPDM, CPMC, CPGG, DW, PH, SL, DJ, JE, CJSJ, YXQ, CKMC, FILENO, ZSCQYMS) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate),null, CPDM, CPMC, CPGG, DW, PH, SL, null, null, null, null, null,null,null ' ||
             'FROM ' || res.zlkdm;

    begin
    EXECUTE IMMEDIATE v_sql;
     EXCEPTION
      WHEN OTHERS THEN
        v_sql := 'INSERT INTO d_kcView_his(viewname,copyday,GSMC) ' ||
             'SELECT''' || res.zlkdm ||''',trunc(sysdate),''wrong'' ' ||
             'FROM ' || res.zlkdm;
        --DBMS_OUTPUT.PUT_LINE('´íÎóµÄv_kcview'||'---'||res.zlkdm);

        EXECUTE IMMEDIATE v_sql;
     end;
     end;
     end;
     end;
     end;
     end;
     --select NAME1, WAREID, SCQY, SL, CPMC, CPGG, DW, FILENO, PH from V_KC_NH_P001_ZJ
 end loop;
   commit ;
end;

