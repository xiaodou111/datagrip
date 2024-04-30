
with a as (
--方案一
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (1)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10502445)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
union all
--方案二
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (2)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
union all
--方案三
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by a.busno,h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (3)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10502445,10600308)
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
left join d_patient_files fi on fi.IDCARDNO = a.IDCARDNO
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
aa.busno,
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
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO;

--报表
select a.BUSNO, ORGNAME, 药店所在省份, 药店所在城市, a.IDCARDNO, a.USERNAME, fi.原用药方案 as 用药方案, fi.该方案曲妥珠单抗是否为赫赛汀,
       fi.疾病分期, fi.是否早期新辅助治疗, K患者本店总购药支数, L二二年1月以前累计购药盒数, M二二年1月以来本店累计购药支数,
       N理论购药支数, O实际药房购药期间盒数偏差分析, P本店购买盒数核查, Q本店累计购药次数, R本店最近一次购药时间,
       S本店前一次购药时间, T最近两次购药周期, U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数,
       X最近购药距首次购药累计时长, Y2022年以来本店平均购药周期, 随访时间, 随访反馈, 随访备注, AC本店第一次购药时间,
       RN
from D_LUOSHI_JMSF_1 a
left join d_patient_files fi on a.idcardno=fi.idcardno;

MERGE INTO d_luoshi_jmsf_1 T1
USING
(
select busno, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO, USERNAME, 用药方案,
                                    该方案曲妥珠单抗是否为赫赛汀, 疾病分期, 是否早期新辅助治疗, k患者本店总购药支数,
                                    l二二年1月以前累计购药盒数, m二二年1月以来本店累计购药支数, N理论购药支数,
                                    o实际药房购药期间盒数偏差分析, p本店购买盒数核查, q本店累计购药次数, r本店最近一次购药时间,
                                    s本店前一次购药时间, t最近两次购药周期, u本店下次理论购药时间, v推测是否已完成疗程,
                                    w最近一次购药距离今日天数, x最近购药距首次购药累计时长, y2022年以来本店平均购药周期,
                                    随访时间, 随访反馈, 随访备注, ac本店第一次购药时间, rn
                             from v_luoshi_jmsf where IDCARDNO is not null
)  T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
WHEN MATCHED THEN
UPDATE SET
           T1.k患者本店总购药支数= T2.k患者本店总购药支数,
           T1.l二二年1月以前累计购药盒数= T2.l二二年1月以前累计购药盒数,
           T1.m二二年1月以来本店累计购药支数= T2.m二二年1月以来本店累计购药支数,
           T1.N理论购药支数= T2.N理论购药支数,
           T1.o实际药房购药期间盒数偏差分析= T2.o实际药房购药期间盒数偏差分析,
           T1.p本店购买盒数核查= T2.p本店购买盒数核查,
           T1.q本店累计购药次数= T2.q本店累计购药次数,
           T1.r本店最近一次购药时间= T2.r本店最近一次购药时间,
           T1.s本店前一次购药时间= T2.s本店前一次购药时间,
           T1.t最近两次购药周期= T2.t最近两次购药周期,
           T1.u本店下次理论购药时间= T2.u本店下次理论购药时间,
           T1.v推测是否已完成疗程= T2.v推测是否已完成疗程,
           T1.w最近一次购药距离今日天数= T2.w最近一次购药距离今日天数,
           T1.x最近购药距首次购药累计时长= T2.x最近购药距首次购药累计时长,
           T1.y2022年以来本店平均购药周期= T2.y2022年以来本店平均购药周期,
           T1.ac本店第一次购药时间= T2.ac本店第一次购药时间

WHEN NOT MATCHED THEN
INSERT (busno, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO, USERNAME, 用药方案,
                                    该方案曲妥珠单抗是否为赫赛汀, 疾病分期, 是否早期新辅助治疗, k患者本店总购药支数,
                                    l二二年1月以前累计购药盒数, m二二年1月以来本店累计购药支数, N理论购药支数,
                                    o实际药房购药期间盒数偏差分析, p本店购买盒数核查, q本店累计购药次数, r本店最近一次购药时间,
                                    s本店前一次购药时间, t最近两次购药周期, u本店下次理论购药时间, v推测是否已完成疗程,
                                    w最近一次购药距离今日天数, x最近购药距首次购药累计时长, y2022年以来本店平均购药周期,
                                    随访时间, 随访反馈, 随访备注, ac本店第一次购药时间, rn)
