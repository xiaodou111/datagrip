

--ҩ����Ļ�Ա 23������ҩ�������,24��û����ҩ��
SELECT a.*,'ҩ����Ļ�Ա',me.MEMCARDNO,me.CARDHOLDER,me.mobile FROM D_ZHYB_YEAR_2023_1  a
LEFT join t_sale_h h ON a.saleno=h.saleno
LEFT join t_memcard_reg me ON me.MEMCARDNO=h.MEMBERCARDNO
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b WHERE a.idcard=b.idcard)
and a.execdate  between DATE '2023-07-01'  and date'2023-08-31';

--�������Ļ�Ա 23������ҩ�������,24��û��������
SELECT a.*,'�������Ļ�Ա',me.MEMCARDNO,me.CARDHOLDER,me.mobile  FROM D_ZHYB_YEAR_2023_1  a
LEFT join t_sale_h h ON a.saleno=h.saleno
LEFT join t_memcard_reg me ON me.MEMCARDNO=h.MEMBERCARDNO
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard)
and a.execdate between DATE '2023-07-01'  and date'2023-08-31';


--D_ZHYB_YEAR_2023_1  ��ȡ�������ۼ�¼��ÿ�����֤ 2023��ҩ�����ڵغͲα��ض�Ӧ�� ҩ����������һ�εļ�¼
select * from D_ZHYB_YEAR_2023_1 where IDCARD='612401198901244775';
select max(EXECDATE) from D_ZHYB_YEAR_2023_1;

select count(*) from d_zhyb_year_2023_zs;
select min(EXECDATE) from d_zhyb_year_2023_zs; --ÿ�����֤24�꿪ʼ���һ���� ҩ�����ڵغͲα��ض�Ӧ�� �������ѵļ�¼