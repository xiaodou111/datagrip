
--��һ�� ״̬����Ϊ0
select * from t_baier_sl;
--�ڶ��� ���������
select sum(sl) from t_baier_sl where status=0; --17986
--������ ���й��̷��䵽���ȼ����ŵ�,�ύǰ���������
call proc_baier_pjfp2();
select sum(wareqty) from aaaa2 where status=0;
--���Ĳ� ����������� �ټ��d_baier_otc_suiji����������

call proc_baier_otc_suiji2();
select sum(WAREQTY) from d_baier_otc_suiji where ACCDATE>=date'2023-11-01';
select * from d_baier_otc_suiji where wareid=10233261 order by accdate desc for updaTE
--
delete from aaaa2 where status=0 and 
wareid=30103176 and busno ='������ҽҩ���Źɷ����޹�˾̨�ݻ���ҩ��'


CALL proc_baier_pjfp2()
CALL proc_baier_otc_suiji2()

SELECT * from aaaa2 WHERE status=0
 AND wareid  IN (10225362,30103214);
 UPDATE d_baier_otc_suiji SET accdate=TRUNC(SYSDATE, 'MM')+ROWNUM-1   WHERE accdate IS NULL AND wareid=30103214




