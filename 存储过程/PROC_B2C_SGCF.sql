create procedure  proc_b2c_sgcf
is
    v_disable_trigger_ind PLS_INTEGER;
    v_cnt PLS_INTEGER;
    v_cnt1 PLS_INTEGER;
    v_classcode v_ware_classinfo.classcode%TYPE;
    v_compid s_busi.compid%TYPE;
    v_busno pls_integer;
BEGIN

for res in ( SELECT * FROM t_b2c_sale_h a WHERE  accdate =trunc(sysdate-1) and  PAYTIME is not null and not exists(select 1 from d_oms_sgcf_h b  where a.erpno=b.cfno   )    ) loop
    begin
    SELECT a.BUSNO,b.compid
    into  v_compid,v_busno
    FROM  t_b2c_sale_h   a
    left join s_busi b on a.busno=b.busno
    WHERE   a.ERPNO=res.erpno  and  PAYTIME is not null;

    SELECT COUNT(*)
    into v_cnt
     FROM t_b2c_sale_d
    WHERE  erpno=res.erpno  and   f_get_classcode('05',wareid,1000) ='05101'  ;

    if v_cnt = 0 then
      continue ;
    end if ;


    SELECT COUNT(*)
    INTO v_cnt1
    FROM  d_oms_sgcf_h WHERE cfno=res.ERPNO;


    IF v_cnt1<>0 THEN
      INSERT INTO d_oms_sgcf_d( cfno,wareid,stdprice,netprice,wareqty,makeno,batchno,rowno,times )
      SELECT res.ERPNO,wareid,stdprice,netprice,wareqty,makeno,batid,rowno,null FROM t_b2c_sale_d
      WHERE erpno=res.ERPNO  and   f_get_classcode('05',wareid,1000) ='05101'  ;
    ELSE
      INSERT INTO d_oms_sgcf_h(cfno,compid,busno,createtime,oms_flag,notes)
      SELECT res.ERPNO,v_compid,v_busno,SYSDATE,1,'B2C生成处方' FROM dual;
      INSERT INTO d_oms_sgcf_d(cfno,wareid,stdprice,netprice,wareqty,makeno,batchno,rowno,times)
      SELECT res.ERPNO,wareid,stdprice,netprice,wareqty,makeno,batid,rowno,null FROM t_b2c_sale_d
      WHERE erpno=res.ERPNO  and   f_get_classcode('05',wareid,1000) ='05101'  ;
      END IF  ;
      exception when others then
        raise_application_error(-20001,res.erpno||'youwenyi',true);
        end ;
END loop;

end ;
/

