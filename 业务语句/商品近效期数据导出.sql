SELECT b.compid as compid,
           s_busi.orgname as orgname,
                
                r.vencusname as vencusname,
                b.wareid as wareid,
                b.busno as busno,
                t.warecode as warecode,
                t.warename as warename,
                t.warespec as warespec,
                f.factoryname as factoryname,
                t.wareunit as wareunit,
                b.wareqty-b.awaitqty-b.pendingqty as wareqty,
                a.makeno as makeno,
                a.invalidate as invalidate,
                a.purprice as purprice,
                round(a.purprice * b.wareqty,2) as amount,
                a.ownerid as ownerid,
                b.stallno as stallno,
                (select z.zonename
                   from t_stall s, s_zone z
                  where s.stallno = b.stallno
                    and s.zoneno = z.zoneno
              and s.compid = z.compid
              and s.compid = b.compid
                    and s.busno = z.busno
                    and s.busno = b.busno) as zonename
 ,f_get_busno_classname('303',b.busno) as busiclassname303,
f_get_busno_classname('304',b.busno) as busiclassname304,
f_get_classname('12',b.wareid) as classname04,
f_get_classname('90',b.wareid) as class90,
f_get_saleprice(b.compid,max(s_busi.salegroupid),b.wareid) as saleprice,
f_get_classname('106',b.wareid) as classname106 FROM t_store_i a
  LEFT JOIN t_vencus r
    ON r.vencusno = a.vencusno
  LEFT JOIN t_factory f
    ON f.factoryid = a.factoryid, t_store_d b, t_ware t,s_busi s_busi
    left join t_busno_class_set se on se.busno=s.busno and se.classgroupno='303'
 WHERE a.compid = b.compid
   AND a.wareid = b.wareid
   AND t.wareid = a.wareid
   AND t.compid = a.compid
   AND a.batid = b.batid
   AND (a.invalidate - SYSDATE) < 390
   AND  b.wareqty-b.awaitqty-b.pendingqty >0
  AND b.compid =s_busi.compid
  and b.busno = s_busi.busno
   and substr(b.stallno, 1, 1) <> 'R'
   and se.classcode='303100'
group by 
   b.compid ,
           s_busi.orgname ,
               
                r.vencusname ,
                b.wareid ,
                b.busno ,
                t.warecode ,
                t.warename ,
                t.warespec ,
                f.factoryname ,
                t.wareunit ,
                b.wareqty-b.awaitqty-b.pendingqty,
                a.makeno ,
                a.invalidate ,
                a.purprice ,
                round(a.purprice * b.wareqty,2) ,
                a.ownerid ,
                b.stallno
