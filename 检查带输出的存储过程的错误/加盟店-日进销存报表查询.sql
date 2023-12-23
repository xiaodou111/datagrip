DECLARE
    -- �����α����
    v_cursor SYS_REFCURSOR;

    -- �����洢���̲���
    v_view VARCHAR2(100) := 'v_kc_tsl_p001';

    -- ����������еı���
    v_kcrq DATE;
    v_cpdm VARCHAR2(50);
    v_cpmc VARCHAR2(100);
    v_cpgg VARCHAR2(50);
    v_ph VARCHAR2(50);
    v_sl NUMBER;

BEGIN
    -- ���ô洢����
    proc_day_inout_hmk(p_busno => 8240023, p_begindate => date'2023-11-01', p_enddate => date'2023-12-01', p_wareid => null, p_outcur => v_cursor);

    -- ��ȡ��������
    /*LOOP
        FETCH v_cursor INTO v_kcrq , v_cpdm, v_cpmc, v_cpgg, v_ph, v_sl;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            to_char(v_kcrq,'yyyy-mm-dd hh24:mi:ss') || ' | ' || v_cpdm || ' | ' || v_cpmc || ' | ' ||
            v_cpgg || ' | ' || v_ph || ' | ' || v_sl
        );
    END LOOP;*/

    -- �ر��α�
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        -- �����쳣
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


select a.busno as ҵ�����,'ƽ����֣¥�����ҩ��' as ��������,b.warecode as ��Ʒ����,max(b.warename) as ��Ʒ����,
          max(b.warespec) as ���,max(d.factoryname) as ������ҵ,max(b.wareunit) as ��λ,
          sum(beginqty) as �ڳ�����,sum(round(beginqty*a.purprice,2)) as �ڳ����,
          sum(accqty) as �������,sum(round(accqty*a.purprice,2)) as �����,
          sum(rejqty) as �˻�����,sum(round(rejqty*a.purprice,2)) as �˻����,
          sum(disqty) as ��������,sum(round(disqty*a.purprice,2)) as ���ͽ��,
          sum(dirqty) as �˲�����,sum(round(dirqty*a.purprice,2)) as �˲ֽ��,
          sum(saleqty) as ��������,sum(round(saleqty*a.purprice,2)) as ���۽��,
          sum(macinqty) as �ӹ��������,sum(round(macinqty*a.purprice,2)) as �ӹ������,
          sum(macoutqty) as �ӹ���������,sum(round(macoutqty*a.purprice,2)) as �ӹ�������,
          sum(cheqty) as �̵�����,sum(round(cheqty*a.purprice,2)) as �̵���,
          sum(whlqty) as ������������,sum(round(whlqty*a.purprice,2)) as �������۽��,
          sum(whrqty) as �����˻�����,sum(round(whrqty*a.purprice,2)) as �����˻����,
          sum(addqty) as �Ӽ۵�������,sum(round(addqty*a.purprice,2)) as �Ӽ۵������,
          sum(adrqty) as �Ӽ۵����˻�����,sum(round(adrqty*a.purprice,2)) as �Ӽ۵����˻ؽ��,
          sum(round(adpoutqty*a.purprice,2)) as �����۳����,
          sum(round(adpinqty*a.purprice,2)) as ����������,
          sum(abninqty) as ��������,sum(round(abninqty*a.purprice,2)) as ������,
          sum(failureqty) as ��������,sum(round(failureqty*a.purprice,2)) as ���ٽ��,
          sum(endqty) as ��ĩ����,sum(round(endqty*a.purprice,2)) as ��ĩ���
          from temp_item_day_inout a
          join t_ware b on a.wareid = b.wareid and b.compid = 9999
          left join t_factory d on b.factoryid = d.factoryid
          group by a.busno,b.warecode
