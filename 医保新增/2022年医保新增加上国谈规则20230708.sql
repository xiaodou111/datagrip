SELECT COUNT(*)  FROM tmp_wlybjs_cyb a
JOIN d_ll_zxcy b ON a.ERP���ۺ�=b.saleno
WHERE  nvl(����ҽ��ͳ��֧��,0)+nvl(����Ա����ͳ��֧��,0)+nvl(�����˻�֧��,0)<>0
and ҽ���ܷ��� - nvl(gtjeed,0)<>0 

SELECT MIN(RECEIPTDATE),MAX(RECEIPTDATE) from d_yb_first_cus a
JOIN d_zhyb_hz_cyb b ON a.erpsaleno=b.ERP���۵���
JOIN d_ll_zxcy gt ON b.erp���۵���=gt.saleno
WHERE nvl(ͳ��֧����,0)+nvl(��������֧����,0)+nvl(���˵����ʻ�֧����,0)<>0
and ҽ�Ʒ����ܶ� - nvl(gtjeed,0)<>0 
-------------

select ERP���ۺ� AS erpsaleno,TRUNC(����ʱ��) AS receiptdate ,��������,d.saler,su.username,a.����,a.���֤��,
case when nvl(��Ա���,' ') in ('2511','40','41','2811','52') then '1' else '0' END AS nb_flag,
ҽ�����ڵر�� AS cbd ,
CASE WHEN replace(���ڵ�����,'����','����') IN ('�б���','������') THEN '�б���' ELSE replace(���ڵ�����,'����','����') END as cbdname,�ܽ�� AS netsum,2 AS status,
case when info.COMPANYNAME like '%������%' or info.COMPANYNAME like '%����%' or info.COMPANYNAME like '%��ͬ��%'
 or info.COMPANYNAME like '%��ʢ��%' then 1 else 0 end yg_flag,
case when nvl(��������,' ')='1' then '1' when nvl(��������,' ') in('33','34','39') then '2' else '0' END
 AS jslx,a.�û��˾������ AS orderno ,cy.�α���Ա��� AS cbrylb
from tmp_wlybjs_cyb a
--
JOIN d_ll_zxcy b ON a.ERP���ۺ�=b.saleno
--
INNER join (SELECT saleno,MAX(saler) saler FROM t_sale_d GROUP BY saleno ) d ON
a.ERP���ۺ�=d.saleno
left join s_user_base su on d.saler=su.userid
join hydee_taizhou.taizhou_personal_info info on info.IDNUMBER=a.���֤��
LEFT join D_ZHYB_HZ_CYB cy ON a.erp���ۺ�=cy.erp���۵��� AND a.���֤��=cy.���֤��
WHERE ����ʱ��>=date'2022-01-01' AND ����ʱ��<date'2022-03-01'
--
AND nvl(����ҽ��ͳ��֧��,0)+nvl(����Ա����ͳ��֧��,0)+nvl(�����˻�֧��,0)<>0
and ҽ���ܷ��� - nvl(gtjeed,0)<>0 
--

