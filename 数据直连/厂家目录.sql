create table d_factory_ware(

)



create table d_factory_ware
(
  zlkmc      VARCHAR2(40) not null,
  zlkdm      VARCHAR2(40),
  waretable  VARCHAR2(2000),
  wareid     number
)
alter table d_factory_ware add lx varchar2(40);
select * from  d_factory_ware where lx='销售'
select * from d_factory_ware  where REGEXP_LIKE(zlkdm, 'hr', 'i');
delete from d_factory_ware
insert into d_factory_ware(zlkmc,zlkdm,lx) select ZLKMC,ZLKDM,'库存' from t_sjzl_wh@hydee_zy  where zlkmc like '%库存%'
update d_factory_ware set waretable='d_aslk_ly' where zlkdm like '%aslk%' 
update d_factory_ware set waretable='d_sjzl_bj_ware' where zlkdm like '%BJ_P001%'
update d_factory_ware set waretable='d_nh_ware,D_NH_WARE_PY' where REGEXP_LIKE(zlkdm, 'NH', 'i');
update d_factory_ware set waretable='d_hs_ware' where REGEXP_LIKE(zlkdm, 'HS', 'i');
update d_factory_ware set waretable='d_baier_cgspml,d_baier_dtp' where REGEXP_LIKE(zlkdm, 'baier', 'i');
update d_factory_ware set waretable='d_msd_ware_ty' where REGEXP_LIKE(zlkdm, 'msd_ty', 'i');
update d_factory_ware set waretable='d_ware_gls' where REGEXP_LIKE(zlkdm, 'gls', 'i');
update d_factory_ware set waretable='d_ware_hr' where REGEXP_LIKE(zlkdm, '_hr', 'i');




select * from d_aslk_ly
insert into d_factory_ware(zlkmc,zlkdm,lx,waretable) values('阿斯利康-配送','v_sale_aslk_p001','销售','d_aslk_ly')
