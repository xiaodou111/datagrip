create view V_ASLK_PY_SALE as
select "CORT_NUM_ID", "CORT_NAME", "RESERVED_NO", "DIST_NUM_ID", "DIST_NAME", "IN_STORAGE", "ORGNAME", "REC_DATE",
       "ITEM_NUM_ID", "ITEM_NAME", "STYLE_DESC", "FACTORY", "APPROVAL_NO", "BATCH_ID", "EXPIRY_DATE", "QTY", "TAX_RATE",
       "TRADE_PRICE", "TOTAL_AMOUNT", "TOTAL_AMOUNT_NO_TAX", "UNITS_NAME", "SUPPLY_UNIT_NUM_ID", "SUPPLY_NAME",
       "BILL_TYPE"
from (SELECT *
      FROM v_sale_xdl_rt03
      WHERE orgname not like '%诊%' and IN_STORAGE not like '2%' and in_storage not like '9%'
        and DIST_NUM_ID in ('RT03', 'RH03', 'RT01')
      union all
      SELECT *
      FROM v_sale_xdl_rt03
      where orgname like '%诊%' and (REC_DATE > (select max(REC_DATE) from d_sale_def where view_name = 'v_aslk_py') or
                                     0 = 0) and DIST_NUM_ID in ('RT03', 'RH03', 'RT01')
      union all
      SELECT *
      FROM v_sale_xdl_rt03
      where IN_STORAGE like '2%' and (REC_DATE > (select max(REC_DATE) from d_sale_def where view_name = 'v_aslk_py') or
                                      0 = 0) and DIST_NUM_ID in ('RT03', 'RH03', 'RT01')
union all

   select  CORT_NUM_ID,CORT_NAME,to_char(RESERVED_NO),PAY_CORT,CUSTOMER_NAME,'1050',CUSTOMER_NAME,REC_DATE,TO_CHAR(ITEM_NUM_ID),ITEM_NAME,STYLE_DESC,FACTORY,APPROVAL_NO,BATCH_ID,
   EXPIRY_DATE,   case when PAY_CORT='RH03' then  QTY else -QTY end,13,TRADE_PRICE,case when PAY_CORT='RH03' then TOTAL_AMOUNT else -TOTAL_AMOUNT end,
   case when PAY_CORT='RH03' then TOTAL_AMOUNT else -TOTAL_AMOUNT end, UNITS_NAME,CORT_NUM_ID,CORT_NAME,case when PAY_CORT='RH03' then '批发出库单' else '批发退库单' end
       from v_pf_rt03
       WHERE  CORT_NUM_ID IN ('RT03','RH03' )  AND PAY_CORT IN ('RT03','RH03' )
      union all
      SELECT 'RT03', '台州瑞人堂药业有限公司', SUPPLY_UNIT_NUM_ID || ITEM_NUM_ID, CORT_NUM_ID, CORT_NAME, '1043',
             (select orgname from s_busi@h2 where 80000 + 1043 = busno), ORDER_DATE, ITEM_NUM_ID, ITEM_NAME, STYLE_DESC,
             FACTORY, APPROVAL_NO, BATCH_ID, EXPIRY_DATE, QTY, TAX_RATE, SUP_PRICE, total_amount, TOTAL_AMOUNT_NO_TAX,
             UNITS_NAME, SUPPLY_UNIT_NUM_ID, SUPPLY_NAME,
             case when qty > 0 then '批发出库单' else '批发退货单' end as BILL_TYPE
      FROM v_accept_xdl_rt03 a
      WHERE IN_STORAGE <> '40101' and (
          ORDER_DATE > (select max(REC_DATE) from d_sale_def where view_name = 'v_aslk_py') or 0 = 0)
        and CORT_NUM_ID in ('RT03', 'RH03', 'RT01')
      union all
      SELECT 'RT03', '台州瑞人堂药业有限公司', a.reserved_no, a.dist_num_id, a.dist_name, '1043',
             (select orgname from s_busi@h2 where 80000 + 1043 = busno), trunc(a.rec_date), a.item_num_id, a.item_name,
             a.style_desc, a.factory, a.approval_no, a.batch_id, a.expiry_date, a.qty, a.tax_rate, a.trade_price,
             a.total_amount, a.total_amount_no_tax, a.units_name, a.supply_unit_num_id, a.supply_name, bill_type
      FROM v_sale_xdl_rt03 a
      WHERE length(IN_STORAGE) = 5 and (
          REC_DATE > (select max(REC_DATE) from d_sale_def where view_name = 'v_aslk_py') or 0 = 0)
        and CORT_NUM_ID in ('RT03', 'RH03', 'RT01')) a
