select count(*),max(ACCDATE) from D_YBZD_detail;
select * from D_YBZD_detail where ACCDATE=date'2024-04-17';
delete from D_YBZD_detail where ACCDATE=date'2024-04-17';
select * from D_YBZD_detail where SALENO='2401301125096653';
delete from  D_YBZD_detail;
DECLARE
    P_StartDate DATE := DATE '2023-01-01';  -- 起始日期
    P_EndDate DATE := DATE '2024-04-01';  -- 结束日期
    BatchSize NUMBER := 100000;  -- 每个批次的大小
    P_CurrentDate DATE := P_StartDate;  -- 将当前日期设为当前月的第一天
    v_count NUMBER;  -- 偏移量，用于批处理
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP
insert into D_YBZD_detail
with a2 as (select yh.RECEIPTDATE,d.BUSNO, tb.CLASSNAME, d.SALENO,d.SALER, d.WAREID, d.WAREQTY, d.NETAMT, d.NETPRICE,d.ROWNO,
                   case when yd.EXT_CHAR08=0 then '医保甲' when yd.EXT_CHAR08=1 then '医保丙' else '医保乙' end as WE_SCHAR01,
--        ext.WE_NUM04 as 药店医保支付价,
--        ext.WE_NUM05 as 门诊医保支付价,
                   decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) as 门店诊所医保支付价,
                   --门店诊所医保支付价=0时取售价*
--                    回返比例<>1时,且医保支付价等于空或0时,去商品单价作为医保支付价
                   case  when yd.EXT_CHAR08<>1 and nvl(decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05),0)=0 then
                       d.NETPRICE*(1-yd.EXT_CHAR08)*d.WAREQTY
                       else
                   round(LEAST(d.NETPRICE,decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05))*(1-yd.EXT_CHAR08)*d.WAREQTY,4) end as 单据明细医保支付价,
                  --非医保乙的乙类先自付为0
                case when yd.EXT_CHAR08  in (1,0) then 0 else
                    case when nvl(decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05),0)=0 then d.NETPRICE*yd.EXT_CHAR08*d.WAREQTY else
                   round(LEAST(d.NETPRICE,decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)),2)*yd.EXT_CHAR08*d.WAREQTY end end as 乙类先自付,

                case
                    when nvl(decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05),0)=0 then 0
                        else case
                       when d.NETPRICE > decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) then
                           round(d.NETAMT - d.WAREQTY * decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05),4)
                       else 0
                       --d.NETAMT-d.WAREQTY*d.NETPRICE
                       end end as 医保超限价,
                   yd.EXT_CHAR08,
--                    case
--                        --回返比例1=医保丙,0=医保甲,剩余的都是医保乙
--                        when yd.EXT_CHAR08 not in (0,1) then
--                            round(yd.EXT_CHAR08 * (d.NETAMT - case
--                                                                  when d.NETPRICE >
--                                                                       decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
--                                                                      then
--                                                                      d.NETAMT - d.WAREQTY *
--                                                                                 decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
--                                                                  else 0 end), 2)
--                        else 0 end as 乙类先自付,
                   case when yd.EXT_CHAR08=1 then d.NETAMT else 0 end as 医疗费用自费总额,
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
                     join (select ORDERNO,WARECODE,EXT_CHAR08 from T_YBY_ORDER_D
group by  ORDERNO,WARECODE, EXT_CHAR08) yd  on yh.ORDERNO=yd.ORDERNO and yd.WARECODE=d.WAREID
                     join t_ware_ext ext on d.WAREID = ext.WAREID and ext.COMPID = 1000
                     join t_busno_class_set ts on d.busno = ts.busno and ts.classgroupno = '305'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
--                 and d.SALENO in ('2401301125096653')
--           and cyb.BUSNO in (81499,81501,84576)
--         and  cyb.销售日期 between trunc(sysdate)-1 and trunc(sysdate)
                and cyb.销售日期 between P_CurrentDate and ADD_MONTHS(P_CurrentDate, 1)
        and cyb.异地标志='非异地'
--   TO_DATE('20240101 07:10:00', 'YYYYMMDD HH24:MI:SS')
--     AND TO_DATE('20240104 07:10:00', 'YYYYMMDD HH24:MI:SS')
            ),
     yb_zfze as (select SALENO, sum(单据明细医保支付价) as 整单医保支付价
                 from a2
                 group by SALENO),
    --每一个每个商品的医保比例
     yb_bl as (select a2.SALENO, a2.WAREID,a2.WAREQTY,a2.MAKENO,a2.ROWNO,
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
         left join yb_bl bl on a2.SALENO = bl.SALENO and a2.WAREID = bl.WAREID  and a2.WAREQTY=bl.WAREQTY and a2.MAKENO=bl.MAKENO
                          and a2.ROWNO=bl.ROWNO;
 COMMIT;
  P_CurrentDate := ADD_MONTHS(P_CurrentDate, 1);
     DBMS_LOCK.SLEEP(5); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
end;

call proc_yb_first_md_new1();