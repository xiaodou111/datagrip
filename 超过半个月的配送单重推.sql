INSERT INTO hd_msg_out
            (msg_id, fq_time, outer_msg_id, outer_timestamp, source_system, target_system, compid, table_type,
             status, trans_falg, error_times, error_lasttime, has_notify, http_code, msg, notes, createtime,
             createuser, billno, billcode)
            SELECT '10100000000151234149' AS msg_id, SYSDATE AS fq_time, '10100000000151234149' AS outer_msg_id,
                   to_char(SYSDATE, 'yyyymmddhh24miss') AS outer_timestamp, 'POS' AS source_system,
                   'SAP' AS target_system, 1000 AS compid, 1023 AS table_type, 0 AS status,
                   0 AS trans_falg, 0 AS error_times, NULL AS error_lasttime, 0 AS has_notify,
                   NULL AS http_code, NULL AS msg, NULL AS notes, SYSDATE AS createtime,
                   168 AS createuser, '22100500004898' AS billno, 'DSSM' AS billcode
            FROM   dual;
            
            SELECT * FROM hd_out_dist_dssm_h  where distno='22100500004898'
