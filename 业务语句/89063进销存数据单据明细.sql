SELECT a.EXECDATE,a.wareid,b.warename,a.数量,a.单据类型,a.distno FROM
(SELECT h.EXECDATE,d.wareid,d.WAREQTY AS 数量,'退仓单' AS 单据类型 ,h.distno  from t_dist_h h
JOIN t_dist_d d ON h.DISTNO=d.DISTNO
 WHERE h.srcbusno=89063 AND H.billcode='DIR'
 UNION ALL
 SELECT h.EXECDATE,d.wareid,d.WAREQTY AS 配送数量,'配送单' AS 单据类型 ,h.distno  from t_dist_h h
JOIN t_dist_d d ON h.DISTNO=d.DISTNO
 WHERE h.objbusno=89063 AND H.billcode='DIS'
 UNION all
SELECT h.EXECDATE,d.wareid,(WAREQTYA-WAREQTYB) AS 损溢数量,'损益单',h.ABNORMITYNO from t_abnormity_h h
JOIN t_abnormity_d d ON h.ABNORMITYNO=d.ABNORMITYNO
 WHERE h.busno=89063 AND d.WAREQTYA<>d.WAREQTYB
 UNION ALL 
SELECT h.accdate,d.wareid,d.wareqty AS 销售数量,'销售单',h.saleno FROM t_sale_h h 
JOIN t_sale_d d ON h.SALENO=d.SALENO
 where h.busno=89063) a
 JOIN t_ware_base b ON a.wareid=b.wareid

 


/*
DSSM 店间调拨单  DSSC 跨公司调拨  
DIS 配送单  DIR 退仓单
APP 配送申请单 RAP 退仓申请单
*/
