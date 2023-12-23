------旺店通订单处理
truncate  table  ffff  ;   

insert into  ffff 
SELECT src_order_no FROM  (
SELECT src_order_no,min(msg_status) as kk FROM d_in_wdt_sale_h 
WHERE consign_time between DATE'2021-08-01' and DATE'2021-08-31' group by src_order_no
) a WHERE kk<>1


SELECT msg FROM   d_in_wdt_sale_h  WHERE src_order_no in (select src_order_no from ffff) 
 and msg not like '%下发单据存在无法识别企业编码的线上门店%'   group by  msg
 ;

truncate table gggg
insert into gggg
SELECT seq_id FROM d_in_wdt_sale_h   WHERE src_order_no in (select src_order_no from ffff)   
 and msg not like '下发单据存在无法识别企业编码的线上门店%' 


merge into (SELECT a.seq_id,a.goods_no,a.BATCH_NO  FROM d_in_wdt_sale_d a  WHERE  seq_id in 
       (select seq_id from  gggg )   
       ) a
using (
 SELECT wareid,makeno,sap_batid,row_number()over( partition by wareid order by invalidate desc ) as rdn FROM  t_store_i 
)  b 
on ( a.goods_no=b.wareid and b.rdn=1)
when matched then 
  update set a.BATCH_NO=b.makeno||'+'||b.sap_batid  ;

  update d_in_wdt_sale_h  set msg_status=0  WHERE  seq_id in  (select seq_id from  gggg )   ;
  
  
  
  
  
  
  
  
  SELECT to_char(CONSIGN_TIME,'yyyy-mm-dd'),count(SRC_ORDER_NO) 
FROM d_in_wdt_sale_h a WHERE  msg_status = 0 and shop_no not in ('9059','9063')
  group by  to_char(CONSIGN_TIME,'yyyy-mm-dd') order by to_char(CONSIGN_TIME,'yyyy-mm-dd') desc
