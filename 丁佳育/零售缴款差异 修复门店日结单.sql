declare
/*���۽ɿ���� �޸��ŵ��սᵥ*/
v_cnt number(1);

begin
     --��Ҫ�ĵ��ŵ�������d_payee_check_temp
    --cproc_check_repirmxԭ�洢����
     


     for pychk in ( select checkno,busno,compid,createdate as accdate  from t_payee_check_h where checkno in 
       (select checkno from d_payee_check_temp) ) loop

        delete from t_payee_check_d where  checkno=pychk.checkno ;

      -- ������ϸ
        INSERT INTO t_payee_check_d
        (checkno,rowno,paytype,netsum,paymentsum,divesum,
         rechargeamt,amt_confirm,advance_payment_amt,advance_deposit_amt,is_pay_interface)

        select pychk.checkno,row_number() over(order by paytype) rowno, paytype, SUM(netsum), SUM(paymentsum), SUM(divesum),
               SUM(rechargeamt), case when MAX(is_pay_interface) = 1 then SUM(netsum) else 0.00 end  AS amt_confirm,SUM(advance_payment_amt), 0.00 AS advance_deposit_amt, MAX(is_pay_interface)
        from V_PAYEE_CHECK
        where busno =pychk.busno  and( trunc(accdate) = trunc(pychk.accdate) or trunc(accdate)  = date'9999-01-01') group by paytype,busno ;

     end loop pychk;

 


end;
