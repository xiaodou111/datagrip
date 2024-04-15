select * from t_sjzl_wh where ZLKMC like '%石药%' for update
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('中美华东(非DTP)-库存','V_KC_ZMHD_P001',sysdate,10001014,10001014,1,2);
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('中美华东(非DTP)-采购','V_ACCEPT_ZMHD_P001',sysdate,10001014,10001014,1,2);
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('中美华东(非DTP)-销售','V_SALE_ZMHD_P001',sysdate,10001014,10001014,1,2);


delete from t_sjzl_wh  where ZLKMC like '%中美华东%';
 select * from V_SALE_OJL_P001;
                                 select * from V_ACCEPT_OJL_P001;
                                 select * from V_KC_OJL_P001;

select ROWID,zlkmc, zlkdm, remark,
       createtime, cgy, watch_user, sfyw, wareids, zbormd, busnos, werks, viewdate, waretable
from t_sjzl_wh where ZLKMC like '%辉瑞%';
select *
from s_busi ;
delete from t_sjzl_wh where ROWID in
                            ('AABRBbABkAAG+NrAAJ','AABRBbABkAAG+NsAAH','AABRBbABkAAG+NsAAI','AABRBbABkAAG+NtAAd');
v_kc_wc_1163 
v_accept_rcsw_hz
v_kc_rcsw_hz
v_sale_rcsw_hz

  


insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('诺诚健华-浣纱路健康药房','v_sale_aslk_85003',sysdate,10003937,10003937,1,2);

insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values
('诺诚健华-上塘路健康药房','v_sale_aslk_85049',sysdate,10003937,10003937,1,2);

delete from t_sjzl_wh where 
ZLKMC in ('阿斯利康-采东路健康药房库存','阿斯利康-采东路健康药房采购','阿斯利康-采东路健康药房销售')
select *
from t_sjzl_wh;
