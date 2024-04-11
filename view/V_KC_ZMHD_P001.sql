create view V_KC_ZMHD_P001 as
select sysdate as kcrq,'' as gsdm,decode(s.werks,'DOO1','台州瑞人堂药业有限公司','浙江瑞人堂连锁有限公司') as gsmc,s.matnr as cpdm,s.maktx as cpmc,s.zguig as cpgg,s.mseh6 as dw,s.zgysph as ph,
       s.menge as sl,0 as dj,0 as je,s.zdate as cjsj,S.vfdat AS yxq,'正常仓' AS CKMC
from stock S
WHERE S.MATNR in('10107141','10100223','10108378','10100258','10100315','10108671','10107779','10109564','10108951',
      '10107768','10109065','10109066','10600188','10110167','10113513','10229983','10114900','10229984','10304005',
       '10600531','10114351','10114417','10114073','10114421','10303940','10502570','10112029','10117219')
       AND s.matnr NOT IN('10100223','10107141','10305516')
      and LIFNR in ('110388','110093') AND s.werks in('D001','D010') and lgort IN('P001','P018','P021')
      --(10100223,10107141)先用导入的数据
      AND matnr NOT IN(10100223,10107141) and 1=0
UNION ALL
select sysdate as kcrq,'' as gsdm,decode(s.werks,'DOO1','台州瑞人堂药业有限公司','浙江瑞人堂连锁有限公司') as gsmc,
s.matnr as cpdm,s.maktx as cpmc,s.zguig as cpgg,s.mseh6 as dw,s.zgysph as ph,
       0 as sl,0 as dj,0 as je,s.zdate as cjsj,S.vfdat AS yxq,'正常仓' AS CKMC
from stock S
WHERE S.MATNR  IN('10100223','10107141')
and LIFNR in ('110388','110093') AND s.werks in('D001','D010') and lgort IN('P001','P018','P021')
AND matnr NOT IN(10100223,10107141) and 1=0
GROUP BY werks,matnr,zgysph,zdate,vfdat,s.zguig,mseh6,s.maktx
UNION ALL
SELECT sysdate as kcrq,'', gsmc,cpdm, cpmc, cpgg, dw, ph, sl, dj, je, cjsj,yxq, ckmc
from d_kc_zmhd_p001   where  1=0
/

