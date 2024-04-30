create view V_ZHYBJSJLB as
select distinct
       bc.orderno as 医保云商户订单号,
       bc.outsaleno as erp销售单号,
       bc.CREATIONTIME as 销售日期,
       c.SETTLENO as 结算交易流水号,
       case
         when substring(bc.orderno, 0, 1) = 'R' then
          1
         else
          0
       end as 是否退货,
       1 as 预或正式,
       bc.insurancecardno as 卡号,
       c.INSTITUTIONCODE as 医疗机构,
       c.Cashier as 操作人,
       c.CARDINFO as 卡信息,
       c.personalcashamount as 现金合计,
       '' as 药师编号,
       c.VISITNO as 就诊编号,
       c.DETAILEDBILLNO as 明细帐单号,
       '' as 退款交易流水号,
       bc.areacode 参保地编码,
       case when cbd.classname is null then bc.areacode else cbd.classname end 参保地,
       nvl(c.CUSTOMERNAME,bc.NAME) as 姓名,
       nvl(c.IDENTITYNO,bc.IDENTITYNO) as 身份证号,
       nvl(c.GENDER,bc.gender) as 性别,
       bc.DISEASENO as 疾病编码,
       bc.DISEASENAME as 疾病名称,
       case when ry.code_name is null then b.PSNTYPE else ry.code_name end as 参保人员类别,
       b.CLROPTINS as 机构所在地编码,
       case when jyd.classname is null then b.CLROPTINS else jyd.classname end 机构所在地名称,
       c.INSTITUTIONname as 登记医疗机构,
       b.CREATIONTIME as 登记时间,
       b.orderno,
       b.totalamount as 医疗费用总额,
       c.PersonalPayAmount  as 医疗费用自费总额,
       c.SelfChargeAmount as 医疗费用自理总额,
      --c.ext_num30 as 医疗费用自理总额,
       c.PersonalcashAmount as 现金支付总额,
       b.totalamount - b.CASHPAY as 合计报销金额,
       b.totalamount - nvl(c.PersonalcashAmount,0.00) - nvl(c.CurrentAccountPay,0.00) - nvl(c.HistoryAccountPay,0.00) - b.CvlservPay - b.MafPay - nvl(c.familyaccountpay,0.00) - b.OTHPAY - b.HIFMIPAY as 基金支付总额,
       c.cashc as 起付标准,
       b.totalamount - nvl(c.PersonalcashAmount,0.00) - nvl(c.CurrentAccountPay,0.00) - nvl(c.HistoryAccountPay,0.00) - b.CvlservPay - b.MafPay - nvl(c.familyaccountpay,0.00) - b.OTHPAY - b.HIFMIPAY as 统筹支付数,
       0.00  as 救助支付数,
       c.CurrentAccountPay  as 个人当年帐户支付数,
       c.HistoryAccountPay  as 个人历年帐户支付数,
       b.CvlservPay as 公补基金支付数,
       b.HIFMIPAY as 大病补助,
       0.00 as 补助基金支付数,
       0.00  as 离休基金支付数,
       0.00  as 二乙基金支付数,
       0.00 as 劳模基金支付数,
       0.00 as 居民基金支付数,
       0.00  as 大学生基金支付数,
       0.00 as 未成年人基金支付数,
       0.00 as 新农合基金支付数,
       b.OTHPAY as 其他基金支付数,
       b.MafPay as 医疗救助,
       c.ext_num30 乙类先自付,
       c.cashb 个人自付,
    --   c.ext_num28-c.CurrentAccountPay-c.personalPayAmount 个人自付,
       c.familyaccountpay as 家庭共济支付,
/*     c.SalvagePay  as 救助支付数,
       c.SalvagePay as 补助基金支付数,
       0.00  as 离休基金支付数,
       0.00  as 二乙基金支付数,
       0.00 as 劳模基金支付数,
       0.00 as 居民基金支付数,
       0.00  as 大学生基金支付数,
       0.00 as 未成年人基金支付数,
       0.00 as 新农合基金支付数,
       0.00 as 其他基金支付数,
       c.ext_num30 乙类先自付,
       c.ext_num28-c.CurrentAccountPay-c.personalPayAmount 个人自付,
       */
       c.ext_num29 医保超限价,
       med.ERPMEDICALNO as busno,t.compid,/*
       case when ext_char02='11' then '普通门诊'
         when ext_char02='140104' then '门诊慢病'
         when ext_char02='140201' then '门诊特病'
         when ext_char02='9211' then '随同住院购药'
         when ext_char02='91' then '其他门诊'
         when ext_char02='9511' then '村卫门诊' else '未知' end */

         case when zd.code_name is null then b.MEDTYPE else zd.code_name end as jslx,
         case when floor(ext_num18)=0 then '社保卡'
          when floor(ext_num18)=1 then '身份证'
          when floor(ext_num18)=2 then '电子凭证'
          when floor(ext_num18)=3 then '港澳台证件'
          when floor(ext_num18)=4 then '澳门身份证' end as sklx,
          bc.AREACODE,
          b.CLROPTINS,

         case when  substr(b.msgid,2,4)<>substr(bc.areacode,1,4) then '异地' else '非异地' end as 异地标志,f_get_利民保(c.orderno) as 利民保,
         c.ext_char04
  from v_pros_order bc
 left join t_yby_order_h c    on c.orderno = bc.orderno
 left join v_pros_order_receipt_list b    on bc.orderno = b.orderno and b.orderstatus not in('0','1','4','7') and bc.REFID=b.REFID
 left join t_sale_h t on bc.outsaleno=t.saleno
 left join d_yb_zdlx zd on zd.type='jzlx' and b.MEDTYPE=trim(zd.code)
 left join d_yb_zdlx ry on ry.type='rylb' and b.PSNTYPE=trim(ry.code)
 left join d_cbd cbd on bc.areacode=cbd.cbd
 left join d_cbd jyd on b.CLROPTINS=jyd.cbd
 left join v_medicare_organ_config med on bc.refid=med.refid
 where bc.CREATIONTIME >=to_date(to_char(TRUNC(SYSDATE-1),'yyyy-mm-dd'),'yyyy-mm-dd') and
  bc.isdeleted<>1 and b.orderstatus not in('0','1','4','7')
union all
select 医保云商户订单号, ERP销售单号, 销售日期, 结算交易流水号, 是否退货, 预或正式, 卡号, 医疗机构, 操作人, 卡信息, 现金合计, 药师编号, 就诊编号, 明细帐单号,退款交易流水号,'',          参保地, 姓名, 身份证号, 性别, 疾病编码, 疾病名称, 参保人员类别,'',                      BUS_QY, 登记医疗机构, 登记时间, ORDERNO, 医疗费用总额, 医疗费用自费总额, 医疗费用自理总额, 现金支付总额, 合计报销金额, 基金支付总额, 起付标准, 统筹支付数, 救助支付数, 个人当年帐户支付数, 个人历年帐户支付数, 公补基金支付数, 大病补助, 补助基金支付数, 离休基金支付数, 二乙基金支付数, 劳模基金支付数, 居民基金支付数, 大学生基金支付数, 未成年人基金支付数, 新农合基金支付数, 其他基金支付数, 医疗救助, 乙类先自付, 个人自付, 家庭共济支付, 医保超限价, BUSNO, COMPID, 结算类型, 刷卡类型,'','',异地标志, 利民保,ext_char04
from d_zhyb_hz_cyb
where to_char(销售日期,'yyyymmdd')<to_char(TRUNC(SYSDATE-1),'yyyymmdd')
/

