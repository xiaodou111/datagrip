-- ������ƥ��nwareid
select factory, LISTAGG(nwareid, ',') WITHIN GROUP (ORDER BY nwareid) AS nwareid_list
from d_sjzl_cjware group by factory;

--������ƥ�串��busnos
MERGE INTO d_rrt_sjzl_config T1
USING
(
SELECT factory, LISTAGG(busno, ',') WITHIN GROUP (ORDER BY busno) AS busno_list
FROM d_sjzl_cjbusno where factory<>'ŵ��'
GROUP BY factory
)  T2
ON ( T1.zlcj=T2.factory)
WHEN MATCHED THEN
UPDATE SET T1.BUSNOS= T2.busno_list;

-- ����d_rrt_sjzl_config������������ܲ���ҩ��ͼ
BEGIN
   -- ����ֵ�б���ÿ��ֵ���ô洢����
   FOR res IN (select VIEW_NAME from d_rrt_sjzl_config where ZLCJ not in ('����','��˹����','������'))   LOOP

      -- ���ô洢���̲����ݵ�ǰ��ֵ
       proc_sjzl_accept_create(res.VIEW_NAME);
       proc_sjzl_kc_create(res.VIEW_NAME);
       proc_sjzl_sale_create(res.VIEW_NAME);
   END LOOP;
END;


--����d_rrt_sjzl_config���busnos���������ŵ���ͼ
BEGIN
   -- ����ֵ�б���ÿ��ֵ���ô洢����
   FOR res IN (select VIEW_NAME from d_rrt_sjzl_config )   LOOP

      -- ���ô洢���̲����ݵ�ǰ��ֵ
       proc_sjzl_md_create_dtp(res.VIEW_NAME);
   END LOOP;
END;


--�������г��ҵ��ŵ���ͼ
SELECT config.ZLCJ as ������,a.view_name as ��ͼ����,substr(a.view_name,-4) as �ŵ����,unit.SUB_UNIT_NAME as �ŵ�����
--      ,lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
FROM all_views a
 left join qyzt_dev.mdms_o_sub_unit unit
   -- DDM�ڲ�ͬ�����ߣ��ֶγ��Ȳ��ܳ���30λ�������qyzt_dev
   on  substr(view_name,-4)=unit.sub_unit_num_id
left join d_rrt_sjzl_config config on config.VIEW_NAME=lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_ty.*$', 'i')   and SUB_UNIT_NAME not like '%ҽ��%'
order by config.ZLCJ;