
with base as (select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY, a.SALENO, a.BUSNO, h.USERNAME,
                     SUM(case when d.WAREID = 10601875 then d.WAREQTY else 0 end) over
                         ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqtqty,--曲妥数量
                     SUM(case when d.WAREID = 10600308 then d.WAREQTY else 0 end) over
                         ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumptqty,--帕妥数量
                     COUNT(case when d.WAREID = 10601875 then d.WAREQTY else null end)
                           over ( partition by h.IDCARDNO) count,  --购买次数以曲妥次数为准
                     MAX(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO ) AS r本店最近一次购药时间,
--                      LAG(a.ACCDATE, 1) OVER (PARTITION BY h.IDCARDNO ORDER BY a.ACCDATE ) AS s本店前一次购药时间,需要查找上次买10601875的记录
                     MIN(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO ) AS ac本店第一次购药时间,
                     ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE desc ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (5, 6, 7)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10601875, 10600308)
  and not EXISTS(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = a.SALENO)
  and not EXISTS(select 1 from T_SALE_RETURN_H rh where rh.SALENO = a.SALENO)),
a1 as ( 
select B1.WAREID, B1.IDCARDNO, B1.ACCDATE, B1.WAREQTY, B1.SALENO, B1.BUSNO, B1.USERNAME, B1.sumqtqty, B1.sumptqty, B1.count,
       B1.r本店最近一次购药时间, B2.s本店前一次购药时间, B1.ac本店第一次购药时间, B1.rn
from base B1
left join (
    select d.WAREID, h.IDCARDNO, a.ACCDATE,a.SALENO,LAG(a.ACCDATE, 1) OVER (PARTITION BY IDCARDNO ORDER BY a.ACCDATE ) AS s本店前一次购药时间
    from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
    where d.WAREID=10601875
) B2 on b1.IDCARDNO=b2.IDCARDNO and b1.SALENO=b2.SALENO and b1.WAREID=b2.WAREID
where b1.rn=1 ),
 add_qc as (
   select a1.busno as busno,a1.IDCARDNO as IDCARDNO,a1.USERNAME as USERNAME,a1.WAREID as WAREID,
       nvl(qc.QTZSL,0)+nvl(sumqtqty,0) as j皮下曲妥珠单抗支数,
       nvl(qc.PTZSL,0)+nvl(sumptqty,0)  as k转皮下后帕妥珠单抗支数,
       nvl(qc.SUMCS,0)+nvl(count,0) as q本店皮下累计购药次数,
       nvl(r本店最近一次购药时间,qc.LASTBUYTIME) as r本店最近一次购药时间,
       nvl(s本店前一次购药时间,qc.LAGBUYTIME) as s本店前一次购药时间,
       nvl(ac本店第一次购药时间,qc.firsttime) as ac本店第一次购药时间,
       (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)+21)/21 as M理论购药支数,
       0 as l皮下phegso支数,
       rn
    from  a1
    left join d_luoshi_qcpx qc on a1.IDCARDNO=qc.IDCARDNO
    )
 select aa.busno,s.ORGNAME,tb.CLASSNAME as 药店所在省份,tb1.CLASSNAME as 药店所在城市,aa.IDCARDNO,aa.USERNAME,
        files.疾病分期,files.是否早期新辅助治疗,files.新皮下方案,
        aa.j皮下曲妥珠单抗支数, aa.k转皮下后帕妥珠单抗支数,aa.l皮下phegso支数,
        aa.M理论购药支数,
        case when M理论购药支数 - j皮下曲妥珠单抗支数 >= 1 then '有非本店购买可能' else '皆在本店购买' end as n实际药房购药期间盒数偏差分析,
        case when j皮下曲妥珠单抗支数 + l皮下phegso支数 - q本店皮下累计购药次数 < 0 then '重新核查盒数' else '0' end as o皮下支数核查,
        case
           when files.新皮下方案 = '双靶(曲妥珠单抗HSC+帕妥珠单抗)' and k转皮下后帕妥珠单抗支数 < q本店皮下累计购药次数
               then '重新核查盒数'
           else '0' end as p转皮下后帕妥支数核查,
        q本店皮下累计购药次数 as q本店累计购药次数,
        r本店最近一次购药时间,
        s本店前一次购药时间,
        r本店最近一次购药时间 - s本店前一次购药时间 as t最近两次购药周期,
        r本店最近一次购药时间 + 21 as u本店下次理论购药时间,
        case when k转皮下后帕妥珠单抗支数 >= 19 then 'Y' else 'N' end as v推测是否已完成疗程,
        trunc(sysdate - r本店最近一次购药时间) as w最近一次购药距离今日天数,
        trunc(r本店最近一次购药时间 - ac本店第一次购药时间) as x最近购药距首次购药累计时长,
        case
           when q本店皮下累计购药次数 <= 1 then null
           else (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)) / (q本店皮下累计购药次数 - 1) end as y2022年以来本店平均购药周期,
       null as 随访时间, null as 随访反馈, null as 随访备注, aa.ac本店第一次购药时间, aa.rn
from add_qc aa
left join s_busi s on aa.busno=s.BUSNO
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO;

select * from  V_LUOSHI_PXSF;
create table d_luoshi_pxsf_1 as
select BUSNO, ORGNAME, "药店所在省份", "药店所在城市", IDCARDNO, USERNAME, I新皮下方案, J皮下曲妥珠单抗支数,
       K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
       P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, "随访时间", "随访反馈", "随访备注", AC本店第一次购药时间, RN2
from v_luoshi_pxsf;
select * from d_luoshi_pxsf_1;
--报表
select a.BUSNO, ORGNAME, 药店所在省份, 药店所在城市, fi.IDCARDNO, a.USERNAME,fi.疾病分期,fi.是否早期新辅助治疗,fi.新皮下方案, J皮下曲妥珠单抗支数,
       K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
       P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, 随访时间, 随访反馈, 随访备注, AC本店第一次购药时间, RN2
from d_luoshi_pxsf_1 a
left join d_patient_files fi on a.idcardno=fi.idcardno;



--随访表
create table d_luoshi_px_hf
(
    idcard   varchar2(100),
    busno    number,
    sfday    date,
    sfresult varchar2(400),
    notes    varchar2(400)
);
drop table d_luoshi_px_hf;
--触发器 TR_V_LUOSHI_PXSF


create or replace trigger TR_V_LUOSHI_PXSF
    instead of update
    on V_LUOSHI_PXSF
    for each row
begin
    MERGE INTO d_luoshi_px_hf T1
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
 drop trigger TR_V_LUOSHI_PXSF;
call proc_luoshi_trigger_daily();

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







