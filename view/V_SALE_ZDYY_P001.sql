create view V_SALE_ZDYY_P001 as
select o.zodertype || o.zorder as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       case when o.zodertype in ('4', '5') then o.zodertype else nvl(l.kunnr_snf, o.bupa) end as cgfdm,
       decode(o.zodertype, '4', '盘亏', '5', '报损', nvl(l.name1_snf, o.name1)) as cgfmc, o.matnr as cpdm,
       o.maktx as cpmc, o.zguig as cpgg, o.mseh6 as dw, o.zgysph as ph, sum(o.menge) as sl, o.dmbtr as dj,
       o.dmbtr * o.menge as je, o.zdate as cjsj, o.VFDAT AS yxq, o.LGOBE AS CKMC, t.fileno AS fileno,
       o.zscqymc AS zscqymc, o.lgort
from stock_out o
         left join customer_list l on l.kunnr = o.bupa
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = o.matnr
WHERE o.zodertype <> '3' AND o.zodertype <> 1
  and o.matnr in ('10112119', '10305422') and to_char(zdate, 'yyyy-mm-dd') between '2022-02-01' and '2022-02-28'
group by o.zodertype || o.zorder,
         case when o.zodertype in ('4', '5') then o.zodertype else nvl(l.kunnr_snf, o.bupa) end,
         decode(o.zodertype, '4', '盘亏', '5', '报损', nvl(l.name1_snf, o.name1)),
         o.matnr, o.maktx, o.zguig, o.mseh6, o.zgysph, o.zdate, o.dmbtr * o.menge, o.dmbtr, o.VFDAt, o.LGOBE, t.fileno,
         o.vfdat, o.zscqymc, o.lgort
UNION ALL
SELECT i.zodertype || i.zorder as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       CASE WHEN i.zodertype = 4 THEN '04' ELSE i.bupa END AS CGFDM, decode(i.zodertype, '4', '盘盈', i.name1) AS CGFMC,
       i.matnr AS CPDM, i.maktx AS CPMC, i.zguig AS CPGG, i.mseh6 AS DW, i.zgysph as ph, -sum(i.menge) AS sl,
       i.dmbtr as dj, - i.dmbtr * i.menge as je, i.ZDATe as cjsj, i.VFDAT AS yxq, i.LGOBE AS CKMC, t.fileno AS fileno,
       i.zscqymc AS zscqymc, i.lgort
FROM stock_in i
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = i.matnr
WHERE i.zodertype IN ('2', '4') AND i.matnr IN ('10112119', '10305422')
  and to_char(zdate, 'yyyy-mm-dd') between '2022-02-01' and '2022-02-28'
group by i.zodertype || i.zorder, CASE WHEN i.zodertype = 4 THEN '04' ELSE i.bupa END,
         decode(i.zodertype, '4', '盘盈', i.name1), i.matnr, i.maktx, i.zguig, i.mseh6, i.zgysph, i.dmbtr, i.ZDATe,
         i.menge, -i.dmbtr * i.menge,
         i.VFDAt, i.LGOBE, t.fileno, i.zscqymc, i.lgort
union all
---加盟店 有两单要体现
SELECT o.zodertype || o.zorder as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       CASE WHEN o.zodertype = 4 THEN '04' ELSE o.bupa END AS CGFDM, decode(o.zodertype, '4', '盘盈', o.name1) AS CGFMC,
       o.matnr AS CPDM, o.maktx AS CPMC, o.zguig AS CPGG, o.mseh6 AS DW, o.zgysph as ph, sum(o.menge) AS sl,
       o.dmbtr as dj, o.dmbtr * o.menge as je,
       case when zorder = '4902489286' then date'2022-04-26' else o.ZDATe end as cjsj, o.VFDAT AS yxq, o.LGOBE AS CKMC,
       t.fileno AS fileno, o.zscqymc AS zscqymc, o.lgort
FROM stock_out o
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = o.matnr
WHERE o.zodertype IN ('2', '4') AND o.matnr IN ('10112119', '10305422') and to_char(zdate, 'yyyy-mm-dd') > '2022-02-28'
  and zorder in ('4902690378', '4902489286')
group by o.zodertype || o.zorder, CASE WHEN o.zodertype = 4 THEN '04' ELSE o.bupa END,
         decode(o.zodertype, '4', '盘盈', o.name1), o.matnr, o.maktx, o.zguig, o.mseh6, o.zgysph, o.dmbtr,
         case when zorder = '4902489286' then date'2022-04-26' else o.ZDATe end,
         o.menge, -o.dmbtr * o.menge, o.VFDAt, o.LGOBE, t.fileno, o.zscqymc, o.lgort
UNION ALL
SELECT i.zodertype || i.zorder as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       CASE WHEN i.zodertype = 4 THEN '04' ELSE i.bupa END AS CGFDM, decode(i.zodertype, '4', '盘盈', i.name1) AS CGFMC,
       i.matnr AS CPDM, i.maktx AS CPMC, i.zguig AS CPGG, i.mseh6 AS DW, i.zgysph as ph, -sum(i.menge) AS sl,
       i.dmbtr as dj, - i.dmbtr * i.menge as je, i.ZDATe as cjsj, i.VFDAT AS yxq, i.LGOBE AS CKMC, t.fileno AS fileno,
       i.zscqymc AS zscqymc, i.lgort
