      
   INSERT INTO hd_msg_out
                (msg_id, fq_time, outer_msg_id, outer_timestamp, source_system, target_system, compid,
                 table_type, status, trans_falg, error_times, error_lasttime, has_notify, http_code, msg,
                 notes, createtime, createuser, billno, billcode)
                SELECT '10100000000185993563' AS msg_id, SYSDATE AS fq_time, '10100000000185993563' AS outer_msg_id,
                       to_char(SYSDATE, 'yyyymmddhh24miss') AS outer_timestamp, 'POS' AS source_system,
                       'SAP' AS target_system, 1000 AS compid, 1030 AS table_type,
                       0 AS status, 0 AS trans_falg, 0 AS error_times, NULL AS error_lasttime, 0 AS has_notify,
                       NULL AS http_code, NULL AS msg, NULL AS notes, SYSDATE AS createtime, 168 AS createuser,
                       '10100000000185993563' AS billno, 'SAL' AS billcode
                FROM   dual;            
            
             select * from hd_out_sale_h where accdate>=date'2023-06-30' where busno='1543' and accdate=date'2023-07-09' 
             select * from hd_msg_out  where msg_id='10100000000185993563'

             dxzfcsad


sdasdsad


                                       sadsad