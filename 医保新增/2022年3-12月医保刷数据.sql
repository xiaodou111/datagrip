 DECLARE
    P_StartDate DATE :=DATE'2022-03-01';  -- number of rows to insert in each batch
   P_EndDate DATE :=DATE '2022-12-31';
   BatchSize NUMBER := 100000;
   P_CurrentDate DATE :=P_StartDate; 
   v_count NUMBER;   -- offset for each batch
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP 
 MERGE INTO d_zhyb_year_2022 a
  USING (SELECT ERP销售单号,销售日期,姓名,身份证号,参保地编码,参保地,BUSNO FROM (
            SELECT ERP销售单号,销售日期,姓名,身份证号,参保地编码,参保地,BUSNO, ROW_NUMBER() OVER (PARTITION BY 身份证号 ORDER BY 销售日期 DESC) rn
           FROM v_zhybjsjlb WHERE 参保地编码 IN (331004,331082,331002,331003,331024,331083,331081,331022,331099,331023) 
           AND 销售日期 between P_CurrentDate  
         AND P_CurrentDate+1) WHERE rn=1 ) b
         
  ON (a.IDCARD = b.身份证号 AND a.saleno=b.ERP销售单号)
  WHEN MATCHED THEN
    UPDATE SET
     
    a.execdate=b.销售日期,
    a.CUSTOMER=b.姓名,
    a.CBDID=b.参保地编码,
    a.CBD=b.参保地,
    a.BUSNO=b.BUSNO;
  COMMIT;
  
  P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

--ALTER table d_zhyb_year_2022 add saleno VARCHAR2(50); 
