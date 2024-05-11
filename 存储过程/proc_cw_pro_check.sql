create or replace PROCEDURE proc_cw_pro_check(p_compid IN number,
                                          p_busno IN number,
                                          p_sql OUT SYS_REFCURSOR )
IS
  v_time number;
  v_zmdz1 number;
  --v_lastyear date;
BEGIN
 v_zmdz1:=8||p_busno;
 OPEN p_sql FOR

 with d_sl as ( select ZMDZ1, busno, WAREID, ������, �����������ܼ�, �ܲ��ϸ�����, �ܴ�������, ��������, sumsl, SALEPRICE, je, rn
 from (
SELECT ZMDZ1,busno,WAREID ,������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn
               FROM (
 select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as ������,sum(d.SUMAWAITQTY) as �����������ܼ�,
        sum(d.SUMDEFECTQTY) as �ܲ��ϸ�����,sum(SUMTESTQTY) as �ܴ�������,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as ��������,
        sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from t_store_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118','0119') and TC.compid = p_compid
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE ) )where rn <= 10),
--���
d_je as (select ZMDZ1, busno, WAREID, ������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, ������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as ������,sum(d.SUMAWAITQTY) as �����������ܼ�,
        sum(d.SUMDEFECTQTY) as �ܲ��ϸ�����,sum(SUMTESTQTY) as �ܴ�������,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as ��������,sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from t_store_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118','0119') and TC.compid = p_compid
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
where rn <= 10),
--����--6����û����
d_zx as (select ZMDZ1, busno, WAREID, ������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������, sumsl, SALEPRICE, je, rn
from (
SELECT ZMDZ1,busno,WAREID, ������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl*SALEPRICE DESC) AS rn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as ������,sum(d.SUMAWAITQTY) as �����������ܼ�,
        sum(d.SUMDEFECTQTY) as �ܲ��ϸ�����,sum(SUMTESTQTY) as �ܴ�������,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as ��������,sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE
                     from T_STORE_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                       and not exists (select 1
                                       from t_ware_class_base tc
                                       where substr(TC.classcode, 1, 4) in ('0112','0116','0118','0119') and TC.compid = p_compid
                                         and TC.classgroupno = '01'
                                         and tc.WAREID = d.WAREID)
                     and not exists (select WAREID from t_sale_d sd
join s_busi s on sd.BUSNO = s.BUSNO where s.COMPID = p_compid and s.ZMDZ1 = v_zmdz1 and sd.ACCDATE between ADD_MONTHS(SYSDATE, -6) and SYSDATE
and sd.WAREID=d.WAREID)
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE
                     ))
where rn <= 10 ),
   a1 as (select ZMDZ1, busno, WAREID, ������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������, sumsl, SALEPRICE, je, rn,lx,lxrn
from (
SELECT ZMDZ1,busno,WAREID, ������,�����������ܼ�,�ܲ��ϸ�����,�ܴ�������,��������,sumsl,SALEPRICE,sumsl*SALEPRICE as je, DENSE_RANK() OVER (ORDER BY sumsl DESC) AS rn,lx,
        row_number() over (partition by lx,busno ORDER BY sumsl DESC) lxrn
               FROM (select s.ZMDZ1,s.BUSNO,d.WAREID,sum(d.SUMQTY) as ������,sum(d.SUMAWAITQTY) as �����������ܼ�,
        sum(d.SUMDEFECTQTY) as �ܲ��ϸ�����,sum(SUMTESTQTY) as �ܴ�������,sum(SUMQTY-SUMAWAITQTY-SUMDEFECTQTY-SUMTESTQTY) as ��������,sum(sum(d.SUMQTY))over ( partition by s.ZMDZ1,d.WAREID) as sumsl,tws.SALEPRICE,
                            decode(tc.classcode,'01120301','�����','01120306','����','01120307','�����Ĳ�') as lx
                     from T_STORE_h d
                              join s_busi s on d.BUSNO = s.BUSNO
                      left join t_ware_saleprice tws on tws.compid=p_compid and tws.salegroupid NOT LIKE '91%' and tws.salegroupid='1000001' and d.WAREID=tws.WAREID
                       join t_ware_class_base tc on tc.CLASSCODE in ('01120301','01120306','01120307') and TC.compid = p_compid and tc.WAREID = d.WAREID and TC.classgroupno = '01'
                     where d.COMPID = p_compid and s.ZMDZ1 = v_zmdz1
                     group by s.ZMDZ1,s.BUSNO,d.WAREID,tws.SALEPRICE,decode(tc.classcode,'01120301','�����','01120306','����','01120307','�����Ĳ�')
                     ))
 where lxrn=1 ),
res as (
 select
      COALESCE(d_sl.busno, d_je.busno, d_zx.busno) as busno,
     COALESCE(d_sl.WAREID, d_je.WAREID, d_zx.WAREID) AS WAREID,
     COALESCE(d_sl.������, d_je.������, d_zx.������) as ������,
     COALESCE(d_sl.�����������ܼ�, d_je.�����������ܼ�, d_zx.�����������ܼ�) as �����������ܼ�,
     COALESCE(d_sl.�ܲ��ϸ�����, d_je.�ܲ��ϸ�����, d_zx.�ܲ��ϸ�����) as �ܲ��ϸ�����,
     COALESCE(d_sl.�ܴ�������, d_je.�ܴ�������, d_zx.�ܴ�������) as �ܴ�������,
     COALESCE(d_sl.��������, d_je.��������, d_zx.��������) as ��������,
     COALESCE(d_sl.SALEPRICE, d_je.SALEPRICE, d_zx.SALEPRICE) as SALEPRICE,
        d_sl.rn as �������
 ,d_je.rn as �������,d_zx.rn as ��������
from
d_sl
FULL OUTER JOIN d_je on d_sl.WAREID=d_je.WAREID and d_sl.BUSNO=d_je.BUSNO
FULL OUTER JOIN d_zx on COALESCE(d_sl.WAREID, d_je.WAREID)=d_zx.WAREID and COALESCE(d_sl.BUSNO, d_je.BUSNO)=d_zx.busno)
-- select * from d_je where WAREID='10117531';
select r.busno,s.ORGNAME, r.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC,f.FACTORYNAME
     , r.������,r.�����������ܼ�,r.�ܲ��ϸ�����,r.�ܴ�������,r.��������, r.SALEPRICE,r.������*r.SALEPRICE as ���, r.�������, r.�������, r.��������
from res r
left join s_busi s on r.busno =s.BUSNO
left join t_ware_base w on r.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID
union all
select  a1.busno,s.ORGNAME, a1.WAREID,w.WARENAME,w.WAREUNIT,w.WARESPEC, f.FACTORYNAME,a1.������,a1.�����������ܼ�,a1.�ܲ��ϸ�����,a1.�ܴ�������,a1.��������, a1.SALEPRICE, a1.je, null,null,null
from a1
left join s_busi s on a1.busno =s.BUSNO
left join t_ware_base w on a1.WAREID=w.WAREID
left join t_factory f on w.FACTORYID=f.FACTORYID order by WAREID,busno;

END ;
/

