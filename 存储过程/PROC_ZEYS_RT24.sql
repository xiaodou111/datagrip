create PROCEDURE proc_zeys_rt24(p_begin IN DATE,
                              p_end IN DATE,
                              p_sql OUT SYS_REFCURSOR)
    IS

    v_months integer;

BEGIN

    v_months := ceil(months_between(p_begin, p_end)) - 1;

    if v_months = 0 then
        v_months := -1;
    end if;

    OPEN p_sql FOR
        WITH cx AS (select a2.sfzs,
                           a2.zmdz1,
                           a2.险种,
                           a2.就诊类型,
                           a2.参保地,
                           a2.jyd,
                           人次,
                           ord2 as 人头,
                           ord3 as 一次人头,
                           国谈总额度,
                           总额度,
                           基本医疗统筹支付,
                           公务员补助统筹支付,
                           当年账户支付,
                           大病金额,
                           医疗费用总额,
                           历年账户支付,
                           现金金额,
                           除国谈总指标,
                           总指标
                    from (select sfzs,
                                 zmdz1,
                                 险种,
                                 就诊类型,
                                 参保地,
                                 jyd,
                                 sum(ord2) as ord2,
                                 sum(ord3) as ord3
                          from (select erp销售号,
                                       sfzs,
                                       zmdz1,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
                                       ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end order by 创建时间) as ord,
                                       case
                                           when nvl(xzrt.identityno, '0') = '0' then 0
                                           else (case
                                                     when ROW_NUMBER() over (partition by case
                                                                                              when nvl(xzrt.identityno, '0') <> '0'
                                                                                                  then xzrt.identityno
                                                                                              else '无' end,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end,
                                                         case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                                         order by 创建时间) =
                                                          1 then 1
                                                     else 0 end) end                                                                         as ord2,
                                       ycrt                                                                                                  as ord3,
                                       nvl(case
                                               when gtje = 0
                                                   then nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)
                                               else gtje * gtbl end,
                                           0)                                                                                                as zed,
                                       nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                       nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                       nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                       nvl(大病金额, 0)                                                                                      as 大病金额,
                                       nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                       参保地,
                                       case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                from d_zjys_wl2023xse
                                         left join D_YB_NEW_CUS_2024_04 xzrt
                                                   on to_char(身份证号) = to_char(identityno) and
                                                      trunc(创建时间) = trunc(RECEIPTDATE)
                                                       and case when 险种 = '职工基本医疗保险' then '0' else '1' end =
                                                           xzrt.NB_FLAG
--and case when 就诊类型='门诊特病' then '1' when 就诊类型='住院双通道' then '2' else  '0' end =xzrt.jslx
                                                       and d_zjys_wl2023xse.机构编码 = xzrt.busno
                                         left join v_zyjy_ycrt yc
                                                   on to_char(身份证号) = to_char(sfzh) and 就医地 = jyd and 险种 = xz and sfzs = sfzs1
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                where trunc(创建时间) BETWEEN p_begin AND p_end
                                  and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                  and 医疗费用总额 - nvl(gtje, 0) <> 0) aaa
                          group by sfzs,zmdz1, 险种, 就诊类型, 参保地, jyd) a1
                             right join
                         (select sfzs,
                                 zmdz1,
                                 险种,
                                 就诊类型,
                                 参保地,
                                 jyd,
                                 sum(case when ord > 1 then 0 else ord end)                                           as 人次,
                                 round(sum(zed), 2)                                                                   as 国谈总额度,
                                 round(sum(zed1), 2)                                                                  as 总额度,
                                 sum(nvl(基本医疗统筹支付, 0))                                                        as 基本医疗统筹支付,
                                 sum(nvl(公务员补助统筹支付, 0))                                                      as 公务员补助统筹支付,
                                 sum(nvl(当年账户支付, 0))                                                            as 当年账户支付,
                                 sum(nvl(大病金额, 0))                                                                as 大病金额,
                                 sum(nvl(医疗费用总额, 0))                                                            as 医疗费用总额,
                                 sum(nvl(历年账户支付, 0))                                                            as 历年账户支付,
                                 sum(nvl(现金金额, 0))                                                                as 现金金额,
                                 round((sum(zed1) - sum(zed)) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
                                       2)                                                                             as 除国谈总指标,
                                 round(sum(zed1) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
                                       2)                                                                             as 总指标
                          from (select bbb1.*,
                                   ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,jyd order by 创建时间) as ord,
                                   case
                                       when ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                           case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                           order by 创建时间) > 1
                                           then 0
                                       else
                                           ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                               case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                               order by 创建时间) end                     as ord2
                                from (select erp销售号,
                                       sfzs,
                                       zmdz1,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
                                       sum(case
                                           when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                               (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                           then
                                              nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                              nvl(detail.整单公补基金支付数, 0) *
                                              detail.单据明细医保比例 +
                                              nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                           else 0
                                           end)                                                                                          as zed, --国谈+药店双通道额度
                                       nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                       nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                       nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                       nvl(大病金额, 0)                                                                                      as 大病金额,
                                       nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                       nvl(现金金额, 0)                                                                                      as 现金金额,
                                       nvl(历年账户支付, 0)                                                                                  as 历年账户支付,
                                       nvl(医疗费用总额, 0)                                                                                  as 医疗费用总额,
                                       参保地,
                                       case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                from d_zjys_wl2023xse
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                left join D_YBZD_detail detail
                                on D_ZJYS_WL2023XSE.ERP销售号 = detail.SALENO
                                left join d_ll_gtml gtml
                                on gtml.WAREID = detail.wareid
                                and D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) BETWEEN p_begin AND p_end
                                and not exists (select 1
                                                from T_SALE_RETURN_H a
                                                where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号, sfzs,身份证号,创建时间,险种, 基本医疗统筹支付, 公务员补助统筹支付,
                                         当年账户支付, 大病金额,现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,zmdz1)bbb1) bbb
                          group by sfzs,zmdz1,险种, 就诊类型, 参保地, jyd) a2
                         on  a1.sfzs = a2.sfzs
                             and a1.险种 = a2.险种
                             and a1.就诊类型 = a2.就诊类型
                             and a1.参保地 = a2.参保地
                             and a1.jyd = a2.jyd
                             and a1.ZMDZ1 = a2.zmdz1),
             cx1 as (select busno, xz, jzlx, zzb from D_ZEYS_IMPORT where PEROID = '2023'),
             --去年
             cx2 AS (select a2.sfzs,
                            a2.zmdz1,
                            a2.险种,
                            a2.就诊类型,
                            a2.参保地,
                            a2.jyd,
                            人次,
                            ord2 as 人头,
                            ord3 as 一次人头,
                            总额度,
                            国谈总额度
                     from (select sfzs,
                                  zmdz1,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(ord2) as ord2,
                                  sum(ord3) as ord3
                           from (select erp销售号,
                                        sfzs,
                                        zmdz1,
                                        身份证号,
                                        创建时间,
                                        险种,
                                        '1'                                                                                                   as 就诊类型,
                                        gtje,
                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end order by 创建时间) as ord,
                                        case
                                            when nvl(xzrt.identityno, '0') = '0' then 0
                                            else (case
                                                      when ROW_NUMBER() over (partition by case
                                                                                               when nvl(xzrt.identityno, '0') <> '0'
                                                                                                   then xzrt.identityno
                                                                                               else '无' end,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end,
                                                          case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                                          order by 创建时间) =
                                                           1 then 1
                                                      else 0 end) end                                                                         as ord2,
                                        ycrt                                                                                                  as ord3,
/*(ROW_NUMBER() over(partition by case when nvl(xzrt.identityno,'0') <>'0' then xzrt.identityno else '无' end,
case when to_char(创建时间,'yyyy')='2021' then '2022' else to_char(创建时间,'yyyy') end,险种,sfzs order by 创建时间)) as ord3,
*/
                                        nvl(case
                                                when gtje = 0
                                                    then nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)
                                                else gtje * gtbl end,
                                            0)                                                                                                as zed,
                                        nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                        nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                        nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                        nvl(大病金额, 0)                                                                                      as 大病金额,
                                        nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                        参保地,
                                        case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                 from d_zjys_wl2023xse
                                          left join D_YB_NEW_CUS_2024_04 xzrt
                                                    on to_char(身份证号) = to_char(identityno) and
                                                       trunc(创建时间) = trunc(RECEIPTDATE)
                                                        and case when 险种 = '职工基本医疗保险' then '0' else '1' end =
                                                            xzrt.NB_FLAG
--and case when 就诊类型='门诊特病' then '1' when 就诊类型='住院双通道' then '2' else  '0' end =xzrt.jslx
                                                        and d_zjys_wl2023xse.机构编码 = xzrt.busno
                                          left join v_zyjy_ycrt yc
                                                    on to_char(身份证号) = to_char(sfzh) and 就医地 = jyd and 险种 = xz and sfzs = sfzs1
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                 where trunc(创建时间) BETWEEN add_months(p_begin, -12) AND add_months(p_end, -12)
                                   and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                   and 医疗费用总额 - nvl(gtje, 0) <> 0) aaa
                           group by sfzs,zmdz1, 险种, 就诊类型, 参保地, jyd) a1
                              right join
                          (select sfzs,
                                  zmdz1,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(case when ord > 1 then 0 else ord end)                              as 人次,
                                  round(sum(zed), 2)                                                      as 国谈总额度,
                                  round(sum(zed1), 2)                                                     as 总额度,
                                  sum(nvl(基本医疗统筹支付, 0))                                           as 基本医疗统筹支付,
                                  sum(nvl(公务员补助统筹支付, 0))                                         as 公务员补助统筹支付,
                                  sum(nvl(当年账户支付, 0))                                               as 当年账户支付,
                                  sum(nvl(大病金额, 0))                                                   as 大病金额,
                                  sum(nvl(医疗费用总额, 0))                                               as 医疗费用总额,
                                  sum(nvl(历年账户支付, 0))                                               as 历年账户支付,
                                  sum(nvl(现金金额, 0))                                                   as 现金金额,
                                  round((sum(zed1) - sum(zed)) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
                                        2)                                                                as 除国谈总指标,
                                  round(sum(zed1) / case when sum(ord2) = 0 then 1 else sum(ord2) end, 2) as 总指标
                           from (select bbb1.*,
                                   ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,jyd order by 创建时间) as ord,
                                   case
                                       when ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                           case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                           order by 创建时间) > 1
                                           then 0
                                       else
                                           ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                               case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                               order by 创建时间) end                     as ord2
                                from (select erp销售号,
                                       sfzs,
                                       zmdz1,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
                                       sum(case
                                           when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                               (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                           then
                                              nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                              nvl(detail.整单公补基金支付数, 0) *
                                              detail.单据明细医保比例 +
                                              nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                           else 0
                                           end)                                                                                          as zed, --国谈+药店双通道额度
                                       nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                       nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                       nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                       nvl(大病金额, 0)                                                                                      as 大病金额,
                                       nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                       nvl(现金金额, 0)                                                                                      as 现金金额,
                                       nvl(历年账户支付, 0)                                                                                  as 历年账户支付,
                                       nvl(医疗费用总额, 0)                                                                                  as 医疗费用总额,
                                       参保地,
                                       case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                from d_zjys_wl2023xse
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                left join D_YBZD_detail detail
                                on D_ZJYS_WL2023XSE.ERP销售号 = detail.SALENO
                                left join d_ll_gtml gtml
                                on gtml.WAREID = detail.wareid
                                and D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) BETWEEN add_months(p_begin, -12) AND add_months(p_end, -12)
                                and not exists (select 1
                                                from T_SALE_RETURN_H a
                                                where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号, sfzs,身份证号,创建时间,险种, 基本医疗统筹支付, 公务员补助统筹支付,
                                         当年账户支付, 大病金额,现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,zmdz1)bbb1) bbb
                           group by sfzs,zmdz1 ,险种, 就诊类型, 参保地, jyd) a2
                          on  a1.险种 = a2.险种
                              and a1.SFZS = a2.SFZS
                              and a1.就诊类型 = a2.就诊类型
                              and a1.参保地 = a2.参保地
                              and a1.jyd = a2.jyd
                              and a1.ZMDZ1 = a2.ZMDZ1),

