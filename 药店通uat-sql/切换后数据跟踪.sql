#1�ŵ��¼��
select log.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_platform.sys_user_wechat_auth_log log
left join rrtuat_mdm.mdms_o_sub_unit unit on log.sub_unit_num_id = unit.sub_unit_num_id
where date(log.create_dtme)=CURRENT_DATE
group by log.sub_unit_num_id, unit.sub_unit_name;
#2��̨��¼��
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����,computer_name as ������� ,count(*) as ����
from rrtuat_platform.sys_user_wechat_auth_log hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where LENGTH(computer_name) = 7
and date(hdr.create_dtme)=CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name,computer_name;
#3�û���¼��
SELECT hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����,auth_user_name AS ����, count(*) as ����
FROM rrtuat_platform.sys_user_wechat_auth_log hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
WHERE auth_user_name IS NOT NULL
  AND length(auth_user_name) <= 8
  AND auth_user_name NOT REGEXP '[^0-9]' -- PostgreSQL ʹ�� ~ ������ REGEXP  !~ '[^0-9]'
  and date(hdr.create_dtme)=CURRENT_DATE
GROUP BY hdr.sub_unit_num_id,unit.sub_unit_name,auth_user_name;
#4�������۵�
select sub_unit_num_id as �ŵ����, sub_unit_name as �ŵ�����, count(*) as ����
from (select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
      from rrtuat_memorder.sd_bl_so_tml_hdr hdr
               left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
      where hdr.order_date = CURRENT_DATE) a
group by sub_unit_num_id, sub_unit_name
#5�������۵��˵�
select sub_unit_num_id as �ŵ����, max(sub_unit_name) as �ŵ�����, count(*) as ����
from (select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
      from rrtuat_memorder.sd_bl_so_tml_hdr hdr
               left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
      WHERE type_num_id = 2
        and hdr.order_date = CURRENT_DATE
-- and not exists(select 1 from sd_bl_so_op_cf_hdr cf where hdr.sub_unit_num_id=cf.sub_unit_num_id)
     ) a
group by sub_unit_num_id;

#6ҽ�����۵�����
select hdr.sub_unit_num_id as �ŵ����, sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_memorder.fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, sub_unit_name;


#7ҽ�����۵��˵�
select hdr.sub_unit_num_id as �ŵ����, sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_memorder.fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and hdr.type_num_id = 2
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, sub_unit_name;

# 8O2Oת����
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.tenant_num_id = 18
  and hdr.data_sign = 0
  and hdr.status_num_id = 6
  and hdr.order_date = CURRENT_DATE
  and so_from_type = 17
group by hdr.sub_unit_num_id, unit.sub_unit_name;
# --9��������
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_op_cf_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where unit.shop_category = 4
  and date(hdr.create_dtme) = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
# --10��������
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where unit.shop_category = 4
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
# --11ҩ���ҽ������
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_tml_hdr_rx hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
         left join rrtuat_memorder.fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id not in ('531', '523', '521', '524', '525', '522')
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
# --12ҩ��ҽ�����䴦��
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_so_op_cf_hdr hdr
         left join rrtuat_memorder.fi_bl_cash_dtl dtl on hdr.cf_sale_no = dtl.reserved_no
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where external_flag = 1
  and dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and unit.shop_category <> 4
  and date(hdr.create_dtme) = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
# --13�ս����
select hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����, count(*) as ����
from rrtuat_memorder.sd_bl_dayend_reconciliation_hdr hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
group by hdr.sub_unit_num_id, unit.sub_unit_name;
#14�û���¼��
SELECT hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����,auth_user_name AS ����, auth_login_name as �û������,
        CASE
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =1 then '�곤'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 10 AND 19 then '�곤'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 2 AND 3 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 20 AND 39 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 202 AND 203 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 220 AND 239 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =4 then '����������'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 40 AND 49 THEN '����������'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =5 then '�ɹ�Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 70 AND 79 THEN '�ɹ�Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =50 then '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 51 AND 59 THEN '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =60 then '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 62 AND 69 THEN '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =8 then '������ϢԱ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 80 AND 89 THEN '������ϢԱ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =9 then 'פ��ҩʦ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 90 AND 99 THEN 'פ��ҩʦ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 100 AND 130 then 'ҽ��'
    END AS �û���,
       count(*) as ����
FROM rrtuat_platform.sys_user_wechat_auth_log hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
WHERE auth_user_name IS NOT NULL
  AND length(auth_user_name) <= 8
  AND auth_user_name NOT REGEXP '[^0-9]' -- PostgreSQL ʹ�� ~ ������ REGEXP  !~ '[^0-9]'
  and date(hdr.create_dtme)=CURRENT_DATE
GROUP BY hdr.sub_unit_num_id,unit.sub_unit_name,auth_user_name,auth_login_name;



select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
from rrtuat_memorder.sd_bl_so_tml_hdr hdr
         left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.tenant_num_id = 18
  and hdr.data_sign = 0
  and hdr.status_num_id = 6
#   and hdr.order_date = date'2024-07-22'
#   and unit.sub_unit_num_id=1364
  and so_from_type = 17
  and tml_num_id='912144077821922'
;
select * from sd_bl_so_tml_hdr where tml_num_id='912144077821922';

select * from rrtuat_memorder.sd_bl_so_tml_hdr where order_date = date'2024-07-17';


SELECT hdr.sub_unit_num_id as �ŵ����, unit.sub_unit_name as �ŵ�����,auth_user_name AS ����, auth_login_name as �û������,
        CASE
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =1 then '�곤'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 10 AND 19 then '�곤'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 2 AND 3 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 20 AND 39 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 202 AND 203 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 220 AND 239 THEN '����'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =4 then '����������'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 40 AND 49 THEN '����������'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =5 then '�ɹ�Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 70 AND 79 THEN '�ɹ�Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =50 then '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 51 AND 59 THEN '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =60 then '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 62 AND 69 THEN '����Ա'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =8 then '������ϢԱ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 80 AND 89 THEN '������ϢԱ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) =9 then 'פ��ҩʦ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 90 AND 99 THEN 'פ��ҩʦ'
        WHEN CAST(RIGHT(auth_login_name, 3) AS SIGNED) BETWEEN 100 AND 130 then 'ҽ��'
    END AS �û���,
       count(*) as ����
FROM rrtuat_platform.sys_user_wechat_auth_log hdr
left join rrtuat_mdm.mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
WHERE auth_user_name IS NOT NULL
  AND length(auth_user_name) <= 8
  AND auth_user_name NOT REGEXP '[^0-9]' -- PostgreSQL ʹ�� ~ ������ REGEXP  !~ '[^0-9]'
  and date(hdr.create_dtme)=CURRENT_DATE
GROUP BY hdr.sub_unit_num_id,unit.sub_unit_name,auth_user_name