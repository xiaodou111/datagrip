--²É¹º
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

 
 --¿â´æ
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

 --ÅäËÍ
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
 SELECT * from d_zdtq_sj_ps WHERE name1 LIKE '%£¨Î÷Ò©D£©%'
 UPDATE d_zdtq_sj_ps SET name1='ÈðÈËÌÃÒ½Ò©¼¯ÍÅ¹É·ÝÓÐÏÞ¹«Ë¾ÎÂÁëÁúÈªÒ©µê£¨Î÷Ò©D£©' 
 WHERE name1='ÈðÈËÌÃÁúÈªÒ©µê£¨Î÷Ò©D£©'
 DELETE from d_zdtq_sj_ps WHERE zdate>=DATE'2023-05-01'
