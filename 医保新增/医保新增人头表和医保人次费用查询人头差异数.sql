 SELECT * from D_YB_NEW_CUS_2023_hz WHERE busno=85065 
 AND RECEIPTDATE>= DATE'2023-01-01' AND RECEIPTDATE<=DATE'2023-05-31'
 

 --ҽ��������ͷ��d_yb_first_cus���������ͷ
 SELECT COUNT(*) FROM(
 SELECT ROW_NUMBER() over(partition BY IDENTITYNO order by RECEIPTDATE) as ord 
 from d_yb_first_cus  WHERE busno=85065  
 AND RECEIPTDATE>= DATE'2023-01-01' AND RECEIPTDATE<=DATE'2023-05-31'
 ) WHERE ord=1
 
 --ҽ���˴η��ò�ѯͳ�Ƴ�����ͷ
 select
  sum(transkind)--���ţ�ָ��ʱ����ͷ��
 FROM(
 select ROW_NUMBER() over(partition BY idcard order by sysdate1) as ord,
    ROW_NUMBER() over (partition BY idcard,to_char(sysdate1,'yyyy-mm-dd') order by idcard,sysdate1) as ord2,
    busno,transkind,ylfyze,zlje,GRZFJE,sysdate1,zyts,cardid,idcard
    from v_hz_ybrccx
    where --sysdate1>=trunc(DATE'2023-01-01','yyyy')
    --and sysdate1<add_months(trunc(DATE'2023-05-31', 'YYYY'),12)
     busno=85065)    
    WHERE  ord=1 AND sysdate1>= DATE'2023-01-01' and sysdate1<DATE'2023-05-31'+1 ;