where not exists(select 1
                 from d_sjzl_pbsj b
                 where b.view_name = 'v_aslk_py' and a.REC_DATE between begindate and enddate
                   and (a.item_num_id = b.wareid or trim(b.wareid) = '全部')
                   and (a.BATCH_ID = b.MAKENO or decode(b.makeno, '全部', 0, 1) = 0))
  and trunc(REC_DATE) <= trunc(sysdate) - 1 and item_num_id in
                                                ('1009700', '1115743', '1017938', '1022664', '1009748', '1085998',
                                                 '1007517', '1129778', '1007704', '1007703', '1065307', '1010310',
                                                 '1096660', '1019229', '1109803', '1007759', '1007760', '1108423',
                                                 '1118990', '1118991', '1015028', '1009726', '1112487', '1001852',
                                                 '1007837', '1115892', '1115893', '1149935', '1007838', '1135283',
                                                 '1002693', '1097486', '1175460', '1175459', '1166338', '1166337',
                                                 '1007519', '1007520', '1015339', '1115182', '1144810', '1007497',
                                                 '1000994', '1009757', '1125040', '1144719', '1015943', '1119931',
                                                 '1180960','1129780')
  and DIST_NUM_ID in ('RT03', 'RH03', 'RT01') /*and exists(select 1
                                                         from (SELECT ITEM_NUM_ID, batch_id, SUPPLY_UNIT_NUM_ID
                                                               FROM v_aslk_py_accept
                                                               union all
                                                               SELECT to_char(wareid), ph, to_char(gysno)
                                                               FROM d_july_kc) b
                                                         where a.ITEM_NUM_ID = b.ITEM_NUM_ID and a.BATCH_ID = b.BATCH_ID
                                                           and b.SUPPLY_UNIT_NUM_ID in
                                                               ('8002221', '8003297', '8003944', '8002225', '8004445',
                                                                '8002260', '8004072', 'RT03'))*/
union all
SELECT a.cort_num_id, a.cort_name, a.reserved_no, a.dist_num_id, a.dist_name, a.in_storage, a.orgname, a.REC_DATE,
       a.item_num_id, a.item_name, a.style_desc, a.factory, a.approval_no, a.batch_id, a.expiry_date, a.qty, a.tax_rate,
       a.trade_price, a.total_amount, a.total_amount_no_tax, a.units_name, a.supply_unit_num_id, a.supply_name,
       BILL_TYPE
FROM d_rrt_sjzl_dr a
where trunc(REC_DATE) < trunc(sysdate) and VIEW_NAME = 'v_aslk_py_sale'
union all
SELECT a.cort_num_id, a.cort_name, a.reserved_no, a.dist_num_id, a.dist_name, a.in_storage, a.orgname, a.REC_DATE,
       a.item_num_id, a.item_name, a.style_desc, a.factory, a.approval_no, a.batch_id, a.expiry_date, a.qty, a.tax_rate,
       a.trade_price, a.total_amount, a.total_amount_no_tax, a.units_name, a.supply_unit_num_id, a.supply_name,
       BILL_TYPE
FROM d_sale_def a
where VIEW_NAME = 'v_aslk_py_sale'
/

