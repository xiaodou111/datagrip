with a1 as (
SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno,a.nb_flag, a.cbd, a.cbdname, 
a.netsum, a.status, a.yg_flag,a.jslx,
a.orderno,a.cbrylb,tb3.classname as ҩ������,
case when tb2.classname in('̨���н�����','̨���б���') then '̨�����б���' else tb2.classname end  AS areano/*,
ROW_NUMBER() OVER (PARTITION BY 
a.IDENTITYNO ORDER BY a.receiptdate ASC) rn*/
 FROM d_yb_new_cus_2023_09 a
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts3 on a.busno=ts3.busno and ts3.classgroupno ='305'
    join t_busno_class_base tb3 on ts3.classgroupno=ts3.classgroupno and ts3.classcode=tb3.classcode
  WHERE a.RECEIPTDATE >= DATE'2023-01-01'
  --and a.identityno='332603197505290624'
  ),
a2 as (
SELECT tb22.classname as ҩ������,
case when tb2.classname in('̨���н�����','̨���б���') then '̨�����б���' else tb2.classname end  AS areano, a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno,a.nb_flag, a.cbd, a.cbdname, 
a.netsum, a.status, a.yg_flag,a.jslx,
a.orderno,a.cbrylb,
ROW_NUMBER() OVER (PARTITION BY 
  CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '324331001'
    ELSE tb2.classcode
  END,
  tb22.classcode, 
a.IDENTITYNO,a.nb_flag ORDER BY a.receiptdate ASC) rn
 FROM d_yb_first_cus a
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
    --���Ϲ�̸����
    join d_zjys_wl2023xse xse on xse.ERP���ۺ�=a.erpsaleno 
    JOIN d_zhyb_hz_cyb cyb ON a.erpsaleno=cyb.erp���۵��� --AND d_zhyb_hz_cyb.��ر�־='�����'
   JOIN d_ll_zxcy ON cyb.erp���۵���=d_ll_zxcy.saleno
    --
    
  WHERE a.RECEIPTDATE between DATE'2023-01-01' and date'2023-09-11'
  AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001')
  and a.identityno='332603197505290624'
    --��̸����
   AND nvl(cyb.ͳ��֧����,0)+nvl(cyb.��������֧����,0)+nvl(cyb.���˵����ʻ�֧����,0)<>0
and cyb.ҽ�Ʒ����ܶ� - nvl(gtjeed,0)<>0
),
--select * from A2
/*same as (select ҩ������,AREANO,RECEIPTDATE,BUSNO,IDENTITYNO,NB_FLAG,CBD,CBDNAME 
FROM a2 WHERE RECEIPTDATE<=DATE'2023-01-10' GROUP BY ҩ������,AREANO,RECEIPTDATE,BUSNO,IDENTITYNO,NB_FLAG,CBD,CBDNAME   HAVING count(*)>1)
select * from same*/
a3 as (select identityno,nb_flag,ҩ������,areano,receiptdate,RN from a2 )
select * from a3 
a4 as (select * from a1 where not exists(select 1 from a3 where a3.identityno=a1.identityno
and a3.nb_flag=a1.nb_flag and a3.ҩ������=a1.ҩ������ and a3.areano=a1.areano ))
SELECT  a.erpsaleno,a.receiptdate,tb.classname AS syb,tb1.classname AS PQ,
case when tb2.classname in('̨���н�����','̨���б���') then '̨�����б���' else tb2.classname end  AS areano,
a.busno,s.orgname,a.saler,a.username,a.customername,a.IDENTITYNO,
decode(a.nb_flag,0,'ҽ��',1,'ũ��') as yblx,a.cbd,a.cbdname,a.netsum,a.status,a.yg_flag,s.zmdz1,
DECODE(a.jslx,'0','��ͨ����','1','�����ز�','2','˫ͨ��') AS jslx,tb3.classname as ҩ������
 FROM a4 a
    join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
    join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode
    join t_busno_class_set ts1 on a.busno=ts1.busno and ts1.classgroupno ='304'
    join t_busno_class_base tb1 on ts1.classgroupno=ts1.classgroupno and ts1.classcode=tb1.classcode
    join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts3 on a.busno=ts3.busno and ts3.classgroupno ='305'
    join t_busno_class_base tb3 on ts3.classgroupno=ts3.classgroupno and ts3.classcode=tb3.classcode
    LEFT join s_busi s ON a.busno=s.busno
    where a.receiptdate between DATE'2023-01-01' and date'2023-09-11'
   and a.identityno='332603197505290624'
    order by a.receiptdate
