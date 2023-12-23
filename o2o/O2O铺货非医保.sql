select * from  for update
delete from d_busno_square

insert into d_busno_square(busno) select busno from s_busi s where not  exists(select 1 from d_busno_square a where a.busno=s.busno  ) 
and length(s.busno)=5
