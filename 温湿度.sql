DECLARE
v_refrigerator NUMBER;
v_STORE NUMBER;
v_Shaded NUMBER;
i NUMBER;
j NUMBER;
k NUMBER;
BEGIN
  --insert into d_bus_wsdsb values(83315,3,3,3); 
  DELETE from d_bus_wsdsb_2;
FOR res IN (SELECT busno,refrigerator,store,shaded FROM d_bus_wsdsb) 
  LOOP
SELECT  res.refrigerator INTO v_refrigerator FROM d_bus_wsdsb WHERE busno=res.busno;
SELECT res.store INTO v_STORE FROM d_bus_wsdsb WHERE busno=res.busno;
SELECT res.shaded INTO v_Shaded FROM d_bus_wsdsb WHERE busno=res.busno;
i:=1;
WHILE i<=v_refrigerator
  LOOP
    INSERT INTO d_bus_wsdsb_2 (busno, area)
    SELECT busno, CONCAT('±ùÏä-',i) AS name
    FROM d_bus_wsdsb WHERE busno=res.busno;
    i:=i+1;
  END LOOP;
j:=1;
WHILE j<=v_STORE
  LOOP
    INSERT INTO d_bus_wsdsb_2 (busno, area)
    SELECT busno, CONCAT('µêÌÃ-',j) AS name
    FROM d_bus_wsdsb WHERE busno=res.busno;
    j:=j+1;
  END LOOP;  
k:=1;
WHILE k<=v_Shaded
  LOOP
    INSERT INTO d_bus_wsdsb_2 (busno, area)
    SELECT busno, CONCAT('ÒõÁ¹Çø-',k) AS name
    FROM d_bus_wsdsb WHERE busno=res.busno;
    k:=k+1;
  END LOOP;
  END LOOP;
  /*UPDATE D_BUS_WSDSB_2 SET area='ÒõÁ¹Çø' WHERE busno IN(SELECT busno FROM ( SELECT busno,SUM(CASE WHEN  area LIKE '%ÒõÁ¹Çø%' THEN 1 ELSE 0 END) AS NUM 
FROM D_BUS_WSDSB_2 GROUP BY busno ) WHERE NUM=1) AND area='ÒõÁ¹Çø-1';
UPDATE D_BUS_WSDSB_2 SET area='±ùÏä' WHERE busno IN(SELECT busno FROM ( SELECT busno,SUM(CASE WHEN  area LIKE '%±ùÏä%' THEN 1 ELSE 0 END) AS NUM 
FROM D_BUS_WSDSB_2 GROUP BY busno ) WHERE NUM=1) AND area='±ùÏä-1';
UPDATE D_BUS_WSDSB_2 SET area='µêÌÃ' WHERE busno IN(SELECT busno FROM ( SELECT busno,SUM(CASE WHEN  area LIKE '%µêÌÃ%' THEN 1 ELSE 0 END) AS NUM 
FROM D_BUS_WSDSB_2 GROUP BY busno ) WHERE NUM=1) AND area='µêÌÃ-1';*/
INSERT INTO d_bus_wsdsb_3
 SELECT busno, area, ROW_NUMBER() OVER (PARTITION BY busno ORDER BY area) AS id
FROM d_bus_wsdsb_2;
DELETE from  d_bus_wsdsb_2;
INSERT INTO d_bus_wsdsb_2 SELECT * FROM d_bus_wsdsb_3; 
DELETE from d_bus_wsdsb_3;
END;
--SELECT * from d_bus_wsdsb_2
--SELECT * from  d_bus_wsdsb_2 WHERE busno=81124

/*SELECT * from d_bus_wsdsb_2 WHERE busno=83049
SELECT compid FROM s_BUsi WHERE busno=81338
SELECT * from t_hygro_annal WHERE 
DELETE from  d_bus_wsdsb
SELECT * from d_bus_wsdsb FOR UPDATE
UPDATE d_bus_wsdsb SET  REFRIGERATOR=REFRIGERATOR+2,STORE=STORE+2,SHADED=SHADED+2
SELECT * from d_bus_wsdsb_3
DELETE from d_bus_wsdsb_3*/
-- 
--SELECT * from d_bus_wsdsb_2 WHERE busno =81154

--SELECT busno FROM d_bus_wsdsb_2 group by busno
 