--上月
             cx3 AS (select a2.sfzs,
                            a2.zmdz1,
                            a2.险种,
                            a2.就诊类型,
                            a2.参保地,
                            a2.jyd,
                            人次,
                            ord2 as 人头,
                            ord3 as 一次人头
                     from (select sfzs,
                                  zmdz1,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(ord2) as ord2,
                                  sum(ord3) as ord3
                           from (select erp销售号,
                                        sfzs,
                                        zmdz1,
                                        身份证号,
                                        创建时间,
                                        险种,
                                        '1'                                                                                                   as 就诊类型,
                                        gtje,
                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end order by 创建时间) as ord,
                                        case
                                            when nvl(xzrt.identityno, '0') = '0' then 0
                                            else (case
                                                      when ROW_NUMBER() over (partition by case
                                                                                               when nvl(xzrt.identityno, '0') <> '0'
                                                                                                   then xzrt.identityno
                                                                                               else '无' end,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end,
                                                          case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                                          order by 创建时间) =
                                                           1 then 1
                                                      else 0 end) end                                                                         as ord2,
                                        ycrt                                                                                                  as ord3,
                                        nvl(case
                                                when gtje = 0
                                                    then nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)
                                                else gtje * gtbl end,
                                            0)                                                                                                as zed,
                                        nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                        nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                        nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                        nvl(大病金额, 0)                                                                                      as 大病金额,
                                        nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                        参保地,
                                        case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                 from d_zjys_wl2023xse
                                          left join D_YB_NEW_CUS_2024_04 xzrt
                                                    on to_char(身份证号) = to_char(identityno) and
                                                       trunc(创建时间) = trunc(RECEIPTDATE)
                                                        and case when 险种 = '职工基本医疗保险' then '0' else '1' end =
                                                            xzrt.NB_FLAG
--and case when 就诊类型='门诊特病' then '1' when 就诊类型='住院双通道' then '2' else  '0' end =xzrt.jslx
                                                        and d_zjys_wl2023xse.机构编码 = xzrt.busno
                                          left join v_zyjy_ycrt yc
                                                    on to_char(身份证号) = to_char(sfzh) and 就医地 = jyd and 险种 = xz and sfzs = sfzs1
                                 left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                 where trunc(创建时间) BETWEEN add_months(p_begin, v_months) AND add_months(p_end, v_months)
                                   and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                   and 医疗费用总额 - nvl(gtje, 0) <> 0) aaa
                           group by sfzs,zmdz1, 险种, 就诊类型, 参保地, jyd) a1
                              right join
                          (select sfzs,
                                  zmdz1,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(case when ord > 1 then 0 else ord end)                              as 人次,
                                  round(sum(zed), 2)                                                      as 国谈总额度,
                                  round(sum(zed1), 2)                                                     as 总额度,
                                  sum(nvl(基本医疗统筹支付, 0))                                           as 基本医疗统筹支付,
                                  sum(nvl(公务员补助统筹支付, 0))                                         as 公务员补助统筹支付,
                                  sum(nvl(当年账户支付, 0))                                               as 当年账户支付,
                                  sum(nvl(大病金额, 0))                                                   as 大病金额,
                                  sum(nvl(医疗费用总额, 0))                                               as 医疗费用总额,
                                  sum(nvl(历年账户支付, 0))                                               as 历年账户支付,
                                  sum(nvl(现金金额, 0))                                                   as 现金金额,
                                  round((sum(zed1) - sum(zed)) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
                                        2)                                                                as 除国谈总指标,
                                  round(sum(zed1) / case when sum(ord2) = 0 then 1 else sum(ord2) end, 2) as 总指标
                           from (select bbb1.*,
                                   ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,jyd order by 创建时间) as ord,
                                   case
                                       when ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                           case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                           order by 创建时间) > 1
                                           then 0
                                       else
                                           ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                               case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                               order by 创建时间) end                     as ord2
                                from (select erp销售号,
                                       sfzs,
                                       zmdz1,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
                                       sum(case
                                           when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                               (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                           then
                                              nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                              nvl(detail.整单公补基金支付数, 0) *
                                              detail.单据明细医保比例 +
                                              nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                           else 0
                                           end)                                                                                          as zed, --国谈+药店双通道额度
                                       nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                       nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                       nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                       nvl(大病金额, 0)                                                                                      as 大病金额,
                                       nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                       nvl(现金金额, 0)                                                                                      as 现金金额,
                                       nvl(历年账户支付, 0)                                                                                  as 历年账户支付,
                                       nvl(医疗费用总额, 0)                                                                                  as 医疗费用总额,
                                       参保地,
                                       case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                from d_zjys_wl2023xse
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                left join D_YBZD_detail detail
                                on D_ZJYS_WL2023XSE.ERP销售号 = detail.SALENO
                                left join d_ll_gtml gtml
                                on gtml.WAREID = detail.wareid
                                and D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) BETWEEN add_months(p_begin, v_months) AND add_months(p_end, v_months)
                                and not exists (select 1
                                                from T_SALE_RETURN_H a
                                                where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号, sfzs,身份证号,创建时间,险种, 基本医疗统筹支付, 公务员补助统筹支付,
                                         当年账户支付, 大病金额,现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,zmdz1)bbb1) bbb
                           group by sfzs,zmdz1, 险种, 就诊类型, 参保地, jyd) a2
                          on  a1.险种 = a2.险种
                              and a1.就诊类型 = a2.就诊类型
                              and a1.SFZS = a2.sfzs
                              and a1.参保地 = a2.参保地
                              and a1.jyd = a2.jyd
                              and a1.ZMDZ1 = a2.zmdz1),

