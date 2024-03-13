 DECLARE
    P_StartDate DATE :=DATE'2023-01-01';  -- number of rows to insert in each batch
   P_EndDate DATE :=DATE '2024-03-12';
   BatchSize NUMBER := 100000;
   P_CurrentDate DATE :=P_StartDate;
   v_count NUMBER;   -- offset for each batch
BEGIN
   WHILE P_CurrentDate <= P_EndDate
    LOOP
 insert into d_ybzd_test
with a1 as (select d.BUSNO, tb.CLASSNAME, d.SALENO, d.WAREID, d.WAREQTY, d.NETAMT, d.NETPRICE, ext.WE_SCHAR01,
--        ext.WE_NUM04 as ҩ��ҽ��֧����,
--        ext.WE_NUM05 as ����ҽ��֧����,
                   decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) as �ŵ�����ҽ��֧����,
                   case
                       when d.NETPRICE > decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) then
                           d.NETAMT - d.WAREQTY * decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
                       else 0
                       --d.NETAMT-d.WAREQTY*d.NETPRICE
                       end as ҽ�����޼�,
                   yd.EXT_CHAR08,
                   case
                       when ext.WE_SCHAR01 = 'ҽ����' then
                           round(yd.EXT_CHAR08 * (d.NETAMT - case
                                                                 when d.NETPRICE >
                                                                      decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
                                                                     then
                                                                     d.NETAMT - d.WAREQTY *
                                                                                decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05)
                                                                 else 0 end), 2)
                       else 0 end as �������Ը�,
                   case when ext.WE_SCHAR01 = 'ҽ����' then d.NETAMT else 0 end as ҽ�Ʒ����Է��ܶ�,
                   cyb.ͳ��֧���� as ����ͳ��֧����, cyb.���˵����ʻ�֧���� as �������˵����ʻ�֧����,
                   cyb.���������ʻ�֧���� as �������������ʻ�֧����,
                   cyb.��������֧���� as ������������֧����, cyb.�󲡲��� as �����󲡲���,
                   cyb.�ֽ�֧���ܶ� as �����ֽ�֧���ܶ�, cyb.��ͥ����֧�� as ������ͥ����֧��,
                   cyb.ҽ�ƾ���+cyb.��������֧���� as ������������֧��,
                   d.MAKENO,d.INVALIDATE
--                    cyb.�ϼƱ������ - cyb.ͳ��֧���� - cyb.���˵����ʻ�֧���� - cyb.��������֧���� - cyb.�󲡲��� as ������������֧��
            --d.NETAMT - decode(tb.CLASSCODE, '30510', ext.WE_NUM04, '30511', ext.WE_NUM05) * d.WAREQTY as ҽ��֧����
            from t_sale_d d
                     join D_ZHYB_HZ_CYB cyb on d.SALENO = cyb.ERP���۵���
                     join t_yby_order_h yh on yh.ERPSALENO = cyb.ERP���۵���
                     join t_yby_order_d_temp yd on yh.ORDERNO=yd.ORDERNO and yd.WARECODE=d.WAREID
                     join t_ware_ext ext on d.WAREID = ext.WAREID and ext.COMPID = 1000
                     join t_busno_class_set ts on d.busno = ts.busno and ts.classgroupno = '305'
                     join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                --and d.SALENO in ('2401304551007053', '2401271247060521')
--           and cyb.BUSNO in (81499,81501,84576)
        and  cyb.�������� between P_CurrentDate and P_CurrentDate+1
--                 and cyb.��������>=date'2023-01-01'
        and cyb.��ر�־='�����'
--   TO_DATE('20240101 07:10:00', 'YYYYMMDD HH24:MI:SS')
--     AND TO_DATE('20240104 07:10:00', 'YYYYMMDD HH24:MI:SS')
            ),
     a2 as (select BUSNO, CLASSNAME, SALENO, WAREID,MAKENO,INVALIDATE, WAREQTY, NETAMT, NETPRICE, WE_SCHAR01, �ŵ�����ҽ��֧����,
                   ҽ�����޼�, EXT_CHAR08,
                   case
                       when WE_SCHAR01 = 'ҽ����' then round(EXT_CHAR08 * (a1.NETAMT - ҽ�����޼�), 2)
                       else 0 end as �������Ը�,
                   ҽ�Ʒ����Է��ܶ�, ����ͳ��֧����, �������˵����ʻ�֧����, ������������֧����, �����󲡲���,
                   ������������֧��, ������ͥ����֧��,
                   �������������ʻ�֧����, �����ֽ�֧���ܶ�,

                   case
                       when WE_SCHAR01 = 'ҽ����' then 0
                       else NETAMT - case
                                         when WE_SCHAR01 = 'ҽ����' then round(EXT_CHAR08 * (a1.NETAMT - ҽ�����޼�), 2)
                                         else 0 end - ҽ�����޼�
                       end as ������ϸҽ��֧����
            from a1),
    yb_zfze as (select SALENO, sum(������ϸҽ��֧����) as ����ҽ��֧����
                 from a2
                 group by SALENO),
    --ÿһ��ÿ����Ʒ��ҽ������
     yb_bl as (select a2.SALENO, a2.WAREID,a2.WAREQTY,
                      b.����ҽ��֧����,
                      case
                                when b.����ҽ��֧���� = 0 then 0
                                else round(a2.������ϸҽ��֧���� / b.����ҽ��֧����, 4) end   as ������ϸҽ������
               from a2
                join yb_zfze b on a2.SALENO = b.SALENO)
select  a2.BUSNO, a2.CLASSNAME, a2.SALENO, a2.WAREID,a2.WAREQTY,a2.MAKENO,a2.INVALIDATE, a2.NETAMT as ʵ�۽��, a2.NETPRICE as ʵ��,
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

--
from a2
         left join yb_zfze b on a2.SALENO = b.SALENO
         left join yb_bl bl on a2.SALENO = bl.SALENO and a2.WAREID = bl.WAREID  and a2.WAREQTY=bl.WAREQTY;
  COMMIT;

  P_CurrentDate := P_CurrentDate + 1;
     DBMS_LOCK.SLEEP(1); -- increase offset for next batch
        -- commit changes after each batch
   END LOOP;
END;