VALUES(T2.busno, T2.ORGNAME, T2.药店所在省份, T2.药店所在城市, T2.IDCARDNO, T2.USERNAME, T2.用药方案,
        T2.该方案曲妥珠单抗是否为赫赛汀, T2.疾病分期, T2.是否早期新辅助治疗, T2.k患者本店总购药支数,
        T2.l二二年1月以前累计购药盒数, T2.m二二年1月以来本店累计购药支数, T2.N理论购药支数,
        T2.o实际药房购药期间盒数偏差分析, T2.p本店购买盒数核查, T2.q本店累计购药次数, T2.r本店最近一次购药时间,
        T2.s本店前一次购药时间, T2.t最近两次购药周期, T2.u本店下次理论购药时间, T2.v推测是否已完成疗程,
        T2.w最近一次购药距离今日天数, T2.x最近购药距首次购药累计时长, T2.y2022年以来本店平均购药周期,
        T2.随访时间, T2.随访反馈, T2.随访备注, T2.ac本店第一次购药时间, T2.rn);


select * from d_luoshi_jmsf_1;
--   and  base.IDCARDNO in ( select base.IDCARDNO from before_22)
;
create table d_luoshi_jm_hf
(
    idcard   varchar2(100),
    busno    number,
    sfday    date,
    sfresult varchar2(400),
    notes    varchar2(400)
);
UPDATE v_luoshi_jmsf SET 随访反馈='1215',随访备注='qq' WHERE busno=81248 AND idcardno='332601197804065168';

select *
from d_luoshi_jm_hf;

select *
from ;







--每个人第一次购买皮下的时间
select * from (select d.WAREID, h.IDCARDNO, a.ACCDATE,
                      row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ) rn
               from t_remote_prescription_h h
                        join t_sale_h a on substr(a.notes, 0,
                                                  decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                         instr(a.notes, ' ')) - 1) =
                                           h.CFNO
                        join t_sale_d d on a.SALENO = d.SALENO
               where  d.WAREID in (10601875) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                 and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                 and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)
               ) where rn=1;

select * from d_luoshi_jm_hf;
create or replace trigger TR_V_LUOSHI_JMSF
    instead of update
    on V_LUOSHI_JMSF
    for each row
begin
    MERGE INTO d_luoshi_jm_hf T1
    USING
        (SELECT

             :new.IDCARDNO IDCARDNO,
             :new.随访时间 随访时间,
             :new.随访反馈 随访反馈,
             :new.随访备注 随访备注,
             :new.不规范记录 不规范记录
         FROM dual) T2
    ON (T1.idcard = T2.IDCARDNO)
    WHEN MATCHED THEN
        UPDATE SET
        T1.sfday= T2.随访时间,
        T1.sfresult= T2.随访反馈,
        T1.notes= T2.随访备注,
        T1.BGFJL= T2.不规范记录
    WHEN NOT MATCHED THEN
        INSERT (idcard, sfday,sfresult,notes,BGFJL) VALUES (
             :new.IDCARDNO,
             :new.随访时间,
             :new.随访反馈,
             :new.随访备注,
             :new.不规范记录);
end;
GRANT CREATE TRIGGER TO h2;
call proc_luoshi_trigger_daily();
delete from d_luoshi_jm_hf ;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
     job_name        => '每天重建罗氏的触发器',
     job_type        => 'PLSQL_BLOCK',
     job_action      => 'BEGIN proc_luoshi_trigger_daily; END;',
     start_date      => SYSTIMESTAMP,
     repeat_interval => 'FREQ=DAILY;BYHOUR=0', -- 每天凌晨执行
     enabled         => TRUE,
     comments        => '每天重建罗氏的触发器');
END;

