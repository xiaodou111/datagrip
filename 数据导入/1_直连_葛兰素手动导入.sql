select gzdate, name1, djlx, matnr, maktx, zguig,gysname,  rksl,ph from d_gls_accept for update
select name1,lgobe, matnr, maktx, zguig, zscqymc, mseh6, kcsl from d_gls_kc for update

delete from d_gls_kc
select gzdate, name1, matnr, maktx, zguig,  name2, rksl, cksl,PH from d_gls_sale for update
select * from  d_gls_sale order by gzdate desc
select * From d_gls_kc  AS OF TIMESTAMP 
 to_date('20230403 16:10:00','yyyymmdd hh24:mi:ss')
 
 select * from d_gls_sale where gzdate>=date'2023-12-01'
 
 
 
 
 --采购视图数据导入到表中
 insert into d_gls_accept select ZDATE,ZNAME1,DJLX,MATNR,MAKTX,ZGUIG,ZSCQYMC,GYS,DW,LS,PH from V_ACCEPT_GLS_P001_1
where  ZDATE>=date'2023-10-07' and ZDATE<date'2023-11-01'

--配送视图导入到表中
insert into d_gls_sale select ZDATE,ZNAME1,DJLX,MATNR,MAKTX,ZGUIG,ZSCQYMC,ORGNAME,DW,RKSL,CKSL,PH from V_SALE_GLS_P001_01 
where ZDATE>=date'2023-10-07' and ZDATE<date'2023-11-01'


