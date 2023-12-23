 DECLARE
    P_StartDate DATE :=DATE'2022-01-01';  -- number of rows to insert in each batch
   P_EndDate DATE :=DATE '2022-03-01';
   BatchSize NUMBER := 100000;
   P_CurrentDate DATE :=P_StartDate; 
   v_count NUMBER;   -- offset for each batch
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP 
 MERGE INTO d_zhyb_year_2022_temp a
  USING (SELECT ERP销售号,创建时间,姓名,身份证号,医保所在地编号,所在地名称,机构编码 FROM (
            SELECT ERP销售号,创建时间,姓名,身份证号,医保所在地编号,所在地名称,机构编码, ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 创建时间 DESC) rn
           FROM v_ybjsjlberp WHERE 医保所在地编号 IN (331004,331082,331002,331003,331024,331083,331081,331022,331099,331023) 
           AND 创建时间 between P_CurrentDate  
         AND P_CurrentDate+1) WHERE rn=1 ) b
         
  ON (a.IDCARD = b.身份证号)
  WHEN MATCHED THEN
    UPDATE SET
    a.saleno=b.ERP销售号, 
    a.execdate=b.创建时间,
    a.CUSTOMER=b.姓名,
    a.CBDID=b.医保所在地编号,
    a.CBD=b.所在地名称,
    a.BUSNO=b.机构编码;
  COMMIT;
  
  P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

ALTER table d_zhyb_year_2022_temp add cbrylx VARCHAR2(200); 
