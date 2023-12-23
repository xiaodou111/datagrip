SELECT t_sale_h.accdate                                                           as accdate,
       t_sale_h.busno                                                             as busno,
       s_busi.orgname                                                             AS busname,
       t_sale_h.compid                                                            as compid,
       (SELECT ss.compname
        FROM s_company ss
        WHERE ss.compid = t_sale_h.compid)                                        AS compname,
       t_sale_h.starttime                                                         as starttime,
       t_sale_h.finaltime                                                         as finaltime,
       round(round(pay.netsum, 2) - round(t_sale_h.loss, 2), 2)                   as netsum,
       t_sale_h.saleno                                                            as saleno,
       pay.PAYTYPE,
       pay.PAYTYPE                                                                as PAYDES,
       pay.CARDNO,
       pay.NETSUM                                                                 as PAYNETSUM,
       round(round(t_sale_h.netsum, 2) - round(t_sale_h.loss, 2), 2) - pay.NETSUM as leftnetsum,
       t_sale_h.membercardno                                                      as membercardno

FROM t_sale_h t_sale_h
         LEFT JOIN s_busi s_busi
                   ON t_sale_h.compid = s_busi.compid
                       AND t_sale_h.busno = s_busi.busno
         left join t_sale_pay pay on pay.saleno = t_sale_h.saleno
WHERE t_sale_h.accdate >= to_date('2023-11-01', 'yyyy-MM-dd')
  and t_sale_h.accdate < to_date('2023-11-02', 'yyyy-MM-dd')
  and t_sale_h.busno = 81001
  and pay.paytype = 'Z022';

--锟秸款方式锟斤拷水锟斤拷询
select accdate, PAYTYPE, sum(round(round(pay.netsum, 2) - round(h.loss, 2), 2))
FROM t_sale_h h
         left join t_sale_pay pay on pay.saleno = h.saleno
WHERE h.accdate >= to_date('2023-11-01', 'yyyy-MM-dd')
  and h.accdate < to_date('2023-11-02', 'yyyy-MM-dd')
group by h.accdate, pay.paytype;
--锟脚碉拷锟斤拷锟叫缴匡拷锟斤拷细
SELECT a.payment_method,
       a.usedate,
       sum(a.busno_payamt),
       max(s_dddw_list.DDDWLISTDISPLAY)
FROM t_busno_bank_paydetails a
         left join s_busi sb on a.busno = sb.busno
         left join s_dddw_list s_dddw_list on s_dddw_list.dddwliststatus = 1
    AND s_dddw_list.dddwname = '222' and s_dddw_list.DDDWLISTDATA = a.payment_method
WHERE a.usedate >= to_date('2023-11-01', 'yyyy-MM-dd')
  and a.usedate < to_date('2023-11-02', 'yyyy-MM-dd')
group by a.payment_method, a.usedate;


SELECT s_dddw_list.dddwlistdata    AS dddwlistdata,
       s_dddw_list.dddwlistdisplay AS dddwlistdisplay,
       s_dddw_list.dddwname        AS dddwname
FROM s_dddw_list s_dddw_list
WHERE s_dddw_list.dddwliststatus = 1
  AND s_dddw_list.dddwname = '222'
  and DDDWLISTDISPLAY = '招行聚合支付';

饿了么	工行刷卡	工行移动刷卡	公司汇入	健E卡	京东到家	老白智慧药房	美团	平安卡	平安药诊卡组合	普康宝	企健付	收银兑换损失	台州医保	微信小程序	现金	预约金消费	招行固定二维码	招行聚合支付

