create trigger TR_T_DIST_H_DSXZ
    after insert
    on T_DIST_H
    for each row
DECLARE v_disable_trigger_ind  PLS_INTEGER;
            v_cnt PLS_INTEGER;
         --   v_compid s_busi.compid%type;

  BEGIN
    SELECT COUNT(*)
    INTO   v_disable_trigger_ind
    FROM   tmp_disable_trigger
    WHERE  upper(table_name) = upper('t_dist_h');
    IF v_disable_trigger_ind > 0 THEN
        RETURN;
    END IF;
    ----该触发器只针对调拨
    if :new.billcode not  IN ('DSSC','DSSM') then
      return ;
    end if ;
    IF  :new.objbusno LIKE '89%' and :new.objbusno not in ('89059','89063','89074','89075') THEN
      raise_application_error(-20001, '禁止往电商门店调拨,请重新确认调入门店', TRUE);
    END IF;
    SELECT COUNT(*)
    INTO v_cnt
    FROM s_busi
    WHERE busno=:new.objbusno and status<>1;
    IF  v_cnt>0 THEN
      raise_application_error(-20001, '目标门店已闭店,请重新确认调入门店', TRUE);
    END IF;
    if  :new.srcbusno=:new.objbusno then
      raise_application_error(-20001, '调入门店与调出门店不能一致', TRUE);
    END IF;
  /*  SELECT compid
    into v_compid
    FROM s_busi WHERE busno=:new.objbusno;*/
--230517新昌可以往金华杭州以外的门店调拨
    if   :new.billcode   IN ('DSSC') and :new.compid in ('1070') and :new.objcompid not in('1060','1040') then
      return;
    end if;

    if  :new.billcode   IN ('DSSC') and  ( :new.compid in (1070,1080) or  :new.objcompid in (1070,1080)   or
       (:new.compid  in (1040,1060,3340) and :new.objcompid  not in (1040,1060,3340) )
       or (:new.compid not in (1040,1060,3340) and :new.objcompid  in (1040,1060,3340) ) )  then
      raise_application_error(-20001, '该目标门店无法通过跨公司调拨调入商品', TRUE);
    end if ;

    END  ;
/

