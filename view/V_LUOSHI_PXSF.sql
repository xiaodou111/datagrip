create or replace view V_LUOSHI_PXSF as
with base as (
-- 按方案统计每个阶段的销售记录
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY, a.SALENO, a.BUSNO, h.USERNAME,
                     SUM(case when d.WAREID = 10601875 then d.WAREQTY else 0 end) over
                         ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqtqty,--曲妥数量
                     SUM(case when d.WAREID = 10600308 then d.WAREQTY else 0 end) over
                         ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumptqty,--帕妥数量
                     COUNT(case when d.WAREID = 10601875 then d.WAREQTY else null end)
                           over ( partition by h.IDCARDNO) count,  --购买次数以曲妥次数为准
                     MAX(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO ) AS r本店最近一次购药时间,
                      LAG(a.ACCDATE, 1) OVER (PARTITION BY h.IDCARDNO,d.WAREID ORDER BY a.ACCDATE ) AS s本店前一次购药时间,--需要查找上次买10601875的记录
                      LAG(a.ACCDATE, 2) OVER (PARTITION BY h.IDCARDNO,d.WAREID ORDER BY a.ACCDATE ) AS 本店倒数第三次购药时间,
                     MIN(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO ) AS ac本店第一次购药时间,
                     ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE desc ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (4,5,6)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10601875, 10600308)
  and not EXISTS(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = a.SALENO)
  and not EXISTS(select 1 from T_SALE_RETURN_H rh where rh.SALENO = a.SALENO)),
--保留最后一条记录
a1 as (
select B1.WAREID, B1.IDCARDNO, B1.ACCDATE, B1.WAREQTY, B1.SALENO, B1.BUSNO, B1.USERNAME, B1.sumqtqty, B1.sumptqty, B1.count,
       B1.r本店最近一次购药时间, B1.s本店前一次购药时间,本店倒数第三次购药时间, B1.ac本店第一次购药时间, B1.rn
from base B1
where b1.rn=1 ),
 --系统数据和期初导入数据进行合并
 add_qc as (
   select nvl(a1.busno,files.BUSNO) as busno,nvl(a1.IDCARDNO,files.IDCARDNO) as IDCARDNO,
          nvl(a1.USERNAME,files.USERNAME) as USERNAME,a1.WAREID as WAREID,
       nvl(qc.QTZSL,0)+nvl(sumqtqty,0) as j皮下曲妥珠单抗支数,
       nvl(qc.PTZSL,0)+nvl(sumptqty,0)  as k转皮下后帕妥珠单抗支数,
       nvl(qc.SUMCS,0)+nvl(count,0) as q本店皮下累计购药次数,
       nvl(r本店最近一次购药时间,qc.LASTBUYTIME) as r本店最近一次购药时间,
       case when r本店最近一次购药时间 is null then qc.LAGBUYTIME else
           case when s本店前一次购药时间 is null then qc.LASTBUYTIME
               else s本店前一次购药时间 end end as s本店前一次购药时间,
        case when 本店倒数第三次购药时间 is not null then 本店倒数第三次购药时间
           else
       case when r本店最近一次购药时间 is not null and s本店前一次购药时间 is not null  then qc.LASTBUYTIME
           else
       case when r本店最近一次购药时间 is not null and s本店前一次购药时间 is null then qc.LAGBUYTIME
           else null
            end end end as 本店倒数第三次购药时间,
       nvl(qc.firsttime,ac本店第一次购药时间) as ac本店第一次购药时间,
--        (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)+21)/21 as M理论购药支数,
       0 as l皮下phegso支数,
       rn
    from  D_LUOSHI_QCPX qc
    left join  d_patient_files files on qc.IDCARDNO=files.IDCARDNO
    full join a1  on a1.IDCARDNO=qc.IDCARDNO
    )
 select aa.busno,s.ORGNAME,tb.CLASSNAME as 药店所在省份,tb1.CLASSNAME as 药店所在城市,aa.IDCARDNO,aa.USERNAME,
        files.疾病分期,files.是否早期新辅助治疗,files.新皮下方案,
        aa.j皮下曲妥珠单抗支数, aa.k转皮下后帕妥珠单抗支数,aa.l皮下phegso支数,
        (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)+21)/21 as M理论购药支数,
        case when (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)+21)/21 - j皮下曲妥珠单抗支数 >= 1 then '有非本店购买可能' else '皆在本店购买' end as n实际药房购药期间盒数偏差分析,
        case when j皮下曲妥珠单抗支数 + l皮下phegso支数 - q本店皮下累计购药次数 < 0 then '重新核查盒数' else '0' end as o皮下支数核查,
        case
           when files.新皮下方案 = '双靶(曲妥珠单抗HSC+帕妥珠单抗)' and k转皮下后帕妥珠单抗支数 < q本店皮下累计购药次数
               then '重新核查盒数'
           else '0' end as p转皮下后帕妥支数核查,
        q本店皮下累计购药次数 as q本店累计购药次数,
        r本店最近一次购药时间,
        s本店前一次购药时间,
        本店倒数第三次购药时间,
        r本店最近一次购药时间 - s本店前一次购药时间 as t最近两次购药周期,
        s本店前一次购药时间-本店倒数第三次购药时间 as 倒三到倒二次购药周期,
        r本店最近一次购药时间 + 21 as u本店下次理论购药时间,
        case when k转皮下后帕妥珠单抗支数 >= 19 then 'Y' else 'N' end as v推测是否已完成疗程,
        trunc(sysdate - r本店最近一次购药时间) as w最近一次购药距离今日天数,
        trunc(r本店最近一次购药时间 - ac本店第一次购药时间) as x最近购药距首次购药累计时长,
        case
           when q本店皮下累计购药次数 <= 1 then null
           else (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)) / (q本店皮下累计购药次数 - 1) end as y2022年以来本店平均购药周期,
       hf.SFDAY as 随访时间, hf.SFRESULT as 随访反馈, hf.NOTES as 随访备注,hf.BGFJL as 不规范记录, aa.ac本店第一次购药时间, aa.rn
from add_qc aa
left join s_busi s on aa.busno=s.BUSNO
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO
left join d_luoshi_px_hf hf on aa.IDCARDNO=hf.IDCARD
/

