create or replace PROCEDURE proc_djy_mdjkcy(p_begin IN DATE,
                                          p_end IN DATE,
                                          p_zmdz IN pls_integer,
                                          p_userid  IN s_user_base.userid%type,
                                          p_compid  in pls_integer,
                                          p_sql OUT SYS_REFCURSOR )
IS
  v_time number;

BEGIN
 if p_compid<>0 then
 OPEN p_sql FOR
        --收银员日结对账单
    with cw_yyj as (select a.CREATE_BUSNO as busno,trunc(ISSUING_DATE) as accdate ,sum(nvl(ADVANCE_PAYAMT,0)) as ADVANCE_PAYAMT  from t_cash_coupon_info a
                                   join s_busi s on a.CREATE_BUSNO=s.BUSNO
                                   where nvl(a.status, 0) <> 2
and s.ZMDZ=p_zmdz and trunc(issuing_date) between p_begin and p_end
group by trunc(ISSUING_DATE),a.CREATE_BUSNO),
        cw_czk as (
            select  sum(nvl(RECHARGE_AMT,0)) as RECHARGE_AMT , a.BUSNO, trunc(a.CREATETIME) as accdate
from t_card_addmoney a
join s_busi s on a.BUSNO=s.BUSNO
where s.ZMDZ = p_zmdz and trunc(a.CREATETIME) between p_begin and p_end
group by a.BUSNO,trunc(a.CREATETIME)
        ),
     --门店银行缴款明细
     cw_bankpay as (SELECT a.USE_BUSNO as busno, a.payment_method as PAYTYPE, trunc(a.usedate) as accdate,
                           sum(a.busno_payamt) as busno_payamt
                    FROM t_busno_bank_paydetails a
                             left join s_busi sb
                                       on a.USE_BUSNO = sb.busno
--                     WHERE a.use_busno = 81001 and trunc(a.usedate) = date'2024-02-01'
                        where trunc(a.usedate) between p_begin and p_end and  sb.ZMDZ=p_zmdz
                    group by a.USE_BUSNO, a.payment_method, trunc(a.usedate)),
     --收款方式流水查询报表
     cw_payls as (SELECT h.accdate as accdate,
                         h.busno as busno,
--        round(round(pay.netsum, 2) - round(t_sale_h.loss, 2),2) as netsum,
                         pay.PAYTYPE,
                         sum(pay.NETSUM) as PAYNETSUM
--        round(round(t_sale_h.netsum, 2) - round(t_sale_h.loss, 2),2)-pay.NETSUM as leftnetsum
                  FROM t_sale_h h
                           LEFT JOIN s_busi s
                                     ON h.compid = s.compid
                                         AND h.busno = s.busno
                           left join t_sale_pay pay on pay.saleno = h.saleno
--                   WHERE h.busno = 81001 and h.accdate = date'2024-02-01'
                  where h.ACCDATE between p_begin and p_end and  s.ZMDZ=p_zmdz
                  group by ACCDATE, h.BUSNO, pay.PAYTYPE),
    r as (select nvl(a.accdate, b.accdate) as accdate, nvl(a.BUSNO, b.busno) as busno,
                 nvl(a.PAYTYPE, b.PAYTYPE) as PAYTYPE,
                 nvl(a.busno_payamt, 0) as 门店银行缴款明细金额, nvl(b.PAYNETSUM, 0) as 销售流水实收金额,
                 nvl(a.busno_payamt, 0) - nvl(b.PAYNETSUM, 0) as 收银长款
          from cw_bankpay a
                   full join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and a.PAYTYPE = b.PAYTYPE
          union all
          select a.accdate, a.BUSNO, 'Z997', nvl(c.busno_payamt, 0) as 门店银行缴款明细,
                 a.RECHARGE_AMT as 储值卡充值金额, nvl(c.busno_payamt, 0)-a.RECHARGE_AMT as 收银长款
          from cw_czk a
                   left join cw_bankpay c on a.accdate = c.accdate and a.BUSNO = c.busno and c.PAYTYPE = 'Z997'
--                    left join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and b.PAYTYPE = 'Z997'
          union all
          select a.accdate, a.BUSNO, 'Z998', nvl(c.busno_payamt, 0) as 销售流水实收金额,
                 a.ADVANCE_PAYAMT as 预约金收款金额,  nvl(c.busno_payamt, 0)-a.ADVANCE_PAYAMT as 收银长款
          from cw_yyj a
                   left join cw_bankpay c on a.accdate = c.accdate and a.BUSNO = c.busno and c.PAYTYPE = 'Z998')
--                    left join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and b.PAYTYPE = 'Z998')
select s.COMPID,sc.COMPNAME,s.ZMDZ,s2.ORGNAME as mdzname,r.busno as busno,s.ORGNAME,accdate, PAYTYPE,
       s_dddw_list.DDDWLISTDISPLAY, 门店银行缴款明细金额, 销售流水实收金额, 收银长款
from r
join s_busi s on r.busno=s.BUSNO
join S_COMPANY sc on sc.COMPID=s.COMPID
join s_busi s2 on s.ZMDZ1=s2.BUSNO
join s_dddw_list on s_dddw_list.dddwliststatus = 1
   AND s_dddw_list.dddwname = '222' and r.PAYTYPE=s_dddw_list.DDDWLISTDATA
 where s.BUSNO  in (SELECT busno FROM v_user_busi WHERE  userid =p_userid and status = 1)
 and s.COMPID=p_compid;
