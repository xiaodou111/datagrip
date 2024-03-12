
call proc_insert_aslkhf();

select w.WARENAME,s.COMPID,c.COMPNAME ,a.BUSNO,s.ORGNAME,MEMBERCARDNO, SALENO, ACCDATE, a.WAREID, WAREQTY, BUYORDER, FIRSTDAY, LASTDAY, LASTQTY, LAST2DAY, LAST2QTY,
       SYZ, WFGYY, YCYY, SFBLFY
from d_aslk_revisit1 a
join t_ware_base w on a.WAREID=w.WAREID
join s_busi s on a.BUSNO=s.BUSNO
join s_company c on s.COMPID=c.COMPID
order by a.MEMBERCARDNO,a.BUSNO,a.WAREID,a.BUYORDER;

