with a1 as (
select yh.RECEIPTDATE, d.BUSNO, tb.CLASSNAME, d.SALENO, d.SALER, d.WAREID, d.WAREQTY, d.NETAMT, d.NETPRICE, d.ROWNO,
       case when yd.EXT_CHAR08 = 0 then '医保甲' when yd.EXT_CHAR08 = 1 then '医保丙' else '医保乙' end as WE_SCHAR01,
       decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) as 门店诊所医保支付价,
       case
           when nvl(decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05), 0) = 0 then
               d.NETPRICE * (1 - yd.EXT_CHAR08) * d.WAREQTY
           else round(LEAST(d.NETPRICE, decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)) *
                      (1 - yd.EXT_CHAR08) * d.WAREQTY, 4) end as 单据明细医保支付价,
    case when yd.EXT_CHAR08 = 1 then d.NETAMT else 0 end as 医疗费用自费总额,
       cyb.统筹支付数 as 整单统筹支付数, cyb.个人当年帐户支付数 as 整单个人当年帐户支付数,
       cyb.个人历年帐户支付数 as 整单个人历年帐户支付数,
       cyb.公补基金支付数 as 整单公补基金支付数, cyb.大病补助 as 整单大病补助,
       cyb.现金支付总额 as 整单现金支付总额, cyb.家庭共济支付 as 整单家庭共济支付,
       cyb.医疗救助 + cyb.其他基金支付数 as 整单其他基金支付,
       d.MAKENO, d.INVALIDATE
from t_sale_d d
         join D_ZHYB_HZ_CYB cyb on d.SALENO = cyb.ERP销售单号
         join t_yby_order_h yh on yh.ERPSALENO = cyb.ERP销售单号
         join (select ORDERNO, WARECODE, EXT_CHAR08
               from T_YBY_ORDER_D
               group by ORDERNO, WARECODE, EXT_CHAR08) yd on yh.ORDERNO = yd.ORDERNO and yd.WARECODE = d.WAREID
         join t_ware_ext ext on d.WAREID = ext.WAREID and ext.COMPID = 1000
         join t_busno_class_set ts on d.busno = ts.busno and ts.classgroupno = '305'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
  where d.SALENO in ('2401304551007053', '2401271247060521') and cyb.异地标志 = '非异地'),
    a2 as (select RECEIPTDATE, BUSNO, CLASSNAME, SALENO, SALER, WAREID, WAREQTY, NETAMT, NETPRICE, ROWNO, WE_SCHAR01,
                  门店诊所医保支付价, 单据明细医保支付价, 医疗费用自费总额, 整单统筹支付数, 整单个人当年帐户支付数,
                  整单个人历年帐户支付数, 整单公补基金支付数, 整单大病补助, 整单现金支付总额, 整单家庭共济支付, 整单其他基金支付,
                  MAKENO, INVALIDATE,sum(单据明细医保支付价) over ( partition by SALENO) as 整单医保支付价,
       单据明细医保支付价/sum(单据明细医保支付价) over ( partition by SALENO) as 单据明细医保比例
           from a1 )
select RECEIPTDATE, BUSNO, CLASSNAME, SALENO, SALER, WAREID, WAREQTY,MAKENO, INVALIDATE, NETAMT, NETPRICE, WE_SCHAR01,
--        门店诊所医保支付价,
       单据明细医保支付价, 医疗费用自费总额  as 单据明细医疗费用自费,
       单据明细医保比例,
       整单统筹支付数 * 单据明细医保比例 as 统筹支付数, 整单个人当年帐户支付数 * 单据明细医保比例 as 个人当年帐户支付数,
       整单个人历年帐户支付数*单据明细医保比例 as 个人历年帐户支付数,
       整单公补基金支付数*单据明细医保比例 as 公补基金支付数,整单大病补助*单据明细医保比例 as 大病补助,
        整单其他基金支付 * 单据明细医保比例 as 其他基金支付,
        NETAMT-整单统筹支付数 * 单据明细医保比例-整单个人当年帐户支付数 * 单据明细医保比例-整单公补基金支付数 * 单据明细医保比例-整单大病补助*单据明细医保比例
            -整单其他基金支付 * 单据明细医保比例 as 历年加现金加共济,
        整单现金支付总额 * 单据明细医保比例 as 单据明细现金支付, 整单家庭共济支付 * 单据明细医保比例 as 单据明细家庭共济支付
      ,  整单医保支付价
from a2;

select ACCDATE, BUSNO, MDLX, SALENO, SALER, WAREID, WAREQTY, MAKENO, INVALIDATE, "实价金额", "实价", WE_SCHAR01,
       "医疗费用自费总额", "单据明细医保比例", "整单统筹支付数", "整单个人当年帐户支付数", "整单个人历年帐户支付数",
       "整单公补基金支付数", "整单大病补助", "整单其他基金支付", "乙类先自付", "医保超限价", "整单现金支付总额",
       "整单家庭共济支付", "回返比例", "单据明细医保支付价"
from D_YBZD_detail;


insert into D_YBZD_detail(ACCDATE, BUSNO, MDLX, SALENO, SALER, WAREID, WAREQTY, MAKENO, INVALIDATE, "实价金额", "实价", WE_SCHAR01,
       "医疗费用自费总额", "单据明细医保比例", "整单统筹支付数", "整单个人当年帐户支付数", "整单个人历年帐户支付数",
       "整单公补基金支付数", "整单大病补助", "整单其他基金支付", "乙类先自付", "医保超限价", "整单现金支付总额",
       "整单家庭共济支付", "回返比例", "单据明细医保支付价")
select a2.RECEIPTDATE,a2.BUSNO, a2.CLASSNAME, a2.SALENO,a2.SALER, a2.WAREID,a2.WAREQTY,a2.MAKENO,a2.INVALIDATE, a2.NETAMT as 实价金额, a2.NETPRICE as 实价,
       a2.WE_SCHAR01,
       a2.医疗费用自费总额,
       单据明细医保比例,
       整单统筹支付数,
       整单个人当年帐户支付数,
       整单个人历年帐户支付数,
       整单公补基金支付数,
       整单大病补助,
       整单其他基金支付,
       乙类先自付,
       医保超限价,
       整单现金支付总额,
       整单家庭共济支付,
       a2.EXT_CHAR08 as 回返比例,
       a2.单据明细医保支付价

