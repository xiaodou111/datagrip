

  select * from   --��������
    stock_out a 
   WHERE a.zodertype=4
   AND  a.matnr 
   in ('10302726','10302875') and A.lgort in ('P888')
  and a.zdate between date'2022-12-01' and date'2023-02-16' 
  
  
  select * from   --�������
    stock_in a 
   WHERE a.zodertype=4
   AND  a.matnr 
   in ('10302726','10302875') and A.lgort in ('P888')
  and a.zdate between date'2022-12-01' and date'2023-02-16' 
  
  
  
  
  
