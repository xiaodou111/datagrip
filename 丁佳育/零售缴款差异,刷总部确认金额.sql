declare


begin
  

  MERGE INTO t_payee_check_d T1
            USING (select a.checkno,paytype from t_payee_check_d a,t_payee_check_h b where a.checkno=b.checkno and trunc(b.createdate) between date'2023-10-25' and date'2023-10-25' 
                    and b.status=1 

                     and not exists(select 1 from t_busno_bank_paydetails c where c.compid=b.compid and c.use_busno=b.busno and trunc(c.usedate)=trunc(b.createdate) 
                                    and a.paytype=c.payment_method and trunc(c.usedate) between date'2023-10-25' and date'2023-10-25'  )
                    --and a.amt_confirm<>0 
                    ) T2
            ON ( T1.checkno=T2.checkno and T1.paytype=T2.paytype)
            WHEN MATCHED THEN
                UPDATE SET T1.amt_confirm = 0;

           
           for upd in (SELECT date'2023-10-25'+ROWNUM-1 as accdate FROM DUAL CONNECT BY ROWNUM<=trunc(date'2023-10-25' -date'2023-10-25')+1 ) loop


            --调整为每次获取一天的总部确认金额
            MERGE INTO t_payee_check_d d
            USING (SELECT d.rowno, d.checkno, nvl(c.busno_payamt, 0) AS busno_payamt
                   FROM   (SELECT a.compid, a.use_busno, a.payment_method, trunc(a.usedate) as usedate,
                                   SUM(a.busno_payamt) AS busno_payamt
                            FROM   t_busno_bank_paydetails a
                            WHERE  trunc(a.usedate) = trunc(upd.accdate) AND a.is_jr = 1
                            GROUP  BY a.compid, a.use_busno, a.payment_method, trunc(a.usedate)) c
                   INNER  JOIN (SELECT b.rowno, b.checkno, h.compid, h.busno,
                                      trunc(h.createdate) as createdate, b.paytype
                               FROM   t_payee_check_d b
                               LEFT   JOIN t_payee_check_h h
                               ON     b.checkno = h.checkno
                               WHERE  h.checkbit1 = 1 AND h.status = 1 AND
                                      trunc(h.createdate) = trunc(upd.accdate)) d
                   ON     c.compid = d.compid AND c.use_busno = d.busno AND c.usedate = d.createdate AND
                          c.payment_method = d.paytype) x
            ON (d.checkno = x.checkno AND d.rowno = x.rowno)
            WHEN MATCHED THEN
                UPDATE SET d.amt_confirm = x.busno_payamt;


          end loop upd;
          

                          
end;                        
                      --  select * from   t_busno_bank_paydetails 
                   /*   select a.checkno,paytype from t_payee_check_d a,t_payee_check_h b where a.checkno=b.checkno and  b.checkno='23102536270290' and trunc(b.createdate) between date'2023-10-25' and date'2023-10-25'
                      and b.status=1 

                     and not exists(select 1 from t_busno_bank_paydetails c where c.compid=b.compid and c.use_busno=b.busno and trunc(c.usedate)=trunc(b.createdate) 
                                    and a.paytype=c.payment_method and trunc(c.usedate) between date'2023-10-25' and date'2023-10-25'  )
                    and a.amt_confirm<>0 */
