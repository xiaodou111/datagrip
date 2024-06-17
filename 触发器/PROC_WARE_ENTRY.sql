create PROCEDURE proc_ware_entry(p_execdate IN DATE, p_compid IN s_company.compid%TYPE, p_busno IN s_busi.busno%TYPE, p_billcode s_bill.billcode%TYPE, p_billno s_bill.serialtype%TYPE, p_rowno NUMBER, p_wareid t_ware.wareid%TYPE, p_batid t_store_d.batid%TYPE, p_stallno t_stall.stallno%TYPE, p_avgprice_ind NUMBER,
                                            --是否需要计算加权平均单价,如:零售等操作便不需要计算加权平均单价.
                                            p_newqty NUMBER, p_newprice NUMBER, p_objname t_store_inout_list.objname%TYPE,
                                            --该业务对应的单位名称,便于查询商品流向.
                                            out_newavgprice OUT NUMBER) IS

    /*
     用于入库/出库时计算加权进价以及处理库存变化
    */
    v_oldavgprice  t_store_h.storepurprice%TYPE;
    v_old_sumqty   t_store_h.sumqty%TYPE;
    v_new_avgprice t_store_h.storepurprice%TYPE;
    --成本核算方式
    v_para1301 s_sys_ini.inipara%TYPE;
    v_avgsum   t_store_inout_list.avgsum%TYPE;
    v_actsum   t_store_inout_list.actsum%TYPE;
    v_difsum   t_store_inout_list.difsum%TYPE;

    v_factoryname    t_factory.factoryname%TYPE;
    v_areaname       t_area.areaname%TYPE;
    v_classname      t_class_base.classname%TYPE;
    v_procname       t_proc_rep.procrepname%TYPE;
    v_zoneno         t_stall.zoneno%TYPE;
    v_period         s_period.period%TYPE;
    v_storebak_count INTEGER;
    v_inoutqty       NUMBER;
    v_purtax         t_store_inout_list.purtax%TYPE;
    v_stdtomin       t_ware.minqty%TYPE;
    v_makeno         t_store_i.makeno%TYPE;