--年度
             cx4 AS (select a2.sfzs,
                            a2.zmdz1,
                            a2.险种,
                            a2.就诊类型,
                            a2.参保地,
                            a2.jyd,
                            人次,
                            ord2 as 人头,
                            ord3 as 一次人头,
                            总额度,
                            国谈总额度
                     from (select sfzs,
                                  zmdz1,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(ord2) as ord2,
                                  sum(ord3) as ord3
                           from (select erp销售号,
                                        sfzs,
                                        zmdz1,
                                        身份证号,
                                        创建时间,
                                        险种,
                                        '1'                                                                                                   as 就诊类型,
                                        gtje,
                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end order by 创建时间) as ord,
                                        case
                                            when nvl(xzrt.identityno, '0') = '0' then 0
                                            else (case
                                                      when ROW_NUMBER() over (partition by case
                                                                                               when nvl(xzrt.identityno, '0') <> '0'
                                                                                                   then xzrt.identityno
                                                                                               else '无' end,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,case when 就医地 = '市本级' then '椒江区' else 就医地 end,
                                                          case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                                          order by 创建时间) =
                                                           1 then 1
                                                      else 0 end) end                                                                         as ord2,
                                        ycrt                                                                                                  as ord3,
                                        nvl(case
                                                when gtje = 0
                                                    then nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)
                                                else gtje * gtbl end,
                                            0)                                                                                                as zed,
                                        nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                        nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                        nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                        nvl(大病金额, 0)                                                                                      as 大病金额,
                                        nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                        参保地,
                                        case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                 from d_zjys_wl2023xse
                                          left join D_YB_NEW_CUS_2024_04 xzrt
                                                    on to_char(身份证号) = to_char(identityno) and
                                                       trunc(创建时间) = trunc(RECEIPTDATE)
                                                        and case when 险种 = '职工基本医疗保险' then '0' else '1' end =
                                                            xzrt.NB_FLAG
--and case when 就诊类型='门诊特病' then '1' when 就诊类型='住院双通道' then '2' else  '0' end =xzrt.jslx
                                                        and d_zjys_wl2023xse.机构编码 = xzrt.busno
                                          left join v_zyjy_ycrt yc
                                                    on to_char(身份证号) = to_char(sfzh) and 就医地 = jyd and 险种 = xz and sfzs = sfzs1
                                 left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                 where trunc(创建时间) >= trunc(p_end, 'y')
                                   and trunc(创建时间) <= p_end
                                   and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                   and 医疗费用总额 - nvl(gtje, 0) <> 0) aaa
                           group by sfzs,zmdz1, 险种, 就诊类型, 参保地, jyd) a1
                              right join
                          (select sfzs,
                                  zmdz1,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(case when ord > 1 then 0 else ord end)                              as 人次,
                                  round(sum(zed), 2)                                                      as 国谈总额度,
                                  round(sum(zed1), 2)                                                     as 总额度,
                                  sum(nvl(基本医疗统筹支付, 0))                                           as 基本医疗统筹支付,
                                  sum(nvl(公务员补助统筹支付, 0))                                         as 公务员补助统筹支付,
                                  sum(nvl(当年账户支付, 0))                                               as 当年账户支付,
                                  sum(nvl(大病金额, 0))                                                   as 大病金额,
                                  sum(nvl(医疗费用总额, 0))                                               as 医疗费用总额,
                                  sum(nvl(历年账户支付, 0))                                               as 历年账户支付,
                                  sum(nvl(现金金额, 0))                                                   as 现金金额,
                                  round((sum(zed1) - sum(zed)) / case when sum(ord2) = 0 then 1 else sum(ord2) end,
                                        2)                                                                as 除国谈总指标,
                                  round(sum(zed1) / case when sum(ord2) = 0 then 1 else sum(ord2) end, 2) as 总指标
                           from (select bbb1.*,
                                   ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs,jyd order by 创建时间) as ord,
                                   case
                                       when ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                           case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                           order by 创建时间) > 1
                                           then 0
                                       else
                                           ROW_NUMBER() over (partition by 身份证号,险种,sfzs,jyd,
                                               case when 险种 = '职工基本医疗保险' and 参保地 in ('市本级','黄岩区','路桥区') then '市本级'
                                                              when 险种 = '城乡居民基本医疗保险' and 参保地 in ('市本级') then '市本级'
                                                              else 参保地 end
                                               order by 创建时间) end                     as ord2
                                from (select erp销售号,
                                       sfzs,
                                       zmdz1,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
                                       sum(case
                                           when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                               (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                           then
                                              nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                              nvl(detail.整单公补基金支付数, 0) *
                                              detail.单据明细医保比例 +
                                              nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                           else 0
                                           end)                                                                                          as zed, --国谈+药店双通道额度
                                       nvl(基本医疗统筹支付, 0)                                                                              as 基本医疗统筹支付,
                                       nvl(公务员补助统筹支付, 0)                                                                            as 公务员补助统筹支付,
                                       nvl(当年账户支付, 0)                                                                                  as 当年账户支付,
                                       nvl(大病金额, 0)                                                                                      as 大病金额,
                                       nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0)                          as zed1,
                                       nvl(现金金额, 0)                                                                                      as 现金金额,
                                       nvl(历年账户支付, 0)                                                                                  as 历年账户支付,
                                       nvl(医疗费用总额, 0)                                                                                  as 医疗费用总额,
                                       参保地,
                                       case when 就医地 = '市本级' then '椒江区' else 就医地 end jyd
                                from d_zjys_wl2023xse
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                left join D_YBZD_detail detail
                                on D_ZJYS_WL2023XSE.ERP销售号 = detail.SALENO
                                left join d_ll_gtml gtml
                                on gtml.WAREID = detail.wareid
                                and D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) >= trunc(p_end, 'y')
                                   and trunc(创建时间) <= p_end
                                and not exists (select 1
                                                from T_SALE_RETURN_H a
                                                where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号, sfzs,身份证号,创建时间,险种, 基本医疗统筹支付, 公务员补助统筹支付,
                                         当年账户支付, 大病金额,现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,zmdz1)bbb1) bbb
                           group by sfzs,zmdz1, 险种, 就诊类型, 参保地, jyd) a2
                          on  a1.险种 = a2.险种
                              and a1.SFZS = a2.SFZS
                              and a1.就诊类型 = a2.就诊类型
                              and a1.参保地 = a2.参保地
                              and a1.jyd = a2.jyd
                              and a1.ZMDZ1 = a2.ZMDZ1)

        select tb.classname                                                                                       as 事业部,
               tb1.classname                                                                                      as 片区,
               cx.jyd                                                                                          as 就医地,
               cx.zmdz1                                                                                          as 门店组,
               case when cx.sfzs = 0 then '药店' else '诊所' end                                                  as 门店类型,
               busi.orgname                                                                                       as 门店名称,
               cx.参保地,
               cx.人次,
               case
                   when nvl(cx2.人次, 0) = 0 then 0
                   else round(cx.人次 / cx2.人次, 4) - 1.00 end                                                   as 人次同比,
               case
                   when nvl(cx3.人次, 0) = 0 then 0
                   else round(cx.人次 / cx3.人次, 4) - 1.00 end                                                   as 人次环比,
               cx.人头,
               case
                   when nvl(cx2.人头, 0) = 0 then 0
                   else round(cx.人头 / cx2.人头, 4) - 1.00 end                                                   as 人头同比,
               case
                   when nvl(cx3.人头, 0) = 0 then 0
                   else round(cx.人头 / cx3.人头, 4) - 1.00 end                                                   as 人头环比,
               cx.一次人头,
               case
                   when nvl(cx2.一次人头, 0) = 0 then 0
                   else round(cx.一次人头 / cx2.一次人头, 4) - 1.00 end                                           as 一次人头同比,
               case
                   when nvl(cx3.一次人头, 0) = 0 then 0
                   else round(cx.一次人头 / cx3.一次人头, 4) - 1.00 end                                           as 一次人头环比,
               cx.险种,
               cx.就诊类型,
               cx1.zzb                                                                                            as 人头基金基数,
               case
                   when cx1.zzb = 0 then 0
                   else round((case
                                   when nvl(cx4.人头, 0) = 0 then 0
                                   else round((cx4.总额度 - cx4.国谈总额度) / cx4.人头, 2) end) / cx1.zzb,
                              4) end                                                                              as 年人头基金使用进度,
               case
                   when nvl(cx.人头, 0) = 0 then 0
                   else round((cx.总额度 - cx.国谈总额度) / cx.人头, 2) end                                       as 人头基金,
               case
                   when nvl(cx.人头, 0) = 0 then 0
                   else (cx1.zzb - round((cx.总额度 - cx.国谈总额度) / cx.人头, 2)) end                           as 人头基金差值,
               case
                   when (case
                             when nvl(cx2.人头, 0) = 0 then 0
                             else round((cx2.总额度 - cx2.国谈总额度) / cx2.人头, 2) end) = 0 then 0
                   else round((case
                                   when nvl(cx.人头, 0) = 0 then 0
                                   else round((cx.总额度 - cx.国谈总额度) / cx.人头, 2) end) / (case
                                                                                                    when nvl(cx2.人头, 0) = 0
                                                                                                        then 0
                                                                                                    else round((cx2.总额度 - cx2.国谈总额度) / cx2.人头, 2) end),
                              4) - 1.00
                   end                                                                                            as 人头基金同比,
               医疗费用总额                                                                                       as 总费用,
               cx.总额度,
               cx.国谈总额度,
               cx.总额度 - cx.国谈总额度                                                                          as 除国谈额度,
               case
                   when (cx2.总额度 - cx2.国谈总额度) = 0 then 0
                   else round((cx.总额度 - cx.国谈总额度) / (cx2.总额度 - cx2.国谈总额度), 4) - 1.00 end          as 除国谈额度同比,
               基本医疗统筹支付,
               当年账户支付,
               公务员补助统筹支付,
               大病金额                                                                                           as 大病保险支付,
               历年账户支付,
               现金金额                                                                                           as 现金支付
        from cx
                 left join cx1  on cx.险种 = cx1.xz and cx.就诊类型 = cx1.jzlx and cx.ZMDZ1 = cx1.BUSNO
                 left join cx2 on  cx.险种 = cx2.险种 and cx.就诊类型 = cx2.就诊类型 and cx.ZMDZ1 = cx2.ZMDZ1 and cx.SFZS = cx2.SFZS and cx.参保地 = cx2.参保地 and cx.jyd = cx2.jyd
                 left join cx3 on  cx.险种 = cx3.险种 and cx.就诊类型 = cx3.就诊类型 and cx.ZMDZ1 = cx3.zmdz1 and cx.SFZS = cx3.SFZS and cx.参保地 = cx3.参保地 and cx.jyd = cx3.jyd
                 left join cx4 on  cx.险种 = cx4.险种 and cx.就诊类型 = cx4.就诊类型 and cx.zmdz1 = cx4.ZMDZ1 and cx.SFZS = cx4.SFZS and cx.参保地 = cx4.参保地 and cx.jyd = cx4.jyd
                 join t_busno_class_set ts on cx.ZMDZ1 = ts.busno and ts.classgroupno = '303'
                 join t_busno_class_base tb on ts.classgroupno = ts.classgroupno and ts.classcode = tb.classcode
                 join t_busno_class_set ts1 on cx.ZMDZ1 = ts1.busno and ts1.classgroupno = '304'
                 join t_busno_class_base tb1 on ts1.classgroupno = ts1.classgroupno and ts1.classcode = tb1.classcode
                 join t_busno_class_set ts2 on cx.ZMDZ1 = ts2.BUSNO and ts2.CLASSGROUPNO = '305'
                 join s_busi busi on cx.ZMDZ1 = busi.busno;

END;
/

