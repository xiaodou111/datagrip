
SELECT OWNER, NAME, TYPE
FROM DBA_SOURCE
WHERE REGEXP_LIKE(TEXT, 'rrt_rpt_sale_pay', 'i');
cproc_sale_paytype_nopayee

cproc_sale_paytype