BEGIN

    UPDATE s_busi SET launch_date = SYSDATE WHERE busno = p_busno AND launch_date IS NULL;

    --是否有替换储存过程start
    BEGIN
        SELECT procrepname
        INTO   v_procname
        FROM   t_proc_rep
        WHERE  upper(procname) = upper('proc_ware_entry') AND status = 1;
    EXCEPTION
        WHEN no_data_found THEN
            v_procname := NULL;
    END;
    IF v_procname IS NOT NULL THEN
    
        BEGIN
            EXECUTE IMMEDIATE 'begin ' || v_procname ||
                              '(:1, :2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14); end;'
                USING p_execdate, p_compid, p_busno, p_billcode, p_billno, p_rowno, p_wareid, p_batid, p_stallno, p_avgprice_ind, p_newqty, p_newprice, p_objname, OUT out_newavgprice;
        END;
        RETURN;
    END IF;
    --是否有替换储存过程end

    /*yx 20160418 考虑零售脱机的问题，如果脱机数据跨月才上传，那么查找该月是否有库存备份，如果该月有备份，则修改该月的备份库存减去本次销售数量*/
    IF upper(p_billcode) = 'SAL' THEN
        SELECT COUNT(1), MAX(t.period)
        INTO   v_storebak_count, v_period
        FROM   t_store_d_bak t, s_period s
        WHERE  t.compid = s.compid AND t.period = s.period AND t.compid = p_compid AND t.busno = p_busno AND
               t.wareid = p_wareid AND t.stallno = p_stallno AND t.batid = p_batid AND
               trunc(p_execdate) BETWEEN s.begindate AND s.enddate;
        IF v_storebak_count > 0 THEN
            UPDATE t_store_d_bak
            SET    wareqty = wareqty + p_newqty
            WHERE  period = v_period AND compid = p_compid AND busno = p_busno AND wareid = p_wareid AND
                   stallno = p_stallno AND batid = p_batid;
        END IF;
    END IF;

    BEGIN
        SELECT minqty INTO v_stdtomin FROM t_ware WHERE compid = p_compid AND wareid = p_wareid;
    EXCEPTION
        WHEN no_data_found THEN
            NULL;
    END;

    IF nvl(v_stdtomin, 0) <= 1 THEN
        v_stdtomin := 1;
    END IF;

    --加上INSERT部分主要是为了防止库存明细中不存在的情况
    /*dbms_output.put_line('p_compid:' || to_char(p_compid)); --输出变量值
    dbms_output.put_line('p_busno:' || to_char(p_busno)); --输出变量值
    dbms_output.put_line('p_billcode:' || to_char(p_billcode)); --输出变量值
    dbms_output.put_line('p_billno:' || to_char(p_billno)); --输出变量值
    dbms_output.put_line('p_rowno:' || to_char(p_rowno)); --输出变量值
    dbms_output.put_line('p_wareid:' || to_char(p_wareid)); --输出变量值
    dbms_output.put_line('p_batid:' || to_char(p_batid)); --输出变量值
    dbms_output.put_line('p_stallno:' || to_char(p_stallno)); --输出变量值*/

    MERGE INTO t_store_d sd
    USING (SELECT p_compid compid, p_busno busno, p_wareid wareid, p_batid batid, p_stallno stallno FROM dual) t
    ON (sd.compid = t.compid AND sd.busno = t.busno AND sd.wareid = t.wareid AND sd.batid = t.batid AND sd.stallno = t.stallno)
    WHEN MATCHED THEN
        UPDATE
        SET    sd.wareqty     = sd.wareqty + p_newqty,
               sd.lastaccdate =
               (CASE
                   WHEN p_billcode = 'SAL' THEN
                    SYSDATE
                   ELSE
                    sd.lastaccdate
               END),
               /*只有零售时记录 lastaccdate*/
               sd.wareqty_min =
               (CASE
                   WHEN sd.wareqty_min IS NOT NULL THEN
                    sd.wareqty_min + (p_newqty * v_stdtomin)
                   ELSE
                    sd.wareqty_min
               END) WHEN NOT MATCHED THEN INSERT(compid, busno, stallno, wareid, batid, wareqty, awaitqty, pendingqty, lastmaintaindate, wareqty_min) VALUES(p_compid, p_busno, p_stallno, p_wareid, p_batid, p_newqty, 0, 0, SYSDATE, p_newqty * v_stdtomin);

    --同步调整零售的拆零库存
    IF upper(p_billcode) <> 'SAL' THEN
        IF f_get_sys_inicode(p_compid, '2751', NULL) = '1' THEN
            proc_split_adj(p_compid => p_compid, p_busno => p_busno, p_wareid => p_wareid,
                           p_stallno => p_stallno, p_batid => p_batid, p_billcode => p_billcode,
                           p_billno => p_billno);
        END IF;
    END IF;

    v_para1301 := f_get_sys_inicode(p_compid, '1301', NULL);

    BEGIN
        SELECT a.storepurprice, a.sumqty
        INTO   v_oldavgprice, v_old_sumqty
        FROM   t_store_h a
        WHERE  a.compid = p_compid AND a.busno = p_busno AND a.wareid = p_wareid;
    EXCEPTION
        WHEN no_data_found THEN
            v_oldavgprice := 0;
            v_old_sumqty  := 0;
    END;

    --需要重新加权
    IF p_avgprice_ind = 1 AND v_para1301 <> '3' THEN
        IF v_old_sumqty <= 0 OR (v_old_sumqty + p_newqty) = 0 THEN
            v_new_avgprice := p_newprice;
        ELSE
            v_new_avgprice := ((v_old_sumqty * v_oldavgprice + p_newprice * p_newqty)) /
                              (v_old_sumqty + p_newqty);
        
            --2.分析加权单价是否在允许范围内(不大于/小于新批次进价*1.5),否则以最新进价作为加权单价
            IF v_new_avgprice > p_newprice * 1.5 OR v_new_avgprice * 1.5 < p_newprice THEN
            
                IF p_billcode = 'REJ' THEN
                    v_new_avgprice := v_oldavgprice;
                ELSE
                    v_new_avgprice := p_newprice;
                END IF;
            
                IF v_new_avgprice < 0 THEN
                    v_new_avgprice := p_newprice;
                END IF;
            
            END IF;
        
        END IF;
    
        --3.计算应得合计\实得合计\差异
        v_avgsum := round(v_old_sumqty * v_oldavgprice + p_newqty * p_newprice, 2);
        v_actsum := round((v_old_sumqty + p_newqty) * v_new_avgprice, 2);
        v_difsum := v_actsum - v_avgsum;
    
        UPDATE t_store_h h
        SET    h.storepurprice = v_new_avgprice
        WHERE  h.compid = p_compid AND h.busno = p_busno AND h.wareid = p_wareid AND
               h.storepurprice <> v_new_avgprice;
    
    END IF;

    IF p_avgprice_ind = 1 OR v_para1301 = '3' THEN
    
        v_new_avgprice := v_oldavgprice;
        v_actsum       := round((p_newqty + v_old_sumqty) * v_oldavgprice, 2);
        v_avgsum       := round((p_newqty + v_old_sumqty) * v_oldavgprice, 2);
        v_difsum       := 0;
        ----如果是月底加权，则月底加权后回写这些字段。
        IF v_para1301 = '3' THEN
            v_new_avgprice := 0;
            v_actsum       := 0;
            v_avgsum       := 0;
            v_difsum       := 0;
        END IF;
    
    END IF;

    IF p_billcode = 'ACC' THEN
        BEGIN
            SELECT f.factoryname
            INTO   v_factoryname
            FROM   t_accept_d ad, t_factory f
            WHERE  ad.acceptno = p_billno AND ad.rowno = p_rowno AND ad.factoryid = f.factoryid;
        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT f.factoryname
                    INTO   v_factoryname
                    FROM   t_ware vw, t_factory f --v_ware
                    WHERE  vw.wareid = p_wareid AND vw.compid = p_compid AND vw.factoryid = f.factoryid;
                
                EXCEPTION
                    WHEN no_data_found THEN
                        v_factoryname := NULL;
                END;
        END;
    
        BEGIN
            SELECT a.areaname
            INTO   v_areaname
            FROM   t_accept_d ad, t_area a
            WHERE  ad.acceptno = p_billno AND ad.rowno = p_rowno AND ad.areacode = a.areacode;
        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT a.areaname
                    INTO   v_areaname
                    FROM   t_ware vw, t_area a --v_ware
                    WHERE  vw.wareid = p_wareid AND vw.compid = p_compid AND vw.areacode = a.areacode;
                
                EXCEPTION
                    WHEN no_data_found THEN
                        v_areaname := NULL;
                END;
        END;
    
        BEGIN
            SELECT ad.purtax
            INTO   v_purtax
            FROM   t_accept_d ad
            WHERE  ad.acceptno = p_billno AND ad.rowno = p_rowno;
        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT vw.purtax
                    INTO   v_purtax
                    FROM   t_ware vw
                    WHERE  vw.wareid = p_wareid AND vw.compid = p_compid;
                EXCEPTION
                    WHEN no_data_found THEN
                        v_purtax := NULL;
                END;
        END;
    ELSE
    
        BEGIN
            SELECT f.factoryname
            INTO   v_factoryname
            FROM   t_store_i i, t_factory f
            WHERE  i.factoryid = f.factoryid AND i.compid = p_compid AND i.wareid = p_wareid AND
                   i.batid = p_batid;
        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT f.factoryname
                    INTO   v_factoryname
                    FROM   t_ware vw, t_factory f --v_ware
                    WHERE  vw.wareid = p_wareid AND vw.compid = p_compid AND vw.factoryid = f.factoryid;
                
                EXCEPTION
                    WHEN no_data_found THEN
                        v_factoryname := NULL;
                END;
        END;
    
        BEGIN
            SELECT a.areaname
            INTO   v_areaname
            FROM   t_store_i i, t_area a
            WHERE  i.areacode = a.areacode AND i.compid = p_compid AND i.wareid = p_wareid AND
                   i.batid = p_batid;
        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT a.areaname
                    INTO   v_areaname
                    FROM   t_ware vw, t_area a --v_ware
                    WHERE  vw.wareid = p_wareid AND vw.compid = p_compid AND vw.areacode = a.areacode;
                
                EXCEPTION
                    WHEN no_data_found THEN
                        v_areaname := NULL;
                END;
        END;
    
        BEGIN
            SELECT i.purtax
            INTO   v_purtax
            FROM   t_store_i i
            WHERE  i.compid = p_compid AND i.wareid = p_wareid AND i.batid = p_batid;
        EXCEPTION
            WHEN no_data_found THEN
                BEGIN
                    SELECT vw.purtax
                    INTO   v_purtax
                    FROM   t_ware vw
                    WHERE  vw.wareid = p_wareid AND vw.compid = p_compid;
                EXCEPTION
                    WHEN no_data_found THEN
                        v_purtax := NULL;
                END;
        END;
    END IF;

    --调进价单处理purtax字段 add by ww 20170801
    IF p_billcode = 'ADP' THEN
        IF p_newqty < 0 THEN
            --调整前
            BEGIN
                SELECT ad.purtaxo
                INTO   v_purtax
                FROM   t_adjust_purprice_d ad
                WHERE  ad.adjustno = p_billno AND ad.rowno = p_rowno;
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;
        ELSIF p_newqty > 0 THEN
            --调整后
            BEGIN
                SELECT ad.purtax
                INTO   v_purtax
                FROM   t_adjust_purprice_d ad
                WHERE  ad.adjustno = p_billno AND ad.rowno = p_rowno;
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;
        END IF;
    END IF;

    BEGIN
        SELECT c.classname
        INTO   v_classname
        FROM   t_ware_class_base b, t_class_base c
        WHERE  b.wareid = p_wareid AND b.classcode = c.classcode AND b.classgroupno = '18' AND
               b.compid = (CASE
                   WHEN EXISTS (SELECT 1
                         FROM   t_ware_class_base twcb
                         WHERE  twcb.compid = p_compid AND twcb.wareid = b.wareid) THEN
                    p_compid
                   ELSE
                    0
               END);
    EXCEPTION
        WHEN no_data_found THEN
            v_classname := NULL;
    END;
    BEGIN
        SELECT t.zoneno
        INTO   v_zoneno
        FROM   t_stall t
        WHERE  t.stallno = p_stallno AND t.busno = p_busno AND t.compid = p_compid AND rownum = 1;
    EXCEPTION
        WHEN no_data_found THEN
            v_zoneno := NULL;
    END;

    BEGIN
        SELECT i.makeno
        INTO   v_makeno
        FROM   t_store_i i
        WHERE  i.compid = p_compid AND i.wareid = p_wareid AND i.batid = p_batid;
    EXCEPTION
        WHEN no_data_found THEN
            v_makeno := NULL;
    END;

    INSERT INTO t_store_inout_list
        (compid, execdate, busno, wareid, billcode, billno, rowno, oldqty, oldvagprice, inqty, newprice,
         avgsum, actsum, difsum, newavgpurprice, inoutid, objname, batid, makeno, stallno, zoneno, factoryname,
         areaname, classname, purtax)
    VALUES
        (p_compid, p_execdate, p_busno, p_wareid, p_billcode, p_billno, p_rowno, nvl(v_old_sumqty, 0),
         nvl(v_oldavgprice, 0), p_newqty, nvl(p_newprice, 0), nvl(v_avgsum, 0), nvl(v_actsum, 0),
         nvl(v_difsum, 0), nvl(v_new_avgprice, nvl(p_newprice, 0)), seq_store_inout_list.nextval, p_objname,
         p_batid, v_makeno, p_stallno, v_zoneno, v_factoryname, v_areaname, v_classname, v_purtax);

    out_newavgprice := nvl(v_new_avgprice, p_newprice);

    --产生断货记录 2017/03/10 
    --库存主表增加（或修改）触发器，当库存有变化时进行判断：
    --如果业务操作前库存大于0，业务操作后库存小于等于0，则写入 商品断货记录表 一条断货记录；
    --如果业务操作前库存小于等于0，业务操作后库存大于0，则写入 商品断货记录表 一条有货记录。
    ---ing 2017.06.09中智大药房增加  LASTBREAKDATE N DATE  Y     最新断货时间
    ----                              LASTBREAKDHDATE N DATE  Y     最新断货后来货时间

    IF v_old_sumqty = 0 THEN
        --增加字段：  单据类型，单据编码，业务对象名称  2016/7/13 ybh
        --断货
        INSERT INTO t_inout_break
            (breakid, compid, execdate, busno, wareid, flag, inoutqty, endqty, stamp, srcinoutqty, billcode,
             billno, objname)
        VALUES
            (seq_inout_break.nextval, p_compid, p_execdate, p_busno, p_wareid, 0, v_old_sumqty, p_newqty,
             seq_stamp.nextval, v_old_sumqty, p_billcode, p_billno, p_objname);
        ----ing 2017.06.09 中智更新t_store_h最新断货时间
        UPDATE t_store_h h
        SET    h.lastbreakdate = p_execdate, h.lastbreakdhdate = NULL /*既然断货了，就把最新断货后来货时间LASTBREAKDHDATE清空*/
        WHERE  h.compid = p_compid AND h.busno = p_busno AND h.wareid = p_wareid;
    END IF;

    v_inoutqty := v_old_sumqty - p_newqty;
    IF v_inoutqty = 0 THEN
        ---到货
        INSERT INTO t_inout_break
            (breakid, compid, execdate, busno, wareid, flag, inoutqty, endqty, stamp, srcinoutqty, billcode,
             billno, objname)
        VALUES
            (seq_inout_break.nextval, p_compid, p_execdate, p_busno, p_wareid, 1, v_old_sumqty, p_newqty,
             seq_stamp.nextval, v_old_sumqty, p_billcode, p_billno, p_objname
             
             );
    
        ----ing 2017.06.09 中智更新t_store_h最新断货后来货时间
        UPDATE t_store_h h
        SET    h.lastbreakdhdate = p_execdate
        WHERE  h.compid = p_compid AND h.busno = p_busno AND h.wareid = p_wareid;
    END IF;

END proc_ware_entry;
/

