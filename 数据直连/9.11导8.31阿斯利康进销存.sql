--��7.31���
with a1 as (
select wareid, REPLACE(REPLACE(ph, ' ', ''), '\t', '') as ph, sum(sl)as sl, yxq
from d_aslk_kc_731 a
group by wareid,REPLACE(REPLACE(ph, ' ', ''), '\t', ''),yxq ),
 a2 as ( select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(SUP_PRICE) as SUP_PRICE,sum(QTY) as qty from V_ASLK_PY_ACCEPT
where CORT_NAME='̨��������ҩҵ���޹�˾' and ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'
group by ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE),
    res1 as (
       select COALESCE(to_char(a1.wareid),a2.ITEM_NUM_ID) as wareid,nvl(a1.sl,0)+nvl(a2.qty,0) as sl,
              COALESCE(a1.ph,a2.BATCH_ID) as ph,COALESCE(a1.yxq,a2.EXPIRY_DATE) as yxq
       from a1 full join a2 on a1.wareid=a2.ITEM_NUM_ID and a1.ph=a2.BATCH_ID and a1.yxq=a2.EXPIRY_DATE
    ),
a3 as (
  select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(TRADE_PRICE) as TRADE_PRICE,sum(QTY) as qty from V_ASLK_PY_sale where DIST_NAME='̨��������ҩҵ���޹�˾'
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
select date'2024-08-31' as �������,basic.ITEM_NAME as ��Ʒ����,basic.STYLE_DESC as ��Ʒ���,  ph as ��Ʒ����,punit.units_name as ��λ,qq.sl as ����,qq.wareid
from result qq
left join  mdms_p_product_basic basic on qq.wareid=basic.ITEM_NUM_ID
left join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id;

--�ɹ�
select
    BILL_TYPE as ��������,ORDER_DATE as ��������, SUPPLY_NAME as ����������, ITEM_NAME as ��Ʒ����, STYLE_DESC as ��Ʒ���,
    BATCH_ID as ��Ʒ����,UNITS_NAME as ��Ʒ��λ, QTY as ��Ʒ����,SUP_PRICE as ����,TOTAL_AMOUNT as ���,ITEM_NUM_ID as ��Ʒ����
from V_ASLK_PY_ACCEPT
where CORT_NAME='̨��������ҩҵ���޹�˾' and ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'

--����
select REC_DATE as ��������, IN_STORAGE as �ŵ����,ORGNAME as �ŵ�����,ITEM_NUM_ID as ��Ʒ����,ITEM_NAME as ��Ʒ����,STYLE_DESC as ��Ʒ���,
     BATCH_ID as ��Ʒ����,UNITS_NAME as ��Ʒ��λ,QTY as ��Ʒ����,TRADE_PRICE as ���۵���,TOTAL_AMOUNT as ���۽��
from V_ASLK_PY_sale where DIST_NAME='̨��������ҩҵ���޹�˾'
   and REC_DATE >=date'2024-08-01' and REC_DATE < date'2024-09-01'



select
    BILL_TYPE as ��������,ORDER_DATE as ��������, SUPPLY_NAME as ����������, ITEM_NAME as ��Ʒ����, STYLE_DESC as ��Ʒ���,
    BATCH_ID as ��Ʒ����,UNITS_NAME as ��Ʒ��λ, QTY as ��Ʒ����,SUP_PRICE as ����,TOTAL_AMOUNT as ���,ITEM_NUM_ID as ��Ʒ����
from V_ASLK_PY_ACCEPT
where CORT_NAME='̨��������ҩҵ���޹�˾' and ORDER_DATE>=date'2024-09-01' and ORDER_DATE<date'2024-09-12' and ITEM_NUM_ID='1129780'

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

--���㽭������7.31���
with a1 as (
select wareid, REPLACE(REPLACE(ph, ' ', ''), '\t', '') as ph, sum(sl)as sl, yxq
from D_ASLK_ZJKC_731 a
group by wareid,REPLACE(REPLACE(ph, ' ', ''), '\t', ''),yxq ),
 a2 as ( select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(SUP_PRICE) as SUP_PRICE,sum(QTY) as qty from V_ASLK_PY_ACCEPT
where CORT_NAME='�㽭������ҩҵ���޹�˾' and ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'
group by ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE),
    res1 as (
       select COALESCE(to_char(a1.wareid),a2.ITEM_NUM_ID) as wareid,nvl(a1.sl,0)+nvl(a2.qty,0) as sl,
              COALESCE(a1.ph,a2.BATCH_ID) as ph,COALESCE(a1.yxq,a2.EXPIRY_DATE) as yxq
       from a1 full join a2 on a1.wareid=a2.ITEM_NUM_ID and a1.ph=a2.BATCH_ID and a1.yxq=a2.EXPIRY_DATE
    ),
a3 as (
  select ITEM_NUM_ID,BATCH_ID,EXPIRY_DATE,max(TRADE_PRICE) as TRADE_PRICE,sum(QTY) as qty from V_ASLK_PY_sale where DIST_NAME='�㽭������ҩҵ���޹�˾'
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
select date'2024-08-31' as �������,basic.ITEM_NAME as ��Ʒ����,basic.STYLE_DESC as ��Ʒ���,  ph as ��Ʒ����,punit.units_name as ��λ,qq.sl as ����,qq.wareid
from result qq
left join  mdms_p_product_basic basic on qq.wareid=basic.ITEM_NUM_ID
left join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id;

--�ɹ�
select
    BILL_TYPE as ��������,ORDER_DATE as ��������, SUPPLY_NAME as ����������, ITEM_NAME as ��Ʒ����, STYLE_DESC as ��Ʒ���,
    BATCH_ID as ��Ʒ����,UNITS_NAME as ��Ʒ��λ, QTY as ��Ʒ����,SUP_PRICE as ����,TOTAL_AMOUNT as ���,ITEM_NUM_ID as ��Ʒ����
from V_ASLK_PY_ACCEPT
where  ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01'

select * from V_ASLK_PY_ACCEPT where  ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01';

--����
select REC_DATE as ��������, IN_STORAGE as �ŵ����,ORGNAME as �ŵ�����,ITEM_NUM_ID as ��Ʒ����,ITEM_NAME as ��Ʒ����,STYLE_DESC as ��Ʒ���,
     BATCH_ID as ��Ʒ����,UNITS_NAME as ��Ʒ��λ,QTY as ��Ʒ����,TRADE_PRICE as ���۵���,TOTAL_AMOUNT as ���۽��
from V_ASLK_PY_sale where DIST_NAME='�㽭������ҩҵ���޹�˾'
   and REC_DATE >=date'2024-08-01' and REC_DATE < date'2024-09-01'

--����
select CORT_NAME as �����ܲ�����,trunc(ORDER_DATE) as ����,TO_CHAR(ORDER_DATE, 'HH24:MI:SS') as ʱ�� ,SUB_UNIT_NAME as �ŵ�����,MANAGE_AREA as Ƭ��,ITEM_NUM_ID as ��Ʒ����,ITEM_NAME as ��Ʒ����,STYLE_DESC as ��Ʒ���,QTY as ����,BATCH_ID as ����,UNITS_NAME as ��λ,
       TRADE_PRICE as ���۵���,F_AMOUNT as ���۽��,TML_NUM_ID as ���۵���ˮ��,'��ϸ' as ��������
from V_ASLK_CX where ORDER_DATE>=date'2024-08-01' and ORDER_DATE<date'2024-09-01';