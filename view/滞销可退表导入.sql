create view V_ZXKT_IMPORT as
select d.execdate,s.compid,d.srcbusno,s.orgname,h.objbusno,s2.orgname as objorgname ,
cf_get_saleprice_hz(w.wareid,s.compid) lastsaleprice , d.wareid,w.warename,w.warespec, f_get_factoryname(w.factoryid) factoryname,w.WAREUNIT,
f_get_ware_classname(c.wareid,c.classgroupno,c.compid)jtgljb,
f_get_ware_classname(e.wareid,e.classgroupno,e.compid) khlb,
  d.batid,
d.makeno,
d.invalidate,
d.zzthsl,
d.zzthsl*cf_get_saleprice_hz(w.wareid,s.compid) AS ktje,
(td.WAREQTY-td.AWAITQTY) mddskc,
d.applyno,d.lastmodify,d.lasttime,td.stallno,
d.note,
d.importuser,

CASE WHEN dd.wareqty IS NULL THEN 0 ELSE 1 END AS ifcomplete,
dd.wareqty,
dd.check_nook_qty,
d.LIABLER --w.lastsaleprice,cf_get_saleprice_hz(w.wareid,s.compid) maxcount_saleprice


from d_zxkt_import d
left join T_DISTAPPLY_H h on h.APPLYNO=d.applyno

LEFT join T_DIST_d dd ON h.distno=dd.distno AND d.wareid=dd.wareid AND d.makeno=dd.makeno AND d.batid=dd.batid
left join s_busi s on  s.busno=d.srcbusno   --s.compid=h.compid and
left join s_busi s2 on  s2.busno=h.objbusno  --s2.compid=h.compid and
left join t_store_d td on td.compid=s.compid and td.wareid=d.wareid and td.busno=d.srcbusno and td.batid=d.batid and td.stallno like '%11'
--left join t_stall tl on tl.stallno=td.stallno and tl.compid=td.compid and tl.busno=td.busno and tl.stalltype='11'
left join t_ware w on w.wareid=d.wareid and w.compid=s.compid
left join t_ware_class_base c on c.wareid=d.wareid  and c.compid=s.compid and c.classgroupno=12
left join t_ware_class_base e on e.wareid=d.wareid  and e.compid=s.compid and e.classgroupno=90
/

