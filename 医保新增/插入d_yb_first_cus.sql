DECLARE
    P_StartDate DATE :=DATE'2023-01-01';  -- number of rows to insert in each batch
   P_EndDate DATE :=DATE '2023-05-08';
   BatchSize NUMBER := 100000;
   P_CurrentDate DATE :=P_StartDate; 
   v_count NUMBER;   -- offset for each batch
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP
      INSERT INTO d_yb_first_cus
         SELECT a.erpsaleno,a.RECEIPTDATE,h.busno,d.saler,su.username,a.customername,a.IDENTITYNO,
    case when a.ext_char01 like '%居民%' OR a.ext_char01 like '%学%' OR a.ext_char01 like '%新生儿%' then 1 else 0 end nb_flag,
    a.ext_char12 AS 参保地,cbd.classname,h.netsum,2 AS status,
    case when a.ext_char04 like '%瑞人堂%' or a.ext_char04 like '%康康%' or a.ext_char04 like '%方同仁%'
    or a.ext_char04 like '%康盛堂%' then  1 else 0 end yg_flag,
    case when zd.code_name is null then b.MEDTYPE else zd.code_name end as jslx,a.orderno
    FROM
    t_yby_order_h a
    INNER JOIN t_sale_h h ON
    a.erpsaleno=h.saleno
    INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
    h.saleno=d.saleno
    left join s_user_base su on d.saler=su.userid
    LEFT join d_cbd cbd ON a.ext_char12= cbd.cbd
    left join s_busi s on s.busno=h.busno
     left join v_pros_order_receipt_list b    on a.orderno = b.orderno and b.orderstatus not in('0','1','4','7') 
    left join d_yb_zdlx zd on zd.type='jzlx' and b.MEDTYPE=trim(zd.code)
    WHERE a.RECEIPTDATE =P_CurrentDate;
          -- limit number of rows to insert
        COMMIT; 
      
      
      -- exit loop when no more rows to insert
      P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;

