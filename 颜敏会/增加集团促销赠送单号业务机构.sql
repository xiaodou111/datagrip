--1.增加集团促销赠送单号业务机构
update t_pstplan_h
set busnos=busnos||',83666'
where PSTPLANNO in('2301020000091','2301020000093','2301020000092','2301020000089','2301020000094');

--2.查找父单号等于集团单号的分公司重新赠送单号
select BUSNOS from t_pstplan_h
where parentno in('2301020000091','2301020000093','2301020000092','2301020000089','2301020000094') and  compid=1050;


--3.手动判断修改哪条分公司单据
update t_pstplan_h
set busnos=busnos||',83666'
where parentno in('2301020000091','2301020000093','2301020000092','2301020000089','2301020000094') and  compid=1050;

select compid from s_busi where busno=83666;






select parentno,PSTPLANNO from t_pstplan_h where PSTPLANNO='2301020000091'

select * from t_pstplan_h where parentno='2301020000093' and compid=1050
and busnos like '%81558%' 
delete from t_pstplan_h where parentno='2301020000082' and trunc(createtime)=
trunc(sysdate) 
and compid=1000 

and busnos like '%81558%'

select compid from s_busi where busno=83665
