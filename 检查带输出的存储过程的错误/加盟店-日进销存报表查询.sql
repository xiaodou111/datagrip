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
    proc_day_inout_hmk(p_busno => 8240023, p_begindate => date'2023-11-01', p_enddate => date'2023-12-01', p_wareid => null, p_outcur => v_cursor);

    -- 获取并输出结果
    /*LOOP
        FETCH v_cursor INTO v_kcrq , v_cpdm, v_cpmc, v_cpgg, v_ph, v_sl;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            to_char(v_kcrq,'yyyy-mm-dd hh24:mi:ss') || ' | ' || v_cpdm || ' | ' || v_cpmc || ' | ' ||
            v_cpgg || ' | ' || v_ph || ' | ' || v_sl
        );
    END LOOP;*/

    -- 关闭游标
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        -- 处理异常
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


select a.busno as 业务机构,'平阳县郑楼镇大众药店' as 机构名称,b.warecode as 商品编码,max(b.warename) as 商品名称,
          max(b.warespec) as 规格,max(d.factoryname) as 生产企业,max(b.wareunit) as 单位,
          sum(beginqty) as 期初数量,sum(round(beginqty*a.purprice,2)) as 期初金额,
          sum(accqty) as 入库数量,sum(round(accqty*a.purprice,2)) as 入库金额,
          sum(rejqty) as 退货数量,sum(round(rejqty*a.purprice,2)) as 退货金额,
          sum(disqty) as 配送数量,sum(round(disqty*a.purprice,2)) as 配送金额,
          sum(dirqty) as 退仓数量,sum(round(dirqty*a.purprice,2)) as 退仓金额,
          sum(saleqty) as 零售数量,sum(round(saleqty*a.purprice,2)) as 零售金额,
          sum(macinqty) as 加工入库数量,sum(round(macinqty*a.purprice,2)) as 加工入库金额,
          sum(macoutqty) as 加工出库数量,sum(round(macoutqty*a.purprice,2)) as 加工出库金额,
          sum(cheqty) as 盘点数量,sum(round(cheqty*a.purprice,2)) as 盘点金额,
          sum(whlqty) as 批发销售数量,sum(round(whlqty*a.purprice,2)) as 批发销售金额,
          sum(whrqty) as 批发退货数量,sum(round(whrqty*a.purprice,2)) as 批发退货金额,
          sum(addqty) as 加价调拨数量,sum(round(addqty*a.purprice,2)) as 加价调拨金额,
          sum(adrqty) as 加价调拨退回数量,sum(round(adrqty*a.purprice,2)) as 加价调拨退回金额,
          sum(round(adpoutqty*a.purprice,2)) as 调进价出金额,
          sum(round(adpinqty*a.purprice,2)) as 调进价入金额,
          sum(abninqty) as 损溢数量,sum(round(abninqty*a.purprice,2)) as 损溢金额,
          sum(failureqty) as 销毁数量,sum(round(failureqty*a.purprice,2)) as 销毁金额,
          sum(endqty) as 期末数量,sum(round(endqty*a.purprice,2)) as 期末金额
          from temp_item_day_inout a
          join t_ware b on a.wareid = b.wareid and b.compid = 9999
          left join t_factory d on b.factoryid = d.factoryid
          group by a.busno,b.warecode
