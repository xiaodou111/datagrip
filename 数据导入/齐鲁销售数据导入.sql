
insert into d_sale_business1 select * from d_sale_business1_temp;
delete from d_sale_business1_temp;
select *
from d_sale_business1 where ACCDATE>=date'2023-12-01';
select ORDERID,DETAILID from  v_sale_business

 group by ORDERID,DETAILID having count(*)>1
 
 update v_sale_business
set DETAILID = DETAILID + row_number() over(partition by ORDERID order by DETAILID)
from (
select ORDERID,DETAILID
from v_sale_business
group by ORDERID,DETAILID
having count(*)>1
) t
where v_sale_business.ORDERID = t.ORDERID and v_sale_business.DETAILID = t.DETAILID


MERGE INTO v_sale_business dst
USING (
SELECT ORDERID, DETAILID,
ROW_NUMBER() OVER(PARTITION BY ORDERID ORDER BY DETAILID) AS rn
FROM (
SELECT ORDERID, DETAILID
FROM v_sale_business
GROUP BY ORDERID, DETAILID
HAVING COUNT(*) > 1
)
) src
ON (dst.ORDERID = src.ORDERID AND dst.DETAILID = src.DETAILID)
WHEN MATCHED THEN
UPDATE SET dst.DETAILID = src.rn;

select rowno,saleno from d_sale_business1@hydee_zy where rowno is not null group by rowno,saleno 
having count(*)>1

select * from d_sale_business1@hydee_zy where saleno in (
select ORDERID from (
select ORDERID,DETAILID from  v_sale_business

 group by ORDERID,DETAILID having count(*)>1)
 
 )
 
 select * from t_sale_h@hydee_zy where saleno in (
 select ORDERID from (
select ORDERID,DETAILID from  v_sale_business

 group by ORDERID,DETAILID having count(*)>1)
 )



MERGE INTO d_sale_business1 dst
USING (
SELECT ORDERID, DETAILID,
ROW_NUMBER() OVER(PARTITION BY ORDERID ORDER BY DETAILID) AS new_detailid
from v_sale_business@zhilian
where ORDERID in ( select ORDERID from (
select ORDERID,DETAILID from  v_sale_business@zhilian

 group by ORDERID,DETAILID having count(*)>1)
 )
 )


 src
ON (dst.SALENO = src.ORDERID )
WHEN MATCHED THEN
UPDATE SET dst.ROWNO = src.new_detailid;
