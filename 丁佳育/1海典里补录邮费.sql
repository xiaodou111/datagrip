call proc_insert_o2o_sale('Z022',date'2023-12-07');

select * from d_saleno_temp



 /*DECLARE
 
 v_saleno t_sale_h.saleno%TYPE;
 BEGIN*/
   
 
 /*truncate table temp_sale_h_wdt;
    truncate table temp_sale_d_wdt;
    truncate table temp_sale_pay_wdt;*/
   -- select * from d_saleno_temp
   --delete from d_saleno_temp
   --delete from d_o2o_bf
  -- select busno,wareid, sl, je from d_o2o_bf for update;
  --delete from d_o2o_bf;
 /* update t_sale_h set accdate=date'2023-10-23' where saleno in ('2311071000119427','2311071000119428','2311071060119429','2311071060119430')
  delete from t_sale_h where saleno in ('2311071000119427','2311071000119428','2311071060119429','2311071060119430')
   delete from t_sale_h where saleno in (select saleno from d_saleno_temp)*/
   
    /*INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_sale_h');
    INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_sale_d');*/

/* FOR RES in (select a.busno, wareid, sl, je,s.compid
            from d_o2o_bf  a
             left join s_busi s on a.busno=s.busno
          
)loop
v_saleno := f_get_serial('SAL', RES.COMPID); 
 insert into d_saleno_temp(saleno) values(v_saleno);

INSERT INTO temp_sale_h_wdt
                (saleno, busno, posno, accdate, starttime, finaltime, payee, stdsum, netsum, loss,
                 membercardno, precash, compid, notes, source_wdt, wdt_saleno)
                SELECT v_saleno, res.busno, '001' AS posno, date'2023-10-25',
                       SYSDATE,SYSDATE, '168' AS payee,
                       res.JE,res.JE, 0 AS loss,
                       NULL AS membercardno, res.JE AS precash, res.compid, NULL AS notes,
                       1 AS source_wdt, null AS wdt_saleno
                FROM   dual;

INSERT INTO temp_sale_d_wdt
                    (saleno, rowno, busno, accdate, wareid, stallno, makeno, stdprice, netprice, minprice,
                     wareqty, groupid, saler, times, invalidate, minqty, stdtomin, distype, disno, purprice,
                     purtax, avgpurprice, batid, iszlzz, is_fdflag, saletax)
                    SELECT v_saleno, 1 AS rowno, res.busno, date'2023-10-25',
                           50000827, res.busno||11 AS stallno, '20230108' as makeno , res.je,/*rec_detail.sell_price*/
                         /*  res.je, 0 AS minprice,1,
                           NULL AS groupid, 168 AS saler, 1 AS times, date'2024-04-20', 0 AS minqty, 1 AS stdtomin,
                           1 AS distype, NULL AS disno, 0 AS purprice, 13 AS purtax,
                           res.je AS avgpurprice, '754621' as batid , 0 AS iszlzz, 0 AS is_fdflag,
                           13 AS saletax
                     FROM   dual;
                     

end loop;
   
 INSERT INTO temp_sale_pay_wdt
        (saleno, paytype, cardno, netsum, netsum_bak)
        SELECT h.saleno, 'Z022' AS paytype, NULL, h.netsum, h.netsum
        FROM   temp_sale_h_wdt h
        WHERE  EXISTS (SELECT 1 FROM temp_sale_d_wdt d WHERE d.saleno = h.saleno AND d.wareqty <> 0);
 
   



                     
--开始生成正式销售单！
    INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_sale_h');
    INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_sale_d');
    INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_sale_pay');
    INSERT INTO t_sale_h
        (saleno, busno, posno, accdate, starttime, finaltime, payee, discounter, crediter, returner,
         warranter1, warranter2, warranter3, warranter4, warranter5, stdsum, netsum, loss, membercardno,
         precash, stamp, shiftid, shiftdate, yb_saleno, compid, weather, doctorid, olshopid, olpickno, notes,
         pstplannos, register_no, srcsaleno, indentsource, ext_str1, ext_str2, ext_str3, ext_str4, ext_str5,
         ext_num1, ext_num2, ext_num3, ext_num4, ext_num5, ext_date1, ext_date2, ext_date3, printcount,
         is_comcfplatporm, doctor_rate, olbillcode, eccode, hdorderno, olorderno, upflag_honey, uptime_honey,
         cfno_honey, source_wdt, wdt_saleno)
        SELECT saleno, busno, posno, accdate, starttime, finaltime, payee, discounter, crediter, returner,
               warranter1, warranter2, warranter3, warranter4, warranter5, stdsum, netsum, loss, membercardno,
               precash, stamp, shiftid, shiftdate, yb_saleno, compid, weather, doctorid, olshopid, olpickno,
               notes, pstplannos, register_no, srcsaleno, indentsource, ext_str1, ext_str2, ext_str3, ext_str4,
               ext_str5, ext_num1, ext_num2, ext_num3, ext_num4, ext_num5, ext_date1, ext_date2, ext_date3,
               printcount, is_comcfplatporm, doctor_rate, olbillcode, eccode, hdorderno, olorderno,
               upflag_honey, uptime_honey, cfno_honey, source_wdt, wdt_saleno
        FROM   temp_sale_h_wdt
        WHERE  EXISTS
         (SELECT 1 FROM temp_sale_d_wdt d WHERE d.saleno = temp_sale_h_wdt.saleno AND d.wareqty <> 0);
    --生成明细
    INSERT INTO t_sale_d
        (saleno, rowno, busno, accdate, wareid, stallno, makeno, stdprice, netprice, minprice, wareqty,
         groupid, saler, times, invalidate, minqty, stdtomin, distype, disno, message, purprice, purtax,
         avgpurprice, ROWTYPE, insno, pile, saletax, storeqty, batid, isrestrict, medicationreminder, disrate,
         pstplanno, notintegral, resprice, stdminprice, batchno, idno, profit_flag, notes, uniteuseid, cfno,
         unite_rate, unite_netprice, ext_str1, ext_str2, ext_str3, ext_str4, ext_str5, ext_num1, ext_num2,
         ext_num3, ext_num4, ext_num5, ext_date1, ext_date2, ext_date3, multiple_integral, old_rowno,
         medphys_type, bindwareid, max_multiple_integral, uniteuseno, before_netprice, netamt, ext_str11,
         ext_str12, ext_str13, ext_str14, ext_str15, ext_str16, ext_str17, ext_num18, ext_num19, ext_num20,
         ext_num21, ext_num22, ext_date23, ext_date24, ext_date25, split_no, iszlzz)
        SELECT saleno, rowno, busno, accdate, wareid, stallno, makeno, stdprice, netprice, minprice, wareqty,
               groupid, saler, times, invalidate, minqty, stdtomin, distype, disno, message, purprice, purtax,
               avgpurprice, ROWTYPE, insno, pile, saletax, storeqty, batid, isrestrict, medicationreminder,
               disrate, pstplanno, notintegral, resprice, stdminprice, batchno, idno, profit_flag, notes,
               uniteuseid, cfno, unite_rate, unite_netprice, ext_str1, ext_str2, ext_str3, ext_str4, ext_str5,
               ext_num1, ext_num2, ext_num3, ext_num4, ext_num5, ext_date1, ext_date2, ext_date3,
               multiple_integral, old_rowno, medphys_type, bindwareid, max_multiple_integral, uniteuseno,
               before_netprice, netamt, ext_str11, ext_str12, ext_str13, ext_str14, ext_str15, ext_str16,
               ext_str17, ext_num18, ext_num19, ext_num20, ext_num21, ext_num22, ext_date23, ext_date24,
               ext_date25, split_no, iszlzz
        FROM   temp_sale_d_wdt
        WHERE  temp_sale_d_wdt.wareqty <> 0;
    --生成付款方式
    INSERT INTO t_sale_pay
        (saleno, paytype, cardno, netsum, netsum_bak, pricetype, ext_str1, ext_str2, ext_str3, ext_str4,
         ext_str5, ext_num1, ext_num2, ext_num3, ext_num4, ext_num5, ext_date1, ext_date2, ext_date3,
         cash_integral)
        SELECT saleno, paytype, cardno, netsum, netsum_bak, pricetype, ext_str1, ext_str2, ext_str3, ext_str4,
               ext_str5, ext_num1, ext_num2, ext_num3, ext_num4, ext_num5, ext_date1, ext_date2, ext_date3,
               cash_integral
        FROM   temp_sale_pay_wdt;
    DELETE tmp_disable_trigger WHERE table_name = 't_sale_h';
    DELETE tmp_disable_trigger WHERE table_name = 't_sale_d';
    DELETE tmp_disable_trigger WHERE table_name = 't_sale_pay';*/
   
    
    --END;
    /*select d.* from t_sale_h h
    join t_sale_d d on h.saleno=d.saleno
     where h.saleno in (select * from d_saleno_temp)*/
     
     /*select * from t_sale_h where saleno in('2310231000101742','2310231293073918');
select * from t_sale_d where saleno in('2310231000101742','2310231293073918');
select * from t_sale_pay where saleno in('2310231000101742','2310231293073918');*/
    
