create or replace view V_LUOSHI_JMSF as
with a as (
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by a.busno,h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (1,3)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10502445)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
union all
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (2,4)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
),
a1 as(
select
a.SALENO, a.ACCDATE, a.WAREQTY,a.IDCARDNO,a.USERNAME,WAREID,
a.busno,
sum(a.WAREQTY)
    over ( partition by a.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) m二二年1月以来本店累计购药支数,
Max(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) AS r本店最近一次购药时间,
LAG(a.ACCDATE, 1) OVER (PARTITION BY a.IDCARDNO ORDER BY a.ACCDATE ) AS s本店前一次购药时间,
min(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) AS ac本店第一次购药时间,
(Max(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) - min(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) +
 21) / 21 as N理论购药支数,
count(distinct a.SALENO) over ( partition by a.IDCARDNO) as q本店累计购药次数,
row_number() over (partition by a.IDCARDNO order by a.ACCDATE desc) rn
 from a
),
add_qc as (
   select a1.busno as busno,a1.IDCARDNO as IDCARDNO,a1.USERNAME as USERNAME,a1.WAREID as WAREID,
    nvl(qc.LBEFORE22,0)+nvl(qc.MSUMSLNOW,0)+nvl(m二二年1月以来本店累计购药支数,0) as  k患者本店总购药支数,
       nvl(qc.LBEFORE22,0) as l二二年1月以前累计购药盒数,
       nvl(qc.MSUMSLNOW,0)+nvl(m二二年1月以来本店累计购药支数,0) as m二二年1月以来本店累计购药支数,
    N理论购药支数,
       nvl(q本店累计购药次数,qc.QSUMCS) as q本店累计购药次数,
       nvl(r本店最近一次购药时间,qc.RLASTBUYTIME) as r本店最近一次购药时间,
       nvl(s本店前一次购药时间,qc.SLAGBUYTIME) as s本店前一次购药时间,
       nvl(ac本店第一次购药时间,qc.firsttime) as ac本店第一次购药时间,rn
    from  a1
    left join d_luoshi_qcsj qc on a1.IDCARDNO=qc.IDCARDNO
    where rn=1
    )
select
aa.busno,s.ORGNAME,
tb.CLASSNAME as 药店所在省份,
tb1.CLASSNAME as 药店所在城市,
       aa.IDCARDNO, aa.USERNAME,
       files.原用药方案 as 用药方案,
       files.该方案曲妥珠单抗是否为赫赛汀,
       files.疾病分期,
       files.是否早期新辅助治疗,
       k患者本店总购药支数,
       l二二年1月以前累计购药盒数,
       m二二年1月以来本店累计购药支数,
       N理论购药支数,
       case when N理论购药支数 - m二二年1月以来本店累计购药支数 >= 1 then '有非本店购买可能' else '皆在本店购买' end as o实际药房购药期间盒数偏差分析,
       case when m二二年1月以来本店累计购药支数 - q本店累计购药次数 < 0 then '重新核查盒数' else '0' end as p本店购买盒数核查,
       q本店累计购药次数,
       r本店最近一次购药时间,
       s本店前一次购药时间,
       r本店最近一次购药时间 - s本店前一次购药时间 as t最近两次购药周期,
       r本店最近一次购药时间 + 21 as u本店下次理论购药时间,
       case when k患者本店总购药支数 >= 19 then 'Y' else 'N' end as v推测是否已完成疗程,
       trunc(sysdate - r本店最近一次购药时间) as w最近一次购药距离今日天数,
       trunc(r本店最近一次购药时间 - ac本店第一次购药时间) as x最近购药距首次购药累计时长,
       case when q本店累计购药次数<=1 then null else (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)) / (q本店累计购药次数 - 1) end as y2022年以来本店平均购药周期,
       null as 随访时间,null as 随访反馈,null as 随访备注,
--        hf.sfday as 随访时间, hf.sfresult as 随访反馈, hf.notes as 随访备注,
       ac本店第一次购药时间,rn
from add_qc aa
left join s_busi s on aa.busno=s.BUSNO
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO;

