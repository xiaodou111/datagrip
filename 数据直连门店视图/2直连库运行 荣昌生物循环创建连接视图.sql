DECLARE
   -- 声明一个数组来存放值列表
   v_kk   varchar2(3000);
   v_values SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(

'81257', '81124', '81166', '81248', '81302', '81026', '81148', '81182',
    '81125', '81368', '81275', '81499', '81086', '81282', '85015', '83630',
    '83609', '84026');
   v_value VARCHAR2(100);
   
BEGIN
   -- 遍历值列表，对每个值调用存储过程
  
      FOR i IN 1..v_values.COUNT LOOP
      v_value := v_values(i);
v_kk := 'begin proc_sjzl_md_replace(''rcsw_' || v_value || '''); end;';
     execute immediate  v_kk ;
 END LOOP;
END;
