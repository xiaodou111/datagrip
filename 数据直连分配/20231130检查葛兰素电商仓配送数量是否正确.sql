--�������
SELECT matnr,zdate,ZSCQYMC,sum(MENGE) as ls,ZGYSPH,MSEH6,'�������'

  FROM stock_in o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001')
  and matnr  in (select wareid from d_gls_ware_py)
  AND zdate>=date'2023-12-01'
  group by matnr,zdate,ZSCQYMC,ZGYSPH,MSEH6
union all  
 --���̳���
SELECT matnr,zdate,ZSCQYMC,sum(MENGE) as ls,ZGYSPH,MSEH6,'���̳���'

  FROM stock_out o
  WHERE lgort in ('P888','P006') and  zodertype='1' and werks in ('D001')
  and matnr  in (select wareid from d_gls_ware_py)
  AND zdate>=date'2023-12-01'
  group by matnr,zdate,ZSCQYMC,ZGYSPH,MSEH6
  
 union all 
--�����Ʋ�
select a.matnr,a.zdate,max(a.ZSCQYMC) as ZSCQYMC,sum( decode(a.lgort,'P001',a.menge,-a.menge) ) as ls,a.zgysph,a.MSEH6,max(decode(a.lgort,'P001','�Ʋֳ���','�Ʋ����'))
             from stock_out a
             INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph
             WHERE
             ((a.lgort ='P001' AND c.lgort='P888') OR (a.lgort ='P001' AND c.lgort='P006')
              OR  (a.lgort ='P888' AND c.lgort='P001') OR (a.lgort ='P006' AND c.lgort='P001')
              )
              and a.ZODERTYPE=3 and  a.lifnr IN ('110093','110116','110388','110673')
              and a.matnr in (select wareid from d_gls_ware_py)
              and a.zdate>=date'2023-12-01'
              --and  a.zdate>=date'2023-04-01'
              group by a.matnr,a.zdate,a.zgysph,a.MSEH6;
          
--10108932  2023/11/30��������Ϊ�����˲ɹ���ͼ����û����
--�ѷ��䵽�����   
          select zdate,matnr,sum(ls),ZSCQYMC,PH,MSEH6,'�ѷ���' from d_gls_pjfp   where   zdate>=date'2023-12-01'
          group by zdate,matnr,ZSCQYMC,PH,MSEH6;
  
  


