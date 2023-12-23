
  
  delete from d_HFYF_kc
  
  select * from d_HFYF_kc for update
  

 select * from       d_HFYF_accept where gzdate>=date'2023-07-01' for update
 select * from v_accept_hfyf_p001 where zdate>=date'2023-07-01'
select gzdate, 
name1, 
djlx, 
matnr, 
maktx, 
zguig, 
zscqymc,
gys, 
name2, 
mseh6, 
rksl, 
cksl,
ZGYSPH
 from  d_hfyf_sale for update


alter table d_hfyf_sale add gys varchar2(100); 
