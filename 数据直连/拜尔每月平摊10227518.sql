DECLARE
  p_a NUMBER :=306;
  p_b NUMBER :=182;
  p_c NUMBER :=124;
  p_d NUMBER :=1217-306-182-124;
  v_numa NUMBER;
  v_numb NUMBER;
  v_numc NUMBER;
  v_numd NUMBER;
BEGIN
  --a
  SELECT COUNT(*) INTO
  v_numa FROM T_BAIER_BUS_grade WHERE  grade='A';
  WHILE p_a>=2*v_numa
  LOOP
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='A';
     p_a:= p_a-2*v_numa;
  END LOOP;
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='A' AND ID<=p_a/2;
  --B
  SELECT COUNT(*) INTO
  v_numb FROM T_BAIER_BUS_grade WHERE  grade='B';
  WHILE p_b>=2*v_numb 
  LOOP
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='B';
     p_b:= p_b-2*v_numb;
  END LOOP;
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='B' AND ID<=p_b/2; 
  
  --C
  SELECT COUNT(*) INTO
  v_numc FROM T_BAIER_BUS_grade WHERE  grade='C';
  WHILE p_c>=2*v_numc
  LOOP
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='C';
     p_c:= p_c-2*v_numc;
  END LOOP;
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='C' AND ID<=p_c/2;   
  --D
  SELECT COUNT(*) INTO
  v_numd FROM T_BAIER_BUS_grade WHERE  grade='D';
  WHILE p_d>=2*v_numd
  LOOP
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='D';
     p_d:= p_d-2*v_numd;
  END LOOP;
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,2,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='D' AND ID<=CEIL(p_d/2)-1; 
  INSERT INTO aaaa2 (busno,wareqty,wareid,status,TIME,grade)
      select orgname,1,10227518,0,TRUNC(SYSDATE, 'MM'),grade
      from T_BAIER_BUS_grade
      WHERE  grade='D' AND ID=CEIL(p_d/2); 
   
 
END;
SELECT * from aaaa2 WHERE status=0  
--DELETE from  aaaa2 WHERE status=0
