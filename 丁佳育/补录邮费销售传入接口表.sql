declare


 v_sqlcode    VARCHAR2(4000);
    v_sqlerrm    VARCHAR2(4000);
    v_table_type hd_msg_in.table_type%TYPE := 1030;
    --v_cnt        PLS_INTEGER;
    v_msg_id hd_msg_out.msg_id%TYPE;
    v_seq_id hd_out_sale_h.seq_id%TYPE;
    insert_count NUMBER;
    i number:=0;
BEGIN
  

 FOR rec_sale IN (SELECT a.saleno,b.busno, b.md_busno, trunc(a.accdate) AS accdate, MAX(a.compid) AS compid
                     FROM   t_sale_h a
                     LEFT   JOIN s_busi b
                     ON     a.compid = b.compid AND a.busno = b.busno
                     WHERE /* a.accdate > trunc(to_date('2021-03-19', 'yyyy-mm-dd') - 1) AND
                            a.accdate < trunc(to_date('2021-03-21', 'yyyy-mm-dd') + 1)*/
                           a.saleno in (
                           select saleno from d_saleno_temp a )
                     GROUP  BY b.busno, b.md_busno, trunc(a.accdate),a.saleno) LOOP
                     
BEGIN
           SAVEPOINT sp_sal;
            --插入接口消息表
            v_msg_id := to_char(hd_msg_out_s.nextval);

            INSERT INTO hd_msg_out
                (msg_id, fq_time, outer_msg_id, outer_timestamp, source_system, target_system, compid,
                 table_type, status, trans_falg, error_times, error_lasttime, has_notify, http_code, msg,
                 notes, createtime, createuser, billno, billcode)
                SELECT v_msg_id AS msg_id, SYSDATE AS fq_time, v_msg_id AS outer_msg_id,
                       to_char(SYSDATE, 'yyyymmddhh24miss') AS outer_timestamp, 'POS' AS source_system,
                       'SAP' AS target_system, rec_sale.compid AS compid, v_table_type AS table_type,
                       0 AS status, 0 AS trans_falg, 0 AS error_times, NULL AS error_lasttime, 0 AS has_notify,
                       NULL AS http_code, NULL AS msg, NULL AS notes, SYSDATE AS createtime, 168 AS createuser,
                       v_msg_id AS billno, 'SAL' AS billcode
                FROM   dual;
                
               insert_count:=SQL%ROWCOUNT ;

   -- 使用DBMS_OUTPUT.PUT_LINE输出插入的行数
  -- DBMS_OUTPUT.PUT_LINE('hd_msg_out插入了 ' || i || ' 行数据'||'msg_id:'||v_msg_id);
    i:=i+1;
            --插入接口主表
            v_seq_id := to_char(hd_out_sale_h_s.nextval);

            INSERT INTO hd_out_sale_h
                (msg_id, seq_id, fq_time, zid, msg_status, msg, compid, busno, accdate, lsno, additional1,
                 additional2, additional3, flag)
                SELECT v_msg_id AS msg_id, v_seq_id AS seq_id, SYSDATE AS fq_time, v_seq_id AS zid,
                       0 AS msg_status, NULL AS msg, rec_sale.compid, rec_sale.md_busno, rec_sale.accdate,
                       v_seq_id AS lsno, NULL AS additional1, NULL AS additional2, NULL AS additional3, 1
                FROM   dual;
             insert_count:=SQL%ROWCOUNT ;

   -- 使用DBMS_OUTPUT.PUT_LINE输出插入的行数
   --DBMS_OUTPUT.PUT_LINE('hd_out_sale_h插入了 ' || i || ' 行数据');

            --插入接口明细表
            INSERT INTO hd_out_sale_d
                (msg_id, seq_id, seq_detail_id, fq_time, warecode, iszlzz, wareqty, netsum, additional1,
                 additional2, additional3, sap_batid, indentsource)
                SELECT msg_id, seq_id, to_char(hd_out_sale_h_s.nextval) AS seq_detail_id, fq_time, warecode,
                       iszlzz, wareqty, netsum, additional1, additional2, additional3, sap_batid, indentsource
                FROM   (SELECT v_msg_id AS msg_id, v_seq_id AS seq_id, NULL AS seq_detail_id,
                                SYSDATE AS fq_time, c.warecode AS warecode, decode(h.busno,83093,1,81421,1,nvl(d.iszlzz, 0)) AS iszlzz,
                                SUM(round((d.wareqty + d.minqty / nvl(d.stdtomin, 1)) * d.times, 3)) AS wareqty,
                                SUM(nvl(d.netamt,
                                         round((d.wareqty * d.times * d.netprice +
                                                d.minqty * d.times * d.minprice), 2))) AS netsum,
                                NULL AS additional1, NULL AS additional2, NULL AS additional3,
                                nvl(b.sap_batid, 'NONE') AS sap_batid, h.indentsource
                         FROM   t_sale_h h, t_sale_d d
                         LEFT   JOIN t_store_i b
                         ON     b.compid = rec_sale.compid AND d.wareid = b.wareid AND d.batid = b.batid
                         LEFT   JOIN t_ware_base c
                         ON     d.wareid = c.wareid
                         WHERE  h.saleno = d.saleno and h.saleno=rec_sale.saleno --旺店通零售不传SAP
                         GROUP  BY c.warecode, decode(h.busno,83093,1,81421,1,nvl(d.iszlzz, 0)), nvl(b.sap_batid, 'NONE'), h.indentsource)
                WHERE  wareqty <> 0 OR netsum <> 0;
                
                 insert_count:=SQL%ROWCOUNT ;

   -- 使用DBMS_OUTPUT.PUT_LINE输出插入的行数
   DBMS_OUTPUT.PUT_LINE('hd_out_sale_d插入了 ' || i || ' 行数据');
   insert into d_bl_saleno values(rec_sale.saleno,v_msg_id) ;
            
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO sp_sal;
                v_sqlcode := to_char(SQLCODE);
                v_sqlerrm := to_char(SQLERRM);

                --记录错误信息被查
                MERGE INTO d_sale_errmsg a
                USING (SELECT rec_sale.busno AS busno, rec_sale.accdate AS accdate FROM dual) b
                ON (a.busno = b.busno AND a.accdate = b.accdate)
                WHEN MATCHED THEN
                    UPDATE SET a.errmsg = v_sqlerrm, a.errlastdate = SYSDATE, a.errortimes = a.errortimes + 1
                WHEN NOT MATCHED THEN
                    INSERT
                        (busno, accdate, errmsg, errlastdate, errortimes)
                    VALUES
                        (b.busno, b.accdate, v_sqlerrm, SYSDATE, 0);

        END;

    --COMMIT;
    END LOOP;
    
end;
/*select * from hd_msg_out where msg_id='10100000000201391743' -- fq_time between trunc(sysdate) and trunc(sysdate)+1;
select trunc(sysdate)-2,trunc(sysdate) from dual;
select * from hd_out_sale_h where fq_time between trunc(sysdate) and trunc(sysdate)+1;
select * from hd_out_sale_h where msg_id='10100000000201391743';
select * from hd_out_sale_d where msg_id='10100000000201391743';*/

-- delete from d_sale_errmsg where busno=81161 and accdate=date'2023-10-23';
-- delete from d_saleno_temp a where not exists (select saleno from d_bl_saleno b where a.saleno=b.saleno) ; 
--delete from   d_bl_saleno
--select * from d_bl_saleno
--delete from d_bl_saleno where saleno='2310231000101389'
--select * from t_sale_d where saleno in (select saleno from d_saleno_temp) and busno in (81102,81450) ;

--2310231000101390
