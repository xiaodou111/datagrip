SELECT t_excel_set.excelno,
       t_excel_set.dataname,
       t_excel_set.compid,
       t_excel_set.createuser,
       t_excel_set.createtime,
       t_excel_set.lastmodify,
       t_excel_set.lasttime,
       t_excel_set.notes,
       t_excel_set.file_format,
       t_excel_set.middle_table,
       t_excel_set.middle_status,
       t_excel_set.validated_proc,
       t_excel_set.validated_status,
       t_excel_set.switch_proc,
       t_excel_set.switch_status,
       t_excel_set.emplate_name,
       t_excel_set.datastore,
       t_excel_set.start_row,
       t_excel_set.is_transition
 FROM t_excel_set  t_excel_set
 WHERE t_excel_set.isenabled = 1 
 AND  exists (select 1 from d_excel_user  kk WHERE userid =10002055  and t_excel_set.excelno=kk.excelno) 
 and (  t_excel_set.dataname like '%商品供应商导入%'  )
 
 
 
 select * from t_excel_set where  
 select * from d_excel_user where userid =10002055
 insert into d_excel_user(excelno, userid, notes) values('00225','10002055',null) 
 update d_excel_user set excelno='00226' where excelno='00225'
 select * from t_excel_set where dataname like '%商品供应商导入%'
