with QMKC as (
select ITEM_NUM_ID,BATCH_ID,sum(PHYSIC_QTY) qty from D_STOCKDAILY
  where VIEWNAME='V_ASLK_PY_KC' and COPYDAY=date'2024-11-01' and CORT_NUM_ID='RH03'
  group by  ITEM_NUM_ID,BATCH_ID),
    CG AS (
     select ITEM_NUM_ID,BATCH_ID,sum(QTY) as qty from V_ASLK_PY_ACCEPT
      where CORT_NUM_ID='RH03' AND ORDER_DATE BETWEEN DATE'2024-08-01' AND DATE'2024-10-31'
      group by ITEM_NUM_ID,BATCH_ID
    ),
    PS AS (
     select ITEM_NUM_ID,BATCH_ID,sum(QTY) as qty from V_ASLK_PY_SALE
    where DIST_NUM_ID='RH03' AND REC_DATE BETWEEN DATE'2024-08-01' AND DATE'2024-10-31'
    group by ITEM_NUM_ID,BATCH_ID
    ),
    jcg AS ( select COALESCE(to_char(a1.ITEM_NUM_ID),a2.ITEM_NUM_ID) as ITEM_NUM_ID,nvl(a1.qty,0)-nvl(a2.qty,0) as qty,
              COALESCE(a1.BATCH_ID,a2.BATCH_ID) as BATCH_ID
              from QMKC a1 full join CG a2 on a1.ITEM_NUM_ID=a2.ITEM_NUM_ID and a1.BATCH_ID=a2.BATCH_ID ),

   addps as (  select COALESCE(to_char(jcg.ITEM_NUM_ID),PS.ITEM_NUM_ID) as ITEM_NUM_ID,nvl(jcg.qty,0)+nvl(PS.qty,0) as qty,
              COALESCE(jcg.BATCH_ID,PS.BATCH_ID) as ph
              from jcg  full join PS  on jcg.ITEM_NUM_ID=PS.ITEM_NUM_ID and jcg.BATCH_ID=PS.BATCH_ID
              where nvl(jcg.qty,0)+nvl(PS.qty,0)<>0
              )
select date'2024-08-01' as 库存日期,basic.ITEM_NAME as 产品名称,basic.STYLE_DESC as 产品规格,  ph as 产品批号,punit.units_name as 单位,qq.qty as 数量,qq.ITEM_NUM_ID
from addps qq
left join  mdms_p_product_basic basic on qq.ITEM_NUM_ID=basic.ITEM_NUM_ID
left join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id;


select CORT_NUM_ID as 公司编码, CORT_NAME as 公司名称, RESERVED_NO as 出库单号, DIST_NUM_ID as 出库仓编码,
       DIST_NAME as 出库仓名称, IN_STORAGE as 接收方,
       ORGNAME as 门店名称, REC_DATE as 出库日期, ITEM_NUM_ID as 商品编码,
       ITEM_NAME as 商品名称, STYLE_DESC as 规格, FACTORY as 生产厂家, APPROVAL_NO as 批准文号, BATCH_ID as 批号,
       EXPIRY_DATE as 有效期, QTY as 商品数量, TAX_RATE as 税率, TRADE_PRICE as 含税单价, TOTAL_AMOUNT as 金额含税,
       TOTAL_AMOUNT_NO_TAX as 金额未税, UNITS_NAME as 单位, SUPPLY_UNIT_NUM_ID as 供应商编码, SUPPLY_NAME as 供应商名称
from V_ASLK_PY_sale where DIST_NUM_ID='RH03' AND REC_DATE BETWEEN DATE'2024-08-01' AND DATE'2024-09-30'


select
    BILL_TYPE as 单据类型,ORDER_DATE as 单据日期, SUPPLY_NAME as 供货方名称, ITEM_NAME as 产品名称, STYLE_DESC as 产品规格,
    BATCH_ID as 产品批号,UNITS_NAME as 产品单位, QTY as 产品数量,SUP_PRICE as 单价,TOTAL_AMOUNT as 金额,ITEM_NUM_ID as 产品编码
from V_ASLK_PY_ACCEPT
where CORT_NUM_ID='RH03' AND ORDER_DATE BETWEEN DATE'2024-08-01' AND DATE'2024-09-30'
