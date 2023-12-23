SELECT a.erpsaleno,a.identityno,a.receiptdate from d_yb_first_cus  a 
INNER JOIN s_busi s ON a.busno=s.busno
WHERE s.zmdz1=81086 AND a.receiptdate=DATE'2023-04-01'
AND NOT EXISTS(select 1 from d_yb_first_cus b  
INNER JOIN s_busi s2 ON b.busno=s2.busno
where b.receiptdate>ADD_MONTHS(a.receiptdate,-6)AND b.receiptdate<a.receiptdate AND a.identityno=b.identityno
AND s.zmdz1=s2.zmdz1
)
ADD_MONTHS(TO_DATE('2023-04-21', 'YYYY-MM-DD'), -6)

SELECT a.erpsaleno,a.receiptdate,h.busno,d.saler,su.username,a.customername,a.IDENTITYNO,
case when a.ext_char01 like '%居民%' OR a.ext_char01 like '%学%' OR a.ext_char01 like '%新生儿%' then 1 else 0 end nb_flag,
a.ext_char12 AS 参保地,cbd.classname,h.netsum,2 AS status,
case when a.ext_char04 like '%瑞人堂%' or a.ext_char04 like '%康康%' or a.ext_char04 like '%方同仁%'
                  or a.ext_char04 like '%康盛堂%' then  1 else 0 end yg_flag
 FROM 
t_yby_order_h a
INNER JOIN t_sale_h h ON
a.erpsaleno=h.saleno
INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON 
h.saleno=d.saleno
left join s_user_base su on d.saler=su.userid
LEFT join d_cbd cbd ON a.ext_char12= cbd.cbd
left join s_busi s on s.busno=h.busno
WHERE a.receiptdate BETWEEN DATE'2022-10-01' AND DATE'2023-04-20'

SELECT  COUNT(*)  FROM d_yb_first_cus


