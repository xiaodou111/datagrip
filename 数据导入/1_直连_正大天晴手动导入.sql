--�ɹ�
select zdate, 
werks, 
zname1, 
djlx, 
matnr, 
maktx, 
zguig,  
zscqymc, 
name1, 
mseh6, 
menge,
zgysph, 
dmbtr
from  d_zdtq_sj_cg for UPDATE
DELETE from  d_zdtq_sj_cg WHERE zdate>=DATE'2023-05-01'

 
 --���
select werks, 
name1, 
matnr, 
maktx, 
zguig, 
zscqyms,
mseh6, 
sl, 
zgysph
from d_zdtq_sj_kc  for update
delete from d_zdtq_sj_kc

 --����
select zdate, 
werks, 
zname1, 
 
matnr, 
maktx, 
zguig, 
 
zscqymc,
name1, 
mseh6, 
menge,
zgysph, 
dmbtr
 from d_zdtq_sj_ps for UPDATE
 SELECT * from d_zdtq_sj_ps WHERE name1 LIKE '%����ҩD��%'
 UPDATE d_zdtq_sj_ps SET name1='������ҽҩ���Źɷ����޹�˾������Ȫҩ�꣨��ҩD��' 
 WHERE name1='��������Ȫҩ�꣨��ҩD��'
 DELETE from d_zdtq_sj_ps WHERE zdate>=DATE'2023-05-01'
