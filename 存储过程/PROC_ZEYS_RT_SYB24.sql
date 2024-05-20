create PROCEDURE proc_zeys_rt_syb24(p_begin IN DATE,
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

                           a2.事业部,
                           a2.险种,
                           a2.就诊类型,
                           a2.参保地,
                           a2.jyd,
                           人次,
                           ord2 as 人头,
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

                                 事业部,
                                 险种,
                                 就诊类型,
                                 参保地,
                                 jyd,
                                 sum(ord2) as ord2
                          from (select erp销售号,

                                       sfzs,
                                       事业部,
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
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                where trunc(创建时间) BETWEEN p_begin AND p_end
                                  and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                  and 医疗费用总额 - nvl(gtje, 0) <> 0
                                and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)) aaa
                          group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a1
                             right join
                         (select sfzs,

                                 事业部,
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
                                from (select
                                       erp销售号,
                                       sfzs,
                                       事业部,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
--                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs order by 创建时间) as ord,
--                                        case
--                                            when ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) > 1
--                                                then 0
--                                            else
--                                                ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) end                     as ord2,
                                      sum(case
                                              when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                                   (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                                  then
                                                  nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                                  nvl(detail.整单公补基金支付数, 0) *
                                                  detail.单据明细医保比例 +
                                                  nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                              else 0
                                          end)                                                                     as zed, --国谈+药店双通道额度
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
                                              and
                                             D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) BETWEEN p_begin AND p_end
                                and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号,
                                                    sfzs,
                                                    身份证号,
                                                    创建时间,
                                                    险种, 基本医疗统筹支付, 公务员补助统筹支付, 当年账户支付, 大病金额,
                                                    现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,事业部)bbb1) bbb
                          group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a2
                         on a1.sfzs = a2.sfzs
                             and a1.事业部 = a2.事业部
                             and a1.险种 = a2.险种
                             and a1.就诊类型 = a2.就诊类型
                             and a1.参保地 = a2.参保地
                             and a1.jyd = a2.jyd
                             ),
             cx1 as (select sfzs, syb, jyd, cbd, xz, jzlx, zzb from D_ZEYS_IMPORT_syb where PEROID = '2023'),
             --去年
             cx2 AS (select a2.sfzs,

                            a2.事业部,
                            a2.险种,
                            a2.就诊类型,
                            a2.参保地,
                            a2.jyd,
                            人次,
                            ord2 as 人头,
                            总额度,
                            国谈总额度
                     from (select sfzs,

                                  事业部,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(ord2) as ord2
                           from (select erp销售号,

                                        sfzs,
                                        事业部,
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
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                 where trunc(创建时间) BETWEEN add_months(p_begin, -12) AND add_months(p_end, -12)
                                   and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                   and 医疗费用总额 - nvl(gtje, 0) <> 0
                                 and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)) aaa
                           group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a1
                              right join
                          (select sfzs,

                                  事业部,
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
                                from (select
                                       erp销售号,
                                       sfzs,
                                       事业部,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
--                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs order by 创建时间) as ord,
--                                        case
--                                            when ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) > 1
--                                                then 0
--                                            else
--                                                ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) end                     as ord2,
                                      sum(case
                                              when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                                   (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                                  then
                                                  nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                                  nvl(detail.整单公补基金支付数, 0) *
                                                  detail.单据明细医保比例 +
                                                  nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                              else 0
                                          end)                                                                     as zed, --国谈+药店双通道额度
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
                                              and
                                             D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) BETWEEN add_months(p_begin, -12) AND add_months(p_end, -12)
                                and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号,
                                                    sfzs,
                                                    身份证号,
                                                    创建时间,
                                                    险种, 基本医疗统筹支付, 公务员补助统筹支付, 当年账户支付, 大病金额,
                                                    现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,事业部)bbb1) bbb
                           group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a2
                          on a1.sfzs = a2.sfzs
                              and a1.险种 = a2.险种
                              and a1.事业部 = a2.事业部
                              and a1.就诊类型 = a2.就诊类型
                              and a1.参保地 = a2.参保地
                              and a1.jyd = a2.jyd
                              ),

--上月
             cx3 AS (select a2.sfzs,

                            a2.事业部,
                            a2.险种,
                            a2.就诊类型,
                            a2.参保地,
                            a2.jyd,
                            人次,
                            ord2 as 人头,
                            总额度,
                            国谈总额度
                     from (select sfzs,

                                  事业部,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(ord2) as ord2
                           from (select erp销售号,

                                        sfzs,
                                        事业部,
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
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                 where trunc(创建时间) BETWEEN add_months(p_begin, v_months) AND add_months(p_end, v_months)
                                   and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                   and 医疗费用总额 - nvl(gtje, 0) <> 0
                                 and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)) aaa
                           group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a1
                              right join
                          (select sfzs,

                                  事业部,
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
                                from (select
                                       erp销售号,
                                       sfzs,
                                       事业部,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
--                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs order by 创建时间) as ord,
--                                        case
--                                            when ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) > 1
--                                                then 0
--                                            else
--                                                ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) end                     as ord2,
                                      sum(case
                                              when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                                   (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                                  then
                                                  nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                                  nvl(detail.整单公补基金支付数, 0) *
                                                  detail.单据明细医保比例 +
                                                  nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                              else 0
                                          end)                                                                     as zed, --国谈+药店双通道额度
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
                                              and
                                             D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) BETWEEN add_months(p_begin, v_months) AND add_months(p_end, v_months)
                                and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号,
                                                    sfzs,
                                                    身份证号,
                                                    创建时间,
                                                    险种, 基本医疗统筹支付, 公务员补助统筹支付, 当年账户支付, 大病金额,
                                                    现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,事业部)bbb1) bbb
                           group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a2
                          on a1.sfzs = a2.sfzs
                              and a1.险种 = a2.险种
                              and a1.事业部 = a2.事业部
                              and a1.就诊类型 = a2.就诊类型
                              and a1.参保地 = a2.参保地
                              and a1.jyd = a2.jyd
                              ),
