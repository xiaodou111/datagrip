--d_luoshi_qcsj 罗氏需要导入的期初数据
    --D_LUOSHI_PROG  患者方案开始时间和结束时间维护,需要加个历史表,每个方案都需要一条记录,加个历史表防止对原表进行修改操作恢复不了
    alter table d_luoshi_qcsj add firsttime date;
--todo 罗氏修改方案时间
select BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE, ENDDATE
from D_LUOSHI_PROG;
332623195005301346
 insert into D_LUOSHI_PROG(IDCARDNO,PROGRAMME,BEGINDATE,ENDDATE) values('332623195005301346',1,date'2021-04-01',date'2021-07-25');
 insert into D_LUOSHI_PROG(IDCARDNO,PROGRAMME,BEGINDATE,ENDDATE) values('332623195005301346',3,date'2021-07-25',date'2023-12-31');
 insert into D_LUOSHI_PROG(IDCARDNO,PROGRAMME,BEGINDATE,ENDDATE) values('332623195005301346',5,date'2023-12-31',date'9999-12-31');

select a.busno, s.ORGNAME, a.idcardno, a.username, a.programme, a.wareid, w.WARENAME, a.begindate, a.ENDDATE
from d_luoshi_prog a
         left join s_busi s on a.busno = s.BUSNO
         left join t_ware_base w on a.wareid = w.WAREID
单靶(单曲妥珠单抗)~t1/双靶(帕妥珠单抗)~t2/双靶(曲妥珠单抗)~t3/其他方案(含曲妥珠单抗)~t4/其他方案(含帕妥珠单抗)~t5/单靶(曲妥珠单抗HSC)~t6/双靶(含曲妥珠单抗HSC)~t7/双靶(帕妥珠单抗)~t8/其他方案(曲妥珠单抗HSC+吡咯替尼)~t9

     alter table D_LUOSHI_PROG
    add enddate date;
--插入时不指定ENDDATE字段会使用默认值
insert into D_LUOSHI_PROG(BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE)
values (null, 332623195005301346, '里斯', 9, 10502445, DATE'2023-12-31');
ALTER TABLE D_LUOSHI_PROG
    MODIFY (enddate DATE DEFAULT TO_DATE('9999-12-31', 'YYYY-MM-DD'));

-- select h.IDCARDNO,a.busno,cyb.参保地,cyb.异地标志,h.USERNAME,h.CAGE,h.SEX,d.WAREID,d.WAREQTY,a.ACCDATE
--                     from t_remote_prescription_h h
--                         join t_sale_h a on substr(a.notes, 0,
--                                                   decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
--                                                          instr(a.notes, ' ')) -
--                                                   1) =
--                                            h.CFNO
--                         join t_sale_d d on a.SALENO = d.SALENO
--       left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
--       where
--           IDCARDNO='332623195005301346' AND
--           a.ACCDATE between date'2023-01-01' and date'2023-09-01' and
-- d.WAREID in (10502445);
--方案一
select * from d_luoshi_jmsf_1 ;
select * from D_LUOSHI_PROG;

--方案一,四

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
  and p.PROGRAMME in (1,4)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10502445)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
union all
--方案二,三,五
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (2,3,5)
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
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO

;
;
--方案六,七,九
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (6,7,9)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10601875)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
;




--方案八
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (6,7,9)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO);
--方案六

create or replace procedure proc_luoshi_update
    is
    v_varcahr1 varchar2(100);
    v_varcahr2 varchar2(100);
    v_varcahr3 varchar2(100);
    v_num      number;
    v_num      number;
    v_num      number;
    v_begin    Date;
    v_end      Date;


begin

    DBMS_OUTPUT.PUT_LINE(v_row_count);
exception
    when others then
        RAISE_APPLICATION_ERROR(-20001, '单轨制更新(处方来源单号)没有行受到影响');

end ;
insert into D_LUOSHI_PROG
values (81001, '123456789012345678', '张三', '方案1', 10502445, date'2024-04-01');
select BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE
from D_LUOSHI_PROG;



update D_LUOSHI_PROG
set PROGRAMME='方案2',
    BEGINDATE=date'2024-04-15'
where IDCARDNO = '123456789012345678';


select *
from D_LUOSHI_PROG_HISTORY;
CREATE OR REPLACE TRIGGER trg_d_luoshi_prog
    AFTER UPDATE
    ON D_LUOSHI_PROG
    FOR EACH ROW
BEGIN

    INSERT INTO D_LUOSHI_PROG_HISTORY (HISTORY_ID, BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE, ACTION,
                                       ACTION_DATE)
    VALUES (D_LUOSHI_PROG_HISTORY_SEQ.NEXTVAL, :NEW.BUSNO, :NEW.IDCARDNO, :NEW.USERNAME, :NEW.PROGRAMME, :NEW.WAREID,
            :NEW.BEGINDATE, 'UPDATE', SYSDATE);


END;
/



select IDCARDNO, COUNT(*)
FROM (select IDCARDNO, busno, rn, lastbuytime, 参保地, 异地标志, USERNAME, CAGE, SEX
from (select h.IDCARDNO, a.busno, cyb.参保地, cyb.异地标志, h.USERNAME, h.CAGE, h.SEX,
             ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE desc) rn,
             MAX(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS lastbuytime
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
where

--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308))
where lastbuytime > date'2023-01-01'
  and IDCARDNO is not null)
GROUP BY IDCARDNO;



select h.IDCARDNO, d.WAREID
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
where

--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308)
GROUP BY h.IDCARDNO, d.WAREID
HAVING COUNT(DISTINCT d.WAREID) = 2;



select h.IDCARDNO, a.busno, cyb.参保地, cyb.异地标志, h.USERNAME, h.CAGE, h.SEX, d.WAREID, d.WAREQTY, a.ACCDATE


from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
where IDCARDNO = '332623195005301346'
  AND
--           a.ACCDATE >= date'2023-01-01' and
    d.WAREID in (10502445, 10601875, 10600308);