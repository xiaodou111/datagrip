--�ѹ����ֽ�ȯ���Ƹ��ֽ����ȯ

insert into T_CASH_COUPON_WARE 
select '�ֽ����ȯ',WAREID,COMPID from T_CASH_COUPON_WARE 
WHERE coupon_type='�����ֽ�ȯ'
-- ����
--CPROC_COUPON_INFO_RSV
--�����ͽ����ĸ��洢����
--����33����
--cproc_coupon_618_rsv

--SPYY ����һ��ȯ���� ��ƷԤԼ�����
SELECT s_dddw_list.dddwname,
       s_dddw_list.dddwlistdata,
       s_dddw_list.dddwliststatus,
       s_dddw_list.dddwlistdisplay,
       s_dddw_list.compidlist,
       s_dddw_list.notes,
       s_dddw_list.status,
       s_dddw_list.sort
 ,s_dddw_list.md_dddwlistdata FROM s_dddw_list s_dddw_list
 WHERE  s_dddw_list.dddwname = 'SPYY' 
