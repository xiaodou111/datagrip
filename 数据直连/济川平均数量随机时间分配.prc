create or replace procedure proc_jc_pjfp

is
-----济川的平均分配


v_numa NUMBER(8);
v_numb NUMBER(8);
v_numc NUMBER(8);

v_cnt NUMBER;
i NUMBER :=1;
v_days NUMBER;--:=31;
v_seq NUMBER;
v_date DATE;
P_StartDate DATE :=DATE'2022-01-01';  -- number of rows to insert in each batch
P_EndDate DATE :=DATE '2022-12-01';
P_CurrentDate DATE :=P_StartDate; 
begin

--SELECT EXTRACT(DAY FROM LAST_DAY(MONTH)) AS days FROM d_jc_busno FROM d_jc_busno;

 ---循环分配    配送 数量
 DELETE from  d_jc_busno WHERE sl=0;
 WHILE P_CurrentDate <= P_EndDate 
   LOOP
     select to_char(last_day(P_CurrentDate),'dd') 
     INTO v_days
     from dual;
     DBMS_OUTPUT.PUT_LINE('v_days: ' || v_days); 
 for res in (SELECT BUSNO,WAREID,ORGNAME,MONTH,SL
             FROM   d_jc_busno  WHERE MONTH=P_CurrentDate
             ) 
              loop
   IF res.sl<=3 THEN 
   INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,res.sl);
   END IF;
   
   IF res.sl>3 AND res.sl<=10  THEN 
   select ceil(res.sl*0.35) 
   into v_numa
   from dual;
   SELECT  ceil(res.sl*0.35)
   into v_numb
   from dual;
   select res.sl-v_numa-v_numb  
   into v_numc
   from dual;
   INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numa);
   INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numb);
   INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numc); 
   END  IF ;
   
   
   i:=1;
   IF res.sl>10 AND res.sl<=90 THEN
     SELECT ceil(res.sl/3)
     INTO v_cnt 
     FROM dual;
     
     SELECT res.sl/v_cnt 
     INTO v_numa 
     FROM dual;
     SELECT res.sl-v_numa*(v_cnt-1)
     INTO v_numb
     FROM dual;
     
     WHILE i<v_cnt LOOP 
    /* DBMS_OUTPUT.PUT_LINE('i: ' || i); 
     DBMS_OUTPUT.PUT_LINE('wareid: ' || res.wareid); 
     DBMS_OUTPUT.PUT_LINE('busno: ' || res.busno); */
     
     INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numa);
     i:= i + 1;     
     
     END LOOP;  
     INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numb);
     
    END IF;
    
    IF res.sl>90 THEN 
    SELECT ceil(res.sl/v_days) --select ceil(124/31) from  dual  --4
    INTO v_numa 
    FROM dual;
    SELECT MOD(res.sl,v_days)
    INTO v_seq
    FROM dual;
    --如果刚好被日期整除,就不用-1
    IF v_seq<>0 THEN
    WHILE i<=v_seq LOOP
     INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numa);
     i:= i + 1;     
     END LOOP;
     WHILE i<=v_days LOOP
     INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numa-1); 
     i:= i + 1;  
     END LOOP; 
    END IF;
    IF v_seq=0 THEN
     WHILE i<=v_days LOOP
     INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numa); 
     i:= i + 1;  
     END LOOP; 
    END IF; 
     
    END IF;
     
     /*LOOP
     DBMS_OUTPUT.PUT_LINE('i: ' || i); 
     DBMS_OUTPUT.PUT_LINE('wareid: ' || res.wareid); 
     DBMS_OUTPUT.PUT_LINE('busno: ' || res.busno); 
     INSERT INTO d_jc_sale_pj(BUSNO,WAREID,ORGNAME,MONTH,SL) VALUES(res.busno,res.wareid,res.orgname,res.month,v_numa);
     i:= i + 1; 
     
     COMMIT;
     EXIT WHEN i =v_cnt;      
 END LOOP; */
     
 end loop ;
 
 DELETE from d_jc_sale_pj WHERE sl=0;


--生成随机时间 
 for res in (select busno, wareid,orgname, month, sl from d_jc_sale_pj WHERE month=P_CurrentDate) loop

IF  to_char(res.month,'YYYY-MM-DD')='2022-02-01' then
  SELECT res.month +
       round(DBMS_RANDOM.VALUE(0,27))+ ROUND(DBMS_RANDOM.VALUE(7.5/24, 20/24), 10)
 into  v_date
FROM dual;
elsif  to_char(res.month,'YYYY-MM-DD') in ('2022-01-01','2022-03-01','2022-05-01','2022-07-01','2022-08-01','2022-10-01','2022-12-01') then
SELECT res.month +
       round(DBMS_RANDOM.VALUE(0,30))+ ROUND(DBMS_RANDOM.VALUE(7.5/24, 20/24), 10)
 into  v_date
 FROM dual;
 ELSE
SELECT res.month +
       round(DBMS_RANDOM.VALUE(0,29))+ ROUND(DBMS_RANDOM.VALUE(7.5/24, 20/24), 10)
 into  v_date
FROM dual;
 END IF; 

  
      insert into D_JC_sale_sj(busno, wareid,orgname, month, sl)
      select res.busno,res.wareid,res.orgname,v_date,res.sl from dual;
   
   end loop ;
   
   P_CurrentDate := add_months(P_CurrentDate,+1);
END LOOP;
 end ;
/
