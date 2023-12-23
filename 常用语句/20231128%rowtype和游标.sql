DECLARE
    -- 声明显式游标
    CURSOR c_busi IS SELECT * FROM s_busi;
    
    -- 声明变量
    v_busi c_busi%ROWTYPE;

BEGIN
    -- 打开游标
    OPEN c_busi;

    -- 使用显式游标进行循环
    LOOP
        FETCH c_busi INTO v_busi;
        EXIT WHEN c_busi%NOTFOUND;

        -- 在这里处理每一行的数据
        DBMS_OUTPUT.PUT_LINE(
            'busno: ' || v_busi.busno || ', orgname: ' || v_busi.orgname
        );
    END LOOP;

    -- 关闭游标
    CLOSE c_busi;

EXCEPTION
    WHEN OTHERS THEN
        -- 处理异常
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
