create or replace PROCEDURE proc_djy_mdjkcy2(p_date IN DATE,
                                          p_zmdz IN pls_integer,
                                          p_sql OUT SYS_REFCURSOR )
IS
  v_time number;

BEGIN

 OPEN p_sql FOR
        --收银员日结对账单
    with cw_rj as (select trunc(ACCDATE) as ACCDATE, h.CHECKNO, h.BUSNO, d.PAYTYPE, d.RECHARGEAMT as 储值卡充值金额,
                      d.ADVANCE_PAYMENT_AMT as 预约金收款金额
               from t_payee_check_h h
                        join t_payee_check_d d on h.CHECKNO = d.CHECKNO
               join s_busi sb on h.BUSNO=sb.BUSNO
--                where BUSNO = 81001 and trunc(ACCDATE) = date'2024-02-01'
                   where trunc(ACCDATE) between p_date and p_date and  sb.ZMDZ=p_zmdz
                 and d.PAYTYPE in ('1')),
     --门店银行缴款明细
     cw_bankpay as (SELECT a.busno, a.payment_method as PAYTYPE, trunc(a.usedate) as accdate,
                           sum(a.busno_payamt) as busno_payamt
                    FROM t_busno_bank_paydetails a
                             left join s_busi sb
                                       on a.busno = sb.busno
--                     WHERE a.use_busno = 81001 and trunc(a.usedate) = date'2024-02-01'
                        where trunc(a.usedate) between p_date and p_date and  sb.ZMDZ=p_zmdz
                    group by a.busno, a.payment_method, trunc(a.usedate)),
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
                  where h.ACCDATE between p_date and p_date and  s.ZMDZ=p_zmdz
                  group by ACCDATE, h.BUSNO, pay.PAYTYPE),
    r as (select nvl(a.accdate, b.accdate) as accdate, nvl(a.BUSNO, b.busno) as busno,
                 nvl(a.PAYTYPE, b.PAYTYPE) as PAYTYPE,
                 nvl(a.busno_payamt, 0) as 门店银行缴款明细金额, nvl(b.PAYNETSUM, 0) as 销售流水实收金额,
                 nvl(a.busno_payamt, 0) - nvl(b.PAYNETSUM, 0) as 收银长款
          from cw_bankpay a
                   full join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and a.PAYTYPE = b.PAYTYPE
          union all
          select a.accdate, a.BUSNO, 'Z997', nvl(b.PAYNETSUM, 0) as 销售流水实收金额,
                 a.储值卡充值金额 as 储值卡充值金额, nvl(b.PAYNETSUM, 0)-a.储值卡充值金额 as 收银长款
          from cw_rj a
                   left join cw_bankpay c on a.accdate = c.accdate and a.BUSNO = c.busno and c.PAYTYPE = 'Z997'
                   left join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and b.PAYTYPE = 'Z997'
          union all
          select a.accdate, a.BUSNO, 'Z998', nvl(b.PAYNETSUM, 0) as 销售流水实收金额,
                 a.预约金收款金额 as 预约金收款金额,  nvl(b.PAYNETSUM, 0)-a.预约金收款金额 as 收银长款
          from cw_rj a
                   left join cw_bankpay c on a.accdate = c.accdate and a.BUSNO = c.busno and c.PAYTYPE = 'Z998'
                   left join cw_payls b on a.accdate = b.accdate and a.BUSNO = b.busno and b.PAYTYPE = 'Z998')
select s.COMPID,sc.COMPNAME,s.ZMDZ,s2.ORGNAME as mdzname,r.busno as busno,s.ORGNAME,accdate, PAYTYPE,
       s_dddw_list.DDDWLISTDISPLAY,销售流水实收金额, 门店银行缴款明细金额,  收银长款
from r
join s_busi s on r.busno=s.BUSNO
join S_COMPANY sc on sc.COMPID=s.COMPID
join s_busi s2 on s.ZMDZ1=s2.BUSNO
join s_dddw_list on s_dddw_list.dddwliststatus = 1
   AND s_dddw_list.dddwname = '222' and r.PAYTYPE=s_dddw_list.DDDWLISTDATA order by PAYTYPE,r.busno;

end;
/

