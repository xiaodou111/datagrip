create view V_HZ_YBRCCX as
select to_char(c.erpmedicalno) AS busno
--,a.creationtime as sysdate1
        ,
       ts.classcode, 1 as transkind, b.totalamount as ylfyze, b.preselfpayamt as zlje,
       b.fulamtownpayamt + b.overlmtselfpay as GRZFJE,
       a.creationtime as sysdate1,
       nvl(case when D.CLASSCODE = '81010' then 1 when waretype = '1' then 1 else 0 end, 0) as zyts,
       to_char(b.PSNNO) as cardid, to_char(a.IDENTITYNO) as idcard, to_char(a.orderno) as orderno

from HYDEE_SYB_HZ.pros_order@hydee a, HYDEE_SYB_HZ.pros_order_receipt_list@hydee b,
     HYDEE_SYB_HZ.medicare_organ_config@hydee c,
     (SELECT MIN(CLASSCODE) AS CLASSCODE, ORDER1.ORDERNO, max(waretype) as waretype
      FROM t_yby_order_d D
               LEFT JOIN HYDEE_SYB_HZ.pros_order ORDER1 ON ORDER1.ORDERNO = D.ORDERNO
               LEFT JOIN (select classcode, PARENT_CLASSCODE, wareid
                          from t_ware_class_base
                          where classgroupno = 810 and compid = 1060 and classcode = ('81010')) BASE
                         ON BASE.WAREID = D.warecode
          --武若卉 要求使用给的药品 国谈分类 用于 杭州医保总额预算报表
               left join t_hz_special_ware_of_wrh c on c.warecode = d.warecode
      WHERE ORDER1.isdeleted = 0 and ORDER1.orderstatus not in ('1', '2', '4')
      GROUP BY ORDER1.ORDERNO) D,
     --20231018变更:只取非异地
     t_busno_class_set ts
--
where a.isdeleted = 0 and a.orderstatus not in ('1', '2', '4')
  and a.orderno = b.orderno and a.refid = c.refid AND A.ORDERNO = D.ORDERNO
  --
  and c.ERPMEDICALNO = ts.busno and ts.classgroupno = '324' and ts.classcode in
                                                                ('324330102', '324330106', '324330105', '324330108',
                                                                 '324330187', '324330186', '324330110', '324330109')
  --
  AND a.AREACODE <> '339900' --and a.AREACODE=substr(ts.classcode,4,6);
  and substr(b.msgid, 2, 4) = substr(a.areacode, 1, 4)
--and a.IDENTITYNO='140429199205215651'
union all
select to_char(c.ERPbusNO) AS busno
--,a.creationtime as sysdate1
        , ts.classcode, 1 as transkind, b.totalamount as ylfyze, b.preselfpayamt as zlje,
       b.fulamtownpayamt + b.overlmtselfpay as GRZFJE,
       a.creationtime as sysdate1,
       nvl(case when D.CLASSCODE = '81010' then 1 when waretype = '1' then 1 else 0 end, 0) as zyts,
       to_char(b.PSNNO) as cardid,
       to_char(a.IDENTITYNO) as idcard, to_char(a.orderno) as orderno
from YBCLOUD.med_order@HDYBYXJG a, YBCLOUD.med_order_rec_list@HDYBYXJG b, YBCLOUD.med_store@HDYBYXJG c,
     (SELECT MIN(CLASSCODE) AS CLASSCODE, ORDER1.ORDERNO, max(waretype) as waretype
      FROM t_yby_order_d D
               LEFT JOIN YBCLOUD.med_order@HDYBYXJG ORDER1 ON ORDER1.ORDERNO = D.ORDERNO
               LEFT JOIN (select classcode, PARENT_CLASSCODE, wareid
                          from t_ware_class_base
                          where classgroupno = 810 and compid = 1060 and classcode = ('81010')) BASE
                         ON BASE.WAREID = D.warecode
          --武若卉 要求使用给的药品 国谈分类 用于 杭州医保总额预算报表
               left join t_hz_special_ware_of_wrh c on c.warecode = d.warecode
      WHERE ORDER1.isdeleted = 0 and ORDER1.orderstatus not in ('1', '2', '4')
      GROUP BY ORDER1.ORDERNO) D,
     --20231018变更:只取非异地
     t_busno_class_set ts
--
where a.isdeleted = 0 and a.orderstatus not in ('1', '2', '4')
  and a.orderno = b.orderno and a.refid = c.refid AND A.ORDERNO = D.ORDERNO
  --
  and c.ERPbusNO = ts.busno and ts.classgroupno = '324' and ts.classcode in
                                                            ('324330102', '324330106', '324330105', '324330108',
                                                             '324330187', '324330186', '324330110', '324330109')
  --
  AND a.AREACODE <> '339900' --and a.AREACODE=substr(ts.classcode,4,6);
  and substr(b.msgid, 2, 4) = substr(a.areacode, 1, 4)
--and a.IDENTITYNO='140429199205215651'
/

