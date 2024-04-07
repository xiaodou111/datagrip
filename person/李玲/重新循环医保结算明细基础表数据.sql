
DECLARE
    P_StartDate DATE := DATE '2023-01-01';  -- 起始日期
    P_EndDate DATE := DATE '2024-04-01';  -- 结束日期
    BatchSize NUMBER := 100000;  -- 每个批次的大小
    P_CurrentDate DATE := TRUNC(P_StartDate, 'MM');  -- 将当前日期设为当前月的第一天
    v_count NUMBER;  -- 偏移量，用于批处理
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP
 insert into D_YBZD_detail
with a1 as (select yh.RECEIPTDATE,d.BUSNO, tb.CLASSNAME, d.SALENO,d.SALER, d.WAREID, d.WAREQTY, d.NETAMT, d.NETPRICE, ext.WE_SCHAR01,
--        ext.WE_NUM04 as 药店医保支付价,
--        ext.WE_NUM05 as 门诊医保支付价,
                   decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) as 门店诊所医保支付价,
                   case
                       when d.NETPRICE > decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) then
                           d.NETAMT - d.WAREQTY * decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
                       else 0
                       --d.NETAMT-d.WAREQTY*d.NETPRICE
                       end as 医保超限价,
                   yd.EXT_CHAR08,
                   case
                       when ext.WE_SCHAR01 = '医保乙' then
                           round(yd.EXT_CHAR08 * (d.NETAMT - case
                                                                 when d.NETPRICE >
                                                                      decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
                                                                     then
                                                                     d.NETAMT - d.WAREQTY *
                                                                                decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
                                                                 else 0 end), 2)
                       else 0 end as 乙类先自付,
                   case when ext.WE_SCHAR01 = '医保丙' then d.NETAMT else 0 end as 医疗费用自费总额,
                   cyb.统筹支付数 as 整单统筹支付数, cyb.个人当年帐户支付数 as 整单个人当年帐户支付数,
                   cyb.个人历年帐户支付数 as 整单个人历年帐户支付数,
                   cyb.公补基金支付数 as 整单公补基金支付数, cyb.大病补助 as 整单大病补助,
                   cyb.现金支付总额 as 整单现金支付总额, cyb.家庭共济支付 as 整单家庭共济支付,
                   cyb.医疗救助+cyb.其他基金支付数 as 整单其他基金支付,
                   d.MAKENO,d.INVALIDATE
--                    cyb.合计报销金额 - cyb.统筹支付数 - cyb.个人当年帐户支付数 - cyb.公补基金支付数 - cyb.大病补助 as 整单其他基金支付
            --d.NETAMT - decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) * d.WAREQTY as 医保支付额
            from t_sale_d d
                     join D_ZHYB_HZ_CYB cyb on d.SALENO = cyb.ERP销售单号
                     join t_yby_order_h yh on yh.ERPSALENO = cyb.ERP销售单号
                     join (select ORDERNO,WARECODE,EXT_CHAR08 from T_YBY_ORDER_D_TEMP
group by  ORDERNO,WARECODE, EXT_CHAR08) yd  on yh.ORDERNO=yd.ORDERNO and yd.WARECODE=d.WAREID
                     join t_ware_ext ext on d.WAREID = ext.WAREID and ext.COMPID = 1000
                     join t_busno_class_set ts on d.busno = ts.busno and ts.classgroupno = '305'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                --and d.SALENO in ('2401304551007053', '2401271247060521')
--           and cyb.BUSNO in (81499,81501,84576)
        and  cyb.销售日期 between P_CurrentDate and ADD_MONTHS(P_CurrentDate, 1)
--                 and cyb.销售日期>=date'2023-01-01'
        and cyb.异地标志='非异地'
--   TO_DATE('20240101 07:10:00', 'YYYYMMDD HH24:MI:SS')
--     AND TO_DATE('20240104 07:10:00', 'YYYYMMDD HH24:MI:SS')
            ),
     a2 as (select RECEIPTDATE,BUSNO, CLASSNAME, SALENO,SALER, WAREID,MAKENO,INVALIDATE, WAREQTY, NETAMT, NETPRICE, WE_SCHAR01, 门店诊所医保支付价,
                   医保超限价, EXT_CHAR08,
                   case
                       when WE_SCHAR01 = '医保乙' then round(EXT_CHAR08 * (a1.NETAMT - 医保超限价), 2)
                       else 0 end as 乙类先自付,
                   医疗费用自费总额, 整单统筹支付数, 整单个人当年帐户支付数, 整单公补基金支付数, 整单大病补助,
                   整单其他基金支付, 整单家庭共济支付,
                   整单个人历年帐户支付数, 整单现金支付总额,

                   case
                       when WE_SCHAR01 = '医保丙' then 0
                       else NETAMT - case
                                         when WE_SCHAR01 = '医保乙' then round(EXT_CHAR08 * (a1.NETAMT - 医保超限价), 2)
                                         else 0 end - 医保超限价
                       end as 单据明细医保支付价
            from a1),
    yb_zfze as (select SALENO, sum(单据明细医保支付价) as 整单医保支付价
                 from a2
                 group by SALENO),
    --每一个每个商品的医保比例
     yb_bl as (select a2.SALENO, a2.WAREID,a2.WAREQTY,
                      b.整单医保支付价,
                      case
                                when b.整单医保支付价 = 0 then 0
                                else round(a2.单据明细医保支付价 / b.整单医保支付价, 4) end   as 单据明细医保比例
               from a2
                join yb_zfze b on a2.SALENO = b.SALENO)
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

--
from a2
         left join yb_zfze b on a2.SALENO = b.SALENO
         left join yb_bl bl on a2.SALENO = bl.SALENO and a2.WAREID = bl.WAREID  and a2.WAREQTY=bl.WAREQTY;
  COMMIT;

  P_CurrentDate := ADD_MONTHS(P_CurrentDate, 1);
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;