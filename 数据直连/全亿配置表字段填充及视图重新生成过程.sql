-- ������ƥ��nwareid
select factory, LISTAGG(nwareid, ',') WITHIN GROUP (ORDER BY nwareid) AS nwareid_list
from d_sjzl_cjware group by factory;

--������ƥ�串��busnos
MERGE INTO d_rrt_sjzl_config T1
USING
(
SELECT factory, LISTAGG(busno, ',') WITHIN GROUP (ORDER BY busno) AS busno_list
FROM d_sjzl_cjbusno where factory='ŵ��'
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

-- ��ͼ������վ ����������Ҫ�滻��ͷ
select row_number() over (order by ZLCJ) �к�,ZLCJ||'-�ֿ�'||VIEWTYPE as ��Ŀ����,'��' as �Ƿ�����,
       '���λ�/./Ī����/./�ս���/./����/./����' as ����鿴, 'ȫ���м��' as ���ݿ����� , VIEW_NAME as ���ݿ���ͼ��
from v_sjzl_ck_view ;

select row_number() over (order by ZLCJ) �к�,ZLCJ||'-�ŵ�'||VIEWTYPE as ��Ŀ����,'��' as �Ƿ�����,
       '���λ�/./Ī����/./�ս���/./����' as ����鿴, 'ȫ���м��' as ���ݿ����� , VIEW_NAME as ���ݿ���ͼ��
from v_sjzl_md_view ;


select * from v_sjzl_ck_view;
select * from v_sjzl_md_view where VIEWTYPE='���';

select * from V_ASLK_TY_KC_MD_5045;
--�������г��ҵ��ŵ���ͼ
select ������, ��ͼ����, �ŵ����, ����, �ŵ�����
from (
SELECT config.ZLCJ as ������,a.view_name as ��ͼ����,substr(a.view_name,-4) as �ŵ����,
       case
           when a.view_name like '%ACCEPT%' THEN '�ɹ�'
           when a.view_name like '%KC%' THEN '���'
           when a.view_name like '%SALE%' THEN '����'
           else '����'
           end as ����,
       unit.SUB_UNIT_NAME as �ŵ�����
--      ,lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
FROM all_views a
 left join qyzt_dev.mdms_o_sub_unit unit
   -- DDM�ڲ�ͬ�����ߣ��ֶγ��Ȳ��ܳ���30λ�������qyzt_dev
   on  substr(view_name,-4)=unit.sub_unit_num_id
left join d_rrt_sjzl_config config on config.VIEW_NAME=lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_ty.*$', 'i')   and SUB_UNIT_NAME not like '%ҽ��%'
union all
--��ѯͩ���ŵ���ͼ
SELECT config.ZLCJ as ������, a.view_name as ��ͼ����, substr(a.view_name, -4) as �ŵ����,
       case
           when a.view_name like '%ACCEPT%' THEN '�ɹ�'
           when a.view_name like '%KC%' THEN '���'
           when a.view_name like '%SALE%' THEN '����'
           else '����'
           end as ����,unit.SUB_UNIT_NAME as �ŵ�����
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
    -- DDM�ڲ�ͬ�����ߣ��ֶγ��Ȳ��ܳ���30λ�������qyzt_dev
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TX') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_tx.*$', 'i') and SUB_UNIT_NAME not like '%ҽ��%'
  and config.ZLCJ like '%ͩ��%');




--��ѯ�ܲ���ҩ��ҩ�ϲ���ͼ
select * from (
SELECT config.ZLCJ as ������, a.view_name as ��ͼ����, WERKS as ��ҵ����,
       case SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1)
           when 'ACCEPT' THEN '�ɹ�'
           when 'KC' THEN '���'
           when 'SALE' THEN '����'
           else '����'
           end as ��ͼ����,
       f_get_sjzl_pjzd(WERKS, 'MDMS_O_CORT', 'CORT_NUM_ID', 'CORT_NAME') as ��ҵ����
--        f_get_sjzl_pjzd(WAREID, 'mdms_p_product_basic', 'ITEM_NUM_ID', 'ITEM_NAME') as ��Ʒ����
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'PY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_py.*$', 'i') and unit.SUB_UNIT_NAME is null
  and SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1) <> '5051'
--   and config.ZLCJ like '%����%'
union all
SELECT config.ZLCJ as ������, a.view_name as ��ͼ����, WERKS as ��˾��,
       case SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1)
           when 'ACCEPT' THEN '�ɹ�'
           when 'KC' THEN '���'
           when 'SALE' THEN '����'
           else '����'
           end as ��ͼ����,
       f_get_sjzl_pjzd(WERKS, 'MDMS_O_CORT', 'CORT_NUM_ID', 'CORT_NAME') as ��ҵ����
--        f_get_sjzl_pjzd(WAREID, 'mdms_p_product_basic', 'ITEM_NUM_ID', 'ITEM_NAME') as ��Ʒ����
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TY') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_ty.*$', 'i') and unit.SUB_UNIT_NAME is null
  and SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1) <> '5051'
--   and config.ZLCJ like '%��˹����%'
)
--          order by ������
where ������ like '%��%';



--��ѯͩ���ܲ���ͼ
SELECT config.ZLCJ as ������, a.view_name as ��ͼ����, WERKS as ��˾����,
       case SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1)
           when 'ACCEPT' THEN '�ɹ�'
           when 'KC' THEN '���'
           when 'SALE' THEN '����'
           else '����'
           end as ��ͼ����,
       f_get_sjzl_pjzd(WERKS, 'MDMS_O_CORT', 'CORT_NUM_ID', 'CORT_NAME') as ��ҵ����
--        f_get_sjzl_pjzd(WAREID, 'mdms_p_product_basic', 'ITEM_NUM_ID', 'ITEM_NAME') as ��Ʒ����
FROM all_views a
         left join qyzt_dev.mdms_o_sub_unit unit
                   on substr(view_name, -4) = unit.sub_unit_num_id
         left join d_rrt_sjzl_config config
                   on config.VIEW_NAME = lower(SUBSTR(a.view_name, 1, INSTR(a.view_name, 'TX') + 1))
WHERE REGEXP_LIKE(a.view_name, '^v_.+?_tx.*$', 'i') and unit.SUB_UNIT_NAME is null
  and SUBSTR(a.view_name, INSTR(a.view_name, '_', -1) + 1) <> '5051'
  and config.ZLCJ like '%ͩ��%'
order by config.ZLCJ;