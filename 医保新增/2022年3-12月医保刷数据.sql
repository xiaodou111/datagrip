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
  USING (SELECT ERP���۵���,��������,����,���֤��,�α��ر���,�α���,BUSNO FROM (
            SELECT ERP���۵���,��������,����,���֤��,�α��ر���,�α���,BUSNO, ROW_NUMBER() OVER (PARTITION BY ���֤�� ORDER BY �������� DESC) rn
           FROM v_zhybjsjlb WHERE �α��ر��� IN (331004,331082,331002,331003,331024,331083,331081,331022,331099,331023) 
           AND �������� between P_CurrentDate  
         AND P_CurrentDate+1) WHERE rn=1 ) b
         
  ON (a.IDCARD = b.���֤�� AND a.saleno=b.ERP���۵���)
  WHEN MATCHED THEN
    UPDATE SET
     
    a.execdate=b.��������,
    a.CUSTOMER=b.����,
    a.CBDID=b.�α��ر���,
    a.CBD=b.�α���,
    a.BUSNO=b.BUSNO;
  COMMIT;
  
  P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

--ALTER table d_zhyb_year_2022 add saleno VARCHAR2(50); 
