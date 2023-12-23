create or replace procedure p_dir_auto_zx_import(p_busno d_zxkt_import.srcbusno%type )
as
v_applyno t_distapply_h.applyno%TYPE;
v_billcode t_distapply_h.billcode%TYPE;
v_objstallno t_store_d.stallno%TYPE;
v_userid s_user_base.userid%TYPE;
v_objbusno t_distapply_h.srcbusno%TYPE;
v_compid s_busi.compid%type;
v_valid_ind integer;
--v_execdate d_zxkt_import.execdate %type;
--v_wareid d_zxkt_import.wareid%type;
--v_batid d_zxkt_import.batid%type;
rows_h_insert NUMBER;
rows_d_insert NUMBER;
v_thy NUMBER;
v_thy2  NUMBER;

begin
v_billcode:='RAP';
v_userid:='168';
--raise_application_error(-20001, '功能正在调整,请稍等！');

SELECT COUNT(*)
INTO   v_valid_ind
from d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ';
IF v_valid_ind = 0 THEN
    raise_application_error(-20001, '没有可以转退仓申请单的明细，请检查！');
END IF;

select distinct compid into v_compid from s_busi where busno=p_busno;
v_applyno := f_get_serial(v_billcode, v_compid);
DBMS_OUTPUT.PUT_LINE('生成的退仓单号:'||v_applyno);



 
BEGIN
IF v_compid IN(3340,1080) then
  v_objbusno:=10600000;
else  
  select distinct busno into v_objbusno from s_busi where compid=v_compid and orgtype='10'; 
END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    raise_application_error(-20001, '公司编号'||v_compid||'没有对应的仓库编号');    
end;
 DBMS_OUTPUT.PUT_LINE('生成的仓库编号:'||v_objbusno);
 

 select count(*)
 into v_thy
 from
 d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ' AND  (LIABLER<>'50003636' OR LIABLER IS NULL);

 select count(*)
 into v_thy2
 from
 d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ' AND LIABLER='50003636';

 --rec.compid
  DBMS_OUTPUT.PUT_LINE('1');
BEGIN
select distinct stallno into v_objstallno from t_stall where busno = p_busno and stalltype='11';
 DBMS_OUTPUT.PUT_LINE('生成的货位号:'||v_objstallno);
       /*IF v_objstallno IS NULL THEN
       raise_application_error(-20001, '门店编号'||p_busno||'没有对应的货位号');
       END IF;*/
EXCEPTION
   WHEN NO_DATA_FOUND THEN
    raise_application_error(-20001,'门店编号'||p_busno||'没有对应的货位号');    
end;
--转单明细责任人有50003636和非50003636的需要进行分单
 if v_thy>0 and v_thy2>0 then

INSERT INTO t_distapply_h
            (applyno, compid, billcode, srcbusno,objbusno, createuser, createtime, lastmodify, lasttime,APPNOTE,
             status, checkbit1, checkbit2, checkbit3, checkbit4, checkbit5, cashtype, notes, pickuptype,
             pickupuser, creditamt_bal, creditday_bal,reason)
VALUES(v_applyno, v_compid, v_billcode,p_busno, v_objbusno, v_userid,SYSDATE,v_userid,
sysdate,'滞销自动生成',0, 0, 0, 0, 0, 0, '01', '滞销自动生成',null,null,null,null,3);

rows_h_insert := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('rows_h_insert: ' || rows_h_insert);

INSERT INTO t_distapply_d
(applyno,wareid,safeqty,overqty,storeqty,applyqty,salemonqty,purprice,saleprice,checkqty,actualqty,
batid,makeno,invalidate,stallno,rowno,notes,srcstallno,wareqty,distqty,PARITYFLAG,LIABLER)
 select v_applyno,wareid,0.00,0.00,0.00,max(zzthsl),0.00,0,0,max(zzthsl),max(zzthsl),
batid,max(makeno),max(invalidate),'/',max(rownum),4,v_objstallno,max(zzthsl),max(zzthsl),0,nvl(LIABLER,'50002455')
from d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ' AND  (LIABLER<>'50003636' OR LIABLER IS NULL)
group by srcbusno,wareid,batid,LIABLER;

FOR res IN (SELECT execdate,srcbusno,wareid,batid,makeno,applyno,zzthsl FROM d_zxkt_import_tc
  where nvl(APPLYNO,' ')=' '
  ) LOOP
  update d_zxkt_import set APPLYNO=v_applyno where srcbusno=p_busno and nvl(APPLYNO,' ')=' '
  AND execdate=res.execdate AND wareid=res.wareid AND batid=res.batid AND makeno=res.makeno
  AND (LIABLER<>'50003636' OR LIABLER IS NULL)
  ;
END LOOP;


v_applyno := f_get_serial(v_billcode, v_compid);

--50003636的和不是50003636的分单
INSERT INTO t_distapply_h
            (applyno, compid, billcode, srcbusno,objbusno, createuser, createtime, lastmodify, lasttime,APPNOTE,
             status, checkbit1, checkbit2, checkbit3, checkbit4, checkbit5, cashtype, notes, pickuptype,
             pickupuser, creditamt_bal, creditday_bal,reason)
VALUES(v_applyno, v_compid, v_billcode,p_busno, v_objbusno, v_userid,SYSDATE,v_userid,
sysdate,'滞销自动生成',0, 0, 0, 0, 0, 0, '01', '滞销自动生成',null,null,null,null,3);

rows_h_insert := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('rows_h_insert: ' || rows_h_insert);

