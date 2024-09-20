--推7.31库存
with a1 as (
select wareid, REPLACE(REPLACE(ph, ' ', ''), '\t', '') as ph, sum(sl)as sl, yxq
from d_aslk_kc_731 a
group by wareid,REPLACE(REPLACE(ph, ' ', ''), '\t', ''),yxq ),
 a2 as ( select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(SUP_PRICE) as SUP_PRICE,sum(QTY) as qty from V_ASLK_PY_ACCEPT
where CORT_NAME='台州瑞人堂药业有限公司' and ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'
group by ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE),
    res1 as (
       select COALESCE(to_char(a1.wareid),a2.ITEM_NUM_ID) as wareid,nvl(a1.sl,0)+nvl(a2.qty,0) as sl,
              COALESCE(a1.ph,a2.BATCH_ID) as ph,COALESCE(a1.yxq,a2.EXPIRY_DATE) as yxq
       from a1 full join a2 on a1.wareid=a2.ITEM_NUM_ID and a1.ph=a2.BATCH_ID and a1.yxq=a2.EXPIRY_DATE
    ),
a3 as (
  select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(TRADE_PRICE) as TRADE_PRICE,sum(QTY) as qty from V_ASLK_PY_sale where DIST_NAME='台州瑞人堂药业有限公司'
   and REC_DATE >=date'2024-08-01' and REC_DATE < date'2024-09-01' group by ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE
),
-- select a1.*,a2.ITEM_NUM_ID,a2.BATCH_ID,a2.QTY, a3.ITEM_NUM_ID,a3.BATCH_ID,a3.QTY
result as (
select
    nvl(res1.wareid,a3.ITEM_NUM_ID) as wareid,
       nvl(res1.sl,0)-nvl(a3.qty,0) as sl,
nvl(res1.ph,a3.BATCH_ID) as ph,
nvl(res1.yxq,a3.EXPIRY_DATE) as yxq
from res1
full join a3 on res1.wareid=a3.ITEM_NUM_ID and res1.ph=a3.BATCH_ID and res1.yxq=a3.EXPIRY_DATE
where nvl(res1.sl,0)-nvl(a3.qty,0)<>0 )
select date'2024-08-31' as 库存日期,basic.ITEM_NAME as 产品名称,basic.STYLE_DESC as 产品规格,  ph as 产品批号,punit.units_name as 单位,qq.sl as 数量,qq.wareid
from result qq
left join  mdms_p_product_basic basic on qq.wareid=basic.ITEM_NUM_ID
left join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id;

--采购
select
    BILL_TYPE as 单据类型,ORDER_DATE as 单据日期, SUPPLY_NAME as 供货方名称, ITEM_NAME as 产品名称, STYLE_DESC as 产品规格,
    BATCH_ID as 产品批号,UNITS_NAME as 产品单位, QTY as 产品数量,SUP_PRICE as 单价,TOTAL_AMOUNT as 金额,ITEM_NUM_ID as 产品编码
from V_ASLK_PY_ACCEPT
where CORT_NAME='台州瑞人堂药业有限公司' and ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'

--配送
select REC_DATE as 单据日期, IN_STORAGE as 门店编码,ORGNAME as 门店名称,ITEM_NUM_ID as 产品编码,ITEM_NAME as 产品名称,STYLE_DESC as 产品规格,
     BATCH_ID as 产品批号,UNITS_NAME as 产品单位,QTY as 产品数量,TRADE_PRICE as 销售单价,TOTAL_AMOUNT as 销售金额
from V_ASLK_PY_sale where DIST_NAME='台州瑞人堂药业有限公司'
   and REC_DATE >=date'2024-08-01' and REC_DATE < date'2024-09-01'



select
    BILL_TYPE as 单据类型,ORDER_DATE as 单据日期, SUPPLY_NAME as 供货方名称, ITEM_NAME as 产品名称, STYLE_DESC as 产品规格,
    BATCH_ID as 产品批号,UNITS_NAME as 产品单位, QTY as 产品数量,SUP_PRICE as 单价,TOTAL_AMOUNT as 金额,ITEM_NUM_ID as 产品编码
from V_ASLK_PY_ACCEPT
where CORT_NAME='台州瑞人堂药业有限公司' and ORDER_DATE>=date'2024-09-01' and ORDER_DATE<date'2024-09-12' and ITEM_NUM_ID='1129780'

select * from V_ASLK_PY_KC where ITEM_NUM_ID='1129780';
select TML_NUM_ID, VIP_NO, ITEM_NUM_ID, QTY, ORDER_DATE, SUB_UNIT_NUM_ID, TRADE_PRICE, F_AMOUNT, CORT_NAME,
       SUB_UNIT_NAME, ITEM_NAME, STYLE_DESC, BATCH_ID, FACTORY, UNITS_NAME, DETAILID
from V_ASLK_CX where ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01';


