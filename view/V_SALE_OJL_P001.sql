create or replace view V_SALE_OJL_P001 as
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else case when trim(o.bupa) like '24%' and o.MENGE>150 then '1516' else o.bupa  end end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '�̿�'
else case when trim(o.bupa) like '24%' and o.MENGE>150 then '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��'
else o.NAME1 end end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('2','4','5') and werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and o.NAME1 not like '%����%'

UNION ALL
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else case when trim(i.bupa) like '24%' and i.MENGE>150 then '1516' else i.bupa  end end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '�̿�'
else case when trim(i.bupa) like '24%' and i.MENGE>150 then '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��'
else i.NAME1 end end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-i.menge AS sl,i.dmbtr as dj,- i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('2','4','5') AND  i.werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and i.NAME1 not like '%����%'
--P888,P006�ɹ��˻������
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  '1516' end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '�̿�'
else '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��'  end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,-o.menge as sl,o.dmbtr as dj,
      -o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'������' as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,'P001'
from stock_out o
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('1') and werks in ('D001','D006','D007','D010') and lgort in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01'
--P888,P006�ɹ���⼴����
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  '1516' end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '��ӯ'
       else  '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��' end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,i.menge AS sl,i.dmbtr as dj,i.dmbtr*i.menge  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,'P001'
 FROM stock_in i
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('1') AND  i.werks in ('D001','D006','D007','D010')  and lgort in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01'
--P888,P006�Ƶ�P001,��ʾ����
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(o.werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
 '1516'  as cgfdm,
 '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��'  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,-o.menge as sl,o.dmbtr as dj,
      -o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'������' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,'P001'
from stock_out o left join customer_list l on l.kunnr = o.bupa
join stock_in i  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in('P888','P006') AND i.lgort='P001' and o.zodertype IN ('3') and o.werks in ('D001','D006','D007','D010')
and o.matnr in  (select wareid from d_ojl_ware)
and   o.zdate>=date'2024-01-01'
union all
--P001�Ƶ�P888,P006,��ʾ��������
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(o.werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
 '1516'  as cgfdm,
 '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��'  as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,o.menge as sl,o.dmbtr as dj,
      o.dmbtr*o.menge as je,o.zdate as cjsj,o.VFDAT AS yxq,'������' as  CKMC,t.fileno AS fileno,o.ZSCQYMC as scqy,'P001'
from stock_out i
join stock_in o  ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.CHARG=i.CHARG
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE  o.lgort in('P888','P006') AND i.lgort='P001' and o.zodertype IN ('3') and o.werks in ('D001','D006','D007','D010')
and o.matnr in  (select wareid from d_ojl_ware)
and   o.zdate>=date'2024-01-01'
--��������������˻���ص�λΪ������ 75%������ ��Ϊ��Ӧ���ŵ�,�ŵ�ƥ�䲻���͸�Ϊ��������ҽҩ���Źɷ����޹�˾��Ȫ��(��ҩD),25%��������ʵ����
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '�̿�'
else nvl(c.orgname,  '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��' ) end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
   ceil(o.menge*0.75)  as sl,o.dmbtr as dj,
      o.dmbtr*ceil(o.menge*0.75) as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o
left join d_msd_busno_zs b on trim(o.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('2','4','5') and werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and o.NAME1 like '%����%'
union all
select o.zodertype||o.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when o.zodertype in ('4','5') then o.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN o.zodertype in ('4','5') THEN '�̿�'
else nvl(c.orgname,  '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��' ) end as cgfmc,
   o.matnr as cpdm,o.maktx as cpmc,o.zguig as cpgg,o.mseh6 as dw,o.zgysph as ph,
   floor(o.menge*0.25)  as sl,o.dmbtr as dj,
      o.dmbtr*ceil(o.menge*0.25) as je,o.zdate as cjsj,o.VFDAT AS yxq,o.lgobe as  CKMC,t.fileno AS fileno,ZSCQYMC as scqy,o.lgort
from stock_out o
left join d_msd_busno_zs b on trim(o.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=o.matnr
WHERE   o.zodertype IN ('2','4','5') and werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
and o.matnr in  (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and o.NAME1 like '%����%' and floor(o.menge*0.25)>0
--�����˻�
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '�̿�'
else nvl(c.orgname,  '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��' ) end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-ceil(i.menge*0.75) AS sl,i.dmbtr as dj,- i.dmbtr*ceil(i.menge*0.75)  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
left join d_msd_busno_zs b on trim(i.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('2','4','5') AND  i.werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and i.NAME1  like '%����%'
union all
SELECT i.zodertype||i.zorder as billno,'' as xsfdm,
DECODE(werks,'D001','̨��������ҩҵ���޹�˾','D006','�������ñ�����ҽҩ�������޹�˾','D007','���������ú��ҽҩ�������޹�˾','D010','�㽭������ҽҩ�������޹�˾') as xsfmc,
case when i.zodertype in ('4','5') then i.zodertype
       else  nvl(substr(b.BUSNO,2,4),'1516')  end as cgfdm,
case WHEN i.zodertype in ('4','5') THEN '�̿�'
else nvl(c.orgname,  '������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��' ) end as cgfmc,
i.matnr AS CPDM,i.maktx AS CPMC,i.zguig AS CPGG,i.mseh6 AS DW,i.zgysph as ph,-floor(i.menge*0.25) AS sl,i.dmbtr as dj,- i.dmbtr*floor(i.menge*0.25)  as je,i.ZDATe as cjsj,
i.VFDAT AS yxq,i.lgobe AS CKMC,t.fileno AS fileno,ZSCQYMC as scqy,i.lgort
 FROM stock_in i
left join d_msd_busno_zs b on trim(i.bupa)=b.zsbm
left join s_busi@hydee_zy c on b.busno=c.busno
 LEFT JOIN t_ware_base@hydee_zy t ON t.wareid=i.matnr
WHERE i.zodertype IN ('2','4','5') AND  i.werks in ('D001','D006','D007','D010') and lgort not in ('P888','P006')
AND i.matnr IN (select wareid from d_ojl_ware)
and   zdate>=date'2024-01-01' and i.NAME1  like '%����%' and floor(i.menge*0.25)>0


/



