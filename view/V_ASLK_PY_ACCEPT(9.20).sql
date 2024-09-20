create view V_ASLK_PY_ACCEPT as
SELECT "CORT_NUM_ID", "CORT_NAME", "ORDER_DATE", "SUPPLY_UNIT_NUM_ID", "SUPPLY_NAME", "ITEM_NUM_ID", "ITEM_NAME", "QTY",
       "STYLE_DESC", "UNITS_NAME", "FACTORY", "APPROVAL_NO", "BATCH_ID", "ACTUAL_PRODUCTION_DATE", "EXPIRY_DATE",
       "TAX_RATE", "SUP_PRICE", "SUP_PRICE_NO_TAX", "TOTAL_AMOUNT", "TOTAL_AMOUNT_NO_TAX", "TYPE_NUM_ID", "IN_STORAGE",
       "BILL_TYPE"
FROM (select *
      from v_accept_xdl_rt03
      where item_num_id in
            ('1009700', '1115743', '1017938', '1022664', '1009748', '1085998', '1007517', '1129778', '1007704',
             '1007703', '1065307', '1010310', '1096660', '1019229', '1109803', '1007759', '1007760', '1108423',
             '1118990', '1118991', '1015028', '1009726', '1112487', '1001852', '1007837', '1115892', '1115893',
             '1149935', '1007838', '1135283', '1002693', '1097486', '1175460', '1175459', '1166338', '1166337',
             '1007519', '1007520', '1015339', '1115182', '1144810', '1007497', '1000994', '1009757', '1125040',
             '1144719', '1015943', '1119931', '1180960', '1129780')
        and CORT_NUM_ID in ('RT03', 'RH03', 'RT01')
          /* and SUPPLY_UNIT_NUM_ID in ('8002221',
                                      '8003297',
                                      '8003944',
                                      '8002225',
                                      '8004445',
                                      '8002260',
                                      '8004072',
                                      'RT03')*/
        and ORDER_DATE >= date
          '2024-08-01'
        and (ORDER_DATE >
             (select max(ORDER_DATE)
              from d_accept_def
              where REGEXP_LIKE(VIEW_NAME, 'v_aslk_py', 'i')) or 0 = 0)
        and ORDER_DATE < trunc(sysdate)
      union all
      select PAY_CORT, CUSTOMER_NAME, REC_DATE, CORT_NUM_ID, CORT_NAME, TO_CHAR(ITEM_NUM_ID), ITEM_NAME,
             QTY, STYLE_DESC, UNITS_NAME, FACTORY, APPROVAL_NO, BATCH_ID,
             null, null, 13,
             TRADE_PRICE, TRADE_PRICE, TOTAL_AMOUNT,
             TOTAL_AMOUNT,
             1, '40101', case when QTY > 0 then '采购入库单' else '采购退货单' end
      from v_pf_rt03
      WHERE item_num_id in
            ('1009700', '1115743', '1017938', '1022664', '1009748', '1085998', '1007517', '1129778', '1007704',
             '1007703', '1065307', '1010310', '1096660', '1019229', '1109803', '1007759', '1007760', '1108423',
             '1118990', '1118991', '1015028', '1009726', '1112487', '1001852', '1007837', '1115892', '1115893',
             '1149935', '1007838', '1135283', '1002693', '1097486', '1175460', '1175459', '1166338', '1166337',
             '1007519', '1007520', '1015339', '1115182', '1144810', '1007497', '1000994', '1009757', '1125040',
             '1144719', '1015943', '1119931', '1180960', '1129780')
        and CORT_NUM_ID IN ('RT03', 'RH03') AND PAY_CORT IN ('RT03', 'RH03')

      union all
      SELECT a.cort_num_id, a.cort_name, a.order_date, a.supply_unit_num_id, a.supply_name, a.item_num_id, a.item_name,
             a.qty, a.style_desc, a.units_name, a.factory, a.approval_no, a.batch_id, a.actual_production_date,
             a.expiry_date, a.tax_rate, a.sup_price, a.sup_price_no_tax, a.total_amount, a.total_amount_no_tax,
             a.type_num_id, a.in_storage, bill_type
      FROM d_accept_def a
      where REGEXP_LIKE(VIEW_NAME, 'v_aslk_py', 'i')
      union all
      select CORT_NUM_ID 公司编码, CORT_NAME 公司名称, ORDER_DATE 入库日期, SUPPLY_UNIT_NUM_ID 供应商,
             SUPPLY_NAME 供应商名称, ITEM_NUM_ID 商品编码, ITEM_NAME 商品名称, QTY 数量, STYLE_DESC 规格,
             UNITS_NAME 单位, FACTORY 生产厂家, APPROVAL_NO 批准文号, BATCH_ID 批号, ACTUAL_PRODUCTION_DATE 生产日期,
             EXPIRY_DATE 有效期, TAX_RATE 税率进项, SUP_PRICE 采购订单单价含税, SUP_PRICE_NO_TAX 采购订单单价不含税,
             TOTAL_AMOUNT 总金额含税, TOTAL_AMOUNT_NO_TAX 总金额不含税, TYPE_NUM_ID as 业务类型, IN_STORAGE, bill_type
      from d_sjzl_accept_dr
      where REGEXP_LIKE(VIEW_NAME, 'v_aslk_py', 'i'))
/

