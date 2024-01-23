select count(*)  from d_in_wdt_sale_h t where t.rowid not in
       (select max(rowid)from d_in_wdt_sale_h t1 group by t1.SRC_ORDER_NO);--group byµ¥×Ö¶ÎÈ¥ÖØ

select * from  d_in_wdt_sale_h

select *  from d_in_wdt_sale_h h 
where h.SRC_ORDER_NO in (select h1.SRC_ORDER_NO                                
from d_in_wdt_sale_h h1                               
group by SRC_ORDER_NO                              
having count(1) > 1)

select h1.SRC_ORDER_NO,count(*)                                
from d_in_wdt_sale_h h1                               
group by SRC_ORDER_NO                              
having count(1) > 1

select *  from (select t1.*,               
count(1) over(partition by t1.SRC_ORDER_NO) rn          
from d_in_wdt_sale_h t1) t1 where t1.rn > 1;

select * from table1 a where rowid !=(select max(rowid) 
from table1 b where a.name1=b.name1 and a.name2=b.name2......)


delete from d_in_wdt_sale_h where SRC_ORDER_NO in(select SRC_ORDER_NO
 from d_in_wdt_sale_h group by SRC_ORDER_NO having count(SRC_ORDER_NO)>1
) and rowid not in (select min(rowid) from d_in_wdt_sale_h group by SRC_ORDER_NO
having count(*)>1  )




delete from d_in_wdt_sale_h t where t.rowid in (select rid                     
from (select t1.rowid rid,t1.SRC_ORDER_NO,
    
    row_number() over(partition by t1.SRC_ORDER_NO order by 1) rn                             
    from d_in_wdt_sale_h t1) t1                    
    where t1.rn > 1);
    
    
    
   
       10890587  341176
       11,231,763
       select count(*) from d_in_wdt_sale_h where SRC_ORDER_NO in (select SRC_ORDER_NO   
       from d_in_wdt_sale_h group by SRC_ORDER_NO having count(SRC_ORDER_NO)>1
       )           
       2 254196 3 219420 4 1372 5 225 6 54    >7 74862  
