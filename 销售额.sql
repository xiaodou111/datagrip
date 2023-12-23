create or replace view v_81091xse  as
select busno,wareid,big,ybzbfl,we_schar05,max(dj)dj,sum(avaqty)avaqty,sum(je)je,sum(xse)xse from (
select qq.busno,qq.wareid,
SUBSTR(tc.PARENT_CLASSCODE,2,INSTR(tc.PARENT_CLASSCODE,';',1,2)-INSTR(tc.PARENT_CLASSCODE,';',1,1)-1) big,
SUBSTR(e.PARENT_CLASSCODE,2,INSTR(e.PARENT_CLASSCODE,';',1,2)-INSTR(e.PARENT_CLASSCODE,';',1,1)-1)ybzbfl ,
ext.we_schar05,F_GET_WARE_CLASSNAME(qq.wareid,'90',1000) dj,a.avaqty,a.je,qq.xse
--取销售额
FROM(
select h.busno,d.wareid,h.compid,sum(d.wareqty*d.netprice) xse
from t_sale_h h
INNER  JOIN t_sale_d d
ON     h.saleno = d.saleno
INNER  JOIN s_busi s
ON     h.busno = s.busno AND h.compid = s.compid
LEFT   JOIN t_store_i i
ON     d.wareid = i.wareid AND d.batid = i.batid AND h.compid = i.compid
INNER  JOIN t_ware_base t ON     d.wareid = t.wareid

WHERE (   d.accdate >= trunc(sysdate)-60 and d.accdate <= trunc(sysdate)
 
 and  (rownum > 0 and EXISTS(SELECT * FROM T_WARE_CLASS_BASE wc__  WHERE  wc__.compid = (CASE
      WHEN EXISTS (SELECT 1
            FROM t_ware_class_base twcb
           WHERE twcb.compid = 0
                 and twcb.wareid = d.wareid) THEN
       0
      ELSE
       0
     END) and wc__.WAREID=d.wareid and SUBSTR(wc__.CLASSCODE, 1, 4) in( '0110','0111')  and wc__.classgroupno='01' ))
  
     and  i.invalidate between date'2023-08-01' and date'2024-01-31'  ) 
     and h.busno= 81091 group by h.busno,d.wareid,h.compid
)qq 
--取效期库存数量,效期库存金额
left join (
select busno,wareid,max(big) big,max(ybzbfl)ybzbfl,max(dj)dj,max(we_schar05)we_schar05,
sum(avaqty)avaqty,sum(je)je,max(invalidate) from
(
select d.busno,i.wareid,
SUBSTR(tc.PARENT_CLASSCODE,2,INSTR(tc.PARENT_CLASSCODE,';',1,2)-INSTR(tc.PARENT_CLASSCODE,';',1,1)-1) big,
SUBSTR(e.PARENT_CLASSCODE,2,INSTR(e.PARENT_CLASSCODE,';',1,2)-INSTR(e.PARENT_CLASSCODE,';',1,1)-1)ybzbfl ,
F_GET_WARE_CLASSNAME(d.wareid,'90',1000) dj,ext.we_schar05,
nvl((d.wareqty - awaitqty), 0)  avaqty,nvl((d.wareqty - awaitqty), 0)*tws.saleprice je,
i.invalidate from 
t_store_d d

INNER JOIN s_busi sb
    ON sb.compid = d.compid
   AND sb.busno = d.busno
LEFT JOIN t_ware_saleprice tws
    ON d.compid = tws.compid
   AND d.wareid = tws.wareid
   AND sb.salegroupid = tws.salegroupid
LEFT JOIN t_store_i i
    ON d.compid = i.compid
   AND d.wareid = i.wareid
   AND d.batid = i.batid
inner join  t_ware_class_base TC on tc.wareid=i.wareid  
and 
SUBSTR(tc.CLASSCODE, 1, 4) in( '0110','0111') and TC.compid=d.compid and TC.classgroupno='01'
LEFT JOIN t_ware_class_base e ON e.compid=1000 AND d.wareid=e.wareid and e.classgroupno='26'
LEFT JOIN t_ware_class_base f ON f.compid=1000 AND d.wareid=f.wareid and f.classgroupno='90'
LEFT JOIN t_ware_ext ext
    ON d.wareid = ext.wareid
   AND d.compid = ext.compid
   
   where  d.wareqty>0 and i.invalidate between date'2023-08-01' and date'2024-01-31'
   and d.busno=81091 
)a group by a.busno,a.wareid ) 
a on qq.busno=a.busno and qq.wareid=a.wareid
LEFT JOIN t_ware_class_base e ON e.compid=1000 AND qq.wareid=e.wareid and e.classgroupno='26'
LEFT JOIN t_ware_class_base f ON f.compid=1000 AND qq.wareid=f.wareid and f.classgroupno='90'

inner join  t_ware_class_base TC on tc.wareid=qq.wareid  
and 
SUBSTR(tc.CLASSCODE, 1, 4) in( '0110','0111') and TC.compid=1000 and TC.classgroupno='01'
LEFT JOIN t_ware_ext ext
    ON qq.wareid = ext.wareid
   AND  ext.compid=1000 ) group by busno,wareid,big,ybzbfl,we_schar05
 
   
