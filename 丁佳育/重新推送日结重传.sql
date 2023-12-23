delete from hd_msg_out_bak
where msg_id in(

select msg_id from    hd_out_payee_check_h a  
   where a.checkno in ('23110564020962')

);


INSERT INTO hd_msg_out
      (msg_id, fq_time, outer_msg_id, outer_timestamp, source_system, target_system, compid, table_type,
       status, trans_falg, error_times, error_lasttime, has_notify, http_code, msg, notes, createtime,
       createuser, billno, billcode)

select msg_id AS msg_id, SYSDATE AS fq_time, msg_id AS outer_msg_id,
       to_char(SYSDATE, 'yyyymmddhh24miss') AS outer_timestamp, 'POS' AS source_system,
       'SAP' AS target_system, b.compid AS compid, 1041 AS table_type, 0 AS status,
       0 AS trans_falg, 0 AS error_times, NULL AS error_lasttime, 0 AS has_notify,
       NULL AS http_code, NULL AS msg, NULL AS notes, SYSDATE AS createtime,
       b.createuser AS createuser, b.checkno AS billno, 'PAY' AS billcode
from hd_out_payee_check_h a join t_payee_check_h b on a.checkno=b.checkno
where a.checkno in ('23110564020962')


create table temp_msg_out_bak(
checkno VARCHAR2(40)
)

select CHECKNO from temp_msg_out_bak for update
delete from  temp_msg_out_bak;


select * from temp_msg_out_bak for update
--select CHECKNO from temp_msg_out_bak
