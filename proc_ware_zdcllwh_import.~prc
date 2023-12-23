CREATE OR REPLACE PROCEDURE proc_ware_zdcllwh_import IS

    v_conde PLS_INTEGER;
    --v_wareid t_ware.wareid%TYPE;

BEGIN
    /*
    创建时间：20210109
    创建人：徐田成-2571
    业务场景：用于Excel批量导入商品最低陈列量维护表*/

    BEGIN
        SELECT COUNT(*) INTO v_conde FROM  t_zdcllwh_import temp;
        IF v_conde = 0 THEN
            raise_application_error(-20001, '提示，导入数据获取失败！请重新导入！', TRUE);
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20001, '提示，导入数据获取失败！请重新导入！', TRUE);
    END;

    /*    FOR rec_i IN (SELECT compid, warecode, is_ybmd, a_cl, b_cl, c_cl, d_cl, e_cl
                  FROM   d_ware_lowest_import temp) LOOP
    
        BEGIN
            SELECT a.wareid
            INTO   v_wareid
            FROM   t_ware a
            WHERE  a.compid = rec_i.compid AND a.warecode = rec_i.warecode;
        EXCEPTION
            WHEN no_data_found THEN
                --如果门店不存在当前平台，先清理数据再返回报错
                DELETE d_ware_lowest_import temp;
                COMMIT;
                raise_application_error(-20001,
                                        '提示，商品编码' || rec_i.warecode || '不存在于企业' || rec_i.compid || '！', TRUE);
        END;
    
        INSERT INTO d_ware_lowest
            (compid, wareid, is_ybmd, a_cl, b_cl, c_cl, d_cl, e_cl)
            SELECT rec_i.compid, v_wareid, rec_i.is_ybmd, rec_i.a_cl, rec_i.b_cl, rec_i.c_cl, rec_i.d_cl,
                   rec_i.e_cl
            FROM   dual;
    
    END LOOP;*/
    --满足条件则更新，不满足条件则新增。
    MERGE INTO  t_zdcllwh a
    USING (SELECT temp.compid, w.wareid, temp.is_ybmd, temp.a_cl, temp.b_cl, temp.c_cl, temp.d_cl, temp.e_cl,temp.f_cl
           FROM   d_ware_lowest_import temp
           INNER  JOIN t_ware w
           ON     temp.compid = w.compid AND temp.warecode = w.warecode) b
    ON (a.compid = b.compid AND a.wareid = b.wareid AND a.is_ybmd = b.is_ybmd)
    WHEN MATCHED THEN
        UPDATE SET a.a_cl = b.a_cl, a.b_cl = b.b_cl, a.c_cl = b.c_cl, a.d_cl = b.d_cl, a.e_cl = b.e_cl,a.f_cl = b.f_cl
    WHEN NOT MATCHED THEN
        INSERT
            (compid, wareid, is_ybmd, a_cl, b_cl, c_cl, d_cl, e_cl,f_cl)
        VALUES
            (b.compid, b.wareid, b.is_ybmd, b.a_cl, b.b_cl, b.c_cl, b.d_cl, b.e_cl,b.f_cl);

    COMMIT;
END proc_ware_zdcllwh_import;
/
