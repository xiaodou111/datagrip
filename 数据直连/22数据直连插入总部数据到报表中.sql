select * from t_sjzl_wh where ZLKMC like '%ʯҩ%' for update
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('����(��DTP)-���','V_KC_HR_P001_PY',sysdate,10001014,10001014,1,2);
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('����(��DTP)-�ɹ�','V_ACCEPT_HR_P001_PY',sysdate,10001014,10001014,1,2);
insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('����(��DTP)-����','V_SALE_HR_P001_PY',sysdate,10001014,10001014,1,2);


v_accept_xs_86219
v_kc_xs_86219
v_sale_xs_86219

select ROWID,zlkmc, zlkdm, remark,
       createtime, cgy, watch_user, sfyw, wareids, zbormd, busnos, werks, viewdate, waretable
from t_sjzl_wh where ZLKMC like '%����%';
delete from t_sjzl_wh where ROWID in
                            ('AABRBbABkAAG+NrAAJ','AABRBbABkAAG+NsAAH','AABRBbABkAAG+NsAAI','AABRBbABkAAG+NtAAd');
v_kc_wc_1163 
v_accept_rcsw_hz
v_kc_rcsw_hz
v_sale_rcsw_hz

  


insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) values 
('��˹����-�ɶ�·����ҩ��','v_sale_aslk_85045',sysdate,10003937,10003937,1,2);

delete from t_sjzl_wh where 
ZLKMC in ('��˹����-�ɶ�·����ҩ�����','��˹����-�ɶ�·����ҩ���ɹ�','��˹����-�ɶ�·����ҩ������')
