delete from  d_baier_business_lsbb;
delete from d_import_jskc;
select * from d_import_jskc for update;
delete from d_baier_business_cgrk;
select * from d_baier_business_cgrk for update;

delete from D_TSL_BUSINESS;
delete from D_TSL_BUSINESS_TEMP;
insert into D_TSL_BUSINESS select * from D_TSL_BUSINESS_TEMP ;
--门店验收入库单
delete from  d_lx_mdysckd;
delete from d_lx_mdysckd_temp;
insert into d_lx_mdysckd select * from d_lx_mdysckd_temp; 
--销售明细
delete from  d_sale_import;