INSERT INTO t_distapply_d
(applyno,wareid,safeqty,overqty,storeqty,applyqty,salemonqty,purprice,saleprice,checkqty,actualqty,
batid,makeno,invalidate,stallno,rowno,notes,srcstallno,wareqty,distqty,PARITYFLAG,LIABLER)
 select v_applyno,wareid,0.00,0.00,0.00,max(zzthsl),0.00,0,0,max(zzthsl),max(zzthsl),
batid,max(makeno),max(invalidate),'/',max(rownum),4,v_objstallno,max(zzthsl),max(zzthsl),0,nvl(LIABLER,'50003636')
from d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ' AND LIABLER='50003636'
group by srcbusno,wareid,batid,LIABLER;

FOR res IN (SELECT execdate,srcbusno,wareid,batid,makeno,applyno,zzthsl FROM d_zxkt_import_tc
  where nvl(APPLYNO,' ')=' '
  ) LOOP
  update d_zxkt_import set APPLYNO=v_applyno where srcbusno=p_busno and nvl(APPLYNO,' ')=' '
  AND execdate=res.execdate AND wareid=res.wareid AND batid=res.batid AND makeno=res.makeno
  AND LIABLER='50003636'
  ;
END LOOP;

  end if;
 --转单明细责任人<>'50003636' OR 责任人 IS NULL,只生成一单
if v_thy>0 and v_thy2=0 then
  INSERT INTO t_distapply_h
            (applyno, compid, billcode, srcbusno,objbusno, createuser, createtime, lastmodify, lasttime,APPNOTE,
             status, checkbit1, checkbit2, checkbit3, checkbit4, checkbit5, cashtype, notes, pickuptype,
             pickupuser, creditamt_bal, creditday_bal,reason)
VALUES(v_applyno, v_compid, v_billcode,p_busno, v_objbusno, v_userid,SYSDATE,v_userid,
sysdate,'滞销自动生成',0, 0, 0, 0, 0, 0, '01', '滞销自动生成',null,null,null,null,3);

rows_h_insert := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('rows_h_insert: ' || rows_h_insert);

INSERT INTO t_distapply_d
(applyno,wareid,safeqty,overqty,storeqty,applyqty,salemonqty,purprice,saleprice,checkqty,actualqty,
batid,makeno,invalidate,stallno,rowno,notes,srcstallno,wareqty,distqty,PARITYFLAG,LIABLER)
 select v_applyno,wareid,0.00,0.00,0.00,max(zzthsl),0.00,0,0,max(zzthsl),max(zzthsl),
batid,max(makeno),max(invalidate),'/',max(rownum),4,v_objstallno,max(zzthsl),max(zzthsl),0,nvl(LIABLER,'50002455')
from d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ' AND  (LIABLER<>'50003636' OR LIABLER IS NULL)
group by srcbusno,wareid,batid,LIABLER;

FOR res IN (SELECT execdate,srcbusno,wareid,batid,makeno,applyno,zzthsl FROM d_zxkt_import_tc
  where nvl(APPLYNO,' ')=' '
  ) LOOP
  update d_zxkt_import set APPLYNO=v_applyno where srcbusno=p_busno and nvl(APPLYNO,' ')=' '
  AND execdate=res.execdate AND wareid=res.wareid AND batid=res.batid AND makeno=res.makeno
  AND (LIABLER<>'50003636' OR LIABLER IS NULL)
  ;
END LOOP;

end if;
--转单明细责任人只有'50003636'的只生成一单
if v_thy=0 and v_thy2>0 then
  INSERT INTO t_distapply_h
            (applyno, compid, billcode, srcbusno,objbusno, createuser, createtime, lastmodify, lasttime,APPNOTE,
             status, checkbit1, checkbit2, checkbit3, checkbit4, checkbit5, cashtype, notes, pickuptype,
             pickupuser, creditamt_bal, creditday_bal,reason)
VALUES(v_applyno, v_compid, v_billcode,p_busno, v_objbusno, v_userid,SYSDATE,v_userid,
sysdate,'滞销自动生成',0, 0, 0, 0, 0, 0, '01', '滞销自动生成',null,null,null,null,3);

rows_h_insert := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('rows_h_insert: ' || rows_h_insert);

INSERT INTO t_distapply_d
(applyno,wareid,safeqty,overqty,storeqty,applyqty,salemonqty,purprice,saleprice,checkqty,actualqty,
batid,makeno,invalidate,stallno,rowno,notes,srcstallno,wareqty,distqty,PARITYFLAG,LIABLER)
 select v_applyno,wareid,0.00,0.00,0.00,max(zzthsl),0.00,0,0,max(zzthsl),max(zzthsl),
batid,max(makeno),max(invalidate),'/',max(rownum),4,v_objstallno,max(zzthsl),max(zzthsl),0,nvl(LIABLER,'50003636')
from d_zxkt_import_tc where srcbusno=p_busno and nvl(APPLYNO,' ')=' ' AND LIABLER='50003636'
group by srcbusno,wareid,batid,LIABLER;

FOR res IN (SELECT execdate,srcbusno,wareid,batid,makeno,applyno,zzthsl FROM d_zxkt_import_tc
  where nvl(APPLYNO,' ')=' '
  ) LOOP
  update d_zxkt_import set APPLYNO=v_applyno where srcbusno=p_busno and nvl(APPLYNO,' ')=' '
  AND execdate=res.execdate AND wareid=res.wareid AND batid=res.batid AND makeno=res.makeno
  AND LIABLER='50003636'
  ;
END LOOP;
end if;
  commit;

end p_dir_auto_zx_import;
