--�ܴ洢����proc_sale_sum_all_new���ÿ�����ó���ִ��һ��
call proc_rpt_sale_new(date'2023-12-07',date'2023-12-07');
    commit;
call    proc_rpt_sale_pos_new(date'2023-12-07',date'2023-12-07');
    commit;
call    proc_rpt_sale_saler_new(date'2023-12-07',date'2023-12-07');
    commit;
 call   proc_rpt_sale_saler_pc(date'2023-12-07',date'2023-12-07');
    commit;
call    proc_rpt_sale_memcard_new(date'2023-12-07',date'2023-12-07');
    commit;
 call   proc_rpt_sale_memcard_sum_new(date'2023-12-07',date'2023-12-07');
    commit;
 call   proc_rpt_sale_payee_new(date'2023-12-07',date'2023-12-07');
    commit;
 call   proc_rpt_sale_shift_new(date'2023-12-07',date'2023-12-07');
    commit;
 call   proc_rpt_sale_pay_new(date'2023-12-07',date'2023-12-07');
    commit;

  call  p_store_limit_busno_new();
    commit;
  call  cproc_busi_sale_job();
    commit;
    --��Ա����
  call  cproc_auto_memcard();
    commit;
--���˵�
   call cproc_rpt_sum_all_jmd();
    commit;
    
    begin
    proc_busno_tj(date'2023-12-07',date'2023-12-07');
    end;