FROM stock_in i
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = i.matnr
WHERE i.zodertype IN ('2', '4') AND i.matnr IN ('10112119', '10305422') and to_char(zdate, 'yyyy-mm-dd') > '2022-02-28'
  and zorder in ('4902690378', '4902489286')
group by i.zodertype || i.zorder, CASE WHEN i.zodertype = 4 THEN '04' ELSE i.bupa END,
         decode(i.zodertype, '4', '盘盈', i.name1), i.matnr, i.maktx, i.zguig, i.mseh6, i.zgysph, i.dmbtr, i.ZDATe,
         i.menge, -i.dmbtr * i.menge,
         i.VFDAt, i.LGOBE, t.fileno, i.zscqymc, i.lgort
union all
---2月份康盛堂显示  3月份都显示退货
select null as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       case when o.zodertype in ('4', '5') then o.zodertype else nvl(l.kunnr_snf, o.bupa) end as cgfdm,
       decode(o.zodertype, '4', '盘亏', '5', '报损', nvl(l.name1_snf, o.name1)) as cgfmc, o.matnr as cpdm,
       o.maktx as cpmc, o.zguig as cpgg, o.mseh6 as dw, o.zgysph as ph, sum(-o.menge) as sl, o.dmbtr as dj,
       -o.dmbtr * o.menge as je, date'2022-03-03' as cjsj, o.VFDAT AS yxq, o.LGOBE AS CKMC, t.fileno AS fileno,
       o.zscqymc AS zscqymc, o.lgort
from stock_out o
         left join customer_list l on l.kunnr = o.bupa
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = o.matnr
WHERE o.zodertype <> '3' AND o.zodertype <> 1
  and o.matnr in ('10112119', '10305422') and to_char(zdate, 'yyyy-mm-dd') between '2022-02-01' and '2022-02-28'
  and o.name1 like '%康盛堂%'
group by o.zodertype || o.zorder,
         case when o.zodertype in ('4', '5') then o.zodertype else nvl(l.kunnr_snf, o.bupa) end,
         decode(o.zodertype, '4', '盘亏', '5', '报损', nvl(l.name1_snf, o.name1)),
         o.matnr, o.maktx, o.zguig, o.mseh6, o.zgysph, o.zdate, -o.dmbtr * o.menge, o.dmbtr, o.VFDAt, o.LGOBE, t.fileno,
         o.vfdat, o.zscqymc, o.lgort
union all
--加盟店屏蔽
SELECT o.zodertype || o.zorder as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       case
           WHEN o.zodertype in (4, 5) THEN '04'
           when trim(o.bupa) not in ('1124', '1257') then '1124'
           ELSE o.bupa END AS CGFDM,

       case
           WHEN o.zodertype in (4, 5) THEN '盘亏'
           when trim(o.bupa) not in ('1124', '1257') then '瑞人堂医药集团股份有限公司温岭新河振兴药店'
           ELSE o.name1 END AS CGFMC,
       o.matnr AS CPDM, o.maktx AS CPMC, o.zguig AS CPGG, o.mseh6 AS DW, o.zgysph as ph, o.menge AS sl, o.dmbtr as dj,
       o.dmbtr * o.menge as je,
       o.ZDATe as cjsj, o.VFDAT AS yxq, o.LGOBE AS CKMC, t.fileno AS fileno, o.zscqymc AS zscqymc, o.lgort
FROM stock_out o
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = o.matnr
WHERE o.zodertype IN ('2', '4') AND o.matnr IN ('10112119', '10305422') and to_char(zdate, 'yyyy-mm-dd') > '2022-02-28'
  and o.werks in ('D001') and lgort in ('P001')
  and zorder not in
      ('4902690378', '4902489286', '4902262179', '4902294655', '4902305020', '4902491738', '4902476984', '4902489298')

UNION ALL
SELECT i.zodertype || i.zorder as billno, 'ZJ0J0001J' as xsfdm, '台州瑞人堂药业有限公司' as xsfmc,
       case
           WHEN i.zodertype in (4, 5) THEN '04'
           when trim(i.bupa) not in ('1124', '1257') then '1124'
           ELSE i.bupa END AS CGFDM,

       case
           WHEN i.zodertype in (4, 5) THEN '盘亏'
           when trim(i.bupa) not in ('1124', '1257') then '瑞人堂医药集团股份有限公司温岭新河振兴药店'
           ELSE i.name1 END AS CGFMC,
       i.matnr AS CPDM, i.maktx AS CPMC, i.zguig AS CPGG, i.mseh6 AS DW, i.zgysph as ph, -i.menge AS sl, i.dmbtr as dj,
       - i.dmbtr * i.menge as je, i.ZDATe as cjsj, i.VFDAT AS yxq, i.LGOBE AS CKMC, t.fileno AS fileno,
       i.zscqymc AS zscqymc, i.lgort
FROM stock_in i
         LEFT JOIN t_ware_base@hydee_zy t ON t.wareid = i.matnr
WHERE i.zodertype IN ('2', '4') AND i.matnr IN ('10112119', '10305422') and to_char(zdate, 'yyyy-mm-dd') > '2022-02-28'
  and i.werks in ('D001') and lgort in ('P001')
  and zorder not in
      ('4902690378', '4902489286', '4902262179', '4902294655', '4902305020', '4902491738', '4902476984', '4902476986',
       '4902718152')
/

