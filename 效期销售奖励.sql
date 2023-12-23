SELECT sa.saleno,dr.zdate AS finaltime,sa.accdate, tb.classname,tb1.classname,dr.srcbusno,dr.objbusno,a.orgname,dr.wareid,w.warename,w.warespec,w.wareunit,f.factoryname,
SUBSTR(e.PARENT_CLASSCODE,2,INSTR(e.PARENT_CLASSCODE,';',1,2)-INSTR(e.PARENT_CLASSCODE,';',1,1)-1) big,
SUBSTR(e.PARENT_CLASSCODE,INSTR(e.PARENT_CLASSCODE,';',1,2)+1,INSTR(e.PARENT_CLASSCODE,';',1,3)-INSTR(e.PARENT_CLASSCODE,';',1,2)-1) middle,
SUBSTR(e.PARENT_CLASSCODE,INSTR(e.PARENT_CLASSCODE,';',1,3)+1,INSTR(e.PARENT_CLASSCODE,';',1,4)-INSTR(e.PARENT_CLASSCODE,';',1,3)-1) SMALL,
DECODE(dd.PARENT_CLASSCODE,'未划分;','',replace(substr(dd.PARENT_CLASSCODE,2,length(dd.PARENT_CLASSCODE) - 2), ';', ' - ')) gljb,
dr.makeno,dr.invalidate,sa.NETPRICE,
CASE WHEN ab.sunyisl IS NULL THEN '销售' ELSE CASE WHEN ab.sunyisl>0 THEN '盘盈' ELSE '盘亏' END END AS leixing,
ABS(ab.sunyisl) sunyisl,dr.wareqty AS zbsl,sa.SALENUM,
CASE WHEN sa.sysl IS NULL THEN dr.wareqty 
  ELSE CASE  WHEN sa.sysl<0 THEN 0 ELSE sa.sysl END END AS sysl,
sa.SALENUM*sa.STDPRICE AS ysje,sa.SALENUM*sa.NETPRICE AS shje,sa.saler,su.username,

    row_number() OVER(partition BY  dr.srcbusno,dr.objbusno,dr.wareid,dr.makeno ORDER BY accdate,salenum ASC )  rn
 FROM 
d_zddb_xqsp_dr dr
join d_sqgz_sale sa ON  dr.objbusno=sa.busno AND dr.wareid=sa.wareid AND dr.makeno=sa.makeno AND sa.srcbusno=dr.srcbusno
AND dr.zdate=sa.zdate
LEFT join (
SELECT h.abnormityno,h.createtime,dr.objbusno,dr.wareid,dr.makeno,d.wareqtyb 损溢前数量 ,d.wareqtya 损溢后数量 ,
(d.wareqtya-d.wareqtyb) AS sunyisl,
d.batid  from d_zddb_xqsp_dr dr
JOIN t_abnormity_h h on dr.objbusno=h.busno
JOIN t_abnormity_d d ON h.abnormityno=d.abnormityno AND d.makeno=dr.makeno AND d.wareid=dr.wareid
WHERE d.wareqtyb<>d.wareqtya AND h.createtime>dr.lasttime
) ab ON ab.objbusno=dr.objbusno AND ab.wareid=dr.wareid AND ab.makeno=dr.makeno
JOIN t_ware_base w ON dr.wareid=w.wareid
JOIN t_factory f ON f.factoryid=w.factoryid
JOIN s_busi a ON dr.objbusno=a.busno
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
join t_busno_class_base tb1 on ts1.classgroupno=ts1.classgroupno and ts1.classcode=tb1.classcode
LEFT JOIN t_ware_class_base e ON e.compid=1000 AND w.wareid=e.wareid and e.classgroupno='01'
LEFT JOIN t_ware_class_base dd ON dd.compid=1000 AND w.wareid=dd.wareid and dd.classgroupno='12'
left join s_user_base su on sa.saler=su.userid
--WHERE dr.objbusno=81001 AND sa.accdate=TRUNC(SYSDATE)