create table D_ASLK_ZJKC_731
(
    WAREID NUMBER,
    PH     VARCHAR2(100),
    SL     NUMBER,
    YXQ    DATE
)
delete from D_ASLK_ZJKC_731;;
select * from D_ASLK_ZJKC_731;


UPDATE D_ASLK_ZJKC_731 T1
SET T1.wareid = (
    SELECT T2.NWAREID
    FROM (
        SELECT OWAREID, NWAREID
        FROM d_rrt_qy_ware@h2
    ) T2
    WHERE T1.wareid = T2.OWAREID
);
select * from D_ASLK_ZJKC_731 where WAREID in (1015339,1007497,1015339
);

--推浙江瑞人堂7.31库存
with a1 as (
select wareid, REPLACE(REPLACE(ph, ' ', ''), '\t', '') as ph, sum(sl)as sl, yxq
from D_ASLK_ZJKC_731 a
group by wareid,REPLACE(REPLACE(ph, ' ', ''), '\t', ''),yxq ),
 a2 as ( select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(SUP_PRICE) as SUP_PRICE,sum(QTY) as qty from V_ASLK_PY_ACCEPT
where CORT_NAME='浙江瑞人堂药业有限公司' and ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'
group by ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE),
    res1 as (
       select COALESCE(to_char(a1.wareid),a2.ITEM_NUM_ID) as wareid,nvl(a1.sl,0)+nvl(a2.qty,0) as sl,
              COALESCE(a1.ph,a2.BATCH_ID) as ph,COALESCE(a1.yxq,a2.EXPIRY_DATE) as yxq
       from a1 full join a2 on a1.wareid=a2.ITEM_NUM_ID and a1.ph=a2.BATCH_ID and a1.yxq=a2.EXPIRY_DATE
    ),
a3 as (
  select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(TRADE_PRICE) as TRADE_PRICE,sum(QTY) as qty from V_ASLK_PY_sale where DIST_NAME='浙江瑞人堂药业有限公司'
   and REC_DATE >=date'2024-08-01' and REC_DATE < date'2024-09-01' group by ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE
),
-- select a1.*,a2.ITEM_NUM_ID,a2.BATCH_ID,a2.QTY, a3.ITEM_NUM_ID,a3.BATCH_ID,a3.QTY
result as (
select
    nvl(res1.wareid,a3.ITEM_NUM_ID) as wareid,
       nvl(res1.sl,0)-nvl(a3.qty,0) as sl,
nvl(res1.ph,a3.BATCH_ID) as ph,
nvl(res1.yxq,a3.EXPIRY_DATE) as yxq
from res1
full join a3 on res1.wareid=a3.ITEM_NUM_ID and res1.ph=a3.BATCH_ID and res1.yxq=a3.EXPIRY_DATE
where nvl(res1.sl,0)-nvl(a3.qty,0)<>0 )
select date'2024-08-31' as 库存日期,basic.ITEM_NAME as 产品名称,basic.STYLE_DESC as 产品规格,  ph as 产品批号,punit.units_name as 单位,qq.sl as 数量,qq.wareid
from result qq
left join  mdms_p_product_basic basic on qq.wareid=basic.ITEM_NUM_ID
left join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id;

--采购
select
    BILL_TYPE as 单据类型,ORDER_DATE as 单据日期, SUPPLY_NAME as 供货方名称, ITEM_NAME as 产品名称, STYLE_DESC as 产品规格,
    BATCH_ID as 产品批号,UNITS_NAME as 产品单位, QTY as 产品数量,SUP_PRICE as 单价,TOTAL_AMOUNT as 金额,ITEM_NUM_ID as 产品编码
from V_ASLK_PY_ACCEPT
where  ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'

select * from V_ASLK_PY_ACCEPT where  ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01';

--配送
select REC_DATE as 单据日期, IN_STORAGE as 门店编码,ORGNAME as 门店名称,ITEM_NUM_ID as 产品编码,ITEM_NAME as 产品名称,STYLE_DESC as 产品规格,
     BATCH_ID as 产品批号,UNITS_NAME as 产品单位,QTY as 产品数量,TRADE_PRICE as 销售单价,TOTAL_AMOUNT as 销售金额
from V_ASLK_PY_sale where DIST_NAME='浙江瑞人堂药业有限公司'
   and REC_DATE >=date'2024-08-01' and REC_DATE < date'2024-09-01'

--纯销
select CORT_NAME as 连锁总部名称,trunc(ORDER_DATE) as 日期,TO_CHAR(ORDER_DATE, 'HH24:MI:SS') as 时间 ,SUB_UNIT_NAME as 门店名称,MANAGE_AREA as 片区,ITEM_NUM_ID as 产品代码,ITEM_NAME as 产品名称,STYLE_DESC as 产品规格,QTY as 数量,BATCH_ID as 批号,UNITS_NAME as 单位,
       TRADE_PRICE as 销售单价,F_AMOUNT as 销售金额,TML_NUM_ID as 零售单流水号,'明细' as 数据类型
from V_ASLK_CX where ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01';