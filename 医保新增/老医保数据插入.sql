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
       select ERP销售号,创建时间,机构编码,d.saler,su.username,姓名,身份证号,
case when nvl(人员类别,' ') in ('2511','40','41','2811','52') then '1' else '0' END AS yblx,
医保所在地编号,
所在地名称,总金额,2 AS status, 
case when info.COMPANYNAME like '%瑞人堂%' or info.COMPANYNAME like '%康康%' or info.COMPANYNAME like '%方同仁%'
 or info.COMPANYNAME like '%康盛堂%' then 1 else 0 end yg_flag,
case when nvl(就诊类型,' ')='1' then '1' when nvl(就诊类型,' ') in('33','34','39') then '2' else '0' END
 AS jslx
from tmp_wlybjs_cyb a
INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
a.ERP销售号=d.saleno
left join s_user_base su on d.saler=su.userid
join hydee_taizhou.taizhou_personal_info info on info.IDNUMBER=a.身份证号
WHERE a.创建时间 BETWEEN P_CurrentDate AND P_CurrentDate+1
AND SUBSTR(统筹区编码,1,6)=医保所在地编号
    ;
          -- limit number of rows to insert
        COMMIT; 
      
      
      -- exit loop when no more rows to insert
      P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

