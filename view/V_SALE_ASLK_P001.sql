create view V_SALE_ASLK_P001 as
SELECT '销售出库' as zordertype,a.zdate,a.lsck, to_char(a.wareid) as wareid, to_char(b.warename) as cpmc,b.warespec as cpgg, a.ph,b.wareunit as dw,a.wareqty as sl,a.dj,a.wareqty*a.dj as je,
'' as jdbj,to_char(a.wareid) as cpdm,a.wareqty as cksl,0 as rksl,a.lsck as orgname,b.warespec as zguig,to_char(b.warename) as maktx,
to_char(a.wareid) as matnr,'P001' as lgort,null as zname1 ,1 as rowno
FROM d_aslk_lx a
left join t_ware_base@hydee_zy b on a.wareid=b.wareid
WHERE  a.wareqty>0   and  a.zdate<>date'2022-05-30' and a.wareid in (select wareid from d_aslk_ware)   and  a.wareid not in (10502379,10502459 )
 and zdate>=date'2022-08-01'  and 1=2
 union all
--第一段取原先字段名,不需要数据
-- D001 OUT
SELECT
case when o.zodertype='2' then '销售出库' else '损溢单' end,zdate,o.name1 as name1,
matnr,maktx,zguig,zgysph,mseh6,menge,o.DMBTR,menge*o.DMBTR,'',to_char(matnr),menge as cksl,0 as rksl,
o.name1,
zguig,maktx,matnr,lgort,null,1 as rowno
FROM stock_out o
where o.werks IN ('D001') and lgort  in('P001','P018','P021','P003','P002','P007','P015','P016','P025')  AND  o.zodertype IN ('2','4','5')
and o.matnr in  (select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3)
AND o.lifnr in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
and zdate >= date'2023-09-01'
 union all
 --D001 IN
SELECT  case when i.zodertype='2' then '销售退货' else '损溢单' end,zdate,i.name1 as name1,
matnr,maktx,zguig,zgysph,mseh6,-menge,i.DMBTR,-menge*i.DMBTR,'',to_char(matnr),0 as cksl,menge as rksl,
i.name1,
zguig,maktx,matnr,lgort,null,2 as rowno
FROM stock_in i
WHERE i.werks IN ( 'D001') and lgort in('P001','P018','P021','P003','P002','P007','P015','P016','P025') AND i.zodertype IN ('2','4','5')
AND i.matnr IN (select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3)
AND i.lifnr in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
 and zdate >= date'2023-09-01'

union all
--普通的移仓  D001的P002，P007，P015，P016，P025的移仓
 SELECT  '销售出库'  as  zordertype ,a.zdate,--'瑞人堂医药集团股份有限公司温岭虎山药店'
 a.zname1,a.matnr,a.MAKTX,a.ZGUIG,a.ZGYSPH,
  a.MSEH6,a.menge,a.DMBTR,a.menge*a.DMBTR,'',a.matnr,a.menge as cksl,0,
 -- '瑞人堂医药集团股份有限公司温岭虎山药店',
 c.zname1,a.ZGUIG,a.MAKTX,a.matnr,a.lgort,null as zname1,3 as rowno
  from stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph  and a.charg=c.charg
  WHERE a.zodertype=3  AND a.matnr in (
select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3
  ) AND  (a.lgort in ('P002','P007','P015','P016','P025') or c.lgort in ('P002','P007','P015','P016','P025'))
    and a.werks='D001'
and a.LIFNR in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
   and a.zdate >= date'2023-09-01'
union all
 SELECT  '销售退货'  as  zordertype ,c.zdate,--'瑞人堂医药集团股份有限公司温岭虎山药店'
 c.zname1,c.matnr,c.MAKTX,c.ZGUIG,c.ZGYSPH,
  c.MSEH6,-c.menge,c.DMBTR,-c.menge*c.DMBTR,'',c.matnr,0,c.menge as rksl,
 -- '瑞人堂医药集团股份有限公司温岭虎山药店',
 a.zname1,c.ZGUIG,c.MAKTX,c.matnr,c.lgort,null as zname1,3 as rowno
  from stock_out a
  INNER JOIN stock_in c ON a.zorder=c.zorder AND a.matnr=c.matnr AND a.zgysph=c.zgysph  and a.charg=c.charg
  WHERE a.zodertype=3  AND a.matnr in (
select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3
  ) AND  (a.lgort in ('P002','P007','P015','P016','P025') or c.lgort in ('P002','P007','P015','P016','P025'))
    and a.werks='D001'
 and a.LIFNR in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
   and a.zdate >= date'2023-09-01'
