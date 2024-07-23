#�ŵ��¼��
select log.sub_unit_num_id, max(unit.sub_unit_name) as sub_unit_name, count(*)
from rrtuat_platform.sys_user_wechat_auth_log log
         left join rrtuat_mdm.mdms_o_sub_unit unit on log.sub_unit_num_id = unit.sub_unit_num_id
group by log.sub_unit_num_id;
#��̨��¼��
select computer_name, count(*)
FROM rrtuat_platform.sys_user_wechat_auth_log
where LENGTH(computer_name) = 7
group by computer_name;
#�û���¼��
SELECT auth_user_name AS userid, count(*)
FROM rrtuat_platform.sys_user_wechat_auth_log
WHERE auth_user_name IS NOT NULL
  AND LENGTH(auth_user_name) <= 8
  AND auth_user_name NOT REGEXP '[^0-9]'
group by auth_user_name;
#�������۵�
select sub_unit_num_id, max(sub_unit_name) as sub_unit_name, count(*)
from (select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
      from rrtuat_memorder.sd_bl_so_tml_hdr hdr
               left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
      where hdr.order_date = CURDATE()) a
group by sub_unit_num_id
#�������۵��˵�
select sub_unit_num_id, max(sub_unit_name) as sub_unit_name, count(*)
from (select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
      from rrtuat_memorder.sd_bl_so_tml_hdr hdr
               left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
      WHERE type_num_id = 2
        and hdr.order_date = CURDATE()
# and not exists(select 1 from sd_bl_so_op_cf_hdr cf where hdr.sub_unit_num_id=cf.sub_unit_num_id)
     ) a
group by sub_unit_num_id;

#ҽ�����۵�����
select *
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_memorder.fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id in ('531', '523', '521', '524', '525', '522');

#ҽ�����۵��˵�
select *
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_memorder.fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and hdr.type_num_id = 2;

#O2Oת����
select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.tenant_num_id = 18
  and hdr.data_sign = 0
  and hdr.status_num_id = 6
  and hdr.order_date = CURDATE()
  and so_from_type = 17;
#��������
select h.sub_unit_num_id, unit.sub_unit_name, h.rx_order_no as ��������, h.create_dtme
from rrtuat_memorder.sd_bl_so_op_cf_hdr h
left join rrtuat_mdm.mdms_o_sub_unit unit on h.sub_unit_num_id = unit.sub_unit_num_id
where unit.shop_category = 4
#��������
select hdr.sub_unit_num_id,hdr.sub_unit_name,hdr.tml_num_id,hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where  unit.shop_category = 4
#ҩ�괦��
select h.sub_unit_num_id, unit.sub_unit_name, h.rx_order_no as ��������, h.create_dtme
from rrtuat_memorder.sd_bl_so_op_cf_hdr h
left join rrtuat_mdm.mdms_o_sub_unit unit on h.sub_unit_num_id = unit.sub_unit_num_id
where  unit.shop_category = 2
#���䴦��
select h.sub_unit_num_id, unit.sub_unit_name, h.rx_order_no as ��������, h.create_dtme
from rrtuat_memorder.sd_bl_so_op_cf_hdr h
left join rrtuat_mdm.mdms_o_sub_unit unit on h.sub_unit_num_id = unit.sub_unit_num_id
where  h.external_flag=1
#�ս����
select h.sub_unit_num_id, unit.sub_unit_name,reconciliation_no as ���˵���,h.create_dtme
from rrtuat_memorder.sd_bl_dayend_reconciliation_hdr h
left join rrtuat_mdm.mdms_o_sub_unit unit on h.sub_unit_num_id = unit.sub_unit_num_id;