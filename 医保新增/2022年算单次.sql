with a1 as (
SELECT erpsaleno, receiptdate, busno, saler, username, customername, identityno, nb_flag, cbd, cbdname, netsum, status, yg_flag,
jslx,orderno
FROM (    

SELECT a.erpsaleno, a.receiptdate, a.busno, a.saler, a.username, a.customername, a.identityno,a.nb_flag, a.cbd, a.cbdname, 
a.netsum, a.status, a.yg_flag,a.jslx,a.orderno,a.cbrylb,
ROW_NUMBER() OVER (PARTITION BY 
 CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '324331001'
    ELSE tb2.classcode
  END,
 -- tb2.classcode,
  tb22.classcode, 
IDENTITYNO,nb_flag ORDER BY receiptdate ASC) rn
 --FROM d_zjys_wl2022_xs a
 from d_yb_first_cus a
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
   --���Ϲ�̸����
    join d_zjys_wl2023xse xse on xse.ERP���ۺ�=a.erpsaleno 
    JOIN (select ERP���۵���,ͳ��֧����,��������֧����,���˵����ʻ�֧����,ҽ�Ʒ����ܶ� from  d_zhyb_hz_cyb
          union select ERP���ۺ�,ͳ����,����Ա����֧��,�����˻�֧��,ҽ���ܷ���  from tmp_wlybjs_cyb) cyb ON a.erpsaleno=cyb.erp���۵��� --AND d_zhyb_hz_cyb.��ر�־='�����'
   JOIN (select BUSNO,SALENO,ACCDATE,GTJEED from d_ll_zxcy
         union 
         select busno,saleno,accdate,gtjeed from D_LL_ZXCY_TEMP_2) d_ll_zxcy  ON cyb.erp���۵���=d_ll_zxcy.saleno
    --
  WHERE a.RECEIPTDATE < DATE'2023-01-01'
  AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001')
  --
  --��̸����
   AND nvl(cyb.ͳ��֧����,0)+nvl(cyb.��������֧����,0)+nvl(cyb.���˵����ʻ�֧����,0)<>0
and cyb.ҽ�Ʒ����ܶ� - nvl(gtjeed,0)<>0
 ) WHERE rn=1)
 
 ;
