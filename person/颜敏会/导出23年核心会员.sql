

--药店核心会员 23年来过药店或诊所,24年没来过药店
SELECT a.*,'药店核心会员',me.MEMCARDNO,me.CARDHOLDER,me.mobile FROM D_ZHYB_YEAR_2023_1  a
LEFT join t_sale_h h ON a.saleno=h.saleno
LEFT join t_memcard_reg me ON me.MEMCARDNO=h.MEMBERCARDNO
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b WHERE a.idcard=b.idcard)
and a.execdate  between DATE '2023-07-01'  and date'2023-08-31';

--诊所核心会员 23年来过药店或诊所,24年没来过诊所
SELECT a.*,'诊所核心会员',me.MEMCARDNO,me.CARDHOLDER,me.mobile  FROM D_ZHYB_YEAR_2023_1  a
LEFT join t_sale_h h ON a.saleno=h.saleno
LEFT join t_memcard_reg me ON me.MEMCARDNO=h.MEMBERCARDNO
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard)
and a.execdate between DATE '2023-07-01'  and date'2023-08-31';


--D_ZHYB_YEAR_2023_1  获取所有销售记录中每个身份证 2023年药店所在地和参保地对应的 药店或诊所最后一次的记录
select * from D_ZHYB_YEAR_2023_1 where IDCARD='612401198901244775';
select max(EXECDATE) from D_ZHYB_YEAR_2023_1;

select count(*) from d_zhyb_year_2023_zs;
select min(EXECDATE) from d_zhyb_year_2023_zs; --每个身份证24年开始最后一次在 药店所在地和参保地对应的 诊所消费的记录