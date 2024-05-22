create view V_ACCEPT_ASLK_P001_ZJ as
SELECT case when a.sl>0 then '进货' else '退货' end  as zordertype ,zdate,a.name1 as gys,to_char(a.wareid) as cpdm,to_char(b.warename) as cpmc,b.warespec as cpgg,
a.ph as ph,b.wareunit as dw,a.sl , a.dj ,a.sl*a.dj as je,'' as jdbj,'P999' as oo ,a.sl as ls,to_char(a.wareid) as matnr,to_char(b.warename) as maktx,b.warespec as zguig,
'P999' as lgort ,null as werks
FROM d_aslk_cgrk a
left join t_ware_base@hydee_zy b on a.wareid=b.wareid
WHERE 1=2

union all
------11月份新规则 新品种
select '进货',zdate,name1,matnr,maktx,zguig,zgysph,mseh6,menge,DMBTR,DMBTR*menge,'',lgort,menge,matnr,maktx,zguig,lgort,werks
from stock_in
WHERE zodertype=1 and matnr in (select wareid from d_aslk_ware2  )
and LIFNR in ('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
and werks in('D010')
and lgort in ('P001','P018','P021','P006','P003','P002','P007','P015','P016','P025') and  to_char(zdate,'yyyy-mm-dd')>='2023-01-01'
union all
select '退货',zdate,name1,matnr,maktx,zguig,zgysph,mseh6,-menge,DMBTR,-DMBTR*menge,'',lgort,menge,matnr,maktx,zguig,lgort,werks
from stock_out
WHERE zodertype=1 and matnr in (select wareid from d_aslk_ware2 )
and LIFNR in ('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
and werks in('D010')
and lgort in ('P001','P018','P021','P006','P003','P002','P007','P015','P016','P025') and  to_char(zdate,'yyyy-mm-dd')>='2023-01-01'

union all

SELECT ZORDERTYPE,zdate,gys,cpdm,cpmc,cpgg,ph,dw,sl,dj,je,'',lgort,ls,matnr,maktx,zguig,lgort,zname1 FROM  v_accept_aslk_p001_ty_zj
/

