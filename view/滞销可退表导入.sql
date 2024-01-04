select d.execdate,s.compid,d.srcbusno,s.ZMDZ,s.orgname,h.objbusno,s2.orgname as objorgname ,
tws.SALEPRICE as lastsaleprice , d.wareid,w.warename,w.warespec, f.FACTORYNAME as factoryname,w.WAREUNIT,
c1.CLASSNAME as  jtgljb,c2.CLASSNAME as khlb,
d.batid,
d.makeno,
d.invalidate,
d.zzthsl,
d.zzthsl*tws.SALEPRICE AS ktje,
(td.WAREQTY-td.AWAITQTY) mddskc,
d.applyno,d.lastmodify,d.lasttime,td.stallno,
d.note,
d.importuser,
CASE WHEN dd.wareqty IS NULL THEN 0 ELSE 1 END AS ifcomplete,
dd.wareqty,
dd.check_nook_qty,
d.LIABLER 
from d_zxkt_import d
left join T_DISTAPPLY_H h on h.APPLYNO=d.applyno
LEFT join T_DIST_d dd ON h.distno=dd.distno AND d.wareid=dd.wareid AND d.makeno=dd.makeno AND d.batid=dd.batid
left join s_busi s on  s.busno=d.srcbusno   --s.compid=h.compid and
left join s_busi s2 on  s2.busno=h.objbusno  --s2.compid=h.compid and
left join t_store_d td on td.compid=s.compid and td.wareid=d.wareid and td.busno=d.srcbusno and td.batid=d.batid and td.stallno like '%11'
--left join t_stall tl on tl.stallno=td.stallno and tl.compid=td.compid and tl.busno=td.busno and tl.stalltype='11'
left join t_ware_base w on w.wareid=d.wareid
left join T_FACTORY f on w.FACTORYID=f.FACTORYID
left join t_ware_saleprice tws on w.WAREID=tws.WAREID and tws.COMPID=1000 and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001'
LEFT JOIN t_ware_class_base b1 ON w.wareid=b1.wareid AND b1.classgroupno=12 AND b1.compid=1000
LEFT JOIN t_class_base c1 ON b1.classcode=c1.classcode
LEFT JOIN t_ware_class_base b2 ON w.wareid=b2.wareid AND b2.classgroupno=90 AND b2.compid=1000
LEFT JOIN t_class_base c2 ON b2.classcode=c2.classcode