--ȷ�����ͳɹ���״̬��Ϊ���   
   update d_saleno_temp set status=1 where status=0 ; 
   update d_bl_saleno   set status=1 where status=0 ; 

--�������msg_id
select * from hd_msg_out where msg_id in (select msg_id from d_bl_saleno where status=0);

--�ɹ����͵�msg_id ���ͳɹ�����Ҧ����СƱ����
select * from hd_msg_out_bak where msg_id in (select msg_id from d_bl_saleno where status=0) 

update hd_msg_out_bak set BILLNO= 9 || SUBSTR(BILLNO, 2) where msg_id in (select msg_id from d_bl_saleno ) 
AS OF TIMESTAMP TO_TIMESTAMP('2023-11-09 13:00:00', 'YYYY-MM-DD HH24:MI:SS'));
select * from hd_msg_out_bak where msg_id in ('10100000000203750479');
--����ʧ�ܵ�msg_id
select * from hd_msg_out_error  
where msg_id in (select msg_id from d_bl_saleno);
select LSNO from hd_out_sale_h where LSNO IN (select LSNO from hd_out_sale_h where FQ_TIME>to_date('2023-11-07 8:00:00', 'yyyy-mm-dd hh24:mi:ss')  
);

--ÿ��ÿ����������һ��������ˮ��(���ܵ���)

select * from hd_out_sale_h where LSNO in (select BILLNO  from hd_msg_out_bak where msg_id in (select msg_id from d_bl_saleno ) )
select * from hd_out_sale_h where FQ_TIME>to_date('2023-11-07 8:00:00', 'yyyy-mm-dd hh24:mi:ss') and busno=5086 ;

select * from hd_out_sale_d --where FQ_TIME>to_date('2023-11-07 8:00:00', 'yyyy-mm-dd hh24:mi:ss') 
where msg_id in (select msg_id from hd_msg_out_bak where msg_id in (select msg_id from hd_out_sale_h 
where FQ_TIME>to_date('2023-11-07 8:00:00', 'yyyy-mm-dd hh24:mi:ss') )) ;
select * from hd_out_sale_h  where msg_id in (select msg_id from d_bl_saleno 
AS OF TIMESTAMP TO_TIMESTAMP('2023-11-09 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
select * from hd_msg_out_bak where msg_id='10100000000203750796';
select * from hd_out_sale_d where msg_id in(select msg_id from d_bl_saleno 
AS OF TIMESTAMP TO_TIMESTAMP('2023-11-09 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
and busno=3601
select * from t_ware_base where wareid=50000847
select * from t_sale_h where saleno='2310231000101407'
select LENGTH('10900000000078106732') FROM DUAL

select * from t_sale_d WHERE SALENO IN ( select  SALENO FROM  d_saleno_temp)


 INSERT INTO tmp_disable_trigger (table_name) VALUES ('t_sale_d');
UPDATE t_sale_d SET PURPRICE=0  WHERE SALENO IN ( select  SALENO FROM  d_saleno_temp);
 DELETE tmp_disable_trigger WHERE table_name = 't_sale_d';
 select SUM(NETPRICE) FROM  t_sale_d WHERE SALENO IN ( select  SALENO FROM  d_saleno_temp);
 
 select * from t_sale_d 
 WHERE SALENO IN ( select  SALENO FROM  d_saleno_temp);
 
 select * from tmp_sale_mx_o2o


SELECT a.saleno,b.busno, b.md_busno, trunc(a.accdate) AS accdate, MAX(a.compid) AS compid
                     FROM   t_sale_h a
                     LEFT   JOIN s_busi b
                     ON     a.compid = b.compid AND a.busno = b.busno
                     WHERE /* a.accdate > trunc(to_date('2021-03-19', 'yyyy-mm-dd') - 1) AND
                            a.accdate < trunc(to_date('2021-03-21', 'yyyy-mm-dd') + 1)*/
                           a.saleno in (select saleno from d_saleno_temp )
                     GROUP  BY b.busno, b.md_busno, trunc(a.accdate),a.saleno
