

select * from s_busi
START WITH zmdz1=81001 
CONNECT BY PRIOR busno = zmdz1
;


select busno,zmdz1,level from s_busi
start with zmdz1='81001'      
connect by prior zmdz1 = busno 
AND LEVEL <= 3 and busno<>zmdz1
order by level desc;


with tmp as
(select 1 as id,'c,b,a' as name from dual
union all
select 2,'d,e,f' from dual
union all
select 3,'h,g' from dual
)
select id, REGEXP_SUBSTR( name,'[^,]+', 1, level) as value
from tmp
connect by level <= regexp_count(name, '[^,]+')
and prior id=id
and prior dbms_random.value() is not null
