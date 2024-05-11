create or replace trigger TR_UPDATE_CF_LUOSHI
    after update of EXT_STR4
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
BEGIN
    select count(*)
    into v_ifluoshi
    from t_remote_prescription_d
--     :OLD.cfno
    where CFNO = :OLD.cfno and WAREID in (10502445, 10600308, 10601875);
    if v_ifluoshi = 0 then
        return ;
    end if;
    BEGIN
        select RESULT
        into v_hfjg
        from d_luoshi_sf_select
        where ID = :OLD.EXT_STR4;

        update t_remote_prescription_h set EXT_STR4=v_hfjg where CFNO = :OLD.cfno;
      DBMS_OUTPUT.PUT_LINE(':old.IDCARDNO:'||:old.IDCARDNO); 
      DBMS_OUTPUT.PUT_LINE(':OLD.CREATETIME:'||:old.IDCARDNO); 
       v_sql:='select PROGRAMME
        into v_program
        from d_luoshi_prog
        where IDCARDNO ='||:old.IDCARDNO||'
          and '||TO_date(:OLD.CREATETIME, 'YYYY-MM-DD HH24:MI:SS') ||'between BEGINDATE and ENDDATE';
        DBMS_OUTPUT.PUT_LINE('v_sql:'||v_sql); 
    EXCEPTION
         WHEN no_data_found THEN
            DBMS_OUTPUT.PUT_LINE(
                    '查询不到该患者方案,请先维护方案: SELECT PROGRAMME FROM d_luoshi_prog WHERE IDCARDNO=' ||
                    :OLD.IDCARDNO || ' AND DATE ''' || TO_date(:OLD.CREATETIME, 'YYYY-MM-DD HH24:MI:SS') ||
                    ''' BETWEEN BEGINDATE AND ENDDATE');
            RAISE_APPLICATION_ERROR(-20001, '查询不到该患者方案,请先维护方案');
         when others then  
            DBMS_OUTPUT.PUT_LINE('发生未知错误: ' || SQLERRM);
     

    END;
    if v_program in (1, 2, 3) then
        --插入到静脉表中
        update d_luoshi_jm_hf set cfsf=:new.EXT_STR4 where IDCARD = :OLD.IDCARDNO;
    end if;
    if v_program in (4, 5, 6) then
        --插入到皮下表中
        update d_luoshi_px_hf set cfsf=:new.EXT_STR4 where IDCARD = :OLD.IDCARDNO;
    end if;

END;
/

