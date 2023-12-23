
SELECT accdate,werks,wareid,ph,WERKS_name,kc FROM d_aslk_business_kc FOR UPDATE
SELECT accdate,WERKS_NAME,WAREID,PH,GYS,scqy,rksl,djlx from d_baier_business_cgrk FOR UPDATE
SELECT accdate,werks,wareid,ph,WERKS_name,kc from d_aslk_business_kc FOR UPDATE 
SELECT accdate,ck,djlx,rksl,cksl,wareid,warename,gg,scqy,orgname,notes,makeno,wareunit,dj FROM D_TSL_BUSINESS
SELECT * from  D_TSL_BUSINESS_TEMP



DELETE from D_TSL_BUSINESS_TEMP
INSERT INTO D_TSL_BUSINESS SELECT * FROM  D_TSL_BUSINESS_TEMP
