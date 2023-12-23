DECLARE
    P_StartDate DATE :=DATE'2022-01-01';  -- number of rows to insert in each batch
   P_EndDate DATE :=DATE '2022-02-23';
   BatchSize NUMBER := 100000;
   P_CurrentDate DATE :=P_StartDate; 
   v_count NUMBER;   -- offset for each batch
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP
      INSERT INTO d_yb_first_cus(
      erpsaleno, 
receiptdate, 
busno, 
saler, 
username, 
customername, 
identityno, 
nb_flag, 
cbd, 
cbdname, 
netsum, 
status, 
yg_flag, 
jslx

      )
       select ERP���ۺ�,����ʱ��,��������,d.saler,su.username,����,���֤��,
case when nvl(��Ա���,' ') in ('2511','40','41','2811','52') then '1' else '0' END AS yblx,
ҽ�����ڵر��,
���ڵ�����,�ܽ��,2 AS status, 
case when info.COMPANYNAME like '%������%' or info.COMPANYNAME like '%����%' or info.COMPANYNAME like '%��ͬ��%'
 or info.COMPANYNAME like '%��ʢ��%' then 1 else 0 end yg_flag,
case when nvl(��������,' ')='1' then '1' when nvl(��������,' ') in('33','34','39') then '2' else '0' END
 AS jslx
from tmp_wlybjs_cyb a
INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
a.ERP���ۺ�=d.saleno
left join s_user_base su on d.saler=su.userid
join hydee_taizhou.taizhou_personal_info info on info.IDNUMBER=a.���֤��
WHERE a.����ʱ�� BETWEEN P_CurrentDate AND P_CurrentDate+1
AND SUBSTR(ͳ��������,1,6)=ҽ�����ڵر��
    ;
          -- limit number of rows to insert
        COMMIT; 
      
      
      -- exit loop when no more rows to insert
      P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

