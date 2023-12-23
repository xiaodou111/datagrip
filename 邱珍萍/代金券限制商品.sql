select * from t_cash_coupon_limit
declare 
v_values SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(

1010,1020,1030,1040,1050,1070);
   v_compid VARCHAR2(100);

begin
  FOR i IN 1..v_values.COUNT LOOP
      v_compid := v_values(i);
   insert into t_cash_coupon_limit select v_compid,BUSNO,BUSNOS,WAREID,sysdate,10003475,FLAG from t_cash_coupon_limit where compid=1000;   
  end loop;
end;
