DECLARE
    P_StartDate DATE :=DATE'2023-01-01';  -- number of rows to insert in each batch
   P_EndDate DATE :=DATE '2023-01-03';
   BatchSize NUMBER := 100000;
   P_CurrentDate DATE :=P_StartDate; 
   v_count NUMBER;   -- offset for each batch
BEGIN
   WHILE P_CurrentDate < P_EndDate
    LOOP
      INSERT INTO d_zhyb_year_2023
         
            SELECT 销售日期,姓名,身份证号,参保地编码,参保地,busno,ERP销售单号,参保人员类别
           FROM v_zhybjsjlb WHERE 参保地 LIKE '台州%' AND 销售日期 between P_CurrentDate
         AND P_CurrentDate+1
          
         ;  -- limit number of rows to insert
        COMMIT; 
    /*  SELECT COUNT(*) INTO v_count FROM d_zhyb_year_2023;
    IF v_count >= BatchSize THEN
      COMMIT;
    END IF;  */
      
      -- exit loop when no more rows to insert
      P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

--delete from d_zhyb_year_2023 where execdate>=date'2023-01-01'
