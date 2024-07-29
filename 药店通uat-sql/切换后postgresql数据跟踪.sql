--1门店登录量
select log.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sys_user_wechat_auth_log log
left join mdms_o_sub_unit unit on log.sub_unit_num_id = unit.sub_unit_num_id
where date(log.create_dtme)=CURRENT_DATE
group by log.sub_unit_num_id, unit.sub_unit_name;
--2机台登录量
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称,computer_name as 计算机名 ,count(*) as 数量
from sys_user_wechat_auth_log hdr
left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where LENGTH(computer_name) = 7
and date(hdr.create_dtme)=CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name,computer_name;
--3用户登录量
SELECT hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称,auth_user_name AS 工号, count(*) as 数量
FROM sys_user_wechat_auth_log hdr
left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
WHERE auth_user_name IS NOT NULL
  AND length(auth_user_name) <= 8
  AND auth_user_name ~ '^[0-9]+$' -- PostgreSQL 使用 ~ 而不是 REGEXP  !~ '[^0-9]'
  and date(hdr.create_dtme)=CURRENT_DATE
GROUP BY hdr.sub_unit_num_id,unit.sub_unit_name,auth_user_name;
--4零售销售单
select sub_unit_num_id as 门店编码, sub_unit_name as 门店名称, count(*) as 数量
from (select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
      from sd_bl_so_tml_hdr hdr
               left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
      where hdr.order_date = CURRENT_DATE) a
group by sub_unit_num_id, sub_unit_name
--5零售销售单退单
select sub_unit_num_id as 门店编码, max(sub_unit_name) as 门店名称, count(*) as 数量
from (select hdr.sub_unit_num_id, unit.sub_unit_name, hdr.tml_num_id, hdr.create_dtme
      from sd_bl_so_tml_hdr hdr
               left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
      WHERE type_num_id = 2
        and hdr.order_date = CURRENT_DATE
-- and not exists(select 1 from sd_bl_so_op_cf_hdr cf where hdr.sub_unit_num_id=cf.sub_unit_num_id)
     ) a
group by sub_unit_num_id;

--6医保销售单据量
select hdr.sub_unit_num_id as 门店编码, sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_tml_hdr hdr
         left join fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, sub_unit_name;

--7医保销售单退单
select hdr.sub_unit_num_id as 门店编码, sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_tml_hdr hdr
         left join fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and hdr.type_num_id = 2
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, sub_unit_name;

--8O2O转单量
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_tml_hdr hdr
         left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where hdr.tenant_num_id = 18
  and hdr.data_sign = 0
  and hdr.status_num_id = 6
  and hdr.order_date = CURRENT_DATE
  and so_from_type = 17
group by hdr.sub_unit_num_id, unit.sub_unit_name;
--9诊所开方
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_op_cf_hdr hdr
         left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where unit.shop_category = 4
  and date(hdr.create_dtme) = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
--10诊所销售
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_tml_hdr hdr
         left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where unit.shop_category = 4
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
--11药店非医保处方
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_tml_hdr_rx hdr
         left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
         left join fi_bl_cash_dtl dtl on hdr.tml_num_id = dtl.reserved_no
where dtl.pay_type_id not in ('531', '523', '521', '524', '525', '522')
  and hdr.order_date = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
--12药店医保外配处方
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_so_op_cf_hdr hdr
         left join fi_bl_cash_dtl dtl on hdr.cf_sale_no = dtl.reserved_no
         left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where external_flag = 1
  and dtl.pay_type_id in ('531', '523', '521', '524', '525', '522')
  and unit.shop_category <> 4
  and date(hdr.create_dtme) = CURRENT_DATE
group by hdr.sub_unit_num_id, unit.sub_unit_name;
--13日结对账
select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称, count(*) as 数量
from sd_bl_dayend_reconciliation_hdr hdr
left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
group by hdr.sub_unit_num_id, unit.sub_unit_name;
---14 第三种带上角色名
SELECT hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称,auth_user_name AS 工号,auth_login_name as 用户组编码,
        CASE
         WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) = 1 THEN '店长'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 10 AND 19 then '店长'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 2 AND 3 THEN '收银'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 20 AND 39 THEN '收银'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 202 AND 203 THEN '收银'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 220 AND 239 THEN '收银'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) =4 then '质量负责人'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 40 AND 49 THEN '质量负责人'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) =5 then '采购员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 70 AND 79 THEN '采购员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) =50 then '养护员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 51 AND 59 THEN '养护员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) =60 then '验收员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 62 AND 69 THEN '验收员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) =8 then '诊所信息员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 80 AND 89 THEN '诊所信息员'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) =9 then '驻店药师'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 90 AND 99 THEN '驻店药师'
        WHEN CAST(SUBSTRING(auth_login_name FROM '[^0-9]*([0-9]{3})$') AS INTEGER) BETWEEN 100 AND 130 then '医生'
    END AS 用户组,
       count(*) as 数量
FROM sys_user_wechat_auth_log hdr
left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
WHERE auth_user_name IS NOT NULL
  AND length(auth_user_name) <= 8
  AND auth_user_name ~ '^[0-9]+$' -- PostgreSQL 使用 ~ 而不是 REGEXP  !~ '[^0-9]'
  and date(hdr.create_dtme)=CURRENT_DATE
GROUP BY hdr.sub_unit_num_id,unit.sub_unit_name,auth_user_name,auth_login_name


select computer_name as 计算机名, count(*) as 数量
FROM sys_user_wechat_auth_log
where LENGTH(computer_name) = 7
group by computer_name;

select hdr.sub_unit_num_id as 门店编码, unit.sub_unit_name as 门店名称,computer_name as 计算机名 ,count(*)
from sys_user_wechat_auth_log hdr
left join mdms_o_sub_unit unit on hdr.sub_unit_num_id = unit.sub_unit_num_id
where LENGTH(computer_name) = 7
group by hdr.sub_unit_num_id, unit.sub_unit_name,computer_name;


