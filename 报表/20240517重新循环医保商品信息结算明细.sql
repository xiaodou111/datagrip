select * from d_ybsp_jsmx;
delete from d_ybsp_jsmx;
DECLARE
    P_StartDate DATE := DATE '2023-01-01';  -- ��ʼ����
    P_EndDate DATE := DATE '2024-05-17';  -- ��������
    BatchSize NUMBER := 100000;  -- ÿ�����εĴ�С
    P_CurrentDate DATE := P_StartDate;  -- ����ǰ������Ϊ��ǰ�µĵ�һ��
    v_count NUMBER;  -- ƫ����������������
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP
 insert into d_ybsp_jsmx
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
       d.MAKENO, d.INVALIDATE,yd.EXT_CHAR08
from t_sale_d d
         join D_ZHYB_HZ_CYB cyb on d.SALENO = cyb.ERP���۵���
         join t_yby_order_h yh on yh.ERPSALENO = cyb.ERP���۵���
         join (select ORDERNO, WARECODE, EXT_CHAR08
               from T_YBY_ORDER_D
               group by ORDERNO, WARECODE, EXT_CHAR08) yd on yh.ORDERNO = yd.ORDERNO and yd.WARECODE = d.WAREID
         join t_ware_ext ext on d.WAREID = ext.WAREID and ext.COMPID = 1000
         join t_busno_class_set ts on d.busno = ts.busno and ts.classgroupno = '305'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
  where
--       d.SALENO in ('2401304551007053', '2401271247060521')
      cyb.�������� between P_CurrentDate and P_CurrentDate+1
     and cyb.��ر�־ = '���'
  ),
    a2 as (select RECEIPTDATE, BUSNO, CLASSNAME, SALENO, SALER, WAREID, WAREQTY, NETAMT, NETPRICE, ROWNO, WE_SCHAR01,
                  �ŵ�����ҽ��֧����, ������ϸҽ��֧����, ҽ�Ʒ����Է��ܶ�, ����ͳ��֧����, �������˵����ʻ�֧����,
                  �������������ʻ�֧����, ������������֧����, �����󲡲���, �����ֽ�֧���ܶ�, ������ͥ����֧��, ������������֧��,
                  MAKENO, INVALIDATE,sum(������ϸҽ��֧����) over ( partition by SALENO) as ����ҽ��֧����,
         case when sum(������ϸҽ��֧����) over ( partition by SALENO)=0 then 0
                   else
       ������ϸҽ��֧����/sum(������ϸҽ��֧����) over ( partition by SALENO) end as ������ϸҽ������,EXT_CHAR08
           from a1 )
select RECEIPTDATE, BUSNO, CLASSNAME, SALENO, SALER, WAREID, WAREQTY,MAKENO, INVALIDATE, NETAMT, NETPRICE, WE_SCHAR01,
       ������ϸҽ��֧����, ҽ�Ʒ����Է��ܶ�  as ������ϸҽ�Ʒ����Է�,
       ������ϸҽ������,
       ����ͳ��֧���� * ������ϸҽ������ as ͳ��֧����, �������˵����ʻ�֧���� * ������ϸҽ������ as ���˵����ʻ�֧����,
       �������������ʻ�֧����*������ϸҽ������ as ���������ʻ�֧����,
       ������������֧����*������ϸҽ������ as ��������֧����,�����󲡲���*������ϸҽ������ as �󲡲���,
        ������������֧�� * ������ϸҽ������ as ��������֧��,
        NETAMT-����ͳ��֧���� * ������ϸҽ������-�������˵����ʻ�֧���� * ������ϸҽ������-������������֧���� * ������ϸҽ������-�����󲡲���*������ϸҽ������
            -������������֧�� * ������ϸҽ������ as ������ֽ�ӹ���,EXT_CHAR08
from a2;
  COMMIT;

  P_CurrentDate := P_CurrentDate+1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;