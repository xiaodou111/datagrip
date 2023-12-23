--1.增加集团促销调价单号业务机构
update  t_prom_h set busnos=busnos||',83666' where promno = '202308090000002';

  
  select compid from s_busi where busno=84048;
--2.查找父单号等于集团单号的分公司重新赠送单号
select busnos from t_prom_h
where parentno='202308090000002' and compid=1050;

select * from t_prom_h
where promno='202308090000003';


--3.手动判断修改哪条分公司单据
update t_prom_h
set busnos=busnos||',83666'
where parentno='202308090000002' ;--and compid=1050;

update t_prom_h
set busnos='84047,84049,84050,84052,84053,84049,84056'
where promno='202209150000002'  ;

  select busnos from t_prom_h where promno = '202202240000023'
  and busnos like '%83665%' ;
  select compid,busnos from t_prom_h where PARENTNO = '202209150000002' ;
 
  select DAYS from t_prom_h where promno = '202202240000023'  ;
  update t_prom_h set DAYS=DAYS||',15'  where promno = '202202240000023'  ;
  select compid from s_busi where busno=83662
