 drop trigger tr_update_cf_luoshi;
select * from t_remote_prescription_h;

CREATE OR REPLACE TRIGGER tr_update_cf_luoshi
    AFTER UPDATE OF EXT_STR4
    ON t_remote_prescription_h
    FOR EACH ROW
DECLARE
--  ����Ҫ�ﵽ��Ч�����ŵ�ҩʦ�ڻطñ������¼�طý��������ͬ�������ϱ�����棬
    --  1.���������21���ڹ�ҩ���ⲿ������ֻ��¼�ڻطñ�����Ҫͬ�������ϱ��
    --  2.���������21�칺ҩ���ⲿ�����ݲ�����¼�ڻطñ�����Ҫͬ�������ϱ�񡰲��淶��ҩ�����棻
    --  3.���������21��С��50��δ��ҩ���ⲿ�����ݲ�����¼�ڻطñ�����Ҫͬ�������ϱ����ñ�ע�����棻
    --  4.���������50��δ��ҩ���ⲿ�����ݲ�����¼�ڻطñ�����Ҫͬ�������ϱ����÷���������
    --����ֻ�����жϲ��뵽�ĸ�����,1234����ʵ��
    v_ifluoshi number;
    v_program number;
BEGIN
    select count(*)
    into v_ifluoshi
    from t_remote_prescription_d
--     :OLD.cfno
    where CFNO = :OLD.cfno and WAREID in (10502445, 10600308, 10601875);
    if v_ifluoshi=0 then
        return ;
    end if;
BEGIN
    select PROGRAMME
    into v_program
    from d_luoshi_prog where IDCARDNO=:old.IDCARDNO
    and :old.CREATETIME between BEGINDATE and ENDDATE;
EXCEPTION
    WHEN no_data_found THEN
        RAISE_APPLICATION_ERROR(-20001, '��ѯ�����û��߷���,����ά������');
END;
    if v_program in (1,2,3) then
        --���뵽��������
        update d_luoshi_jm_hf set cfsf=:new.EXT_STR4 where IDCARD=:OLD.IDCARDNO;
    end if;
    if v_program in (4,5,6) then
        --���뵽Ƥ�±���
        update d_luoshi_px_hf set cfsf=:new.EXT_STR4 where IDCARD=:OLD.IDCARDNO;
    end if;

END;


-- update d_luoshi_jm_hf a
-- set BGFJL=cfsf
-- where exists(select 1 from V_LUOSHI_JMSF jm where T������ι�ҩ���� >= 21 and jm.IDCARDNO=a.IDCARD);