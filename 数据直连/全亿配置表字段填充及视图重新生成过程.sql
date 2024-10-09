-- 厂家名匹配nwareid
select factory, LISTAGG(nwareid, ',') WITHIN GROUP (ORDER BY nwareid) AS nwareid_list
from d_sjzl_cjware group by factory;

--厂家名匹配覆盖busnos
MERGE INTO d_rrt_sjzl_config T1
USING
(
SELECT factory, LISTAGG(busno, ',') WITHIN GROUP (ORDER BY busno) AS busno_list
FROM d_sjzl_cjbusno where factory='诺华'
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

-- 视图导入网站 导出来后需要替换表头
select row_number() over (order by ZLCJ) 行号,ZLCJ||'-仓库'||VIEWTYPE as 栏目名称,'是' as 是否启用,
       '金鑫辉/./莫晓慧/./颜江仪/./潘雷/./杨仁' as 允许查看, '全亿中间库' as 数据库名称 , VIEW_NAME as 数据库视图名
from v_sjzl_ck_view ;

select row_number() over (order by ZLCJ) 行号,ZLCJ||'-门店'||VIEWTYPE as 栏目名称,'是' as 是否启用,
       '金鑫辉/./莫晓慧/./颜江仪/./杨仁' as 允许查看, '全亿中间库' as 数据库名称 , VIEW_NAME as 数据库视图名
from v_sjzl_md_view ;


select * from v_sjzl_ck_view;
select * from v_sjzl_md_view where VIEWTYPE='库存';

select * from V_ASLK_TY_KC_MD_5045;
--查找所有厂家的门店视图
select 厂家名, 视图名称, 门店编码, 类型, 门店名称
from (
SELECT config.ZLCJ as 厂家名,a.view_name as 视图名称,substr(a.view_name,-4) as 门店编码,
       case
           when a.view_name like '%ACCEPT%' THEN '采购'
           when a.view_name like '%KC%' THEN '库存'
           when a.view_name like '%SALE%' THEN '配送'
           else '纯销'
           end as 类型,
       unit.SUB_UNIT_NAME as 门店名称
--      ,lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
FROM all_views a
 left join qyzt_dev.mdms_o_sub_unit unit
   -- DDM内部同步工具，字段长度不能超过30位，这个用qyzt_dev
   on  substr(view_name,-4)=unit.sub_unit_num_id
left join d_rrt_sjzl_config config on config.VIEW_NAME=lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_ty.*$', 'i')   and SUB_UNIT_NAME not like '%医保%'
union all
--查询桐乡门店视图
SELECT config.ZLCJ as 厂家名, a.view_name as 视图名称, substr(a.view_name, -4) as 门店编码,
       case
           when a.view_name like '%ACCEPT%' THEN '采购'
           when a.view_name like '%KC%' THEN '库存'
           when a.view_name like '%SALE%' THEN '配送'
           else '纯销'
           end as 类型,unit.SUB_UNIT_NAME as 门店名称
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
    -- DDM内部同步工具，字段长度不能超过30位，这个用qyzt_dev
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TX') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_tx.*$', 'i') and SUB_UNIT_NAME not like '%医保%'
  and config.ZLCJ like '%桐乡%');




--查询总部普药特药合并视图
select * from (
SELECT config.ZLCJ as 厂家名, a.view_name as 视图名称, WERKS as 商业编码,
       case SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1)
           when 'ACCEPT' THEN '采购'
           when 'KC' THEN '库存'
           when 'SALE' THEN '配送'
           else '纯销'
           end as 视图类型,
       f_get_sjzl_pjzd(WERKS, 'MDMS_O_CORT', 'CORT_NUM_ID', 'CORT_NAME') as 商业名称
--        f_get_sjzl_pjzd(WAREID, 'mdms_p_product_basic', 'ITEM_NUM_ID', 'ITEM_NAME') as 商品名称
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'PY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_py.*$', 'i') and unit.SUB_UNIT_NAME is null
  and SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1) <> '5051'
--   and config.ZLCJ like '%雅培%'
union all
SELECT config.ZLCJ as 厂家名, a.view_name as 视图名称, WERKS as 公司名,
       case SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1)
           when 'ACCEPT' THEN '采购'
           when 'KC' THEN '库存'
           when 'SALE' THEN '配送'
           else '纯销'
           end as 视图类型,
       f_get_sjzl_pjzd(WERKS, 'MDMS_O_CORT', 'CORT_NUM_ID', 'CORT_NAME') as 商业名称
--        f_get_sjzl_pjzd(WAREID, 'mdms_p_product_basic', 'ITEM_NUM_ID', 'ITEM_NAME') as 商品名称
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_ty.*$', 'i') and unit.SUB_UNIT_NAME is null
  and SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1) <> '5051'
--   and config.ZLCJ like '%阿斯利康%'
)
--          order by 厂家名
where 厂家名 like '%博%';



--查询桐乡总部视图
SELECT config.ZLCJ as 厂家名, a.view_name as 视图名称, WERKS as 公司编码,
       case SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1)
           when 'ACCEPT' THEN '采购'
           when 'KC' THEN '库存'
           when 'SALE' THEN '配送'
           else '纯销'
           end as 视图类型,
       f_get_sjzl_pjzd(WERKS, 'MDMS_O_CORT', 'CORT_NUM_ID', 'CORT_NAME') as 商业名称
--        f_get_sjzl_pjzd(WAREID, 'mdms_p_product_basic', 'ITEM_NUM_ID', 'ITEM_NAME') as 商品名称
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TX') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_tx.*$', 'i') and unit.SUB_UNIT_NAME is null
  and SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1) <> '5051'
  and config.ZLCJ like '%桐乡%'
order by config.ZLCJ;