end if;
 if p_compid=0 then
     OPEN p_sql FOR

    with cw_yyj as (select a.CREATE_BUSNO as busno,trunc(ISSUING_DATE) as accdate ,sum(nvl(ADVANCE_PAYAMT,0)) as ADVANCE_PAYAMT  from t_cash_coupon_info a
                                   join s_busi s on a.CREATE_BUSNO=s.BUSNO
                                   where nvl(a.status, 0) <> 2
and s.ZMDZ=p_zmdz and trunc(issuing_date) between p_begin and p_end
group by trunc(ISSUING_DATE),a.CREATE_BUSNO),
        cw_czk as (
            select  sum(nvl(RECHARGE_AMT,0)) as RECHARGE_AMT , a.BUSNO, trunc(a.CREATETIME) as accdate
from t_card_addmoney a
join s_busi s on a.BUSNO=s.BUSNO
where s.ZMDZ = p_zmdz and trunc(a.CREATETIME) between p_begin and p_end
group by a.BUSNO,trunc(a.CREATETIME)
        ),
     --门店银行缴款明细
     cw_bankpay as (SELECT a.USE_BUSNO as busno, a.payment_method as PAYTYPE, trunc(a.usedate) as accdate,
                           sum(a.busno_payamt) as busno_payamt
                    FROM t_busno_bank_paydetails a
                             left join s_busi sb
                                       on a.USE_BUSNO = sb.busno
--                     WHERE a.use_busno = 81001 and trunc(a.usedate) = date'2024-02-01'
                        where trunc(a.usedate) between p_begin and p_end and  sb.ZMDZ=p_zmdz
                    group by a.USE_BUSNO, a.payment_method, trunc(a.usedate)),
     --收款方式流水查询报表
     cw_payls as (SELECT h.accdate as accdate,
                         h.busno as busno,
--        round(round(pay.netsum, 2) - round(t_sale_h.loss, 2),2) as netsum,
                         pay.PAYTYPE,
                         sum(pay.NETSUM) as PAYNETSUM
--        round(round(t_sale_h.netsum, 2) - round(t_sale_h.loss, 2),2)-pay.NETSUM as leftnetsum
                  FROM t_sale_h h
                           LEFT JOIN s_busi s
                                     ON h.compid = s.compid
                                         AND h.busno = s.busno
                           left join t_sale_pay pay on pay.saleno = h.saleno
--                   WHERE h.busno = 81001 and h.accdate = date'2024-02-01'
                  where h.ACCDATE between p_begin and p_end and  s.ZMDZ=p_zmdz
                  group by ACCDATE, h.BUSNO, pay.PAYTYPE),
    r as (select nvl(a.accdate, b.accdate) as accdate, nvl(a.BUSNO, b.busno) as busno,
                 nvl(a.PAYTYPE, b.PAYTYPE) as PAYTYPE,
                 nvl(a.busno_payamt, 0) as 门店银行缴款明细金额, nvl(b.PAYNETSUM, 0) as 销售流水实收金额,
                 nvl(a.busno_payamt, 0) - nvl(b.PAYNETSUM, 0) as 收银长款
          from cw_bankpay a
                   full join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and a.PAYTYPE = b.PAYTYPE
          union all
          select a.accdate, a.BUSNO, 'Z997', nvl(c.busno_payamt, 0) as 销售流水实收金额,
                 a.RECHARGE_AMT as 储值卡充值金额, nvl(c.busno_payamt, 0)-a.RECHARGE_AMT as 收银长款
          from cw_czk a
                   left join cw_bankpay c on a.accdate = c.accdate and a.BUSNO = c.busno and c.PAYTYPE = 'Z997'
--                    left join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and b.PAYTYPE = 'Z997'
          union all
          select a.accdate, a.BUSNO, 'Z998', nvl(c.busno_payamt, 0) as 销售流水实收金额,
                 a.ADVANCE_PAYAMT as 预约金收款金额,  nvl(c.busno_payamt, 0)-a.ADVANCE_PAYAMT as 收银长款
          from cw_yyj a
                   left join cw_bankpay c on a.accdate = c.accdate and a.BUSNO = c.busno and c.PAYTYPE = 'Z998')
--                    left join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and b.PAYTYPE = 'Z998')
select s.COMPID,sc.COMPNAME,s.ZMDZ,s2.ORGNAME as mdzname,r.busno as busno,s.ORGNAME,accdate, PAYTYPE,
       s_dddw_list.DDDWLISTDISPLAY, 门店银行缴款明细金额, 销售流水实收金额, 收银长款
from r
join s_busi s on r.busno=s.BUSNO
join S_COMPANY sc on sc.COMPID=s.COMPID
join s_busi s2 on s.ZMDZ1=s2.BUSNO
join s_dddw_list on s_dddw_list.dddwliststatus = 1
   AND s_dddw_list.dddwname = '222' and r.PAYTYPE=s_dddw_list.DDDWLISTDATA
 where s.BUSNO  in (SELECT busno FROM v_user_busi WHERE  userid =p_userid and status = 1);
 end if;
end;
/

