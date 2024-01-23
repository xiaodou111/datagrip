
DECLARE
   type namesarray IS VARRAY(5) OF VARCHAR2(10);
   type grades IS VARRAY(5) OF INTEGER;
   names namesarray;
   marks grades;
   total integer;
BEGIN
   names := namesarray('Kavita', 'Pritam', 'Ayan', 'Rishav', 'Aziz');
   marks:= grades(98, 97, 78, 87, 92);
   total := names.count; -- 获取数组元素的个数
   dbms_output.put_line('Total '|| total || ' Students.');
   FOR i in 1 .. total LOOP
      dbms_output.put_line('Student: ' || names(i) || 'Marks: ' || marks(i));
   END LOOP;
END;



DECLARE
   -- 声明一个数组来存放值列表
   v_values SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(

'81257', '81124', '81166', '81248', '81302', '81026', '81148', '81182',
    '81125', '81368', '81275', '81499', '81086', '81282', '85015', '83630',
    '83609', '84026');
   v_value VARCHAR2(100);

BEGIN
   -- 遍历值列表，对每个值调用存储过程

      FOR i IN 1..v_values.COUNT LOOP
      v_value := v_values(i);
      -- 调用存储过程并传递当前的值
      begin proc_sjzl_md_create_dtp('rcsw', v_value, 'd_ware_rcsw_ty@zhilian') ; end;
   END LOOP;
END;