UNION ALL
--P888、P006移仓给P001,入库数量不为0,单据类型改为批发退货单,从瑞人堂医药集团股份有限公司温岭虎山药店退回
select  '销售出库',O.ZDATE,'瑞人堂医药集团股份有限公司温岭虎山药店' AS name1 ,O.MATNR,O.maktx,O.zguig,O.zgysph,O.mseh6,O.menge,o.DMBTR,O.menge*o.DMBTR,'',
to_char(O.matnr),O.menge as cksl,0 as rksl,'瑞人堂医药集团股份有限公司温岭虎山药店',o.zguig,o.maktx,o.matnr,o.lgort,null,3 as rowno
FROM  stock_out o
INNER JOIN stock_in i ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.menge=i.menge and o.CHARG=i.CHARG
WHERE o.zodertype=3
and o.werks IN ('D001')   and o.matnr in  (select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3)
and  o.lgort in('P001','P018','P021') AND i.lgort IN('P888','P006')
AND i.lifnr in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
and o.zdate >= date'2023-09-01'
UNION ALL
select  '销售退货',O.ZDATE,'瑞人堂医药集团股份有限公司温岭虎山药店' AS name1 ,O.MATNR,O.maktx,O.zguig,O.zgysph,O.mseh6,-O.menge,o.DMBTR,-O.menge*o.DMBTR,'',
to_char(O.matnr), 0 as cksl,O.menge as rksl,'瑞人堂医药集团股份有限公司温岭虎山药店',o.zguig,o.maktx,o.matnr,o.lgort,null,4 as rowno
FROM  stock_out o
INNER JOIN stock_in i ON o.zorder=i.zorder AND o.matnr=i.matnr AND o.zgysph=i.zgysph and o.menge=i.menge and o.CHARG=i.CHARG
WHERE o.zodertype=3
and o.werks IN ('D001')   and o.matnr in  (select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3)
and  o.lgort IN('P888','P006') AND i.lgort in('P001','P018','P021')
AND i.lifnr in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
and o.zdate >= date'2023-09-01'


--D001 P888、P006的采购入库单,改为p001入库，瑞人堂医药集团股份有限公司温岭虎山药店,
union all
SELECT   '销售出库' ,zdate,'瑞人堂医药集团股份有限公司温岭虎山药店' as name1,
matnr,maktx,zguig,zgysph,mseh6,menge,i.DMBTR,menge*i.DMBTR,'',to_char(matnr),menge as cksl,0 as rksl,
'瑞人堂医药集团股份有限公司温岭虎山药店',
zguig,maktx,matnr,lgort,null,5 as rowno
FROM stock_in i
WHERE i.werks IN ( 'D001') AND i.lgort in ('P888','P006') AND I.zodertype='1'
AND i.matnr IN (select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3)
AND  i.lifnr in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
 and zdate >= date'2023-09-01'
 union all
SELECT

'销售退货',zdate,'瑞人堂医药集团股份有限公司温岭虎山药店' as name1,
matnr,maktx,zguig,zgysph,mseh6,-menge,o.DMBTR,-menge*o.DMBTR,'',to_char(matnr),0 as cksl,menge as rksl,
'瑞人堂医药集团股份有限公司温岭虎山药店',
zguig,maktx,matnr,lgort,null,1 as rowno
FROM stock_out o
where o.werks IN ('D001') and lgort  in('P888','P006')  AND  o.zodertype='1'
and o.matnr in  (select WAREID FROM d_aslk_ware2 UNION ALL select WAREID FROM d_aslk_ware3)
AND o.lifnr in('110032','110073','110093','110220','110288','110388','110602','110634','110673','110190','110221','110451','110339','110473','110293','110076','110344')
and zdate >= date'2023-09-01'
union all
select "ZORDERTYPE","ZDATE","LSCK","WAREID","CPMC","CPGG","PH","DW","SL","DJ","JE","JDBJ","CPDM","CKSL","RKSL","ORGNAME","ZGUIG","MAKTX","MATNR","LGORT","ZNAME1","ROWNO" from d_sale_aslk_p001_230801 where zdate>=date'2023-01-01'
/

