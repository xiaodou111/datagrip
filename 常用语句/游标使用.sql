
DECLARE 
   c_busno s_busi.busno%type;
   c_ORGNAME s_busi.ORGNAME%type;
   c_SALEGROUPID s_busi.SALEGROUPID%type;
   CURSOR c_busi is
      SELECT busno, ORGNAME, SALEGROUPID FROM s_busi where busno<81020 order by busno;
BEGIN
   OPEN c_busi;
   LOOP
   FETCH c_busi into c_busno, c_ORGNAME, c_SALEGROUPID;
      EXIT WHEN c_busi%notfound;
      dbms_output.put_line(c_busno || ' ' || c_ORGNAME || ' ' || c_SALEGROUPID);
   END LOOP;
   CLOSE c_busi;
   end;

