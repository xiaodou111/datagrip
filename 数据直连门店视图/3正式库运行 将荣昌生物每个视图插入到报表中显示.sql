DECLARE
   -- 声明一个数组来存放值列表
   v_kk   varchar2(3000);
   v_kk1  varchar2(3000);
   v_kk2  varchar2(3000);
   v_orgname  varchar2(1000);
   v_values SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(

'81257', '81124', '81166', '81248', '81302', '81026', '81148', '81182',
    '81125', '81368', '81275', '81499', '81086', '81282', '85015', '83630',
    '83609', '84026');
   v_value VARCHAR2(100);
   
BEGIN
   -- 遍历值列表，对每个值调用存储过程
  
      FOR i IN 1..v_values.COUNT LOOP
      v_value := v_values(i);
      select SUBSTR(orgname, INSTR(orgname, '公司') + 2) 
      into v_orgname
      from s_busi where busno=v_value;
      --sfwy 0不是院外 1是院外   ZBORMD:1是门店,2是总部
v_kk := 'insert into t_sjzl_wh(ZLKMC,ZLKDM,CREATETIME,CGY,WATCH_USER,SFYW,ZBORMD) 
values (''荣昌生物-'|| v_orgname ||''',''v_sale_rcsw_'|| v_value ||''',sysdate,10003937,10003937,1,1)';
     --dbms_output.put_line(v_kk);
     execute immediate  v_kk ;

 END LOOP;
END;

select * from t_sjzl_wh where ZLKMC like '%荣昌生物%'
