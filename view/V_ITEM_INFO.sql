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