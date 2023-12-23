--d_yb_base_sl_22  base_22
--324331082 �ٺ�
 --ͳ��23��ÿ���ŵ�(����),ҽ��(ũ��),����Ĺ˿͵�count(distinct trunc(receiptdate))
with base_23 as (
 select a.identityno,tb22.classname as mdlx,a.nb_flag, CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '̨���б���'
    ELSE tb2.classname
  END as mdfw,count(distinct trunc(receiptdate)) as sl--,count(*) as sumsksl 
 from d_yb_first_cus a
 --303��ҵ��
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 --324 �ŵ�����
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  --�ŵ�����(ҩ������)  
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
    join d_zjys_wl2023xse xse on xse.ERP���ۺ�=a.erpsaleno 
    JOIN d_zhyb_hz_cyb cyb ON a.erpsaleno=cyb.erp���۵��� --AND d_zhyb_hz_cyb.��ر�־='�����'
    JOIN d_ll_zxcy ON cyb.erp���۵���=d_ll_zxcy.saleno 
 
 where a.RECEIPTDATE between DATE'2023-01-01' and date'2023-10-31'
 AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001') 
  AND nvl(cyb.ͳ��֧����,0)+nvl(cyb.��������֧����,0)+nvl(cyb.���˵����ʻ�֧����,0)<>0
and cyb.ҽ�Ʒ����ܶ� - nvl(gtjeed,0)<>0
 --and  identityno='332623193301011416'
 group by a.identityno,tb22.classname,a.nb_flag,CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '̨���б���'
    ELSE tb2.classname
  END ),
  --������һ�ű�ͳ��ÿ������,ҽ������,ҩ������ sl��ΪΪ1,2,3,>3�Ĺ˿͵�����
sksl_23 as (
  select mdfw,nb_flag,mdlx,case when sl<=3 then sl else 4 end as sl,count(identityno) as onedaysl
  from base_23 
  --where sl=1 and nb_flag=1 and mdlx='�ŵ�'  
  group by mdfw,nb_flag,mdlx,case when sl<=3 then sl else 4 end ),
  --����������ֽ����ת��
sksl_23_PIVOT as ( SELECT *
  FROM
  sksl_23
  PIVOT
  (
  max(onedaysl)
  FOR sl IN (1 AS onedaysl, 2 AS twodaysl, 3 AS threedaysl, 4 AS moredaysl)
  )
  ),
  --�ϼ�ˢ������
sksl_23_sum as (
  select mdfw,nb_flag,mdlx,sum(sl) as sumsksl
  from base_23 
  --where sl=1 and nb_flag=1 and mdlx='�ŵ�'  
  group by mdfw,nb_flag,mdlx),
result_23 as  
 (
 select aa.*,sum23.sumsksl as �ϼ�ˢ������,sum23.sumsksl/(aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL) as �˾�ˢ������,
 aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL as ��ͷ��,
 (aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL)/(aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL) as ������ռ��
  from sksl_23_PIVOT  aa
  left join sksl_23_sum sum23 on aa.mdfw=sum23.mdfw and  aa.NB_FLAG=sum23.NB_FLAG and aa.MDLX=sum23.MDLX
  --where aa.NB_FLAG=1 and aa.MDLX='�ŵ�'  and  aa.MDFW='̨�����ٺ���'
  ),  
--22������
base_22 as (
 select a.identityno,a. mdlx,a.nb_flag,a.mdfw,count(distinct trunc(receiptdate)) as sl--,count(*) as sumsksl 
 from d_yb_base_sl_22 a where a.RECEIPTDATE between DATE'2022-01-01' and date'2022-10-31'
 group by a.identityno,a. mdlx,a.nb_flag,a.mdfw),
  --������һ�ű�ͳ��ÿ������,ҽ������,ҩ������ sl��ΪΪ1,2,3,>3�Ĺ˿͵�����
sksl_22 as (
  select mdfw,nb_flag,mdlx,case when sl<=3 then sl else 4 end as sl,count(identityno) as onedaysl
  from base_22 
  --where sl=1 and nb_flag=1 and mdlx='�ŵ�'  
  group by mdfw,nb_flag,mdlx,case when sl<=3 then sl else 4 end ),
  --����������ֽ����ת��
sksl_22_PIVOT as ( SELECT *
  FROM
  sksl_22
  PIVOT
  (
  max(onedaysl)
  FOR sl IN (1 AS onedaysl, 2 AS twodaysl, 3 AS threedaysl, 4 AS moredaysl)
  )
  ),
  --�ϼ�ˢ������
