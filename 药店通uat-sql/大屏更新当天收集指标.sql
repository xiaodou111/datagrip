#�û���¼��
SELECT auth_user_name AS userid,count(*)
FROM rrtuat_platform.sys_user_wechat_auth_log
WHERE auth_user_name IS NOT NULL
  AND LENGTH(auth_user_name) <= 8
  AND auth_user_name NOT REGEXP '[^0-9]'
group by auth_user_name;

# select auth_user_name AS userid,emp.empe_name
# FROM rrtuat_platform.sys_user_wechat_auth_log log
# left join rrtuat_platform.ex_arc_empe emp on log.auth_user_name=emp.work_nums
# WHERE log.auth_user_name IS NOT NULL
#   AND LENGTH(auth_user_name) <= 8
#   AND auth_user_name NOT REGEXP '[^0-9]'
# and emp.empe_name is not  null group by auth_user_name,emp.empe_name;

#�ŵ��¼��
select log.sub_unit_num_id, max(unit.sub_unit_name) as sub_unit_name,count(*) from rrtuat_platform.sys_user_wechat_auth_log log
left join rrtuat_mdm.mdms_o_sub_unit unit on log.sub_unit_num_id = unit.sub_unit_num_id
group by log.sub_unit_num_id;


# --ҽ�����۵�


select *
from rrtuat_memorder.sd_bl_so_tml_hdr
where
#     order_date>=date'2024-07-16'
#1005 ҽ����
tml_num_id = '912274007420808';

#��ͨ���۵�
select sub_unit_num_id,max(sub_unit_name) as sub_unit_name,count(*) from (
select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.order_date = CURDATE()
)a group by sub_unit_num_id
##�����Ķ���
#   AND not exists(select 1 from sd_bl_so_op_cf_hdr cf where hdr.sub_unit_num_id=cf.sub_unit_num_id);

#��ͨ���۵��˵�
select sub_unit_num_id,max(sub_unit_name) as sub_unit_name,count(*) from (
select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
WHERE type_num_id = 2 and hdr.order_date=CURDATE()
# and not exists(select 1 from sd_bl_so_op_cf_hdr cf where hdr.sub_unit_num_id=cf.sub_unit_num_id)
)a group by sub_unit_num_id;
#   and hdr.order_date=CURDATE();
# where tml_num_id in('912684017220912');

#O2O����
select sub_unit_num_id,max(sub_unit_name) as sub_unit_name,count(*) from (
select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.tenant_num_id = 18 #`tenant_num_id` int(11) NOT NULL DEFAULT '0' COMMENT '�⻧ID',
  and hdr.data_sign = 0      #`data_sign` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0: ��ʽ  1������',
  and hdr.status_num_id = 6  #  `status_num_id` bigint(20) DEFAULT '0' COMMENT
  # '״̬(0-�½�,1-������,2-������,3,�������δ����,6-������� 9-����(��ֹ),10-�ҵ�,11-�ҵ�(���ύԶ����),
  # 12-�ҵ�(Զ����ͨ��),13-�ҵ�(Զ���󷽲�ͨ��))',
  and hdr.order_date = CURDATE()
  and so_from_type = 17
)a group by sub_unit_num_id;

#����������
select sub_unit_num_id,max(sub_unit_name) as sub_unit_name,count(*) from (
select h.cf_sale_no, h.sub_unit_num_id, unit.sub_unit_name, h.create_dtme
from rrtuat_memorder.sd_bl_so_op_cf_hdr h
         left join rrtuat_mdm.mdms_o_sub_unit unit on h.sub_unit_num_id = unit.sub_unit_num_id
where
    cf_sale_no is not null and
  # `external_flag` tinyint(4) DEFAULT '1' COMMENT '�Ƿ����䴦��  0: ��  1����',
#     `rx_status_num_id` tinyint(4) NOT NULL DEFAULT '1' COMMENT '������״̬��0:�����½�    3�������Ѹ���   ö��ֵ����',
  date(h.create_dtme) = CURDATE()
    )a group by sub_unit_num_id;

#����������
select sub_unit_num_id,max(sub_unit_name) as sub_unit_name,count(*) from (
select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.order_date = CURDATE()
  AND shop_category = 4
    )a group by sub_unit_num_id;


select shop_category, sub_unit_id, sub_unit_name, division_num_id, manage_area, shop_category
from rrtuat_mdm.mdms_o_sub_unit
where shop_category = 4;

