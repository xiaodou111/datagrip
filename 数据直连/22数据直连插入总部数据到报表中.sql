select * from t_sjzl_wh where ZLKMC like '%石药%' for update
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('默沙东(DTP)-三门人民路店','V_KC_SYSS_P001_TY',sysdate,10003937,10003937,1,2);
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('沈阳三生(DTP)-采购','V_ACCEPT_SYSS_P001_TY',sysdate,10003937,10003937,1,2);
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('沈阳三生(DTP)-销售','V_SALE_SYSS_P001_TY',sysdate,10003937,10003937,1,2);
V_ACCEPT_NH_P001
V_ACCEPT_NH_P001_ZJ
V_SALE_NH_P001_1
V_SALE_NH_P001_ZJ

v_accept_xs_86219
v_kc_xs_86219
v_sale_xs_86219

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
