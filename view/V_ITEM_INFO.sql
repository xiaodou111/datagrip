select count(*)
from v_item_info where PRF_AMT is null;
create or replace view v_item_info
as
SELECT dim_prod_sp_fb.matnr                                  AS wareid,
       dim_prod_sp_fb.vkorg_id                               AS cort_num_id,
       dim_prod_sp_fb.psl_pro_name                           AS warename,
       dim_prod_sp_fb.zgg                                    AS warespec,
       dim_prod_sp_fb.meins                                  AS wareunit,
       dim_prod_sp_fb.ztymc                                  AS common_name,
       dim_prod_sp_fb.zsbpp                                  AS brand_name,
       dim_prod_sp_fb.zsccj                                  AS factoryname,
       right(dim_prod_sp_fb.sub_pro_status_notes, 2) AS sub_pro_status,
       dim_prod_sp_fb.zcffl_nm                               AS partial_prescript_class,
       dim_prod_sp_fb.zspdw                                  AS positioning_name,
       dim_prod_sp_fb.dl_name                                AS big,
       dim_prod_sp_fb.zl_name                                AS middle,
       dim_prod_sp_fb.xl_name                                AS small,
       SALE.QTY,
       SALE.avg_price,
       SALE.F_AMOUNT,
       SALE.PRF_AMT,
       sale.PRF_MLL
FROM dwb.dim_prod_sp_fb

left join (select vkorg_id,psl_pro_id,sum(psl_qty) as QTY,sum(psl_cb) as PSL_CB,sum(psl_amt) as F_AMOUNT,sum(prf_amt) as SUM_AMT,
sum(psl_amt)/nullif(sum(psl_qty),0) as avg_price,
sum(prf_amt)/nullif(sum(psl_qty),0) as PRF_AMT,
sum(prf_amt)/nullif(sum(psl_cb),0) as PRF_MLL
from dwb.dwb_sale_basic where  bill_qd_type='O2O' AND psl_date>CURRENT_DATE - interval '90 days'
and psl_qty>1
group by  vkorg_id,psl_pro_id) sale on dim_prod_sp_fb.vkorg_id=sale.vkorg_id and dim_prod_sp_fb.matnr=sale.psl_pro_id;
create or replace view v_item_info
as
SELECT dim_prod_sp_fb.matnr                                  AS wareid,
       dim_prod_sp_fb.vkorg_id                               AS cort_num_id,
       dim_prod_sp_fb.psl_pro_name                           AS warename,
       dim_prod_sp_fb.zgg                                    AS warespec,
       dim_prod_sp_fb.meins                                  AS wareunit,
       dim_prod_sp_fb.ztymc                                  AS common_name,
       dim_prod_sp_fb.zsbpp                                  AS brand_name,
       dim_prod_sp_fb.zsccj                                  AS factoryname,
       right(dim_prod_sp_fb.sub_pro_status_notes, 2) AS sub_pro_status,
       dim_prod_sp_fb.zcffl_nm                               AS partial_prescript_class,
       dim_prod_sp_fb.zspdw                                  AS positioning_name,
       dim_prod_sp_fb.dl_name                                AS big,
       dim_prod_sp_fb.zl_name                                AS middle,
       dim_prod_sp_fb.xl_name                                AS small,
       SALE.QTY,
       coalesce(SALE.avg_price,lsj.retail_price) as avg_price,
       SALE.F_AMOUNT,
       coalesce(SALE.PRF_AMT,lsj.retail_price-cb.cost_price) as PRF_AMT,
       coalesce(sale.PRF_MLL,(lsj.retail_price-cb.cost_price)/nullif(lsj.retail_price,0)) as PRF_MLL
FROM dwb.dim_prod_sp_fb

left join (select vkorg_id,psl_pro_id,sum(psl_qty) as QTY,sum(psl_cb) as PSL_CB,sum(psl_amt) as F_AMOUNT,sum(prf_amt) as SUM_AMT,
sum(psl_amt)/nullif(sum(psl_qty),0) as avg_price,
sum(prf_amt)/nullif(sum(psl_qty),0) as PRF_AMT,
sum(prf_amt)/nullif(sum(psl_amt),0) as PRF_MLL
from dwb.dwb_sale_basic where  bill_qd_type='O2O' AND psl_date>CURRENT_DATE - interval '90 days'
and psl_qty>1
group by  vkorg_id,psl_pro_id) sale on dim_prod_sp_fb.vkorg_id=sale.vkorg_id and dim_prod_sp_fb.matnr=sale.psl_pro_id
left join
    --成本
    (select cort_num_id,item_num_id,cost_price,row_number() over (PARTITION BY cort_num_id,item_num_id ORDER BY  balance_date DESC) rn ,balance_date
from zt.fi_move_weighting_cost) cb on dim_prod_sp_fb.vkorg_id=cb.cort_num_id and dim_prod_sp_fb.matnr=cb.item_num_id and cb.rn=1
    --建议零售价
left join
(select cort_num_id,item_num_id,avg(retail_price) as retail_price from zt.mdms_p_product_shop  group by cort_num_id,item_num_id
union all
select cort_num_id,item_num_id,avg(retail_price) from zt_rrt.mdms_p_product_shop group by cort_num_id,item_num_id) lsj
    on dim_prod_sp_fb.matnr=lsj.item_num_id and dim_prod_sp_fb.vkorg_id=lsj.cort_num_id
;
select cort_num_id from zt.fi_move_weighting_cost group by cort_num_id;
-- where item_num_id=1038002 and cort_num_id='RT01' ;
select * from zt_rrt.fi_move_weighting_cost where item_num_id='1037255';
select zjylsj from dwb.dim_prod_sp_fb where vkorg_id='HT03' and matnr=1007051;
1007051,HT03


select cort_num_id,item_num_id,cost_price,row_number() over (PARTITION BY cort_num_id,item_num_id ORDER BY  balance_date DESC) rn ,balance_date
from zt.fi_move_weighting_cost where item_num_id='1041513' and cort_num_id='HM01';
select * from zt.fi_move_weighting_cost;
select cort_num_id,item_num_id,avg(retail_price) from zt.mdms_p_product_shop where item_num_id='1041513' and cort_num_id='HM01'  group by cort_num_id,item_num_id
union all
select cort_num_id,item_num_id,avg(retail_price) from zt_rrt.mdms_p_product_shop where item_num_id='1037255' group by cort_num_id,item_num_id;;

