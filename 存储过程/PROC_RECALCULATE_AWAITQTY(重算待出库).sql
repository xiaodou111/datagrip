create PROCEDURE proc_recalculate_awaitqty(p_compid IN VARCHAR2,
                                                      p_busno  IN VARCHAR2,
                                                      p_wareid IN VARCHAR2) IS
  /* --重新计算待出库 根据以下业务单据:
      --货位调整单STL,
      --采购退货申请单ARJ,
      --采购退货单REJ,
      --销售订单WHO,
      --移仓单申请单 AWH,
      --批发销售单 WHL,
      --报损报溢单ABN
      --报损报溢申请单APPABN
      --移仓建议审核单AWH
      --中医馆待出库 MEDCF
      --不合格品报告单FLEAPPLY
      --不合格品确认单FAL
      --('DSS','DSSM','ADD','ADR','DIS','DER','DIR','APS')
      --('DETR', 'RAP')
      --author : pengwzh ,date :20160117
  */
  --v_warename t_ware_base.warename%TYPE;
  v_wareid   t_store_h.wareid%TYPE;
  v_saleqty  t_store_h.sumqty%TYPE;
  v_batid    t_store_d.batid%TYPE;
  v_para2825 s_sys_ini.inipara%TYPE;
  v_wareqty  t_batorder_d.wareqty%TYPE;
  v_procname t_proc_rep.procrepname%TYPE;
  v_warecode t_ware_base.warecode%TYPE;
  v_warename t_ware_base.warename%TYPE;
  --批发销售定单，根据批号分配批次待出库
  CURSOR cur_store(p_ownerid t_store_i.ownerid%TYPE,
                   p_ind     s_sys_ini.inipara%TYPE,
                   p_makeno  t_store_i.makeno%TYPE,
                   p_batid   t_store_d.batid%TYPE) IS
    SELECT si.batid, sd.wareqty, sd.awaitqty, sd.stallno
      FROM t_store_i si, t_store_d sd, t_stall st
     WHERE si.batid = sd.batid
       AND si.wareid = sd.wareid
       AND st.stallno = sd.stallno
       AND st.compid = sd.compid
       AND st.busno = sd.busno
       AND sd.wareqty - sd.awaitqty > 0
       AND si.ownerid = p_ownerid
       AND si.compid = p_compid
       AND si.wareid = p_wareid
       AND sd.busno = p_busno
       AND si.makeno = p_makeno
       AND (sd.batid = p_batid OR p_batid = 0)
       AND st.stalltype LIKE '1%'
       AND nvl(si.recall_flag, 0) <> 1
       AND nvl(si.resale_flag, 0) <> 1
     ORDER BY CASE
                WHEN p_ind = '1' THEN --按效期
                 to_char(si.invalidate - to_date('19700101', 'yyyymmdd')) --UNIX时间
                WHEN p_ind = '2' THEN --按库存数
                 lpad(to_char(floor(sd.wareqty)), 10, '0')
                WHEN p_ind = '3' THEN --按批号
                 nvl(si.makeno, '')
                ELSE
                 to_char(si.batid) --按批次
              END;
