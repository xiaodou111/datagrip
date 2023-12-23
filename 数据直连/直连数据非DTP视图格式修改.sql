--原销售视图
CREATE OR REPLACE VIEW V_SALE_GLS_P001 AS
SELECT "GZDATE","NAME1","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","NAME2","MSEH6","RKSL","CKSL" FROM d_gls_sale
--销售视图修改
CREATE OR REPLACE VIEW V_SALE_HFYF_P001 AS
select GZDATE as zdate,NAME1 as zname1,null as lgort,MATNR,MAKTX,zguig,NAME2 as orgname,MSEH6,RKSL,CKSL,null as ph 
from d_HFYF_sale
--采购视图修改
CREATE OR REPLACE VIEW V_ACCEPT_GLS_P001 AS
SELECT "GZDATE","NAME1","DJLX","MATNR","MAKTX","ZGUIG","ZSCQYMC","GYSNAME","MSEH6","RKSL" from  d_gls_accept
--采购视图修改
CREATE OR REPLACE VIEW V_ACCEPT_HFYF_P001 AS
select GZDATE as zdate,'D001' as werks,MATNR, MAKTX,ZGUIG,RKSL as ls,null as ph,null as lgort from d_HFYF_accept
--原库存视图
CREATE OR REPLACE VIEW V_KC_HFYF_P001 AS
SELECT "NAME1","LGOBE","MATNR","MAKTX","ZGUIG","ZSCQYMC","MSEH6","KCSL" from  d_HFYF_kc;
--库存视图修改
CREATE OR REPLACE VIEW V_KC_HFYF_P001 AS
select MATNR as cpdm, MAKTX as cpmc,ZGUIG as cpgg,KCSL as sl,null as kcrq,null as ph from  d_HFYF_kc 


SELECT zdate,werks,lgort,matnr,maktx,zguig,ph,ls 
FROM V_ACCEPT_GLS_P001
   

SELECT kcrq,cpdm,cpmc,cpgg,ph,sl FROM d_HFYF_kc a