--年度
             cx4 AS (select a2.sfzs,

                            a2.事业部,
                            a2.险种,
                            a2.就诊类型,
                            a2.参保地,
                            a2.jyd,
                            人次,
                            ord2 as 人头,
                            总额度,
                            国谈总额度
                     from (select sfzs,

                                  事业部,
                                  险种,
                                  就诊类型,
                                  参保地,
                                  jyd,
                                  sum(ord2) as ord2
                           from (select erp销售号,

                                        sfzs,
                                        事业部,
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
                                left join s_busi
                                on d_zjys_wl2023xse.机构编码 = s_busi.BUSNO
                                 where trunc(创建时间) >= trunc(p_end, 'y')
                                   and trunc(创建时间) <= p_end
                                   and nvl(基本医疗统筹支付, 0) + nvl(公务员补助统筹支付, 0) + nvl(当年账户支付, 0) <> 0
                                   and 医疗费用总额 - nvl(gtje, 0) <> 0
                                 and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)) aaa
                           group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a1
                              right join
                          (select sfzs,

                                  事业部,
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
                                from (select
                                       erp销售号,
                                       sfzs,
                                       事业部,
                                       身份证号,
                                       创建时间,
                                       险种,
                                       '1'                                                                                                   as 就诊类型,
                                       gtje,
--                                        ROW_NUMBER() over (partition by 身份证号,to_char(创建时间, 'yyyy-mm-dd'),险种,sfzs order by 创建时间) as ord,
--                                        case
--                                            when ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) > 1
--                                                then 0
--                                            else
--                                                ROW_NUMBER() over (partition by 身份证号,险种,sfzs order by 创建时间) end                     as ord2,
                                      sum(case
                                              when (SFZS = '1' and gtml.PZFL = '国谈品种') or
                                                   (SFZS = '0' and gtml.PZFL in ('国谈品种', '双通道品种'))
                                                  then
                                                  nvl(detail.整单统筹支付数, 0) * detail.单据明细医保比例 +
                                                  nvl(detail.整单公补基金支付数, 0) *
                                                  detail.单据明细医保比例 +
                                                  nvl(detail.整单个人当年帐户支付数, 0) * detail.单据明细医保比例
                                              else 0
                                          end)                                                                     as zed, --国谈+药店双通道额度
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
                                              and
                                             D_ZJYS_WL2023XSE.创建时间 between gtml.BEGINDATE and gtml.ENDDATE
                                where trunc(创建时间) >= trunc(p_end, 'y')
                                   and trunc(创建时间) <= p_end
                                and not exists (select 1 from T_SALE_RETURN_H a
                                            where a.RETSALENO = D_ZJYS_WL2023XSE.ERP销售号)
                                group by erp销售号,
                                                    sfzs,
                                                    身份证号,
                                                    创建时间,
                                                    险种, 基本医疗统筹支付, 公务员补助统筹支付, 当年账户支付, 大病金额,
                                                    现金金额, 历年账户支付, 医疗费用总额, 参保地, case when 就医地 = '市本级' then '椒江区' else 就医地 end,gtje,事业部)bbb1) bbb
                           group by sfzs, 事业部, 险种, 就诊类型, 参保地, jyd) a2
                          on a1.sfzs = a2.sfzs
                              and a1.险种 = a2.险种
                              and a1.事业部 = a2.事业部
                              and a1.就诊类型 = a2.就诊类型
                              and a1.参保地 = a2.参保地
                              and a1.jyd = a2.jyd
                              )

        select
               case when cx.sfzs = 0 then '药店' else '诊所' end                                                  as 门店类型,
               cx.事业部                                                                                          as 事业部,
               cx.jyd                                                                                          as 就医地,
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
               cx.险种,
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
                 left join cx1 on cx.sfzs = cx1.sfzs and cx.险种 = cx1.xz and cx.就诊类型 = cx1.jzlx and
                                  cx.jyd = cx1.jyd and cx.参保地 = cx1.cbd and cx.事业部 = cx1.syb
                 left join cx2 on cx.sfzs = cx2.sfzs and cx.险种 = cx2.险种 and cx.就诊类型 = cx2.就诊类型 and
                                  cx2.jyd = cx1.jyd and cx2.参保地 = cx1.cbd and cx2.事业部 = cx1.syb
                 left join cx3 on cx.sfzs = cx3.sfzs and cx.险种 = cx3.险种 and cx.就诊类型 = cx3.就诊类型 and
                                  cx3.jyd = cx1.jyd and cx3.参保地 = cx1.cbd and cx3.事业部 = cx1.syb
                 left join cx4 on cx.sfzs = cx4.sfzs and cx.险种 = cx4.险种 and cx.就诊类型 = cx4.就诊类型 and
                                  cx4.jyd = cx1.jyd and cx4.参保地 = cx1.cbd and cx4.事业部 = cx1.syb;

END;
/

