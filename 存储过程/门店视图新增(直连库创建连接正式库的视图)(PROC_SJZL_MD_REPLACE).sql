create PROCEDURE proc_sjzl_md_replace(p_suffix VARCHAR2) AS
 v_kk   varchar2(3000);
BEGIN

  
  v_kk:='CREATE OR REPLACE VIEW V_SALE_' || p_suffix || ' AS
    SELECT saleno, xsfdm, xsfmc, cgfdm, cgfmc, cpdm, cpmc, cpgg, dw,
           ph, sl, dj, je, cjsj, 销售类型, 库位, 有效日期, syz, yxq,
           billno, factoryname,fileno
    FROM v_sale_' || p_suffix || '@hydee_zy';
  EXECUTE IMMEDIATE v_kk;
  --dbms_output.put_line(v_kk);
  v_kk:='CREATE OR REPLACE VIEW V_ACCEPT_' || p_suffix || ' AS
    SELECT xsfdm,xsfmc, cgfdm, cgfmc, cpdm, cpmc, cpgg, ph, sl, dw, dj,
           je, cjsj, billcode, distno, invalidate, factoryname,fileno
    FROM v_accept_' || p_suffix || '@hydee_zy';
  EXECUTE IMMEDIATE v_kk;
  --dbms_output.put_line(v_kk);
  v_kk:='CREATE OR REPLACE VIEW V_KC_' || p_suffix || ' AS
    SELECT kcrq, gsdm, gsmc, cpdm, cpmc, cpgg, ph, sl, dj,
           je, dw, cjsj, factoryname, invalidate,fileno
    FROM v_kc_' || p_suffix || '@hydee_zy';
  EXECUTE IMMEDIATE v_kk;
  --dbms_output.put_line(v_kk);
END;
/

