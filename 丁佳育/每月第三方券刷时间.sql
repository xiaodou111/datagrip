insert into tmp_disable_trigger(table_name) values ('t_cash_coupon_info');
update t_cash_coupon_info  set issuing_date=use_date,create_busno=use_busnos,createtime=use_date
where banktype is not null and trunc(use_date) between date'2023-11-01' and date'2023-11-30'and advance_payamt<>0;
