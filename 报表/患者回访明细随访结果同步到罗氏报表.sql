create or replace trigger TR_UPDATE_CF_LUOSHI
    after update of EXT_STR4
    on T_REMOTE_PRESCRIPTION_H
    for each row
DECLARE
--  ����Ҫ�ﵽ��Ч�����ŵ�ҩʦ�ڻطñ������¼�طý��������ͬ�������ϱ�����棬
    --  1.���������21���ڹ�ҩ���ⲿ������ֻ��¼�ڻطñ�����Ҫͬ�������ϱ��
    --  2.���������21�칺ҩ���ⲿ�����ݲ�����¼�ڻطñ�����Ҫͬ�������ϱ�񡰲��淶��ҩ�����棻
    --  3.���������21��С��50��δ��ҩ���ⲿ�����ݲ�����¼�ڻطñ�����Ҫͬ�������ϱ����ñ�ע�����棻
    --  4.���������50��δ��ҩ���ⲿ�����ݲ�����¼�ڻطñ�����Ҫͬ�������ϱ����÷���������
    --����ֻ�����жϲ��뵽�ĸ�����,1234����ʵ��
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
                    '��ѯ�����û��߷���,����ά������: SELECT PROGRAMME FROM d_luoshi_prog WHERE IDCARDNO=' ||
                    :OLD.IDCARDNO || ' AND DATE ''' || TO_date(:OLD.CREATETIME, 'YYYY-MM-DD HH24:MI:SS') ||
                    ''' BETWEEN BEGINDATE AND ENDDATE');
            RAISE_APPLICATION_ERROR(-20001, '��ѯ�����û��߷���,����ά������');
         when others then  
            DBMS_OUTPUT.PUT_LINE('����δ֪����: ' || SQLERRM);
     

    END;
    if v_program in (1, 2, 3) then
        --���뵽��������
        update d_luoshi_jm_hf set cfsf=:new.EXT_STR4 where IDCARD = :OLD.IDCARDNO;
    end if;
    if v_program in (4, 5, 6) then
        --���뵽Ƥ�±���
        update d_luoshi_px_hf set cfsf=:new.EXT_STR4 where IDCARD = :OLD.IDCARDNO;
    end if;

END;
/

