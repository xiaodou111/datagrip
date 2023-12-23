DECLARE
    -- 声明游标变量
    v_cursor SYS_REFCURSOR;

    -- 声明存储过程参数
    v_view VARCHAR2(100) := 'v_kc_tsl_p001';

    -- 声明结果集中的变量
    v_kcrq DATE;
    v_cpdm VARCHAR2(50);
    v_cpmc VARCHAR2(100);
    v_cpgg VARCHAR2(50);
    v_ph VARCHAR2(50);
    v_sl NUMBER;

BEGIN
    -- 调用存储过程
    proc_sjzl_kc_nodtp(p_view => v_view, p_sql => v_cursor);

    -- 获取并输出结果
    LOOP
        FETCH v_cursor INTO v_kcrq , v_cpdm, v_cpmc, v_cpgg, v_ph, v_sl;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            to_char(v_kcrq,'yyyy-mm-dd hh24:mi:ss') || ' | ' || v_cpdm || ' | ' || v_cpmc || ' | ' ||
            v_cpgg || ' | ' || v_ph || ' | ' || v_sl
        );
    END LOOP;

    -- 关闭游标
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        -- 处理异常
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
