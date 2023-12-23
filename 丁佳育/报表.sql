SELECT t_sale_h.accdate as accdate,
       t_sale_h.busno as busno,
       s_busi.orgname AS busname,
       t_sale_h.compid as compid,
       (SELECT ss.compname
          FROM s_company ss
         WHERE ss.compid = t_sale_h.compid) AS compname,
         t_sale_h.starttime as starttime,
       t_sale_h.finaltime as finaltime,
       round(round(t_sale_h.netsum, 2) - round(t_sale_h.loss, 2),2) as netsum,
       t_sale_h.saleno as saleno,
       pay.PAYTYPE,
       pay.CARDNO,
       pay.NETSUM as PAYNETSUM,
       round(round(t_sale_h.netsum, 2) - round(t_sale_h.loss, 2),2)-pay.NETSUM as leftnetsum,       
       t_sale_h.membercardno as membercardno
       
        FROM t_sale_h t_sale_h
  LEFT JOIN s_busi s_busi
    ON t_sale_h.compid = s_busi.compid
   AND t_sale_h.busno = s_busi.busno
  left join t_sale_pay pay on pay.saleno=t_sale_h.saleno
 WHERE t_sale_h.saleno='2311024549143155'
/*DW2£ºSELECT saleno, paytype,cardno,netsum,
  netsum_bak,
  pricetype
 FROM t_sale_pay WHERE saleno='2311024549201011'*/
