DECLARE
    p_minday DATE ;  -- number of rows to insert in each batch
    p_maxday DATE;
    p_currentdate DATE ;
  
      -- offset for each batch
BEGIN
  SELECT TRUNC(MIN(zdate)),TRUNC(MAX(zdate))
    INTO p_minday, p_maxday
    FROM d_zddb_xqsp_dr;
  p_currentdate :=p_minday;
   WHILE p_currentdate<=p_maxday
    LOOP
   BEGIN
  INSERT INTO d_sqgz_sale_temp(
  saleno,accdate,FINALTIME,busno,zdate,srcbusno,wareid,makeno,saler,stdprice,netprice,salenum,drnum,total_sales,rn
  )
  SELECT
    saleno, ACCDATE,FINALTIME,BUSNO,zdate, srcbusno,WAREID,makeno, SALER, STDPRICE, NETPRICE, 卖出数量, 调入数量,
    SUM(卖出数量) OVER (PARTITION BY  zdate,srcbusno,busno,wareid,makeno ORDER BY rn) AS total_sales,rn
  FROM (
  SELECT h.saleno,h.accdate,FINALTIME,h.busno,dr.zdate,dr.srcbusno,d.wareid,d.makeno,d.saler,d.STDPRICE,d.netprice,d.wareqty 卖出数量,dr.wareqty 调入数量,
row_number() OVER(partition BY dr.zdate,dr.srcbusno,h.busno,d.wareid,dr.makeno ORDER BY h.FINALTIME ) rn
FROM t_sale_d d
JOIN t_sale_h h   ON h.saleno=d.saleno
JOIN d_zddb_xqsp_dr dr ON dr.objbusno=d.busno AND d.makeno=dr.makeno AND d.wareid=dr.wareid
 WHERE h.accdate>dr.zdate AND dr.zdate BETWEEN  p_currentdate AND p_currentdate+1 AND h.accdate>=p_minday
 --AND h.busno=81525 AND d.wareid=10111607
  );
  COMMIT; 
  
  EXCEPTION
      -- 捕获异常并记录错误信息
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
        -- 终止循环
        EXIT;
     END ;
  DBMS_OUTPUT.PUT_LINE('p_currentdate: ' || p_currentdate); 
    DBMS_LOCK.SLEEP(1);
    p_currentdate := p_currentdate + 1;
   END LOOP;
END;