BEGIN
  --是否有替换储存过程
  BEGIN
    SELECT procrepname --COUNT(*)
      INTO v_procname --v_count
      FROM t_proc_rep
     WHERE upper(procname) = upper('proc_recalculate_awaitqty')
       AND status = 1;
  EXCEPTION
    WHEN no_data_found THEN
      v_procname := NULL;
  END;
  IF v_procname IS NOT NULL THEN
    BEGIN
      EXECUTE IMMEDIATE 'begin ' || v_procname || '(:1, :2,:3); end;'
        USING p_compid, p_busno, p_wareid;
    END;
    RETURN;
  END IF;
  --先清掉所有待出库记录
  INSERT INTO tmp_disable_trigger VALUES ('t_store_h');
  INSERT INTO tmp_disable_trigger VALUES ('t_store_d');
  INSERT INTO tmp_disable_trigger VALUES ('t_store_makeno');
  INSERT INTO tmp_disable_trigger VALUES ('t_store_owner');
  DELETE FROM t_await_store_ware t
   WHERE t.compid = p_compid
     AND t.busno = p_busno
     AND t.wareid = p_wareid;
  --更新库存表待出库记录为0
  UPDATE t_store_d d
     SET d.awaitqty = 0
   WHERE (d.compid = p_compid)
     AND (d.busno = p_busno)
     AND (d.wareid = p_wareid);
  UPDATE t_store_h h
     SET h.sumawaitqty = 0, h.sumawaitqty_nobatch = 0
   WHERE (h.compid = p_compid)
     AND (h.busno = p_busno)
     AND (h.wareid = p_wareid);
  UPDATE t_store_makeno m
     SET m.awaitqty = 0
   WHERE m.compid = p_compid
     AND m.busno = p_busno
     AND m.wareid = p_wareid;
  UPDATE t_store_owner o
     SET o.awaitqty = 0
   WHERE o.compid = p_compid
     AND o.busno = p_busno
     AND o.wareid = p_wareid;
  --往待出库表写入记录
  --货位调整单STL
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     checkdate1,
     checkdate2,
     checkdate3,
     checkdate4,
     checkdate5,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT h.billcode, -- billcode,
           h.adjustno, --billno,
           h.busno, --busno,
           d.wareid,
           d.batid,
           d.srcstallno, --stallno,
           d.wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.price, --price,
           h.lastmodify, --createuser,
           h.lastmodify, --buyerorsaler,
           h.checker1,
           h.checkbit1,
           h.checker2,
           h.checkbit2,
           h.checker3,
           h.checkbit3,
           h.checker4,
           h.checkbit4,
           h.checker5,
           h.checkbit5,
           h.compid,
           h.checkdate1,
           h.checkdate2,
           h.checkdate3,
           h.checkdate4,
           h.checkdate5,
           d.rowno,
           si.orgname,
           h.busno
      FROM t_adjust_stall_h h, t_adjust_stall_d d, s_busi si
     WHERE h.adjustno = d.adjustno
       AND (h.compid = p_compid)
       AND (h.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND h.status = 0
       AND si.compid = h.compid
       AND si.busno = h.busno;
  --采购退货申请单ARJ
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT 'ARJ',
           th.applyno,
           th.busno,
           td.wareid,
           td.batid,
           td.stallno,
           --td.wareqty,
           td.wareqty - nvl(rtn.returnqty, 0),
           th.vencusno,
           t_vencus.vencusname,
           td.purprice,
           th.lastmodify,
           th.buyer,
           th.checker1,
           th.checkbit1,
           th.checker2,
           th.checkbit2,
           th.checker3,
           th.checkbit3,
           th.checker4,
           th.checkbit4,
           th.checker5,
           th.checkbit5,
           th.compid,
           td.rowno,
           t_vencus.vencusname,
           t_vencus.vencuscode
      FROM t_reject_apply_h th, t_reject_apply_d td
      LEFT JOIN (SELECT rd.applyno, rd.applyrowno, SUM(rd.returnqty) returnqty
                   FROM t_reaccept_d rd, t_reaccept_h rh
                  WHERE rd.reacceptno = rh.reacceptno
                    AND rh.status = 1
                    AND rd.applyno IS NOT NULL
                  GROUP BY rd.applyno, rd.applyrowno) rtn
        ON td.applyno = rtn.applyno
       AND td.rowno = rtn.applyrowno, t_vencus
     WHERE th.applyno = td.applyno
       AND th.vencusno = t_vencus.vencusno
       AND th.compid = t_vencus.compid
       AND (th.compid = p_compid)
       AND (th.busno = p_busno)
       AND (td.wareid = p_wareid)
       AND th.status <> 2
       AND td.wareqty - nvl(rtn.returnqty, 0) > 0;
  --采购退货单REJ
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT 'REJ',
           bh.reacceptno,
           bh.busno,
           d.wareid,
           d.batid,
           d.stallno,
           d.returnqty,
           bh.vencusno,
           t_vencus.vencusname,
           d.purprice,
           bh.lastmodify,
           bh.buyer,
           checker1,
           bh.checkbit1,
           bh.checker2,
           bh.checkbit2,
           bh.checker3,
           bh.checkbit3,
           bh.checker4,
           bh.checkbit4,
           bh.checker5,
           bh.checkbit5,
           bh.compid,
           d.rowno,
           t_vencus.vencusname,
           t_vencus.vencuscode
      FROM t_reaccept_h bh, t_reaccept_d d, t_vencus
     WHERE bh.reacceptno = d.reacceptno
       AND bh.vencusno = t_vencus.vencusno
       AND bh.compid = t_vencus.compid
       AND (bh.compid = p_compid)
       AND (bh.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND bh.status = 0
       AND d.applyno IS NULL;
  --销售订单WHO 无批号或有批号有批次的
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT bh.billcode,
           bh.batorderno,
           d.busno,
           d.wareid,
           d.batid,
           d.stallno,
           d.wareqty,
           bh.vencusno,
           bh.vencusname,
           d.whlprice AS whlprice,
           bh.lastmodify,
           bh.saler,
           checker1,
           bh.checkbit1,
           bh.checker2,
           bh.checkbit2,
           bh.checker3,
           bh.checkbit3,
           bh.checker4,
           bh.checkbit4,
           bh.checker5,
           bh.checkbit5,
           bh.compid,
           d.rowno,
           bh.vencusname,
           tvb.vencuscode
      FROM t_batorder_h bh, t_batorder_d d, t_vencus_base tvb
     WHERE bh.batorderno = d.batorderno
       AND (bh.compid = p_compid)
       AND (d.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND nvl(d.ifhang, 0) <> 1
       AND bh.status <> 2
       AND NOT EXISTS (SELECT 1
              FROM t_batsale_d td
             WHERE td.batorderno = d.batorderno
               AND td.batorderrowno = d.rowno)
       AND (d.makeno = '全部' AND d.batid = 0)
       AND tvb.vencusno = bh.vencusno;
  --批发销售单 WHL
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT bh.billcode,
           bh.batsaleno,
           bh.busno,
           d.wareid,
           d.batid,
           d.stallno,
           d.wareqty,
           bh.vencusno,
           bh.vencusname,
           d.whlprice AS whlprice,
           bh.lastmodify,
           bh.saler,
           checker1,
           bh.checkbit1,
           bh.checker2,
           bh.checkbit2,
           bh.checker3,
           bh.checkbit3,
           bh.checker4,
           bh.checkbit4,
           bh.checker5,
           bh.checkbit5,
           bh.compid,
           d.rowno,
           bh.vencusname,
           tvb.vencuscode
      FROM t_batsale_h bh, t_batsale_d d, t_vencus_base tvb
     WHERE bh.batsaleno = d.batsaleno
       AND (bh.compid = p_compid)
       AND (bh.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND bh.status = 0
       AND tvb.vencusno = bh.vencusno;
  --门店报损报溢申请单APPABN
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT 'APPABN', --billcode,
           d.abnapplyno, --billno,
           a.busno,
           d.wareid,
           d.batid,
           d.stallno,
           d.wareqtyb - d.wareqtya, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno,
           si.orgname,
           a.busno
      FROM t_abnormity_apply_h a, t_abnormity_apply_d d, s_busi si
     WHERE a.abnapplyno = d.abnapplyno
       AND (a.compid = p_compid)
       AND (a.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND d.wareqtyb - d.wareqtya > 0
       AND ((a.status = 0) OR (a.status = 1 AND a.abnormityno IS NULL))
       AND si.compid = a.compid
       AND si.busno = a.busno;
  --报损报溢单ABN
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT 'ABN', --billcode,
           d.abnormityno, --billno,
           a.busno,
           d.wareid,
           d.batid,
           d.stallno,
           d.wareqtyb - d.wareqtya, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno,
           si.orgname,
           a.busno
      FROM t_abnormity_h a, t_abnormity_d d, s_busi si
     WHERE a.abnormityno = d.abnormityno
       AND (a.compid = p_compid)
       AND (a.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND d.wareqtyb - d.wareqtya > 0
       AND a.status = 0
       AND si.compid = a.compid
       AND si.busno = a.busno;
  -- 连锁申请单 DETR, RAP
  --退仓申请这里 再此处有异常 若存在拒收两次 这里插入就会报主键重复 所以修改
  ----退仓的待出库 就判断退仓单有没有   有了就不锁待出库   jxh
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.CHECKQTY wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
      WHERE a.applyno=d.applyno
      and not exists (select 1 from t_dist_h  b WHERE a.applyno=b.sap_distno )
      and d.wareid=p_wareid  and a.srcbusno=p_busno and a.billcode='RAP'   and a.status=1 ;


 /* INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.checkqty - nvl(twd.check_nook_qty, 0) - nvl(tdd.wareqty, 0) wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
    --1.未考虑到退仓收货单全部拒收,没生成退仓验收单的情况 guisy 20180830
    --2.未考虑到退仓收货单拒收,退仓验收单无拒收的情况
   --3.未考虑到退仓收货单无拒收,退仓单有拒收的情况
    \*LEFT JOIN (SELECT td.srcbillno,
          td.srcrowno,
          td.rowno,
          SUM(kd.check_nook_qty) check_nook_qty
     FROM t_distnotice_d td,
          t_distnotice_h th,
          t_rwhcheck_d   kd,
          t_rwhcheck_h   kh
    WHERE th.noticeno = td.noticeno
      AND th.status = 1
      AND kh.checkno = kd.checkno
      AND kh.status = 1
      AND kd.srcbillno = td.noticeno
      AND kd.srcrowno = td.rowno
      AND kd.srcbillcode = th.billcode
      AND td.srcbillno IS NOT NULL
      AND td.srcrowno IS NOT NULL
      AND td.check_nook_qty > 0
      AND kd.check_nook_qty > 0
    GROUP BY td.srcbillno, td.srcrowno, td.rowno) twd*\
    --考虑全部拒收与部分拒收和退仓验收单拒收情况
      LEFT JOIN (SELECT dd.srcbillno,
                        dd.srcrowno,
                        -- dd.rowno,
                        SUM(dd.check_nook_qty) check_nook_qty
                   FROM (SELECT srcbillno, srcrowno, rowno, check_nook_qty
                           FROM t_distnotice_d td, t_distnotice_h th
                          WHERE th.noticeno = td.noticeno
                            AND th.status = 1
                            AND td.srcbillno IS NOT NULL
                            AND td.srcrowno IS NOT NULL
                            AND td.check_nook_qty > 0
                         UNION ALL
                         SELECT td.srcbillno      AS srcbillno,
                                td.srcrowno       AS srcrowno,
                                td.rowno          AS rowno,
                                kd.check_nook_qty AS check_nook_qty
                           FROM t_distnotice_d td,
                                t_distnotice_h th,
                                t_rwhcheck_d   kd,
                                t_rwhcheck_h   kh
                          WHERE th.noticeno = td.noticeno
                            AND th.status = 1
                            AND kh.checkno = kd.checkno
                            AND kh.status = 1
                            AND kd.srcbillno = td.noticeno
                            AND kd.srcrowno = td.rowno
                            AND kd.srcbillcode = th.billcode
                            AND td.srcbillno IS NOT NULL
                            AND td.srcrowno IS NOT NULL
                            AND kd.check_nook_qty > 0
                         UNION ALL
                         SELECT td.srcbillno      AS srcbillno,
                                td.srcrowno       AS srcrowno,
                                td.rowno          AS rowno,
                                kd.check_nook_qty AS check_nook_qty
                           FROM t_distnotice_d td,
                                t_distnotice_h th,
                                t_rwhcheck_d   kd,
                                t_rwhcheck_h   kh,
                                t_dist_d       dd,
                                t_dist_h       dh
                          WHERE th.noticeno = td.noticeno
                            AND th.status = 1
                            AND kh.checkno = kd.checkno
                            AND kh.status = 1
                            AND dd.distno = dh.distno
                            AND dh.status = 1
                            AND kd.srcbillno = td.noticeno
                            AND kd.srcrowno = td.rowno
                            AND kd.srcbillcode = th.billcode
                            AND dd.billno = kd.checkno
                            AND dd.srcrowno = kd.rowno
                            AND dd.billcode = kh.billcode
                            AND td.srcbillno IS NOT NULL
                            AND td.srcrowno IS NOT NULL
                            AND dd.check_nook_qty > 0) dd
                  GROUP BY dd.srcbillno, dd.srcrowno --, dd.rowno
                 ) twd
        ON (twd.srcbillno = d.applyno AND twd.srcrowno = d.rowno)
      --需要减去已退仓的数量 by ww 20181218
      LEFT JOIN (SELECT td.srcbillno      AS srcbillno,
                        td.srcrowno       AS srcrowno,
                        --td.rowno          AS rowno,
                        SUM(dd.wareqty)   AS wareqty
                   FROM t_distnotice_d td,
                        t_distnotice_h th,
                        t_rwhcheck_d   kd,
                        t_rwhcheck_h   kh,
                        t_dist_d       dd,
                        t_dist_h       dh
                  WHERE th.noticeno = td.noticeno
                    AND th.status = 1
                    AND kh.checkno = kd.checkno
                    AND kh.status = 1
                    AND dd.distno = dh.distno
                    AND dh.status = 1
                    AND kd.srcbillno = td.noticeno
                    AND kd.srcrowno = td.rowno
                    AND kd.srcbillcode = th.billcode
                    AND dd.billno = kd.checkno
                    AND dd.srcrowno = kd.rowno
                    AND dd.billcode = kh.billcode
                    AND td.srcbillno IS NOT NULL
                    AND td.srcrowno IS NOT NULL
                    AND dd.wareqty > 0
                  GROUP BY td.srcbillno, td.srcrowno
                 ) tdd
        ON (tdd.srcbillno = d.applyno AND tdd.srcrowno = d.rowno)
     WHERE a.applyno = d.applyno
       AND a.status <> 2
       AND (a.compid = p_compid)
       AND (a.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       \*AND NOT EXISTS (SELECT 1
              FROM t_dist_d dd
             WHERE dd.srcapplyno = d.applyno
               AND dd.srcrowno = d.rowno)*\
       AND a.billcode IN ('RAP')
       AND d.check_nook_qty IS NULL
       AND d.retdist_qty IS NULL --两个字段为空的是历史数据，维持原方式
       AND nvl(a.cancel_flag, 0) <> 1
       AND d.checkqty - nvl(twd.check_nook_qty, 0) - nvl(tdd.wareqty, 0) > 0
    UNION ALL
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.applyqty - nvl(d.retdist_qty, 0) - nvl(d.check_nook_qty, 0) wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
     WHERE a.applyno = d.applyno
       AND a.status <> 2
       AND (a.compid = p_compid)
       AND (a.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       AND a.billcode IN ('RAP')
       AND d.check_nook_qty IS NOT NULL
       AND d.retdist_qty IS NOT NULL --两个字段有值使用新算法：申请数量 - 已退仓数量 - 已拒收数量
       AND nvl(a.cancel_flag, 0) <> 1
       AND d.applyqty - nvl(d.retdist_qty, 0) - nvl(d.check_nook_qty, 0) > 0;*/
  --  INSERT INTO t_await_store_ware
  --    (billcode,
  --     billno,
  --     busno,
  --     wareid,
  --     batid,
  --     stallno,
  --     wareqty,
  --     vencusno,
  --     vendorname,
  --     price,
  --     createuser,
  --     buyerorsaler,
  --     checker1,
  --     checkbit1,
  --     checker2,
  --     checkbit2,
  --     checker3,
  --     checkbit3,
  --     checker4,
  --     checkbit4,
  --     checker5,
  --     checkbit5,
  --     compid,
  --     rowno)
  --    SELECT a.billcode, --billcode,
  --           d.applyno, --billno,
  --           a.srcbusno,
  --           d.wareid,
  --           d.batid,
  --           d.srcstallno,
  --           d.checkqty - nvl(tnd.check_nook_qty, 0) -
  --           nvl(twd.check_nook_qty, 0), --wareqty,
  --           NULL, --vencusno,
  --           NULL, --vendorname,
  --           d.purprice, --price,
  --           a.lastmodify, --createuser,
  --           NULL, --buyerorsaler,
  --           a.checker1,
  --           a.checkbit1,
  --           a.checker2,
  --           a.checkbit2,
  --           a.checker3,
  --           a.checkbit3,
  --           a.checker4,
  --           a.checkbit4,
  --           a.checker5,
  --           a.checkbit5,
  --           a.compid,
  --           d.rowno
  --      FROM t_distapply_h a, t_distapply_d d
  --      left join (select th.noticeno,
  --                        td.srcbillno,
  --                        td.srcrowno,
  --                        td.rowno,
  --                        td.check_nook_qty --关联收货、验收单取拒收数量
  --                   from t_distnotice_d td, t_distnotice_h th
  --                  where th.noticeno = td.noticeno
  --                    and th.status = 1) tnd
  --        on tnd.srcbillno = d.applyno
  --       and tnd.srcrowno = d.rowno
  --      left join (select td.srcbillno, td.srcrowno, td.check_nook_qty
  --                   from t_rwhcheck_d td, t_rwhcheck_h th
  --                  where th.checkno = td.checkno
  --                    and th.status = 1) twd
  --        on twd.srcbillno = tnd.noticeno
  --       and twd.srcrowno = tnd.rowno
  --     WHERE a.applyno = d.applyno
  --       AND a.status <> 2
  --       AND (a.compid = p_compid)
  --       AND (a.srcbusno = p_busno)
  --       AND (d.wareid = p_wareid)
  --       AND NOT EXISTS (SELECT 1
  --              FROM t_dist_d dd
  --             WHERE dd.srcapplyno = d.applyno
  --               AND dd.srcapplyrowno = d.rowno)
  --       AND a.billcode IN ('DETR');
  -- add by 1723 txy 20180123 DETR 委托配送退货申请单 待出库重算脚本重新处理；
  -- 一部分是单据本身未审核的，一部分是已审核完，但是配送退回的流程还未走完的，也纳入到待出库范围内
  /* INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.checkqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
     WHERE a.applyno = d.applyno
       AND a.status = 0
       AND (a.compid = p_compid OR p_compid = 0)
       AND (a.srcbusno = p_busno OR p_busno = 0)
       AND (d.wareid = p_wareid OR p_wareid = 0)
       AND NOT EXISTS (SELECT 1
              FROM t_dist_d dd
             WHERE dd.srcapplyno = d.applyno
               AND dd.srcrowno = d.rowno)
       AND a.billcode = 'DETR';

  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.checkqty - nvl(trh.wareqty, 0) - nvl(tnd.wareqty, 0), --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
      LEFT JOIN (SELECT td.detr_billno,
                        td.detr_rowno rowno,
                        decode(th.status,
                               1,
                               nvl(td.wareqty, 0),
                               2,
                               nvl(td.wareqty, 0),
                               0) wareqty --关联批发退货单未生效的数量
                   FROM t_rebatsale_apply_h th, t_rebatsale_apply_d td
                  WHERE th.rebatsaleapplyno = td.rebatsaleapplyno) trh
        ON trh.detr_billno = d.applyno
       AND trh.rowno = d.rowno
      LEFT JOIN (SELECT td.detr_billno,
                        td.detr_rowno rowno,
                        decode(th.status,
                               1,
                               nvl(td.wareqty, 0),
                               2,
                               nvl(td.wareqty, 0),
                               0) wareqty --关联批发退货单未生效的数量
                   FROM t_rebatsale_h th, t_rebatsale_d td
                  WHERE th.rebatsaleno = td.rebatsaleno) tnd
        ON tnd.detr_billno = d.applyno
       AND tnd.rowno = d.rowno
     WHERE a.applyno = d.applyno
       AND a.status = 1
       AND (a.compid = p_compid)
       AND (a.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       AND d.checkqty - nvl(trh.wareqty, 0) - nvl(tnd.wareqty, 0) > 0
       AND a.allot_flag = 0
       AND NOT EXISTS (SELECT 1
              FROM t_dist_d dd
             WHERE dd.srcapplyno = d.applyno
               AND dd.srcapplyrowno = d.rowno)
       AND a.billcode = 'DETR';*/
  --委托配送退仓申请单未审核的
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.checkqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
     WHERE a.applyno = d.applyno
       AND a.status = 0
       AND (a.compid = p_compid OR p_compid = 0)
       AND (a.srcbusno = p_busno OR p_busno = 0)
       AND (d.wareid = p_wareid OR p_wareid = 0)
       AND a.billcode = 'DETR';

  --已生效的委托配送退仓申请单，待出库=批准数量-已拒收数量-已退数量
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT a.billcode, --billcode,
           d.applyno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.checkqty - nvl(rtn.backqty, 0) - nvl(brf.refuseqty, 0), --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_distapply_h a, t_distapply_d d
      LEFT JOIN (SELECT rd.detr_billno,
                        rd.detr_rowno,
                        rd.wareid,
                        SUM(rd.backqty) AS backqty
                   FROM t_rebatsale_d rd, t_rebatsale_h rh
                  WHERE rd.rebatsaleno = rh.rebatsaleno
                    AND rh.status = 1
                    AND rd.detr_billno IS NOT NULL
                    AND rd.detr_rowno IS NOT NULL
                  GROUP BY rd.detr_billno, rd.detr_rowno, rd.wareid) rtn
        ON rtn.detr_billno = d.applyno
       AND rtn.detr_rowno = d.rowno
       AND rtn.wareid = d.wareid
      LEFT JOIN (SELECT brd.detr_billno,
                        brd.detr_rowno,
                        brd.wareid,
                        SUM(brd.retqty) AS refuseqty
                   FROM t_batrtn_refuse_d brd, t_batrtn_refuse_h brh
                  WHERE brd.refuseno = brh.refuseno
                    AND brh.status <> 2
                    AND brd.detr_billno IS NOT NULL
                    AND brd.detr_rowno IS NOT NULL
                  GROUP BY brd.detr_billno, brd.detr_rowno, brd.wareid) brf
        ON brf.detr_billno = d.applyno
       AND brf.detr_rowno = d.rowno
       AND brf.wareid = d.wareid
     WHERE a.applyno = d.applyno
       AND a.status = 1
       AND d.checkqty - nvl(rtn.backqty, 0) - nvl(brf.refuseqty, 0) > 0
       AND (a.compid = p_compid OR p_compid = 0)
       AND (a.srcbusno = p_busno OR p_busno = 0)
       AND (d.wareid = p_wareid OR p_wareid = 0)
       AND a.billcode = 'DETR';

  /*--委托配送退仓申请单已审核走到了批发退货申请的未继续往下的  根据批发退货申请来算
  --注意：批发退与委托退货申请关联   detr_billno 和 detr_rowno 为关键字段
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT 'DETR',
           a.applyno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           td.wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_rebatsale_apply_h th
      JOIN t_rebatsale_apply_d td
        ON (th.rebatsaleapplyno = td.rebatsaleapplyno AND th.status = 0)
      JOIN t_distapply_d d
        ON (d.applyno = td.detr_billno AND d.rowno = td.detr_rowno AND
           d.wareid = td.wareid)
      JOIN t_distapply_h a
        ON (a.applyno = d.applyno AND a.billcode = 'DETR' AND a.status = 1)
     WHERE (a.compid = p_compid OR p_compid = 0)
       AND (a.srcbusno = p_busno OR p_busno = 0)
       AND (d.wareid = p_wareid OR p_wareid = 0);
  --委托配送退仓申请单已审核走到了批发退货单的未审核的       根据批发退货单来算
  --注意：批发退与委托退货申请关联   detr_billno 和 detr_rowno 为关键字段
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     busno,
     wareid,
     batid,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno)
    SELECT 'DETR',
           a.applyno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           td.backqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno
      FROM t_rebatsale_h th
      JOIN t_rebatsale_d td
        ON (th.rebatsaleno = td.rebatsaleno AND th.status = 0)
      JOIN t_distapply_d d
        ON (d.applyno = td.detr_billno AND d.rowno = td.detr_rowno AND
           d.wareid = td.wareid)
      JOIN t_distapply_h a
        ON (a.applyno = d.applyno AND a.billcode = 'DETR' AND a.status = 1)
     WHERE (a.compid = p_compid OR p_compid = 0)
       AND (a.srcbusno = p_busno OR p_busno = 0)
       AND (d.wareid = p_wareid OR p_wareid = 0);*/

  --连锁单    ('DSS','DSSM','ADD','ADR','DIS','DER','DIR','APS')
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT a.billcode, --billcode,
           d.distno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno,
           si.orgname,
           a.objbusno
      FROM t_dist_h a, t_dist_d d, s_busi si
     WHERE a.billcode IN
           ('DSS', 'DSSM', 'ADD', 'ADR', 'DIS', 'DER', 'DIR', 'APS', 'DSSC')
       AND (a.compid = p_compid)
       AND (a.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       AND a.distno = d.distno
       AND a.status = 0
       AND si.compid = a.compid
       AND si.busno = a.objbusno
       MINUS        --如果退仓单引用了退仓验收单，则不再计算待出库，否则会重复计算待出库      zzx    2018-11-6
       SELECT a.billcode, --billcode,
           d.distno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno,
           si.orgname,
           a.objbusno
      FROM t_dist_h a, t_dist_d d, s_busi si
     WHERE a.billcode = 'DIR'
       AND (a.compid = p_compid)
       AND (a.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       AND a.distno = d.distno
       AND a.status = 0
       AND si.compid = a.compid
       AND si.busno = a.objbusno
       AND a.srcbillcode = '07'
    MINUS --若【调拨退回单】是由退仓验收单新增产生，则不记入待出库 LYL    2018-11-14
    SELECT a.billcode, --billcode,
           d.distno, --billno,
           a.srcbusno,
           d.wareid,
           d.batid,
           d.srcstallno,
           d.wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.purprice, --price,
           a.lastmodify, --createuser,
           NULL, --buyerorsaler,
           a.checker1,
           a.checkbit1,
           a.checker2,
           a.checkbit2,
           a.checker3,
           a.checkbit3,
           a.checker4,
           a.checkbit4,
           a.checker5,
           a.checkbit5,
           a.compid,
           d.rowno,
           si.orgname,
           a.objbusno
      FROM t_dist_h a, t_dist_d d, s_busi si
     WHERE a.billcode = 'ADR'
       AND (a.compid = p_compid)
       AND (a.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       AND a.distno = d.distno
       AND a.status = 0
       AND si.compid = a.compid
       AND si.busno = a.objbusno
       and a.srcbillcode = 'RWCK';

  --中医馆待出库 MEDCF
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     checkdate1,
     checkdate2,
     checkdate3,
     checkdate4,
     checkdate5,
     rowno)
    SELECT 'MEDCF' AS billcode, -- billcode,
           h.cfno, --billno,
           h.busno, --busno,
           d.wareid,
           i.batid,
           i.stallno, --stallno,
           i.wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           d.saleprice, --price,
           h.lastmodify, --createuser,
           h.lastmodify, --buyerorsaler,
           h.checkuser1,
           nvl(h.checkbit1, 0),
           h.checkuser2,
           nvl(h.checkbit2, 0),
           NULL AS checker3,
           0 AS checkbit3,
           NULL AS checker4,
           0 AS checkbit4,
           NULL AS checker5,
           0 AS checkbit5,
           h.compid,
           h.checkdate1,
           h.checkdate2,
           NULL AS checkdate3,
           NULL AS checkdate4,
           NULL AS checkdate5,
           i.rowno
      FROM t_med_cf_h h, t_med_cf_d d, t_med_cf_i i
     WHERE h.cfno = d.cfno
       AND (d.cfno = i.cfno)
          --AND (d.rowno = i.rowno)
       AND (d.wareid = i.wareid)
       AND (h.compid = p_compid)
       AND (h.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND h.status IN (0, 1, 2);
  --不合格品报告单FLEAPPLY
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     checkdate1,
     checkdate2,
     checkdate3,
     checkdate4,
     checkdate5,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT h.billcode, -- billcode,
           h.failureno, --billno,
           h.busno, --busno,
           d.wareid,
           d.batid,
           d.stallno, --stallno,
           (d.wareqty - nvl(sdh.wareqty, 0)) wareqty, --wareqty,
           NULL, --vencusno,
           NULL, --vendorname,
           NULL, --price,
           h.lastmodify, --createuser,
           h.lastmodify, --buyerorsaler,
           h.checker1,
           h.checkbit1,
           h.checker2,
           h.checkbit2,
           h.checker3,
           h.checkbit3,
           h.checker4,
           h.checkbit4,
           h.checker5,
           h.checkbit5,
           h.compid,
           NULL, --checkdate1,
           NULL, --checkdate2,
           NULL, --checkdate3,
           NULL, --checkdate4,
           NULL, --checkdate5,
           d.rowno,
           s.orgname,
           h.busno
      FROM t_failure_h h
      JOIN t_failure_d d
        ON (h.failureno = d.failureno)
      JOIN s_busi s
        ON (h.busno = s.busno)
      LEFT JOIN (SELECT SUM(nvl(sd.wareqty, 0)) wareqty,
                        sd.idno,
                        sd.wareid,
                        sd.batid,
                        sd.makeno,
                        sd.srcstallno stallno
                   FROM t_adjust_stall_d sd
                   JOIN t_adjust_stall_h sh
                     ON sh.adjustno = sd.adjustno
                    AND sh.billcode = 'FAL'
                    AND sd.idno IS NOT NULL
                    AND sh.status <> 2
                  GROUP BY sd.idno,
                           sd.wareid,
                           sd.batid,
                           sd.makeno,
                           sd.srcstallno) sdh
        ON (d.failureno = sdh.idno AND d.wareid = sdh.wareid AND
           d.batid = sdh.batid AND d.makeno = sdh.makeno AND
           d.stallno = sdh.stallno)
     WHERE h.status <> 2
       AND h.billcode = 'FLEAPPLY'
       AND (h.compid = p_compid)
       AND (h.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND d.wareqty - nvl(sdh.wareqty, 0) > 0;
  --不合格品确认单FAL   就是货位调整单所以这里不调整了
  --移仓单申请单 AWH
  /* INSERT INTO t_await_store_ware
  (billcode,
   billno,
   busno,
   wareid,
   batid,
   stallno,
   wareqty,
   vencusno,
   vendorname,
   price,
   createuser,
   buyerorsaler,
   checker1,
   checkbit1,
   checker2,
   checkbit2,
   checker3,
   checkbit3,
   checker4,
   checkbit4,
   checker5,
   checkbit5,
   compid,
   rowno)
  SELECT 'AWH' billcode,
         bh.appwhno,
         bh.srcbusno,
         bh.wareid,
         0,
         '全部',
         bh.wareqty - nvl(b.wareqty, 0) as wareqty,
         null,
         null,
         null,
         bh.lastmodify,
         null,
         bh.checker1,
         bh.checkbit1,
         bh.checker2,
         bh.checkbit2,
         bh.checker3,
         bh.checkbit3,
         bh.checker4,
         bh.checkbit4,
         bh.checker5,
         bh.checkbit5,
         bh.compid,
         1 as rowno
    FROM t_apply_warehouse bh
    LEFT JOIN (select regexp_substr(h.notes, '[0-9]+') as apply_no,
                      h.compid,
                      h.srcbusno,
                      h.objbusno,
                   --   d.makeno,
                      d.srcstallno,
                      d.objstallno,
                      d.wareid,
                      d.applyqty,
                      sum(d.wareqty) wareqty
                 from t_adjust_warehouse_h h, t_adjust_warehouse_d d
                where h.adjustwhno = d.adjustwhno
                group by h.compid,
                         h.srcbusno,
                         h.objbusno,
                    --     d.makeno,
                         d.srcstallno,
                         d.objstallno,
                         d.wareid,
                         d.applyqty,
                         regexp_substr(h.notes, '[0-9]+')) b

      on b.apply_no = bh.appwhno
     and b.compid = bh.compid
     and b.wareid = bh.wareid
     and b.srcbusno = bh.srcbusno
     and b.objbusno = bh.objbusno
   --  and b.makeno = bh.makeno
   WHERE bh.status <> 2
     AND (bh.compid = p_compid or p_compid = 0)
     AND (bh.srcbusno = p_busno or p_busno = 0)
     AND (bh.wareid = p_wareid or p_wareid = 0)
     AND bh.wareqty - nvl(b.wareqty, 0) > 0
     and bh.wms_real_qty <> 0
     and bh.makeno = '全部'
        \*   and not exists
        (select 1
                 from t_adjust_warehouse_h b
                where b.compid = bh.compid
                  and REGEXP_SUBSTR(b.notes, '[0-9]+') =
                      bh.appwhno)*\
     and not exists (select *
            from wms.wmsoperate_task h
           where task_type in ('309', '210')
             and real_qty = 0
             and bh.appwhno = h.src_proof_id);*/
  --移仓建议审核单AWH
  /* INSERT INTO t_await_store_ware
      (billcode,
       billno,
       busno,
       wareid,
       batid,
       stallno,
       wareqty,
       vencusno,
       vendorname,
       price,
       createuser,
       buyerorsaler,
       checker1,
       checkbit1,
       checker2,
       checkbit2,
       checker3,
       checkbit3,
       checker4,
       checkbit4,
       checker5,
       checkbit5,
       compid,
       rowno)
      SELECT 'AWH',
             t.billno,
             t.srcbusno,
             t.wareid,
             0,
             '全部',
             (t.rep_qty - nvl(t.wms_real_qty,0)) as rep_qty,
             NULL,
             NULL,
             NULL,
             t.lastmodify,
             t.lastmodify,
             t.checker1,
             1, --t.checkbit1,
             t.checker1,
             1, --t.checkbit2,
             t.checker1,
             1, --t.checkbit3,
             t.checker1,
             1, -- t.checkbit4,
             t.checker1,
             1, --t.checkbit5,
             t.compid,
             1
        FROM t_warehouse_shift_check t
       WHERE (t.compid = p_compid or p_compid = 0)
         AND (t.srcbusno = p_busno or p_busno = 0)
         AND (t.wareid = p_wareid or p_wareid = 0)
         and t.makeno = '全部'
         and t.status <> 2
         and (t.wmsoutflag = 0 OR
             (t.wmsoutflag = 1 AND t.rep_qty - t.wms_real_qty > 0 AND
             t.wms_real_qty <> 0));
  */
  --货主调拨单OWNADJ
  INSERT INTO t_await_store_ware
    (billcode,
     billno,
     busno,
     wareid,
     batid,
     stallno,
     wareqty,
     vencusno,
     vendorname,
     price,
     createuser,
     buyerorsaler,
     checker1,
     checkbit1,
     checker2,
     checkbit2,
     checker3,
     checkbit3,
     checker4,
     checkbit4,
     checker5,
     checkbit5,
     compid,
     checkdate1,
     checkdate2,
     checkdate3,
     checkdate4,
     checkdate5,
     rowno,
     relatedunits,
     relatedunitsid)
    SELECT 'OWNADJ' AS billcode,
           h.billno,
           h.busno,
           d.wareid,
           d.batid,
           d.stallno,
           d.allotqty,
           NULL AS vencusno,
           NULL AS vencusname,
           d.allotprice,
           h.lastmodify,
           h.saler,
           h.checker1,
           h.checkbit1,
           h.checker2,
           h.checkbit2,
           h.checker3,
           h.checkbit3,
           h.checker4,
           h.checkbit4,
           h.checker5,
           h.checkbit5,
           h.compid,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           d.rowno,
           si.orgname,
           h.busno
      FROM t_store_owner_shift_h h, t_store_owner_shift_d d, s_busi si
     WHERE h.billno = d.billno
       AND h.compid = si.compid
       AND h.busno = si.busno
       AND (h.compid = p_compid)
       AND (h.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND h.status = 0;
  --加工单
  INSERT INTO t_await_store_ware
  (billcode, billno, busno, wareid, batid, stallno, wareqty, vencusno,
   vendorname, price, createuser, buyerorsaler, checker1, checkbit1,
   checker2, checkbit2, checker3, checkbit3, checker4, checkbit4, checker5,
   checkbit5, compid, rowno)
  SELECT 'MAH', d.machno, h.srcbusno, d.wareid, d.batid,
         d.stallno, nvl(d.wareqty, 0), NULL, NULL,
         d.saleprice AS saleprice, h.lastmodify, 0, h.checker1,
         h.checkbit1, h.checker2, h.checkbit2, h.checker3, h.checkbit3,
         h.checker4, h.checkbit4, h.checker5, h.checkbit5, h.compid,
         d.rowno
  FROM   t_machining_h h,t_machining_d d
  WHERE  h.machno = d.machno and h.status = 0
       AND (h.compid = p_compid)
       AND (h.srcbusno = p_busno)
       AND (d.wareid = p_wareid)
       and d.direct = -1;

  --与梦同行订单
  INSERT INTO t_await_store_ware
    (billcode, billno, busno, wareid, batid, stallno, wareqty, vencusno,
     vendorname, price, createuser, buyerorsaler, checker1, checkbit1,
     checker2, checkbit2, checker3, checkbit3, checker4, checkbit4, checker5,
     checkbit5, compid, rowno, relatedunits, relatedunitsid)
    SELECT 'YMTX', d.billno, h.busno, d.wareid, d.batid, d.stallno,
           nvl(d.wareqty, 0), NULL, NULL, d.netprice, NULL lastmodify, 0,
           NULL checker1, 0 checkbit1, NULL checker2, 0 checkbit2,
           NULL checker3, 0 checkbit3, NULL checker4, 0 checkbit4,
           NULL checker5, 0 checkbit5, h.compid, d.rowno, s_busi.orgname,
           h.busno
      FROM t_ymtx_order_h h, t_ymtx_order_d d, s_busi
     WHERE h.billno = d.billno
       AND h.busno = s_busi.busno
       AND (h.compid = p_compid)
       AND (h.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND h.status = 0
       AND d.wareqty > 0;

  --WMS盘点损溢单WMSABN
  INSERT INTO t_await_store_ware
    (billcode, billno, busno, wareid, batid, stallno, wareqty, vencusno,
     vendorname, price, createuser, buyerorsaler, checker1, checkbit1,
     checker2, checkbit2, checker3, checkbit3, checker4, checkbit4, checker5,
     checkbit5, compid, rowno, relatedunits, relatedunitsid)
    SELECT 'WMSABN',
           --billcode,
           d.applyno,
           --billno,
           a.busno, d.wareid, d.batid, d.stallno, d.wareqtyb - d.wareqtya,
           --wareqty,
           NULL,
           --vencusno,
           NULL,
           --vendorname,
           d.purprice,
           --price,
           a.lastmodify,
           --createuser,
           NULL,
           --buyerorsaler,
           a.checker1, a.checkbit1, a.checker2, a.checkbit2, a.checker3,
           a.checkbit3, a.checker4, a.checkbit4, a.checker5, a.checkbit5,
           a.compid, d.rowno, si.orgname, a.busno
      FROM t_wms_abnormity_h a, t_wms_abnormity_d d, s_busi si
     WHERE a.applyno = d.applyno
       AND (a.compid = p_compid)
       AND (a.busno = p_busno)
       AND (d.wareid = p_wareid)
       AND d.wareqtyb - d.wareqtya > 0
       AND d.batid > 0
       AND a.status = 0
       AND si.compid = a.compid
       AND si.busno = a.busno;

  --根据t_await_store_ware表记录，计算库存表待出库记录
  --更新库存明细待出库
  MERGE INTO t_store_d d
  USING (SELECT compid,
                busno,
                wareid,
                stallno,
                batid,
                SUM(wareqty) AS wareqty
           FROM t_await_store_ware t
          WHERE t.compid = p_compid
            AND t.busno = p_busno
            AND t.wareid = p_wareid
          GROUP BY compid, busno, wareid, stallno, batid) t1
  ON (d.compid = t1.compid AND d.busno = t1.busno AND d.wareid = t1.wareid AND d.stallno = t1.stallno AND d.batid = t1.batid AND d.compid = p_compid AND d.busno = p_busno AND d.wareid = p_wareid)
  WHEN MATCHED THEN
    UPDATE SET d.awaitqty = t1.wareqty;
  --更新库存主表待出库（因批发定单存在不分配批号的商品，因此库存主表待出库都通过计算汇总，而不是走库存明细计算得到）
  MERGE INTO t_store_h h
  USING (SELECT compid,
                busno,
                wareid,
                SUM(CASE
                      WHEN t.batid <> 0 THEN
                       wareqty
                      ELSE
                       0
                    END) AS wareqty,
                SUM(CASE
                      WHEN t.batid = 0 THEN
                       wareqty
                      ELSE
                       0
                    END) AS awaitqty_nobatch
           FROM t_await_store_ware t
          WHERE t.compid = p_compid
            AND t.busno = p_busno
            AND t.wareid = p_wareid
         --AND ((t.batid <> 0 AND t.stallno <> 'ALL') OR t.billcode = 'WHO') --过滤掉不计批次的待出库 by ww 20161124
          GROUP BY compid, busno, wareid) t1
  ON (h.compid = t1.compid AND h.busno = t1.busno AND h.wareid = t1.wareid AND h.compid = p_compid AND h.busno = p_busno AND h.wareid = p_wareid)
  WHEN MATCHED THEN
    UPDATE
       SET h.sumawaitqty         = t1.wareqty,
           h.sumawaitqty_nobatch = t1.awaitqty_nobatch;
  --更新库存批号汇总表有批次的待出库
  MERGE INTO t_store_makeno m
  USING (SELECT t.compid,
                t.busno,
                t.wareid,
                i.makeno,
                i.ownerid,
                SUM(t.wareqty) AS wareqty
           FROM t_await_store_ware t
           JOIN t_store_i i
             ON t.batid = i.batid
            AND t.compid = i.compid
            AND t.wareid = i.wareid
          WHERE t.compid = p_compid
            AND t.busno = p_busno
            AND t.wareid = p_wareid
            AND t.batid <> 0
          GROUP BY t.compid, t.busno, t.wareid, i.makeno, i.ownerid) t1
  ON (m.compid = t1.compid AND m.busno = t1.busno AND m.wareid = t1.wareid AND m.makeno = t1.makeno AND m.ownerid = t1.ownerid AND m.compid = p_compid AND m.busno = p_busno AND m.wareid = p_wareid)
  WHEN MATCHED THEN
    UPDATE SET m.awaitqty = t1.wareqty;
  --更新库存批号汇总表不计批次待出库
  MERGE INTO t_store_makeno m
  USING (SELECT t.compid,
                t.busno,
                t.wareid,
                d.makeno,
                h.ownerid,
                SUM(t.wareqty) AS wareqty
           FROM t_await_store_ware t
           JOIN t_batsale_d d
             ON t.rowno = d.rowno
            AND t.wareid = d.wareid
            AND t.billno = d.batsaleno
           JOIN t_batsale_h h
             ON h.batsaleno = d.batsaleno
            AND h.billcode = t.billcode
          WHERE t.compid = p_compid
            AND t.busno = p_busno
            AND t.wareid = p_wareid
            AND t.billcode = 'WHL'
            AND t.batid = 0
            AND d.makeno <> 'ALL'
          GROUP BY t.compid, t.busno, t.wareid, d.makeno, h.ownerid) t1
  ON (m.compid = t1.compid AND m.busno = t1.busno AND m.wareid = t1.wareid AND m.makeno = t1.makeno AND m.ownerid = t1.ownerid AND m.compid = p_compid AND m.busno = p_busno AND m.wareid = p_wareid)
  WHEN MATCHED THEN
    UPDATE SET m.awaitqty = m.awaitqty + t1.wareqty;
  --更新货主库存汇总表有批次的待出库
  MERGE INTO t_store_owner o
  USING (SELECT t.compid,
                t.busno,
                t.wareid,
                i.ownerid,
                SUM(t.wareqty) AS wareqty
           FROM t_await_store_ware t
           JOIN t_store_i i
             ON t.batid = i.batid
            AND t.compid = i.compid
            AND t.wareid = i.wareid
          WHERE t.compid = p_compid
            AND t.busno = p_busno
            AND t.wareid = p_wareid
            AND t.batid <> 0
          GROUP BY t.compid, t.busno, t.wareid, i.ownerid) t1
  ON (o.compid = t1.compid AND o.busno = t1.busno AND o.wareid = t1.wareid AND o.ownerid = t1.ownerid AND o.compid = p_compid AND o.busno = p_busno AND o.wareid = p_wareid)
  WHEN MATCHED THEN
    UPDATE SET o.awaitqty = t1.wareqty;
  --更新货主库存汇总表不计批次待出库
  MERGE INTO t_store_owner o
  USING (SELECT t.compid,
                t.busno,
                t.wareid,
                h.ownerid,
                SUM(t.wareqty) AS wareqty
           FROM t_await_store_ware t
           JOIN t_batsale_d d
             ON t.rowno = d.rowno
            AND t.wareid = d.wareid
            AND t.billno = d.batsaleno
           JOIN t_batsale_h h
             ON h.batsaleno = d.batsaleno
            AND h.billcode = t.billcode
          WHERE t.compid = p_compid
            AND t.busno = p_busno
            AND t.wareid = p_wareid
            AND t.billcode = 'WHL'
            AND t.batid = 0
          GROUP BY t.compid, t.busno, t.wareid, h.ownerid) t1
  ON (o.compid = t1.compid AND o.busno = t1.busno AND o.wareid = t1.wareid AND o.ownerid = t1.ownerid AND o.compid = p_compid AND o.busno = p_busno AND o.wareid = p_wareid)
  WHEN MATCHED THEN
    UPDATE SET o.awaitqty = o.awaitqty + t1.wareqty;
  --删除屏蔽触发器
  DELETE FROM tmp_disable_trigger t
   WHERE t.table_name IN
         ('t_store_h', 't_store_d', 't_store_makeno', 't_store_owner');
  --特殊处理销售定单中有批号但无批次的待出库，需先分配批次信息，再锁相应批次待出库
  --前台销售按批次还是效期出库存 0：按批次，1：按效期
  v_para2825 := f_get_sys_inicode(p_compid  => p_compid,
                                  p_inicode => '2825',
                                  p_userid  => NULL);
  FOR line IN (SELECT bh.billcode,
                      bh.batorderno,
                      d.busno,
                      d.wareid,
                      d.batid,
                      d.stallno,
                      d.wareqty,
                      bh.vencusno,
                      bh.vencusname,
                      d.whlprice AS whlprice,
                      bh.lastmodify,
                      bh.saler,
                      checker1,
                      bh.checkbit1,
                      bh.checker2,
                      bh.checkbit2,
                      bh.checker3,
                      bh.checkbit3,
                      bh.checker4,
                      bh.checkbit4,
                      bh.checker5,
                      bh.checkbit5,
                      bh.compid,
                      d.rowno,
                      d.makeno,
                      bh.ownerid
                 FROM t_batorder_h bh, t_batorder_d d
                WHERE bh.batorderno = d.batorderno
                  AND (bh.compid = p_compid OR p_compid = 0)
                  AND (d.busno = p_busno OR p_busno = 0)
                  AND (d.wareid = p_wareid OR p_wareid = 0)
                  AND nvl(d.ifhang, 0) <> 1
                  AND bh.status <> 2
                  AND NOT EXISTS (SELECT 1
                         FROM t_batsale_d td
                        WHERE td.batorderno = d.batorderno
                          AND td.wareid = d.wareid)
                  AND d.makeno <> '全部')
  LOOP
    BEGIN
      SELECT MAX(d.wareid),
             MAX(wb.warecode),
         MAX(wb.warename),
             SUM(d.wareqty - d.awaitqty),
             MAX(d.batid)
        INTO v_wareid, v_warecode,v_warename, v_saleqty, v_batid
        FROM t_store_d d, t_store_i i, t_ware_base wb
       WHERE i.compid = d.compid
         AND i.wareid = d.wareid
         AND i.batid = d.batid
         AND d.wareid = wb.wareid
         AND d.compid = line.compid
         AND d.busno = line.busno
         AND d.wareid = line.wareid
         AND d.wareqty > 0
         AND TRIM(i.makeno) = TRIM(line.makeno);
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001,
                                '商品' || v_warecode || '(' || v_warename || ')在库存中不存在',
                                TRUE);
    END;
    IF v_saleqty < line.wareqty THEN
      /*    raise_application_error(-20001,
      '商品' || v_warename || '--' || v_batid ||
      '库存数量' || v_saleqty || '小于销售单批次数量',
      TRUE);*/
      EXIT;
    END IF;
    SELECT SUM(nvl(d.sumqty, 0)) - SUM(nvl(d.sumawaitqty, 0)) -
           SUM(nvl(d.sumdefectqty, 0)) - SUM(nvl(d.recallqty, 0))
      INTO v_saleqty
      FROM t_store_h d
     WHERE d.wareid = line.wareid
       AND d.compid = line.compid
       AND d.busno = line.busno;
    IF v_saleqty < line.wareqty THEN
      /*      raise_application_error(-20001,
      '商品' || v_warename || '--' || v_batid ||
      '总库存数量' || v_saleqty || '小于销售单批次数量',
      TRUE);*/
      dbms_output.put_line('商品' || v_warecode ||'('||v_warename|| ')--' || v_batid ||
                           '总库存数量' || v_saleqty || '小于销售单批次数量');
    END IF;
    v_wareqty := line.wareqty;
    FOR rec_store IN cur_store(line.ownerid,
                               v_para2825,
                               line.makeno,
                               line.batid)
    LOOP
      IF rec_store.wareqty - rec_store.awaitqty >= v_wareqty AND
         v_wareqty > 0 THEN
        INSERT INTO t_await_store_ware
          (billcode,
           billno,
           busno,
           wareid,
           batid,
           stallno,
           wareqty,
           vencusno,
           vendorname,
           price,
           createuser,
           buyerorsaler,
           checker1,
           checkbit1,
           checker2,
           checkbit2,
           checker3,
           checkbit3,
           checker4,
           checkbit4,
           checker5,
           checkbit5,
           compid,
           rowno)
        VALUES
          (line.billcode,
           line.batorderno,
           line.busno,
           line.wareid,
           rec_store.batid,
           rec_store.stallno,
           v_wareqty,
           line.vencusno,
           line.vencusname,
           line.whlprice,
           line.lastmodify,
           line.saler,
           line.checker1,
           line.checkbit1,
           line.checker2,
           line.checkbit2,
           line.checker3,
           line.checkbit3,
           line.checker4,
           line.checkbit4,
           line.checker5,
           line.checkbit5,
           line.compid,
           line.rowno);
        --待出库数量不能大于库存数量
        UPDATE t_store_d sd
           SET sd.awaitqty = sd.awaitqty + v_wareqty
         WHERE sd.compid = line.compid
           AND sd.busno = line.busno
           AND sd.wareid = line.wareid
           AND sd.stallno = rec_store.stallno
           AND sd.batid = rec_store.batid;
        EXIT;
      ELSE
        INSERT INTO t_await_store_ware
          (billcode,
           billno,
           busno,
           wareid,
           batid,
           stallno,
           wareqty,
           vencusno,
           vendorname,
           price,
           createuser,
           buyerorsaler,
           checker1,
           checkbit1,
           checker2,
           checkbit2,
           checker3,
           checkbit3,
           checker4,
           checkbit4,
           checker5,
           checkbit5,
           compid,
           rowno)
        VALUES
          (line.billcode,
           line.batorderno,
           line.busno,
           line.wareid,
           rec_store.batid,
           rec_store.stallno,
           rec_store.wareqty - rec_store.awaitqty, --:new.wareqty,
           line.vencusno,
           line.vencusname,
           line.whlprice,
           line.lastmodify,
           line.saler,
           line.checker1,
           line.checkbit1,
           line.checker2,
           line.checkbit2,
           line.checker3,
           line.checkbit3,
           line.checker4,
           line.checkbit4,
           line.checker5,
           line.checkbit5,
           line.compid,
           line.rowno);
        --待出库数量不能大于库存数量
        UPDATE t_store_d sd
           SET sd.awaitqty = sd.awaitqty + rec_store.wareqty -
                             rec_store.awaitqty
         WHERE sd.compid = line.compid
           AND sd.busno = line.busno
           AND sd.wareid = line.wareid
           AND sd.batid = rec_store.batid
           AND sd.stallno = rec_store.stallno;
        v_wareqty := v_wareqty - (rec_store.wareqty - rec_store.awaitqty);
      END IF;
    END LOOP;
  END LOOP;
  COMMIT; --此处COMMIT是为了调用的时候，调用者不commit, 有可能导致对库存相关表比较长时间的行锁等待
  --移仓申请单
  /*  v_para2825 := f_get_sys_inicode(p_compid  => p_compid,
  p_inicode => '2825',
  p_userid  => NULL);*/
END proc_recalculate_awaitqty;
/

