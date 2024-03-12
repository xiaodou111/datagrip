create or replace PROCEDURE proc_day_inout_hmk(p_busno IN VARCHAR2,
                                                 p_begindate IN DATE,
                                                 p_enddate IN DATE,
                                                 p_wareid IN VARCHAR2,
                                                 p_outcur OUT SYS_REFCURSOR) IS

  v_procname t_proc_rep.procrepname%TYPE;
  v_sql      VARCHAR2(2000);
  v_compid   NUMBER;
  v_orgname  s_busi.orgname%TYPE;
  v_wareid   t_ware.wareid%TYPE;
BEGIN
  --是否有替换储存过程
  BEGIN
    SELECT procrepname
      INTO v_procname
      FROM t_proc_rep
     WHERE upper(procname) = upper('proc_day_inout_hmk')
       AND status = 1;
  EXCEPTION
    WHEN no_data_found THEN
      v_procname := NULL;
  END;
  IF v_procname IS NOT NULL THEN
    BEGIN
      EXECUTE IMMEDIATE 'begin ' || v_procname || '(:1,:2,:3,:4,:5); end;'
        USING p_busno, p_begindate, p_enddate, p_wareid, p_outcur;
    END;
    RETURN;
  END IF;

  IF p_busno IS NULL THEN
    raise_application_error(-20001, '业务机构编码不能为空！');
  END IF;

  DELETE FROM temp_item_day_inout;
  DELETE FROM temp_item_in_out_hmk;

  BEGIN
    SELECT compid, orgname
      INTO v_compid, v_orgname
      FROM s_busi
     WHERE busno = p_busno;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, '业务机构 ' || p_busno || ' 不存在！', TRUE);
  END;

  --先查出商品编号，下面就无需再关联t_ware表
  IF p_wareid IS NOT NULL THEN
    BEGIN
      SELECT wareid
        INTO v_wareid
        FROM t_ware
       WHERE compid = v_compid
         AND warecode = p_wareid;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, '商品信息 ' || p_wareid || ' 不存在！',
                                TRUE);
    END;
  END IF;

  INSERT INTO temp_item_day_inout
    (busno, wareid, batchno, idno, stallno, beginqty, endqty, accqty,
     rejqty, disqty, dirqty, saleqty, macinqty, macoutqty, cheqty, whlqty,
     whrqty, addqty, adrqty, adpoutqty, adpinqty, abninqty, failureqty,
     purprice, saleamt, whlamt)
    SELECT a.busno, a.wareid, b.makeno, a.batid, a.stallno,
           wareqty AS beginqty, wareqty AS endqty, 0 AS accqty, 0 AS rejqty,
           0 AS disqty, 0 AS dirqty, 0 AS saleqty, 0 AS macinqty,
           0 AS macoutqty, 0 AS cheqty, 0 AS whlqty, 0 AS whrqty,
           0 AS addqty, 0 AS adrqty, 0 AS adpoutqty, 0 AS adpinqty,
           0 AS abninqty, 0 AS failureqty, b.purprice, 0 AS saleprice,
           0 AS whlprice
      FROM t_store_d a, t_store_i b --, t_ware c
     WHERE busno = p_busno
       AND a.wareid = b.wareid
       AND a.batid = b.batid
       AND (p_wareid IS NULL OR a.wareid = v_wareid)
          --AND a.wareid = c.wareid
          --AND c.compid = b.compid
          --AND (c.warecode = p_wareid OR p_wareid IS NULL)
       AND b.compid = v_compid;

  INSERT INTO temp_item_in_out_hmk
    (compid, billcode, execdate, busno, billname, vencuscode, vencusname,
     wareid, batchno, idno, inqty, outqty, acceptno, purprice, whlprice,
     makeno, stallno, createuser, saleprice, buyer, notes, rowno)
    SELECT compid, billcode, execdate, busno, billname, vencuscode,
           vencusname, wareid, batchno, idno, inqty, outqty, acceptno,
           purprice, whlprice, makeno, stallno, createuser, saleprice, buyer,
           notes, rowno
      FROM v_item_in_out_hmk
     WHERE compid = v_compid
       AND busno = p_busno
       AND execdate >= p_begindate
       AND (p_wareid IS NULL OR wareid = v_wareid);

  UPDATE temp_item_day_inout a
     SET beginqty =
          (a.beginqty - (SELECT nvl(SUM(b.inqty - b.outqty), 0) AS inoutqty
                           FROM temp_item_in_out_hmk b
                          WHERE a.busno = b.busno
                            AND a.wareid = b.wareid
                            AND a.idno = b.idno
                            AND a.stallno = b.stallno
                            AND a.batchno = b.batchno
                            AND b.execdate >= p_begindate
                            AND b.compid = v_compid));

  UPDATE temp_item_day_inout a
     SET endqty =
          (a.endqty - (SELECT nvl(SUM(b.inqty - b.outqty), 0) AS inoutqty
                         FROM temp_item_in_out_hmk b
                        WHERE a.busno = b.busno
                          AND a.wareid = b.wareid
                          AND a.idno = b.idno
                          AND a.stallno = b.stallno
                          AND a.batchno = b.batchno
                          AND b.execdate >= p_enddate + 1
                          AND b.compid = v_compid));

  INSERT INTO temp_item_day_inout
    (busno, wareid, batchno, idno, stallno, beginqty, endqty, accqty,
     rejqty, disqty, dirqty, saleqty, macinqty, macoutqty, cheqty, whlqty,
     whrqty, addqty, adrqty, adpoutqty, adpinqty, abninqty, failureqty,
     purprice, saleamt, whlamt)
    SELECT busno, a.wareid, batchno, idno, stallno, 0 AS beginqty,
           0 AS endqty, SUM(accqty), SUM(rejqty), SUM(disqty), SUM(dirqty),
           SUM(saleqty), SUM(macinqty), SUM(macoutqty), SUM(cheqty),
           SUM(whlqty), SUM(whrqty), SUM(addqty), SUM(adrqty),
           SUM(adpoutqty), SUM(adpinqty), SUM(abninqty), SUM(failureqty),
           MAX(purprice), SUM(nvl(round(saleprice * saleqty, 2), 0)),
           -- 20180123 mingbo modify
           --sum(nvl(round(whlprice * (whlqty - whrqty), 2), 0))
           SUM(nvl(round(whlprice * whlqty, 2), 0) -
                nvl(round(whlprice * whrqty, 2), 0))
      FROM v_item_in_out_hmk2 a --, t_ware b
     WHERE /*a.compid = b.compid
             AND a.wareid = b.wareid
             AND*/
     a.compid = v_compid
     AND a.busno = p_busno
     AND (p_wareid IS NULL OR a.wareid = v_wareid)
     AND a.execdate >= p_begindate
     AND a.execdate < p_enddate + 1
    --AND (b.warecode = p_wareid OR p_wareid IS NULL)
     GROUP BY a.busno, a.wareid, a.batchno, a.idno, a.stallno;
  if p_busno<>'8240539'  then
  v_sql := 'select a.busno as 业务机构,''' || v_orgname ||
           ''' as 机构名称,b.warecode as 商品编码,max(b.warename) as 商品名称,
          max(b.warespec) as 规格,max(d.factoryname) as 生产企业,max(b.wareunit) as 单位,
          sum(beginqty) as 期初数量,sum(round(beginqty*a.purprice,2)) as 期初金额,
          sum(accqty) as 入库数量,sum(round(accqty*a.purprice,2)) as 入库金额,
          sum(rejqty) as 退货数量,sum(round(rejqty*a.purprice,2)) as 退货金额,
          sum(disqty) as 配送数量,sum(round(disqty*a.purprice,2)) as 配送金额,
          sum(dirqty) as 退仓数量,sum(round(dirqty*a.purprice,2)) as 退仓金额,
          sum(saleqty) as 零售数量,sum(round(saleqty*a.purprice,2)) as 零售金额,
          sum(macinqty) as 加工入库数量,sum(round(macinqty*a.purprice,2)) as 加工入库金额,
          sum(macoutqty) as 加工出库数量,sum(round(macoutqty*a.purprice,2)) as 加工出库金额,
          sum(cheqty) as 盘点数量,sum(round(cheqty*a.purprice,2)) as 盘点金额,
          sum(whlqty) as 批发销售数量,sum(round(whlqty*a.purprice,2)) as 批发销售金额,
          sum(whrqty) as 批发退货数量,sum(round(whrqty*a.purprice,2)) as 批发退货金额,
          sum(addqty) as 加价调拨数量,sum(round(addqty*a.purprice,2)) as 加价调拨金额,
          sum(adrqty) as 加价调拨退回数量,sum(round(adrqty*a.purprice,2)) as 加价调拨退回金额,
          sum(round(adpoutqty*a.purprice,2)) as 调进价出金额,
          sum(round(adpinqty*a.purprice,2)) as 调进价入金额,
          sum(abninqty) as 损溢数量,sum(round(abninqty*a.purprice,2)) as 损溢金额,
          sum(failureqty) as 销毁数量,sum(round(failureqty*a.purprice,2)) as 销毁金额,
          sum(endqty) as 期末数量,sum(round(endqty*a.purprice,2)) as 期末金额
          from temp_item_day_inout a
          join t_ware b on a.wareid = b.wareid and b.compid = ' ||
           to_char(v_compid) || --'left join s_busi c on a.busno = c.busno
           '
          left join t_factory d on b.factoryid = d.factoryid
          group by a.busno,b.warecode';
  /*,sum(beginqty + accqty - rejqty + disqty - dirqty - saleqty +macinqty - macoutqty + cheqty - whlqty
  + whrqty + addqty - adrqty - adpoutqty + adpinqty - abninqty - failureqty - endqty)*/
  else
  v_sql := 'select a.busno as 业务机构,''' || v_orgname ||
           ''' as 机构名称,b.warecode as 商品编码,max(b.warename) as 商品名称,
          max(b.warespec) as 规格,max(d.factoryname) as 生产企业,max(b.wareunit) as 单位,
          sum(beginqty) as 期初数量,sum(round(beginqty*a.purprice,2)) as 期初金额,
          sum(accqty) as 入库数量,sum(round(accqty*a.purprice,2)) as 入库金额,
          sum(rejqty) as 退货数量,sum(round(rejqty*a.purprice,2)) as 退货金额,
          sum(disqty) as 配送数量,sum(round(disqty*a.purprice,2)) as 配送金额,
          sum(dirqty) as 退仓数量,sum(round(dirqty*a.purprice,2)) as 退仓金额,
          sum(saleqty) as 零售数量,sum(round(saleqty*a.purprice,2)) as 零售金额,
          sum(macinqty) as 加工入库数量,sum(round(macinqty*a.purprice,2)) as 加工入库金额,
          sum(macoutqty) as 加工出库数量,sum(round(macoutqty*a.purprice,2)) as 加工出库金额,
          sum(cheqty) as 盘点数量,sum(round(cheqty*a.purprice,2)) as 盘点金额,
          sum(whlqty) as 批发销售数量,sum(round(whlqty*a.purprice,2)) as 批发销售金额,
          sum(whrqty) as 批发退货数量,sum(round(whrqty*a.purprice,2)) as 批发退货金额,
          sum(addqty) as 加价调拨数量,sum(round(addqty*a.purprice,2)) as 加价调拨金额,
          sum(adrqty) as 加价调拨退回数量,sum(round(adrqty*a.purprice,2)) as 加价调拨退回金额,
          sum(round(adpoutqty*a.purprice,2)) as 调进价出金额,
          sum(round(adpinqty*a.purprice,2)) as 调进价入金额,
          sum(abninqty) as 损溢数量,sum(round(abninqty*a.purprice,2)) as 损溢金额,
          sum(failureqty) as 销毁数量,sum(round(failureqty*a.purprice,2)) as 销毁金额,
          sum(endqty) as 期末数量,sum(round(endqty*a.purprice,2)) as 期末金额
          from temp_item_day_inout a
          join t_ware b on a.wareid = b.wareid and b.compid = ' ||
           to_char(v_compid) || --'left join s_busi c on a.busno = c.busno
           '
          left join t_factory d on b.factoryid = d.factoryid' ||
           ' where a.wareid not in (select wareid from d_wz_ycml where busno = 8240144)
          group by a.busno,b.warecode';
  end if;
  OPEN p_outcur FOR v_sql;
  DBMS_OUTPUT.PUT_LINE('v_sql: ' || v_sql);
END proc_day_inout_hmk;

