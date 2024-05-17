create view V_YB_SPXX_DETAIL as
SELECT a.BUSNO,s.ORGNAME,a.mdlx as 业务机构类型, a.SALENO,a.ACCDATE,cyb.销售日期,cyb.结算交易流水号,
       cyb.医保云商户订单号,cyb.结算类型,cyb.参保地,cyb.姓名,cyb.性别,
       cyb.身份证号,cyb.疾病名称,cyb.参保人员类别,cyb.EXT_CHAR04 as 参保单位,
       a.WAREID,w.WARENAME,w.WARESPEC, f.FACTORYNAME,w.WAREUNIT,w.LISTING_HOLDER as 上市许可持有人,
       c03.CLASSNAME as 剂型,c12.CLASSNAME as 集团管理类别,c26.CLASSNAME as 医保招标分类,c810.CLASSNAME as 双通道分类,
       a.SALER as 营业员工号,su.USERNAME as 营业员,h.MEMBERCARDNO as 会员卡号,mem.CARDHOLDER as 会员姓名,
       WAREQTY as 商品数量, MAKENO,a.INVALIDATE,总价, 单价, WE_SCHAR01 as 医保类型, a.医疗费用自费总额, 基金比例, a.统筹支付数,
       a.个人当年帐户支付数, a.公补基金支付数, 整单大病补助 as 大病补助, 其他基金支付, a.乙类先自付, a.医保超限价,
       a.历年加现金加共济,回返比例,单据明细医保支付价
 FROM (select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, 总价, 单价, WE_SCHAR01, 医疗费用自费总额, 基金比例,
             0 as 统筹支付数,
             0 as 个人当年帐户支付数,

             0 as 公补基金支付数, 0 as 整单大病补助, 0 as 其他基金支付,
             0 as 乙类先自付, 0 as 医保超限价,
             总价 as 历年加现金加共济,
             回返比例,单据明细医保支付价
      from (select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, 实价金额 as 总价, 实价 as 单价, WE_SCHAR01,
                   医疗费用自费总额, 单据明细医保比例 as 基金比例,
                   整单统筹支付数, 整单个人当年帐户支付数, 整单个人历年帐户支付数, 整单公补基金支付数,
                   整单大病补助,
                   整单其他基金支付, 乙类先自付, 医保超限价, 整单现金支付总额, 整单家庭共济支付, 回返比例,单据明细医保支付价
            from D_YBZD_detail
            where 回返比例=1)
      union all
      select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, 总价, 单价, WE_SCHAR01, 医疗费用自费总额, 基金比例,
             整单统筹支付数 * 基金比例 as 统筹支付数,
             整单个人当年帐户支付数 * 基金比例 as 个人当年帐户支付数,

             整单公补基金支付数 * 基金比例 as 公补基金支付数, 整单大病补助 * 基金比例 as 整单大病补助,
             整单其他基金支付 * 基金比例 as 其他基金支付,
             乙类先自付, 医保超限价,
             总价-整单统筹支付数 * 基金比例-整单个人当年帐户支付数 * 基金比例
             -整单公补基金支付数 * 基金比例-整单大病补助 * 基金比例
             -整单其他基金支付 * 基金比例 as 历年加现金加共济,回返比例,单据明细医保支付价
      from (select ACCDATE,SALER,BUSNO, mdlx, SALENO, WAREID, WAREQTY,MAKENO,INVALIDATE, 实价金额 as 总价, 实价 as 单价, WE_SCHAR01,
                   医疗费用自费总额, 单据明细医保比例 as 基金比例,
                   整单统筹支付数, 整单个人当年帐户支付数, 整单个人历年帐户支付数, 整单公补基金支付数,
                   整单大病补助,
                   整单其他基金支付, 乙类先自付, 医保超限价, 整单现金支付总额, 整单家庭共济支付, 回返比例,单据明细医保支付价
            from D_YBZD_detail
            where 回返比例<>1  )) a
    join s_busi s on a.BUSNO=s.busno
    join t_sale_h h on a.SALENO=h.SALENO
    join S_USER_BASE su on a.saler=su.USERID
    join D_ZHYB_HZ_CYB cyb on a.SALENO=cyb.ERP销售单号
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
/

