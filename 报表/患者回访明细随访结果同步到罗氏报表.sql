create or replace trigger TR_UPDATE_CF_LUOSHI
    before update of EXT_STR4
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
    v_oldcreatetime date;
    v_oldIDCARDNO varchar2(20);
BEGIN
    v_oldcreatetime:=:OLD.CREATETIME;
    v_oldIDCARDNO:=:OLD.IDCARDNO;
       DBMS_OUTPUT.PUT_LINE(':old.IDCARDNO:'||v_oldIDCARDNO);
      DBMS_OUTPUT.PUT_LINE(':OLD.CREATETIME:'||v_oldcreatetime);
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
            DBMS_OUTPUT.PUT_LINE('����δ֪����: ' || SQLERRM);
    end;
--     insert into tmp_disable_trigger(table_name) values ('t_remote_prescription_h');
     :NEW.EXT_STR4:=v_hfjg;
    DBMS_OUTPUT.PUT_LINE(':NEW.EXT_STR4:'||:NEW.EXT_STR4);

--     delete from tmp_disable_trigger where table_name='t_remote_prescription_h';
       v_sql:='select PROGRAMME
        from d_luoshi_prog
        where IDCARDNO ='''||v_oldIDCARDNO||'''';

    EXECUTE IMMEDIATE v_sql INTO v_program;
        DBMS_OUTPUT.PUT_LINE('v_sql:'||v_sql);
        DBMS_OUTPUT.PUT_LINE('v_program:'||v_program);

    v_program:=1;
    if v_program in (1, 2, 3) then
        --���뵽��������
        update d_luoshi_jm_hf set cfsf=v_hfjg where IDCARD = :OLD.IDCARDNO;
    end if;
    if v_program in (4, 5, 6) then
        --���뵽Ƥ�±���
        update d_luoshi_px_hf set cfsf=v_hfjg where IDCARD = :OLD.IDCARDNO;
    end if;

END;
/

