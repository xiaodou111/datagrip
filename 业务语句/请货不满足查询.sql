SELECT a.applyno,a.SAP_APPLYNO,a.busno,c.orgname, a.wareid,
 a.applqty, a.wareqty,(a.wareqty-a.applqty) wfh,b.EXECDATE,a.lasttime,b.status,DIST_FLAG FROM d_distapply_sap a 
LEFT JOIN T_distapply_h b ON a.APPLYNO=b.APPLYNO
LEFT JOIN s_busi c ON TRIM(a.busno)=TRIM(c.busno) 
LEFT JOIN t_ware_base d ON a.wareid=d.wareid WHERE
 a.wareqty-a.applqty<0 and
 (  a.busno = '84005' and  a.lasttime >= to_date('2023-03-01', 'yyyy-MM-dd') 
and a.lasttime < to_date('2023-03-10', 'yyyy-MM-dd')  ) and a.wareid=10228806

SELECT a.applyno,a.SAP_APPLYNO,a.busno,c.orgname, a.wareid,d.warename,d.WARESPEC,d.areacode,d.WAREUNIT,
 a.applqty, a.wareqty,(a.wareqty-a.applqty) wfh,b.EXECDATE FROM d_distapply_sap a 
LEFT JOIN T_distapply_h b ON a.APPLYNO=b.APPLYNO
LEFT JOIN s_busi c ON TRIM(a.busno)=TRIM(c.busno)
LEFT JOIN t_ware_base d ON a.wareid=d.wareid WHERE  a.wareqty-a.applqty<0 and (  a.busno = '84005' and  a.wareid = '10228806'  )

select * from d_distapply_sap a 
LEFT JOIN T_distapply_h b ON a.APPLYNO=b.APPLYNO 
WHERE a.wareqty-a.applqty<0 and a.busno = '84005'  and
b.execdate >= to_date('2023-03-01', 'yyyy-MM-dd') 
and b.execdate < to_date('2023-03-10', 'yyyy-MM-dd')

select * from d_distapply_sap where BUSNO='84005' and  LASTTIME>=date'2023-03-01' 
and wareid=10228806



select a.* from T_distapply_h a
inner join T_distapply_d b on a.applyno=b.applyno
 where a.SRCBUSNO='84005' and  LASTTIME >= to_date('2023-03-01', 'yyyy-MM-dd') 
  and b.wareid=10228806
