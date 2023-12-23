DECLARE
   -- 声明一个数组来存放值列表
   v_values SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('81026','81124','81257','81499','85003','85045','85049','85055','85015','85004',
   '81125','81334','81148','81478','81086','81474','81248','81182','81274','81055','81282','81473','81368','85051','85048','81030');
   v_value VARCHAR2(100);

BEGIN
   -- 遍历值列表，对每个值调用存储过程
   FOR res IN (select busno from d_hs_busno)   LOOP
      
      -- 调用存储过程并传递当前的值
      CALL proc_sjzl_md_create_dtp('hs', res.busno, 'd_hs_ware_ty');
   END LOOP;
END;

CALL proc_sjzl_md_create_dtp('hs', 81026, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81124, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81257, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81499, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85003, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85045, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85049, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85055, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85015, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85004, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81125, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81334, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81148, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81478, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81086, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81474, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81248, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81182, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81274, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81055, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81282, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81473, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81368, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85051, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 85048, 'd_hs_ware_ty');
CALL proc_sjzl_md_create_dtp('hs', 81030, 'd_hs_ware_ty');



create table d_hs_busno (
busno number
)
delete from d_hs_busno
insert into d_hs_busno values(81026) 
