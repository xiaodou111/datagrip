select orgname,SALENO,ACCDATE,WAREID,WAREQTY,MEMCARDNO,SALEPRICE,NETAMT,rowno from d_sale_business1 
where accdate>=date'2023-03-01' and saleno='2303314019039408'
where rowno is not null  order by rowno desc for update
--数据导入 诺华数据
--直连库的V_SALE_BUSINESS查看



delete from d_sale_business1_temp
select max(accdate) from d_sale_business1_temp
delete from d_sale_business1_temp

select * from 
d_sale_business1_temp
insert into   d_sale_business1 select * from d_sale_business1_temp
select count(*)  from d_sale_business1_temp where accdate>=date'2023-07-01'
delete from d_sale_business1_temp
