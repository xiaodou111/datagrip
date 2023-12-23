DECLARE
    -- �������������ڴ洢��������
    v_compid t_ware.compid%TYPE := '1000';
    v_busno s_busi.busno%TYPE := '81058';
    v_wareid t_ware.wareid%TYPE := '30701294';
    v_memcardno t_memcard_reg.memcardno%TYPE := '0402';
    v_saleno VARCHAR2(100) := '2023112713582350002418';
    v_user s_user.userid%TYPE := '50002418';
    v_reserve_type d_ware_coupon_rsv.reserve_type%TYPE := '34';
    v_pst_ware VARCHAR2(100) := '';
    v_out_coupon_no t_proc_rep.notes%TYPE;

BEGIN
    -- ���ô洢����
    CPROC_COUPON_INFO_RSV(
        p_compid => v_compid,
        p_busno => v_busno,
        p_wareid => v_wareid,
        p_memcardno => v_memcardno,
        p_saleno => v_saleno,
        p_user => v_user,
        p_reserve_type => v_reserve_type,
        p_pst_ware => v_pst_ware,
        out_coupon_no => v_out_coupon_no
    );

    -- ��ӡ�����Ϣ
    DBMS_OUTPUT.PUT_LINE('Output Coupon No: ' || v_out_coupon_no);

    -- ������������������߼���������֤�洢���̵�����Ƿ����Ԥ�ڵ�
END;
