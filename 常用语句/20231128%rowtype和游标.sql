DECLARE
    -- ������ʽ�α�
    CURSOR c_busi IS SELECT * FROM s_busi;
    
    -- ��������
    v_busi c_busi%ROWTYPE;

BEGIN
    -- ���α�
    OPEN c_busi;

    -- ʹ����ʽ�α����ѭ��
    LOOP
        FETCH c_busi INTO v_busi;
        EXIT WHEN c_busi%NOTFOUND;

        -- �����ﴦ��ÿһ�е�����
        DBMS_OUTPUT.PUT_LINE(
            'busno: ' || v_busi.busno || ', orgname: ' || v_busi.orgname
        );
    END LOOP;

    -- �ر��α�
    CLOSE c_busi;

EXCEPTION
    WHEN OTHERS THEN
        -- �����쳣
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
