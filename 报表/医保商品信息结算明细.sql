SELECT a.BUSNO,s.ORGNAME,a.mdlx as ҵ���������, a.SALENO,a.ACCDATE,cyb.��������,cyb.���㽻����ˮ��,
       cyb.ҽ�����̻�������,cyb.��������,cyb.�α���,cyb.����,cyb.�Ա�,
       cyb.���֤��,cyb.��������,cyb.�α���Ա���,cyb.EXT_CHAR04 as �α���λ,
       a.WAREID,w.WARENAME,w.WARESPEC, f.FACTORYNAME,w.WAREUNIT,w.LISTING_HOLDER as ������ɳ�����,
       c03.CLASSNAME as ����,c12.CLASSNAME as ���Ź������,c26.CLASSNAME as ҽ���б����,c810.CLASSNAME as ˫ͨ������,
       a.SALER as ӪҵԱ����,su.USERNAME as ӪҵԱ,h.MEMBERCARDNO as ��Ա����,mem.CARDHOLDER as ��Ա����,
       WAREQTY as ��Ʒ����, MAKENO,a.INVALIDATE,�ܼ�, ����, WE_SCHAR01 as ҽ������, a.ҽ�Ʒ����Է��ܶ�, �������, a.ͳ��֧����,
       a.���˵����ʻ�֧����, a.��������֧����, �����󲡲��� as �󲡲���, ��������֧��, a.�������Ը�, a.ҽ�����޼�,
       a.������ֽ�ӹ���,�ط�����,������ϸҽ��֧����
 FROM (select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, �ܼ�, ����, WE_SCHAR01, ҽ�Ʒ����Է��ܶ�, �������,
             0 as ͳ��֧����,
             0 as ���˵����ʻ�֧����,

             0 as ��������֧����, 0 as �����󲡲���, 0 as ��������֧��,
             0 as �������Ը�, 0 as ҽ�����޼�,
             �ܼ� as ������ֽ�ӹ���,
             �ط�����,������ϸҽ��֧����
      from (select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, ʵ�۽�� as �ܼ�, ʵ�� as ����, WE_SCHAR01,
                   ҽ�Ʒ����Է��ܶ�, ������ϸҽ������ as �������,
                   ����ͳ��֧����, �������˵����ʻ�֧����, �������������ʻ�֧����, ������������֧����,
                   �����󲡲���,
                   ������������֧��, �������Ը�, ҽ�����޼�, �����ֽ�֧���ܶ�, ������ͥ����֧��, �ط�����,������ϸҽ��֧����
            from D_YBZD_detail
            where �ط�����=1)
      union all
      select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, �ܼ�, ����, WE_SCHAR01, ҽ�Ʒ����Է��ܶ�, �������,
             ����ͳ��֧���� * ������� as ͳ��֧����,
             �������˵����ʻ�֧���� * ������� as ���˵����ʻ�֧����,

             ������������֧���� * ������� as ��������֧����, �����󲡲��� * ������� as �����󲡲���,
             ������������֧�� * ������� as ��������֧��,
             �������Ը�, ҽ�����޼�,
             �ܼ�-����ͳ��֧���� * �������-�������˵����ʻ�֧���� * �������
             -������������֧���� * �������-�����󲡲��� * �������
             -������������֧�� * ������� as ������ֽ�ӹ���,�ط�����,������ϸҽ��֧����
      from (select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, ʵ�۽�� as �ܼ�, ʵ�� as ����, WE_SCHAR01,
                   ҽ�Ʒ����Է��ܶ�, ������ϸҽ������ as �������,
                   ����ͳ��֧����, �������˵����ʻ�֧����, �������������ʻ�֧����, ������������֧����,
                   �����󲡲���,
                   ������������֧��, �������Ը�, ҽ�����޼�, �����ֽ�֧���ܶ�, ������ͥ����֧��, �ط�����,������ϸҽ��֧����
            from D_YBZD_detail
            where �ط�����<>1  )) a
    join s_busi s on a.BUSNO=s.busno
    join t_sale_h h on a.SALENO=h.SALENO
    join S_USER_BASE su on a.saler=su.USERID
    join D_ZHYB_HZ_CYB cyb on a.SALENO=cyb.ERP���۵���
    join t_ware_base w on a.WAREID=w.WAREID
    join t_factory f on w.FACTORYID=f.FACTORYID
    left join T_MEMCARD_REG mem on h.MEMBERCARDNO=mem.MEMCARDNO
    JOIN t_ware_class_base tc03 ON a.wareid=tc03.wareid and tc03.compid=1000 and tc03.classgroupno='03'
    JOIN t_class_base c03 ON tc03.classcode=c03.classcode
    JOIN t_ware_class_base tc12 ON a.wareid=tc12.wareid and tc12.compid=1000 and tc12.classgroupno='12'
    JOIN t_class_base c12 ON tc12.classcode=c12.classcode
    JOIN t_ware_class_base tc26 ON a.wareid=tc26.wareid and tc26.compid=1000 and tc26.classgroupno='26'
    JOIN t_class_base c26 ON tc26.classcode=c26.classcode
    JOIN t_ware_class_base tc810 ON a.wareid=tc810.wareid and tc810.compid=1000 and tc810.classgroupno='810'
    JOIN t_class_base c810 ON tc810.classcode=c810.classcode