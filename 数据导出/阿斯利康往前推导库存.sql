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
select date'2024-08-01' as �������,basic.ITEM_NAME as ��Ʒ����,basic.STYLE_DESC as ��Ʒ���,  ph as ��Ʒ����,punit.units_name as ��λ,qq.qty as ����,qq.ITEM_NUM_ID
from addps qq
left join  mdms_p_product_basic basic on qq.ITEM_NUM_ID=basic.ITEM_NUM_ID
left join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id;


select CORT_NUM_ID as ��˾����, CORT_NAME as ��˾����, RESERVED_NO as ���ⵥ��, DIST_NUM_ID as ����ֱ���,
       DIST_NAME as ���������, IN_STORAGE as ���շ�,
       ORGNAME as �ŵ�����, REC_DATE as ��������, ITEM_NUM_ID as ��Ʒ����,
       ITEM_NAME as ��Ʒ����, STYLE_DESC as ���, FACTORY as ��������, APPROVAL_NO as ��׼�ĺ�, BATCH_ID as ����,
       EXPIRY_DATE as ��Ч��, QTY as ��Ʒ����, TAX_RATE as ˰��, TRADE_PRICE as ��˰����, TOTAL_AMOUNT as ��˰,
       TOTAL_AMOUNT_NO_TAX as ���δ˰, UNITS_NAME as ��λ, SUPPLY_UNIT_NUM_ID as ��Ӧ�̱���, SUPPLY_NAME as ��Ӧ������
from V_ASLK_PY_sale where DIST_NUM_ID='RH03' AND REC_DATE BETWEEN DATE'2024-08-01' AND DATE'2024-09-30'


select
    BILL_TYPE as ��������,ORDER_DATE as ��������, SUPPLY_NAME as ����������, ITEM_NAME as ��Ʒ����, STYLE_DESC as ��Ʒ���,
    BATCH_ID as ��Ʒ����,UNITS_NAME as ��Ʒ��λ, QTY as ��Ʒ����,SUP_PRICE as ����,TOTAL_AMOUNT as ���,ITEM_NUM_ID as ��Ʒ����
from V_ASLK_PY_ACCEPT
where CORT_NUM_ID='RH03' AND ORDER_DATE BETWEEN DATE'2024-08-01' AND DATE'2024-09-30'
