CREATE PROCEDURE proc_get_split_ware()
BEGIN
    DECLARE output_values VARCHAR(4000) DEFAULT '';
    DECLARE current_value VARCHAR(2000);
    DECLARE original_upc_code VARCHAR(200);
    DECLARE delimiter_position INT;
    DECLARE v_wareids VARCHAR(2000);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_begindate VARCHAR(200);
    DECLARE v_enddate VARCHAR(200);
    DECLARE v_store_id VARCHAR(200);
    DECLARE v_package_name VARCHAR(200);
    DECLARE v_sku_code VARCHAR(200);
    DECLARE v_upc_code VARCHAR(200);
    DECLARE v_package_item_name VARCHAR(200);
    DECLARE v_order_qty decimal(20, 4);
    DECLARE v_order_amount decimal(20, 4);
    DECLARE v_order_people int;
#     DECLARE v_status int;

    -- 声明游标
    DECLARE CURSOR_1 CURSOR FOR
        SELECT begindate,enddate,store_id,package_name,sku_code,upc_code,package_item_name,order_qty,order_amount,order_people
        FROM qy_o2o_package_orderinfo
        WHERE status = 0
        and  upc_code in ('6921874367249;6943116400262',
'6901339913419;6926720800826',
'6901339913419;6923848600727',
'6923528176009;6934247900011','6925558400390') ;


    -- 声明继续处理的处理器
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
              delete from qy_o2o_package_orderinfo_temp;
    -- 打开游标
    OPEN CURSOR_1;

    read_loop: LOOP
        FETCH CURSOR_1 INTO v_begindate,v_enddate,v_store_id,v_package_name,v_sku_code,v_upc_code,
            v_package_item_name,v_order_qty,v_order_amount,v_order_people;

        -- 检查是否到达了结果集的末尾
        IF done THEN
            LEAVE read_loop;
        END IF;
         -- 在每次处理新的 v_upc_code 时重置 output_values
        SET output_values = NULL;
        set original_upc_code= v_upc_code;
            WHILE v_upc_code IS NOT NULL AND v_upc_code != '' DO
        ##查找当前v_upc_code是否是复合组包
        SET delimiter_position = LOCATE(';', v_upc_code);
        IF delimiter_position = 0 THEN
            SET current_value = v_upc_code;
            SET v_upc_code = NULL;
        select wareid
        into v_wareids
        from qy_o2o_package_product_sign where barcode=current_value;
         -- 如果 v_wareids 不为空，则拼接到 output_values
                IF output_values IS NULL THEN
                    SET output_values = v_wareids;
                ELSE
                    SET output_values = CONCAT(output_values, '_', v_wareids);
                END IF;
        ELSE
            SET current_value = SUBSTRING(v_upc_code, 1, delimiter_position - 1);
            select wareid
            into v_wareids
            from qy_o2o_package_product_sign where barcode=current_value;
            SET v_upc_code = SUBSTRING(v_upc_code, delimiter_position + 1);
                 IF output_values IS NULL THEN
                    SET output_values = v_wareids;
                ELSE
                    SET output_values = CONCAT(output_values, '_', v_wareids);
                END IF;
        END IF;

             END WHILE;

        -- 插入数据到临时表
        INSERT INTO qy_o2o_package_orderinfo_temp
            (begindate,enddate,store_id,package_name,sku_code,upc_code,package_item_name,order_qty,order_amount,order_people,status,qywareid)
        VALUES (v_begindate,v_enddate,v_store_id,v_package_name,v_sku_code,original_upc_code,
            v_package_item_name,v_order_qty,v_order_amount,v_order_people,1,output_values);
        update qy_o2o_package_orderinfo set status=1
            where begindate=v_begindate and enddate=v_enddate and store_id=v_store_id  and sku_code=v_sku_code;

    END LOOP;

    -- 关闭游标
    CLOSE CURSOR_1;

END ;