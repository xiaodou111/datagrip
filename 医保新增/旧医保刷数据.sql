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
  USING (SELECT ERP���ۺ�,����ʱ��,����,���֤��,ҽ�����ڵر��,���ڵ�����,�������� FROM (
            SELECT ERP���ۺ�,����ʱ��,����,���֤��,ҽ�����ڵر��,���ڵ�����,��������, ROW_NUMBER() OVER (PARTITION BY ���֤�� ORDER BY ����ʱ�� DESC) rn
           FROM v_ybjsjlberp WHERE ҽ�����ڵر�� IN (331004,331082,331002,331003,331024,331083,331081,331022,331099,331023) 
           AND ����ʱ�� between P_CurrentDate  
         AND P_CurrentDate+1) WHERE rn=1 ) b
         
  ON (a.IDCARD = b.���֤��)
  WHEN MATCHED THEN
    UPDATE SET
    a.saleno=b.ERP���ۺ�, 
    a.execdate=b.����ʱ��,
    a.CUSTOMER=b.����,
    a.CBDID=b.ҽ�����ڵر��,
    a.CBD=b.���ڵ�����,
    a.BUSNO=b.��������;
  COMMIT;
  
  P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

ALTER table d_zhyb_year_2022_temp add cbrylx VARCHAR2(200); 