sksl_22_sum as (
  select mdfw,nb_flag,mdlx,sum(sl) as sumsksl
  from base_22 
  --where sl=1 and nb_flag=1 and mdlx='�ŵ�'  
  group by mdfw,nb_flag,mdlx),
result_22 as  
 (select aa.*,sum22.sumsksl as �ϼ�ˢ������,sum22.sumsksl/(aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL) as �˾�ˢ������,
 aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL as ��ͷ��,
 (aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL)/(aa.ONEDAYSL+aa.TWODAYSL+aa.THREEDAYSL+aa.MOREDAYSL) as ������ռ��
  from sksl_22_PIVOT  aa
  left join sksl_22_sum sum22 on aa.mdfw=sum22.mdfw and  aa.NB_FLAG=sum22.NB_FLAG and aa.MDLX=sum22.MDLX
  --where aa.NB_FLAG=1 and aa.MDLX='�ŵ�'  and  aa.MDFW='̨�����ٺ���'
  )
select a23.MDFW,a23.NB_FLAG,a23.MDLX,
a22.��ͷ�� as ��������ͷ��,a22.ONEDAYSL as ������ˢ��һ����ͷ��,a22.TWODAYSL as ������ˢ��������ͷ��,a22.THREEDAYSL as ������ˢ��������ͷ��,
a22.MOREDAYSL as �����곬������ͷ��,a22.�˾�ˢ������ as �������˾�ˢ������,a22.������ռ�� as ������������ռ��,
a23.��ͷ�� as ��������ͷ��,a23.ONEDAYSL as ������ˢ��һ����ͷ��,a23.TWODAYSL as ������ˢ��������ͷ��,
a23.THREEDAYSL as ������ˢ��������ͷ��,a23.MOREDAYSL as �����곬������ͷ��,a23.�˾�ˢ������ as  �������˾�ˢ������,a23.������ռ�� as  ������������ռ��,
1-a23.�˾�ˢ������/a22.�˾�ˢ������ as �˾�ˢ���������Ͱٷֱ�,a23.ONEDAYSL/a23.��ͷ��-a22.ONEDAYSL/a22.��ͷ�� as һ����ռ�Ȳ����ٷֵ���,
a23.������ռ��-a22.������ռ�� as ������ռ�Ȳ����ٷֵ���

from   
result_23 a23
left join result_22 a22 on   a23.NB_FLAG=a22.NB_FLAG and  a23.MDLX=a22.MDLX and a23.MDFW=a22.MDFW;

end;



/*create table d_yb_base_sl_22 as 
select a.identityno,tb22.classname as mdlx,a.nb_flag, CASE
    WHEN tb2.classcode IN ('324331001','324331002') THEN '̨���б���'
    ELSE tb2.classname
  END as mdfw,a.receiptdate--,count(*) as sumsksl 
 from d_yb_first_cus a
 --303��ҵ��
 join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='303'
join t_busno_class_base tb on ts.classgroupno=ts.classgroupno and ts.classcode=tb.classcode 
AND tb.classcode IN('303100','303101','303102')
 --324 �ŵ�����
 join t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
    join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  --�ŵ�����(ҩ������)  
    join t_busno_class_set ts22 on a.busno=ts22.busno and ts22.classgroupno ='305'
    join t_busno_class_base tb22 on ts22.classgroupno=ts22.classgroupno and ts22.classcode=tb22.classcode
     join d_zjys_wl2023xse xse on xse.ERP���ۺ�=a.erpsaleno 
    JOIN (select ERP���۵���,ͳ��֧����,��������֧����,���˵����ʻ�֧����,ҽ�Ʒ����ܶ� from  d_zhyb_hz_cyb
          union select ERP���ۺ�,ͳ����,����Ա����֧��,�����˻�֧��,ҽ���ܷ���  from tmp_wlybjs_cyb) cyb ON a.erpsaleno=cyb.erp���۵��� --AND d_zhyb_hz_cyb.��ر�־='�����'
   JOIN (select BUSNO,SALENO,ACCDATE,GTJEED from d_ll_zxcy
         union 
         select busno,saleno,accdate,gtjeed from D_LL_ZXCY_TEMP_2) d_ll_zxcy  ON cyb.erp���۵���=d_ll_zxcy.saleno
 
 --where a.RECEIPTDATE between DATE'2022-01-01' and date'2022-12-31'
 AND a.CBD IN('331082','331004','331083','331024','331081','331023','331022','331003','331002','331099','331001') 
  AND nvl(cyb.ͳ��֧����,0)+nvl(cyb.��������֧����,0)+nvl(cyb.���˵����ʻ�֧����,0)<>0
and cyb.ҽ�Ʒ����ܶ� - nvl(gtjeed,0)<>0*/
  
  
 
  
