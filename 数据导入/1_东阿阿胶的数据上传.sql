
select * from  d_ej_cgrk for update
d_ej_cgrk
select * from  d_ej_kc FOR UPDATE
delete from  d_ej_kc
INSERT into  d_ej_cgrk
VALUES(0,NULL,'D001','台州瑞人堂药业仓库','2023-04-30',DATE'2023-04-30',10224821,'复方阿胶浆','48支','盒',2210045,48,0,'P001')
--直连库和正式库都有传到直连库
select accdate,busno,wareid,sl,batchid,je,lx from d_ej 

select * from d_ej FOR UPDATE

select max(accdate)   from d_ej 
select max(SDSYGJ_GRRQ) from d_ej_cgrk 

DELETE FROM  d_ej WHERE accdate>=20230502

INSERT into d_ej  SELECT * from d_ej@hydee_zy;

SELECT * from  v_ej_lx WHERE SDYXLX_XSRQ>=20231101 AND SDYXLX_SJLX=1

SELECT substr(a.BUSNO,2,4) as SDYXLX_GRKHDM,a.* FROM d_ej a
WHERE ACCDATE>=20230501 AND LX=1
select busno, 
accdate, 
wareid, 
sl, 
je, 
batchid, 
lx
from d_ej  group by busno, 
accdate, 
wareid, 
sl, 
je, 
batchid, 
lx
having count(*)>1
select count(*)  from d_ej where LENGTH(BUSNO)=4
delete from d_ej where LENGTH(BUSNO)=4
UPDATE d_ej SET BUSNO=8||BUSNO WHERE LENGTH(BUSNO)=4
p006,p888已给p001 显示退货

