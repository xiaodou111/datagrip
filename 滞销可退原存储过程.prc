create or replace procedure p_dir_auto_zx(p_objbusno  d_zxkt.OBJBUSNO%TYPE)
as

begin

insert into t_dir_auto1(compid,busno,wareid,sumqty,we_num07)
select a.compid,c.busno,c.wareid,c.sumqty,nvl(f_get_classname(tw.classgroupno,tw.wareid,tw.compid),0) as we_num07
from t_ware_ext a
join t_ware_class_base b on a.compid=b.compid and a.wareid=b.wareid and b.classgroupno='19' and b.classcode not in('19100','19101')
join t_ware_class_base c on a.compid=c.compid and a.wareid=c.wareid and c.classgroupno='01' and substring(c.classcode,1,4) in('0110','0111')
join t_ware_class_base d on a.compid=d.compid and a.wareid=d.wareid and d.classgroupno='12'  and d.classcode<>'12106'
join t_ware_class_base e on a.compid=e.compid and a.wareid=e.wareid and e.classgroupno='28'  and e.classcode<>'28106'
join t_store_h c on a.compid=c.compid and a.wareid=c.wareid and c.sumqty>0
join s_busi d on b.compid=d.compid and c.busno=d.busno and (sysdate - d.openingdate)>730
left join t_ware_class_base tw on a.wareid=tw.wareid and tw.classgroupno='112' and tw.compid=a.compid
where  nvl(f_get_classname(tw.classgroupno,tw.wareid,tw.compid),0)  is not null
and nvl(f_get_classname(tw.classgroupno,tw.wareid,tw.compid),0) <>0
and d.orgtype='20' and substring(c.busno,1,1)<>'9' and d.compid<>'1900'
and c.busno=p_objbusno
and d.openingdate>date'2001-01-01';

insert into T_DIR_AUTO2(compid,busno,wareid,we_num07,sumqty,execdate)
select a.compid,a.busno,a.wareid,a.we_num07,max(a.sumqty) as sumqty,max(execdate) as execdate
from t_dir_auto1 a
left join t_dist_h b on a.busno=b.objbusno
join t_dist_d c on b.distno=c.distno and a.wareid=c.wareid
where b.billcode='DIS'
--and c.invalidate - sysdate>360
group by a.compid,a.busno,a.wareid,a.we_num07
having sysdate - max(b.execdate) >=a.we_num07;

insert into T_DIR_AUTO3(compid,busno,wareid,we_num07,sumqty,disdate,saldate)
select a.compid,a.busno,a.wareid,a.we_num07,max(a.sumqty) as sumqty,max(a.execdate) as disdate,max(nvl(b.accdate,date'1999-01-01')) as saldate
from T_DIR_AUTO2 a
left join t_rpt_sale b on a.busno=b.busno and a.wareid=b.wareid
left join t_store_i c on b.wareid=c.wareid and b.compid=c.compid and b.batid=c.batid
--where c.invalidate - sysdate>360
group by a.compid,a.busno,a.wareid,a.we_num07
having sysdate - max(nvl(b.accdate,date'1999-01-01')) >=we_num07;

insert into T_DIR_AUTO4(compid,execdate,saledate,objbusno,wareid,wareqty,batid,makeno,invalidate,purprice,saleprice,xfpsl,kfprowno,kfpsl,nfpsl,zzthsl)
select aaa.compid,execdate,saldate,objbusno,aaa.wareid,sd.wareqty,aaa.batid,makeno,invalidate,purprice,saleprice,xfpsl,kfprowno,kfpsl,abs(nfpsl) as nfpsl,sd.wareqty - sd.awaitqty as zzthsl
from(
select a.compid,b.execdate,a.saldate,b.objbusno,c.wareid,c.wareqty,c.batid,c.makeno,c.invalidate,c.purprice,c.objsaleprice as saleprice,a.sumqty as xfpsl,
row_number() OVER (PARTITION BY b.objbusno,c.wareid ORDER BY b.execdate desc,c.batid) as kfprowno,
SUM(c.wareqty) OVER (PARTITION BY b.objbusno,c.wareid ORDER BY b.execdate desc,c.batid) AS kfpsl,
a.sumqty - SUM(c.wareqty) OVER (PARTITION BY b.objbusno,c.wareid ORDER BY b.execdate desc,c.batid)  AS nfpsl
from T_DIR_AUTO3 a,t_dist_h b,t_dist_d c
where a.busno=b.objbusno
and a.wareid=c.wareid
and b.distno=c.distno
and b.billcode='DIS'
and c.invalidate - sysdate>360
--and c.wareid='10225768' and a.busno='81299'
order by b.objbusno,b.execdate desc) aaa
join t_store_d sd on aaa.objbusno=sd.busno
and aaa.wareid=sd.wareid and aaa.batid=sd.batid and sd.wareqty>0
where (nfpsl>=0 or kfprowno=1 )
and sd.wareqty - sd.awaitqty>0;


delete from d_zxkt where objbusno=p_objbusno;

insert into d_zxkt(compid,execdate,saledate,objbusno,wareid,wareqty,batid,makeno,invalidate,purprice,saleprice,xfpsl,kfprowno,kfpsl,nfpsl,zzthsl
) 
select compid,max(execdate),max(saledate),objbusno,wareid,sum(wareqty),batid,max(makeno),max(invalidate),max(purprice),max(saleprice),max(xfpsl),max(kfprowno),max(kfpsl),max(nfpsl),sum(zzthsl)
from T_DIR_AUTO4
group by compid,objbusno,wareid,batid;
commit;

end p_dir_auto_zx;
/
