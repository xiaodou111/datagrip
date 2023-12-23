with a1 as (
select ERP销售单号,tb.CLASSNAME as 门店类型,姓名,a.BUSNO,s.ORGNAME,销售日期 as 末次消费日期,身份证号,参保地,EXT_CHAR04 as 参保单位,
       case when 参保人员类别 like '%居民%' then '农保' else '医保' end as  参保人员类别,
       h.MEMBERCARDNO as 会员卡号,mem.MOBILE as 手机号,mem.CARDHOLDER as 持卡人,
       row_number() over (partition by tb.CLASSNAME,身份证号,参保地,case when 参保人员类别 like '%居民%' then '农保' else '医保' end,
           EXT_CHAR04 order by 销售日期 desc ) rn
from d_zhyb_hz_cyb a
left join s_busi s on a.BUSNO=s.busno
left join t_sale_h h on a.ERP销售单号=h.saleno
left join t_memcard_reg mem on h.MEMBERCARDNO=mem.MEMCARDNO
join t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode
where 销售日期>=trunc(sysdate)-120
and tb.CLASSCODE in ('30510','30511')),
a2 as ( select
            case when rn=1 and 末次消费日期 between trunc(sysdate)-60 and trunc(sysdate)-30 then '30-60天未回访'
             when rn=1 and 末次消费日期 between trunc(sysdate)-90 and trunc(sysdate)-60 then '60-90天未回访'
             when rn=1 and 末次消费日期 between trunc(sysdate)-120 and trunc(sysdate)-90 then '90-120天未回访' else '0' end as 未回访类型,
            a1.* from a1)
select *
from a2 where 未回访类型 in('30-60天未回访','60-90天未回访','90-120天未回访');