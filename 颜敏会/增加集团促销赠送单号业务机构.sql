--1.���Ӽ��Ŵ������͵���ҵ�����
update t_pstplan_h
set busnos=busnos||',83666'
where PSTPLANNO in('2301020000091','2301020000093','2301020000092','2301020000089','2301020000094');

--2.���Ҹ����ŵ��ڼ��ŵ��ŵķֹ�˾�������͵���
select BUSNOS from t_pstplan_h
where parentno in('2301020000091','2301020000093','2301020000092','2301020000089','2301020000094') and  compid=1050;


--3.�ֶ��ж��޸������ֹ�˾����
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