--门店银行缴款明细
with d_mdyhjkmx as
         (SELECT a.payment_method,
                 a.usedate,
                 sum(a.busno_payamt)              as je,
                 max(s_dddw_list.DDDWLISTDISPLAY) as DDDWLISTDISPLAY
          FROM t_busno_bank_paydetails a
                   left join s_busi sb on a.busno = sb.busno
                   left join s_dddw_list s_dddw_list on s_dddw_list.dddwliststatus = 1
              AND s_dddw_list.dddwname = '222' and s_dddw_list.DDDWLISTDATA = a.payment_method
          WHERE a.usedate >= to_date('2023-11-01', 'yyyy-MM-dd')
            and a.usedate < to_date('2023-11-02', 'yyyy-MM-dd')
            and a.BUSNO in (81001, 81002, 81003, 81004, 81005)
          group by a.payment_method, a.usedate),
     --收款方式流水查询报表
     d_skfsllcx as (select accdate, PAYTYPE, sum(round(round(pay.netsum, 2) - round(h.loss, 2), 2)) as je
                    FROM t_sale_h h
                             left join t_sale_pay pay on pay.saleno = h.saleno
                    WHERE h.accdate >= to_date('2023-11-01', 'yyyy-MM-dd')
                      and h.accdate < to_date('2023-11-02', 'yyyy-MM-dd')
                      and h.BUSNO in (81001, 81002, 81003, 81004, 81005)
                    group by h.accdate, pay.paytype),
     a1 as (SELECT accdate,
                   MAX(CASE WHEN PAYTYPE = '91' THEN diffje END)   AS HYT补充医疗,
                   MAX(CASE WHEN PAYTYPE = '43' THEN diffje END)   AS PICC医卡通,
                   MAX(CASE WHEN PAYTYPE = 'Z010' THEN diffje END) AS 储值卡消费,
                   MAX(CASE WHEN PAYTYPE = 'Z034' THEN diffje END) AS 饿了么,
                   MAX(CASE WHEN PAYTYPE = '48' THEN diffje END)   AS 工行刷卡,
                   MAX(CASE WHEN PAYTYPE = 'Z087' THEN diffje END) AS 工行移动刷卡,
                   MAX(CASE WHEN PAYTYPE = 'Z043' THEN diffje END) AS 公司汇入,
                   MAX(CASE WHEN PAYTYPE = 'Z037' THEN diffje END) AS 健E卡,
                   MAX(CASE WHEN PAYTYPE = 'Z025' THEN diffje END) AS 京东到家,
                   MAX(CASE WHEN PAYTYPE = 'Z065' THEN diffje END) AS 老白智慧药房,
                   MAX(CASE WHEN PAYTYPE = 'Z022' THEN diffje END) AS 美团,
                   MAX(CASE WHEN PAYTYPE = '45' THEN diffje END)   AS 平安卡,
                   MAX(CASE WHEN PAYTYPE = 'Z082' THEN diffje END) AS 平安药诊卡组合,
                   MAX(CASE WHEN PAYTYPE = 'Z075' THEN diffje END) AS 普康宝,
                   MAX(CASE WHEN PAYTYPE = 'Z021' THEN diffje END) AS 企健付,
                   MAX(CASE WHEN PAYTYPE = 'Z996' THEN diffje END) AS 收银兑换损失,
                   MAX(CASE WHEN PAYTYPE = 'Z060' THEN diffje END) AS 台州医保,
                   MAX(CASE WHEN PAYTYPE = 'Z027' THEN diffje END) AS 微信小程序,
                   MAX(CASE WHEN PAYTYPE = '1' THEN diffje END)    AS 现金,
                   MAX(CASE WHEN PAYTYPE = 'Z012' THEN diffje END) AS 预约金消费,
                   MAX(CASE WHEN PAYTYPE = 'Z018' THEN diffje END) AS 招行固定二维码,
                   MAX(CASE WHEN PAYTYPE = 'Z017' THEN diffje END) AS 招行聚合支付
            FROM (SELECT nvl(mdyh.USEDATE, skfs.ACCDATE)        as accdate,
                         NVL(mdyh.je, 0) - NVL(skfs.je, 0)      AS diffje,
                         nvl(mdyh.PAYMENT_METHOD, skfs.PAYTYPE) as PAYTYPE,
                         DDDWLISTDISPLAY
                  FROM d_mdyhjkmx mdyh
                           full join d_skfsllcx skfs
                                     ON mdyh.USEDATE = skfs.ACCDATE AND mdyh.PAYMENT_METHOD = skfs.PAYTYPE)
            GROUP BY accdate)
select accdate,
       HYT补充医疗,
       PICC医卡通,
       储值卡消费,
       饿了么,
       工行刷卡,
       工行移动刷卡,
       公司汇入,
       健E卡,
       京东到家,
       老白智慧药房,
       美团,
       平安卡,
       平安药诊卡组合,
       普康宝,
       企健付,
       收银兑换损失,
       台州医保,
       微信小程序,
       现金,
       预约金消费,
       招行固定二维码,
       招行聚合支付,
       NVL(HYT补充医疗, 0) +
       NVL(PICC医卡通, 0) +
       NVL(储值卡消费, 0) +
       NVL(饿了么, 0) +
       NVL(工行刷卡, 0) +
       NVL(工行移动刷卡, 0) +
       NVL(公司汇入, 0) +
       NVL(健E卡, 0) +
       NVL(京东到家, 0) +
       NVL(老白智慧药房, 0) +
       NVL(美团, 0) +
       NVL(平安卡, 0) +
       NVL(平安药诊卡组合, 0) +
       NVL(普康宝, 0) +
       NVL(企健付, 0) +
       NVL(收银兑换损失, 0) +
       NVL(台州医保, 0) +
       NVL(微信小程序, 0) +
       NVL(现金, 0) +
       NVL(预约金消费, 0) +
       NVL(招行固定二维码, 0) +
       NVL(招行聚合支付, 0) as sumje
from a1;









