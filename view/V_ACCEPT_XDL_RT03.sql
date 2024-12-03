create view V_ACCEPT_XDL_RT03 as
select
   hdr.cort_num_id,                                                   --公司编码
       cort.cort_name,                                                    --公司名称
       hdr.REC_DATE as order_date ,                                                    --入库日期
       hdr.supply_unit_num_id,                                            --供应商
       nvl(supply.supply_name, incort.cort_name) supply_name,             --供应商名称
       dtl.item_num_id,                                                   --商品编码
       basic.item_name,                                                   --商品名称
       dtl.qty,                                                           --数量
       basic.style_desc,                                                  --规格
       punit.units_name ,                                                  --单位
       basic.factory,                                                     --生产厂家
       basic.approval_no,                                                 --批准文号
       dtl.batch_id,                                                      --批号
       dtl.actual_production_date,                                        --生产日期
       dtl.expiry_date,                                                  --有效期
       dtl.tax_rate,                                                      --税率（进项）
       dtl.price sup_price,                                               --采购订单单价（含税）
       round(dtl.sup_price/(1+dtl.tax_rate/100),4) sup_price_no_tax,      --采购订单单价（不含税）
       round(dtl.confirm_qty*dtl.price,2) total_amount,                   --金额（含税）
       round(dtl.confirm_qty*dtl.price/(1+dtl.tax_rate/100),2) total_amount_no_tax,--金额（不含税）
       hdr.type_num_id  ,
       hdr.IN_STORAGE, -- 01 合格,03 B2C,05 B2B,07 线下B2C
       '采购入库单' as bill_type
       from  wm_bl_receipt_bud_hdr hdr
 inner join scm_rep_po_hdr po  on hdr.tenant_num_id=po.tenant_num_id and hdr.data_sign=po.data_sign and TO_CHAR(hdr.po_num_id)=po.po_num_id
 inner join wm_bl_receipt_bud_batch_dtl dtl on hdr.tenant_num_id = dtl.tenant_num_id and hdr.data_sign = dtl.data_sign
   and hdr.reserved_no = dtl.reserved_no and hdr.cort_num_id = dtl.cort_num_id and hdr.sub_unit_num_id = dtl.sub_unit_num_id
 inner join mdms_o_cort cort on hdr.cort_num_id = cort.cort_num_id and hdr.data_sign = cort.data_sign and hdr.tenant_num_id = cort.tenant_num_id
 left join mdms_o_supply supply on hdr.supply_unit_num_id = supply.supply_num_id
 left join mdms_o_cort incort on hdr.supply_unit_num_id = incort.cort_num_id and hdr.data_sign = incort.data_sign and hdr.tenant_num_id = incort.tenant_num_id
 inner join mdms_p_product_basic basic on dtl.tenant_num_id = basic.tenant_num_id and dtl.data_sign = basic.data_sign and dtl.item_num_id = basic.item_num_id
 inner join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id
where hdr.tenant_num_id = 18 and hdr.data_sign = 0 and hdr.status_num_id = 5
 --批发采购入库 1
   --连锁采购入库 2
   --门店采购入库 3
   --连锁委托配送收货入库 5
   --内部批销收  22
   --广济收货 10
   --存仁堂格式1收货 10
   --存仁堂上药主供 11
   --天天康直通入库 15
 and hdr.type_num_id in (1,2,22,5 )   
  --12.2拿掉,直接采购到RT01的没体现
  and  (  hdr.IN_STORAGE like '401%'  or hdr.IN_STORAGE like '418%' )
 and dtl.FIRST_REC_DATE  is not null
  --and   hdr.cort_num_id  not like 'TX%'

   union all

 select
       hdr.cort_num_id,                                                   --公司编码
       cort.cort_name,                                                    --公司名称
       hdr.rec_date as ship_date,                                         --出库日期
       hdr.supply_unit_num_id,                                            --供应商
       pond.supply_name,                                                  --供应商名称
     to_char(  dtl.item_num_id),                                                   --商品编码
       basic.item_name,                                                   --商品名称
       -dtl.qty,                                                           --商品数量
       basic.style_desc,                                                  --规格
       punit.units_name,                                                  --单位
       basic.factory,                                                     --生产厂家
       basic.approval_no,                                                 --批准文号
       dtl.batch_id,                                                      --批号
       dtl.actual_production_date,                                        --生产日期
       dtl.expiry_date,                                                  --有效期
       dtl.tax_rate,                                                      --税率（进项）
       dtl.trade_price,                                                   --交易价格（含税）
       round(dtl.trade_price/(1+dtl.tax_rate/100),4) trade_price_no_tax,  --采交易价格（不含税）
      - dtl.total_amount,                                                  --金额（含税）
      - dtl.total_amount-dtl.tax_amount total_amount_no_tax,               --金额（不含税）
       hdr.type_num_id ,hdr.out_STORAGE,
       '采购退货单' as bill_type
  from wm_bl_ship_hdr hdr
  inner join scm_rep_po_hdr po on hdr.tenant_num_id=po.tenant_num_id and hdr.data_sign=po.data_sign and hdr.po_num_id=po.po_num_id
 inner join wm_bl_ship_batch_dtl dtl on hdr.tenant_num_id = dtl.tenant_num_id and hdr.data_sign = dtl.data_sign and hdr.reserved_no = dtl.reserved_no
   and hdr.cort_num_id = dtl.cort_num_id and hdr.sub_unit_num_id = dtl.sub_unit_num_id
 inner join mdms_o_cort cort on hdr.cort_num_id = cort.cort_num_id and hdr.data_sign = cort.data_sign and hdr.tenant_num_id = cort.tenant_num_id
 inner join scm_item_pond pond on hdr.tenant_num_id = pond.tenant_num_id and hdr.data_sign = pond.data_sign and hdr.cort_num_id = pond.cort_num_id
     and dtl.item_num_id = pond.item_num_id and hdr.supply_unit_num_id = pond.supply_num_id and pond.item_status = 0
 inner join mdms_p_product_basic basic on dtl.tenant_num_id = basic.tenant_num_id and dtl.data_sign = basic.data_sign and dtl.item_num_id = basic.item_num_id
 inner join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id
 where hdr.tenant_num_id = 18 and hdr.data_sign = 0 and hdr.status_num_id = 2
   --大仓退供应商 12
   --门店退供应商 13
   --内部批销退 21
   --存仁堂退上药 18
   --连锁委托配送退库  6
  and hdr.type_num_id in (12 )
   and dtl.FIRST_REC_DATE  is not null
/

