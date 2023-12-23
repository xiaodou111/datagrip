BEGIN
    /*
    创建时间：20201111
    创建人：徐田成-2571
    业务场景：用于批量汇总门店银行缴款明细表金额，匹配同步至已一审未二审的日结对账单*/
 

        begin
          
            SAVEPOINT sp_dis;
            
             --20210819 CXD 把银行缴款明细外的收款方式清零          
            MERGE INTO t_payee_check_d T1
            USING (select a.checkno,paytype from t_payee_check_d a,t_payee_check_h b where a.checkno=b.checkno and 
                     b.checkno in (select checkno from d_payee_check_temp)
            ) T2
            ON ( T1.checkno=T2.checkno and T1.paytype=T2.paytype)
            WHEN MATCHED THEN
                UPDATE SET T1.amt_confirm = 0;

           
           for upd in (SELECT p_begindate+ROWNUM-1 as accdate FROM DUAL CONNECT BY ROWNUM<=trunc(p_enddate -p_begindate)+1 ) loop


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
                               WHERE  h.checkbit1 = 1 AND h.status = 0 AND
                                      trunc(h.createdate) = trunc(upd.accdate)) d
                   ON     c.compid = d.compid AND c.use_busno = d.busno AND c.usedate = d.createdate AND
                          c.payment_method = d.paytype) x
            ON (d.checkno = x.checkno AND d.rowno = x.rowno)
            WHEN MATCHED THEN
                UPDATE SET d.amt_confirm = x.busno_payamt;


          end loop upd;
          
          
        exception 
         when OTHERS then --default错误时
             ROLLBACK TO sp_dis; --回滚保存点之后所有数据
             return;
        end;
        
  commit;
  
END proc_busnobank_to_amt_confirm;
