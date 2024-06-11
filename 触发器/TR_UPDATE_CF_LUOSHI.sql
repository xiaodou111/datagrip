create or replace trigger TR_UPDATE_CF_LUOSHI
    before update of EXT_STR4
    on T_REMOTE_PRESCRIPTION_H
    for each row
DECLARE
--  理论要达到的效果：门店药师在回访表里面记录回访结果，数据同步到罗氏表格里面，
    --  1.患者如果在21天内购药，这部分数据只记录在回访表，不需要同步到罗氏表格；
    --  2.患者如果＞21天购药，这部分数据不仅记录在回访表，还需要同步到罗氏表格“不规范购药”里面；
    --  3.患者如果＞21天小于50天未购药，这部分数据不仅记录在回访表，还需要同步到罗氏表格“随访备注”里面；
    --  4.患者如果＞50天未购药，这部分数据不仅记录在回访表，还需要同步到罗氏表格“随访反馈”里面
    --这里只负责判断插入到哪个表中,1234在中实现
    v_ifluoshi number;
    v_program  number;
    v_hfjg     varchar2(100);
    v_sql VARCHAR2(4000);
    v_oldcreatetime date;
    v_oldIDCARDNO varchar2(20);
BEGIN
    v_oldcreatetime:=:OLD.CREATETIME;
    v_oldIDCARDNO:=:OLD.IDCARDNO;
       DBMS_OUTPUT.PUT_LINE(':old.IDCARDNO:'||v_oldIDCARDNO);
      DBMS_OUTPUT.PUT_LINE(':OLD.CREATETIME:'||v_oldcreatetime);
    if :OLD.IDCARDNO is null then
        return ;
    end if;
    select count(*)
    into v_ifluoshi
    from t_remote_prescription_d
--     :OLD.cfno
    where CFNO = :OLD.cfno and WAREID in (10502445, 10600308, 10601875);
    if v_ifluoshi = 0 then
        return ;
    end if;

    begin
    v_sql:='select RESULT
        from d_luoshi_sf_select
        where ID = '||:NEW.EXT_STR4;
    EXECUTE IMMEDIATE v_sql INTO v_hfjg;
    DBMS_OUTPUT.PUT_LINE('v_sql:'||v_sql);
    DBMS_OUTPUT.PUT_LINE('v_hfjg:'||v_hfjg);
     EXCEPTION
         when others then
            DBMS_OUTPUT.PUT_LINE('发生未知错误: ' || SQLERRM);
    end;
--     insert into tmp_disable_trigger(table_name) values ('t_remote_prescription_h');
     :NEW.EXT_STR4:=v_hfjg;
    DBMS_OUTPUT.PUT_LINE(':NEW.EXT_STR4:'||:NEW.EXT_STR4);

--     delete from tmp_disable_trigger where table_name='t_remote_prescription_h';
       v_sql:='select PROGRAMME
        from d_luoshi_prog
        where IDCARDNO ='''||v_oldIDCARDNO||''' and :createtime between BEGINDATE AND ENDDATE ';

    begin
    EXECUTE IMMEDIATE v_sql INTO v_program USING v_oldcreatetime;
    EXCEPTION
     WHEN no_data_found THEN
         RAISE_APPLICATION_ERROR(-20001, '查询不到该患者方案,请先到-患者用药方案(乳腺癌)-报表维护方案');
         when others then
            DBMS_OUTPUT.PUT_LINE('发生未知错误: ' || SQLERRM);
     end;
        DBMS_OUTPUT.PUT_LINE('v_sql:'||v_sql);
        DBMS_OUTPUT.PUT_LINE('v_program:'||v_program);
--     if v_program in (1, 2, 3) then
--         --插入到静脉表中
--         update d_luoshi_jm_hf set cfsf=v_hfjg where IDCARD = :OLD.IDCARDNO;
--     end if;
--     if v_program in (4, 5, 6) then
--         --插入到皮下表中
--         update d_luoshi_px_hf set cfsf=v_hfjg where IDCARD = :OLD.IDCARDNO;
--     end if;

END;
/

