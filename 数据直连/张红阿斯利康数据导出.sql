

/*select h.accdate,h.STARTTIME,h.busno,d.wareid,t.warename,t.warespec,d.wareqty,i.batid as 批号,t.wareunit
,d.NETPRICE as saleprice, d.wareqty*d.NETPRICE as xsje,h.saleno,h.membercardno,''as 付款方式
 from t_sale_h h
INNER  JOIN t_sale_d d
ON     h.saleno = d.saleno 
INNER  JOIN t_ware_base t
ON     d.wareid = t.wareid
LEFT   JOIN t_store_i i
ON     d.wareid = i.wareid AND d.batid = i.batid AND h.compid = i.compid 
where 
 h.accdate between date'2023-04-01' and date'2023-06-30'
 and
exists(
select 1 from t_aslkml ml where ml.wareid=d.wareid
)*/ 

--在正式库查询,直连库字段不全
SELECT * from  V_ASLK_CX WHERE  accdate> DATE'2023-06-01' AND accdate< DATE'2023-07-01'
