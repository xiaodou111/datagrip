declare

v_busi s_busi%rowtype;

begin
  

select * into v_busi from s_busi where busno=81001;
dbms_output.put_line('busno��'||v_busi.busno||',orgname:'||v_busi.orgname);
exception 
  when no_data_found then 
    dbms_output.put_line('û���ҵ�����');
  when too_many_rows then 
    dbms_output.put_line('���ض�������');
end;
