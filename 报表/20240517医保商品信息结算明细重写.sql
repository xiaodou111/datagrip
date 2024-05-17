with a1 as (
select yh.RECEIPTDATE, d.BUSNO, tb.CLASSNAME, d.SALENO, d.SALER, d.WAREID, d.WAREQTY, d.NETAMT, d.NETPRICE, d.ROWNO,
       case when yd.EXT_CHAR08 = 0 then 'ҽ����' when yd.EXT_CHAR08 = 1 then 'ҽ����' else 'ҽ����' end as WE_SCHAR01,
       decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) as �ŵ�����ҽ��֧����,
       case
           when nvl(decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05), 0) = 0 then
               d.NETPRICE * (1 - yd.EXT_CHAR08) * d.WAREQTY
           else round(LEAST(d.NETPRICE, decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)) *
                      (1 - yd.EXT_CHAR08) * d.WAREQTY, 4) end as ������ϸҽ��֧����,
    case when yd.EXT_CHAR08 = 1 then d.NETAMT else 0 end as ҽ�Ʒ����Է��ܶ�,
       cyb.ͳ��֧���� as ����ͳ��֧����, cyb.���˵����ʻ�֧���� as �������˵����ʻ�֧����,
       cyb.���������ʻ�֧���� as �������������ʻ�֧����,
       cyb.��������֧���� as ������������֧����, cyb.�󲡲��� as �����󲡲���,
       cyb.�ֽ�֧���ܶ� as �����ֽ�֧���ܶ�, cyb.��ͥ����֧�� as ������ͥ����֧��,
       cyb.ҽ�ƾ��� + cyb.��������֧���� as ������������֧��,
       d.MAKENO, d.INVALIDATE
from t_sale_d d
         join D_ZHYB_HZ_CYB cyb on d.SALENO = cyb.ERP���۵���
         join t_yby_order_h yh on yh.ERPSALENO = cyb.ERP���۵���
         join (select ORDERNO, WARECODE, EXT_CHAR08
               from T_YBY_ORDER_D
               group by ORDERNO, WARECODE, EXT_CHAR08) yd on yh.ORDERNO = yd.ORDERNO and yd.WARECODE = d.WAREID
         join t_ware_ext ext on d.WAREID = ext.WAREID and ext.COMPID = 1000
         join t_busno_class_set ts on d.busno = ts.busno and ts.classgroupno = '305'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
  where d.SALENO in ('2401304551007053', '2401271247060521') and cyb.��ر�־ = '�����'),
    a2 as (select RECEIPTDATE, BUSNO, CLASSNAME, SALENO, SALER, WAREID, WAREQTY, NETAMT, NETPRICE, ROWNO, WE_SCHAR01,
                  �ŵ�����ҽ��֧����, ������ϸҽ��֧����, ҽ�Ʒ����Է��ܶ�, ����ͳ��֧����, �������˵����ʻ�֧����,
                  �������������ʻ�֧����, ������������֧����, �����󲡲���, �����ֽ�֧���ܶ�, ������ͥ����֧��, ������������֧��,
                  MAKENO, INVALIDATE,sum(������ϸҽ��֧����) over ( partition by SALENO) as ����ҽ��֧����,
       ������ϸҽ��֧����/sum(������ϸҽ��֧����) over ( partition by SALENO) as ������ϸҽ������
           from a1 )
select RECEIPTDATE, BUSNO, CLASSNAME, SALENO, SALER, WAREID, WAREQTY,MAKENO, INVALIDATE, NETAMT, NETPRICE, WE_SCHAR01,
--        �ŵ�����ҽ��֧����,
       ������ϸҽ��֧����, ҽ�Ʒ����Է��ܶ�  as ������ϸҽ�Ʒ����Է�,
       ������ϸҽ������,
       ����ͳ��֧���� * ������ϸҽ������ as ͳ��֧����, �������˵����ʻ�֧���� * ������ϸҽ������ as ���˵����ʻ�֧����,
       �������������ʻ�֧����*������ϸҽ������ as ���������ʻ�֧����,
       ������������֧����*������ϸҽ������ as ��������֧����,�����󲡲���*������ϸҽ������ as �󲡲���,
        ������������֧�� * ������ϸҽ������ as ��������֧��,
        NETAMT-����ͳ��֧���� * ������ϸҽ������-�������˵����ʻ�֧���� * ������ϸҽ������-������������֧���� * ������ϸҽ������-�����󲡲���*������ϸҽ������
            -������������֧�� * ������ϸҽ������ as ������ֽ�ӹ���,
        �����ֽ�֧���ܶ� * ������ϸҽ������ as ������ϸ�ֽ�֧��, ������ͥ����֧�� * ������ϸҽ������ as ������ϸ��ͥ����֧��
      ,  ����ҽ��֧����
from a2;

select ACCDATE, BUSNO, MDLX, SALENO, SALER, WAREID, WAREQTY, MAKENO, INVALIDATE, "ʵ�۽��", "ʵ��", WE_SCHAR01,
       "ҽ�Ʒ����Է��ܶ�", "������ϸҽ������", "����ͳ��֧����", "�������˵����ʻ�֧����", "�������������ʻ�֧����",
       "������������֧����", "�����󲡲���", "������������֧��", "�������Ը�", "ҽ�����޼�", "�����ֽ�֧���ܶ�",
       "������ͥ����֧��", "�ط�����", "������ϸҽ��֧����"
from D_YBZD_detail;


insert into D_YBZD_detail(ACCDATE, BUSNO, MDLX, SALENO, SALER, WAREID, WAREQTY, MAKENO, INVALIDATE, "ʵ�۽��", "ʵ��", WE_SCHAR01,
       "ҽ�Ʒ����Է��ܶ�", "������ϸҽ������", "����ͳ��֧����", "�������˵����ʻ�֧����", "�������������ʻ�֧����",
       "������������֧����", "�����󲡲���", "������������֧��", "�������Ը�", "ҽ�����޼�", "�����ֽ�֧���ܶ�",
       "������ͥ����֧��", "�ط�����", "������ϸҽ��֧����")
select a2.RECEIPTDATE,a2.BUSNO, a2.CLASSNAME, a2.SALENO,a2.SALER, a2.WAREID,a2.WAREQTY,a2.MAKENO,a2.INVALIDATE, a2.NETAMT as ʵ�۽��, a2.NETPRICE as ʵ��,
       a2.WE_SCHAR01,
       a2.ҽ�Ʒ����Է��ܶ�,
       ������ϸҽ������,
       ����ͳ��֧����,
       �������˵����ʻ�֧����,
       �������������ʻ�֧����,
       ������������֧����,
       �����󲡲���,
       ������������֧��,
       �������Ը�,
       ҽ�����޼�,
       �����ֽ�֧���ܶ�,
       ������ͥ����֧��,
       a2.EXT_CHAR08 as �ط�����,
       a2.������ϸҽ��֧����

