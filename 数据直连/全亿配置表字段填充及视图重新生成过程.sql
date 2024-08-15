-- 厂家名匹配nwareid
select factory, LISTAGG(nwareid, ',') WITHIN GROUP (ORDER BY nwareid) AS nwareid_list
from d_sjzl_cjware group by factory;

--厂家名匹配覆盖busnos
MERGE INTO d_rrt_sjzl_config T1
USING
(
SELECT factory, LISTAGG(busno, ',') WITHIN GROUP (ORDER BY busno) AS busno_list
FROM d_sjzl_cjbusno where factory<>'诺华'
GROUP BY factory
)  T2
ON ( T1.zlcj=T2.factory)
WHEN MATCHED THEN
UPDATE SET T1.BUSNOS= T2.busno_list;

-- 遍历d_rrt_sjzl_config表的生成所有总部特药视图
BEGIN
   -- 遍历值列表，对每个值调用存储过程
   FOR res IN (select VIEW_NAME from d_rrt_sjzl_config where ZLCJ not in ('罗氏','阿斯利康','爱而开'))   LOOP

      -- 调用存储过程并传递当前的值
       proc_sjzl_accept_create(res.VIEW_NAME);
       proc_sjzl_kc_create(res.VIEW_NAME);
       proc_sjzl_sale_create(res.VIEW_NAME);
   END LOOP;
END;


--遍历d_rrt_sjzl_config表的busnos生成所有门店视图
BEGIN
   -- 遍历值列表，对每个值调用存储过程
   FOR res IN (select VIEW_NAME from d_rrt_sjzl_config )   LOOP

      -- 调用存储过程并传递当前的值
       proc_sjzl_md_create_dtp(res.VIEW_NAME);
   END LOOP;
END;


--查找所有厂家的门店视图
SELECT config.ZLCJ as 厂家名,a.view_name as 视图名称,substr(a.view_name,-4) as 门店编码,unit.SUB_UNIT_NAME as 门店名称
--      ,lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
FROM all_views a
 left join qyzt_dev.mdms_o_sub_unit unit
   -- DDM内部同步工具，字段长度不能超过30位，这个用qyzt_dev
   on  substr(view_name,-4)=unit.sub_unit_num_id
left join d_rrt_sjzl_config config on config.VIEW_NAME=lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_ty.*$', 'i')   and SUB_UNIT_NAME not like '%医保%'
order by config.ZLCJ;