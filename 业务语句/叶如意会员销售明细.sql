select to_char(a.accdate,'yyyymm'),a.saleno,a.membercardno
FROM t_sale_h a
 WHERE 
    a.membercardno IS NOT NULL
    AND a.compid in(1060,1080) 
 and a.accdate between date'2022-10-01' and date'2023-09-30'
 and not exists(select 1 from t_sale_return_h b where a.saleno=b.saleno)
 order by a.accdate
