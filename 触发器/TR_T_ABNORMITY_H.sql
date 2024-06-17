create trigger TR_T_ABNORMITY_H
    before update
    on T_ABNORMITY_H
    for each row
DECLARE

     v_newavgprice         t_store_h.storepurprice%TYPE;

     v_disable_trigger_ind PLS_INTEGER;

     v_adjustno            t_adjust_stall_h.adjustno%TYPE;

     v_count               PLS_INTEGER;

 BEGIN

     SELECT COUNT(*) INTO v_disable_trigger_ind FROM tmp_disable_trigger WHERE table_name = 't_abnormity_h';

     IF v_disable_trigger_ind > 0 THEN

         RETURN;

     END IF;

     IF :old.status IN (1, 2) THEN

         raise_application_error(-20001, '已生效或作废的单据不允许操作！', TRUE);

     END IF;

     --审核通过

     IF :new.status = 1 AND :old.status = 0 THEN

         --add by cc 20160707 单据生效时更新会计日期

         --20161111,为生效时间

         /*if :new.account_date is null then

           :new.account_date := trunc(sysdate);

         end if;*/

         :new.account_date := f_get_account_date(:new.compid); --trunc(SYSDATE);



         DELETE FROM t_await_store_ware w

         WHERE  w.billcode = nvl(:new.billcode, 'ABN') AND w.billno = :new.abnormityno;



         INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_abnormity_d');

         FOR rec IN (SELECT d.wareid, d.batid, d.stallno, d.wareqtya, d.wareqtyb, d.purprice, d.rowno

                     FROM   t_abnormity_d d

                     WHERE  d.abnormityno = :new.abnormityno) LOOP



             IF (rec.wareqtyb - rec.wareqtya) > 0 THEN

                 UPDATE t_store_d d

                 SET    d.awaitqty = d.awaitqty - (rec.wareqtyb - rec.wareqtya)

                 WHERE  d.compid = :new.compid AND d.busno = :new.busno AND d.wareid = rec.wareid AND

                        d.stallno = rec.stallno AND d.batid = rec.batid;

             END IF;



             proc_ware_entry(SYSDATE, :new.compid, :new.busno, nvl(:new.billcode, 'ABN'), :new.abnormityno,

                             rec.rowno, rec.wareid, rec.batid, rec.stallno, 1, rec.wareqtya - rec.wareqtyb,

                             rec.purprice, NULL, v_newavgprice);

             --同步最新批次进价

             UPDATE t_abnormity_d d

             SET    d.avgpurprice = v_newavgprice,

                    d.purprice   =

                    (SELECT i.purprice FROM t_store_i i WHERE i.batid = d.batid AND i.wareid = d.wareid),

                    d.tran_status = 1

             WHERE  d.abnormityno = :new.abnormityno AND d.rowno = rec.rowno;



         END LOOP;

         DELETE FROM tmp_disable_trigger WHERE table_name = 't_abnormity_d';



         --往抽送检结果表里面插入资料

         IF :new.billcode = 'SCK' THEN

             INSERT INTO t_abnormity_d_notes

                 (abnormityno, batid, stallno, wareid, rowno)

                 SELECT t.abnormityno, t.batid, t.stallno, t.wareid, t.rowno

                 FROM   t_abnormity_d t

                 WHERE  t.abnormityno = :new.abnormityno;

         END IF;



         SELECT COUNT(*)

         INTO   v_count

         FROM   t_abnormity_d

         WHERE  abnormityno = :new.abnormityno AND wareqtya - wareqtyb > 0 AND length(newstallno) > 0;

         IF v_count > 0 THEN

             SELECT f_get_serial(in_billcode => 'STL', in_org_code => :new.busno) INTO v_adjustno FROM dual;

             INSERT INTO t_adjust_stall_h

                 (adjustno, compid, busno, ownerid, createuser, createtime, lastmodify, lasttime, checkbit1,

                  checkbit2, checkbit3, checkbit4, checkbit5, billcode, status)

             VALUES

                 (v_adjustno, :new.compid, :new.busno, :new.ownerid, :new.createuser, :new.createtime,

                  :new.lastmodify, :new.lasttime, 0, 0, 0, 0, 0, 'STL', 0);



             INSERT INTO t_adjust_stall_d

                 (adjustno, rowno, wareid, purprice, purtax, batid, srcstallno, objstallno, wareqty,

                  invalidate, makeno, factoryid, makedate)

                 SELECT v_adjustno, rownum, wareid, purprice, purtax, batid, stallno, newstallno,

                        wareqtya - wareqtyb, invalidate, makeno, factoryid, makedate

                 FROM   t_abnormity_d

                 WHERE  abnormityno = :new.abnormityno AND wareqtya - wareqtyb > 0 AND length(newstallno) > 0;



             UPDATE t_adjust_stall_h h

             SET    h.checker1   = :new.checker1,

                    h.checker2   = :new.checker2,

                    h.checkbit1  = 1,

                    h.checkbit2  = 1,

                    h.checkdate1 = SYSDATE,

                    h.checkdate2 = SYSDATE,

                    h.execdate   = SYSDATE,

                    h.status     = 1

             WHERE  h.adjustno = v_adjustno;

         END IF;



     END IF;



     --作废

     IF :new.status = 2 AND :old.status = 0 THEN



         MERGE INTO t_store_d d

         USING (SELECT SUM(a.wareqtyb - a.wareqtya) wareqty, a.wareid, a.batid, a.stallno

                FROM   t_abnormity_d a

                WHERE  a.abnormityno = :new.abnormityno AND a.wareqtyb - a.wareqtya > 0

                GROUP  BY a.abnormityno, a.wareid, a.batid, a.stallno) t

         ON (d.compid = :new.compid AND d.busno = :new.busno AND d.wareid = t.wareid AND d.batid = t.batid AND d.stallno = t.stallno)

         WHEN MATCHED THEN

             UPDATE SET d.awaitqty = d.awaitqty - t.wareqty;



         DELETE FROM t_await_store_ware w

         WHERE  w.billcode = nvl(:new.billcode, 'ABN') AND w.billno = :new.abnormityno;



     END IF;



     pkg_bill_variable.g_billcode  := nvl(:new.billcode, 'ABN');

     pkg_bill_variable.g_billno    := :new.abnormityno;

     pkg_bill_variable.g_checkbit1 := :new.checkbit1;

     pkg_bill_variable.g_checkbit2 := :new.checkbit2;

     pkg_bill_variable.g_checkbit3 := :new.checkbit3;

     pkg_bill_variable.g_checkbit4 := :new.checkbit4;

     pkg_bill_variable.g_checkbit5 := :new.checkbit5;



     pkg_bill_variable.g_checkbit1_old := :old.checkbit1;

     pkg_bill_variable.g_checkbit2_old := :old.checkbit2;

     pkg_bill_variable.g_checkbit3_old := :old.checkbit3;

     pkg_bill_variable.g_checkbit4_old := :old.checkbit4;

     pkg_bill_variable.g_checkbit5_old := :old.checkbit5;



     pkg_bill_variable.g_checker1 := :new.checker1;

     pkg_bill_variable.g_checker2 := :new.checker2;

     pkg_bill_variable.g_checker3 := :new.checker3;

     pkg_bill_variable.g_checker4 := :new.checker4;

     pkg_bill_variable.g_checker5 := :new.checker5;



     pkg_bill_variable.g_checker1_old := :old.checker1;

     pkg_bill_variable.g_checker2_old := :old.checker2;

     pkg_bill_variable.g_checker3_old := :old.checker3;

     pkg_bill_variable.g_checker4_old := :old.checker4;

     pkg_bill_variable.g_checker5_old := :old.checker5;



     pkg_bill_variable.g_lastmodify := :new.lastmodify;

     pkg_bill_variable.g_new_status := :new.status;

     pkg_bill_variable.g_old_status := :old.status;

     pkg_bill_variable.g_userid     := :new.proposer;

     pkg_bill_variable.g_compid     := :new.compid;



     proc_exec_trigger_ext(p_trigger_name => 'tr_t_abnormity_h');

 END tr_t_abnormity_h;
/

