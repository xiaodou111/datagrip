
with a as (
--����һ
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
--������
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
--������
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
    over ( partition by a.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) m������1�����������ۼƹ�ҩ֧��,
Max(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) AS r�������һ�ι�ҩʱ��,
LAG(a.ACCDATE, 1) OVER (PARTITION BY a.IDCARDNO ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��,
min(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) AS ac�����һ�ι�ҩʱ��,
(Max(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) - min(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) +
 21) / 21 as N���۹�ҩ֧��,
count(distinct a.SALENO) over ( partition by a.IDCARDNO) as q�����ۼƹ�ҩ����,
row_number() over (partition by a.IDCARDNO order by a.ACCDATE desc) rn
 from a
left join d_patient_files fi on fi.IDCARDNO = a.IDCARDNO
),
add_qc as (
   select a1.busno as busno,a1.IDCARDNO as IDCARDNO,a1.USERNAME as USERNAME,a1.WAREID as WAREID,
    nvl(qc.LBEFORE22,0)+nvl(qc.MSUMSLNOW,0)+nvl(m������1�����������ۼƹ�ҩ֧��,0) as  k���߱����ܹ�ҩ֧��,
       nvl(qc.LBEFORE22,0) as l������1����ǰ�ۼƹ�ҩ����,
       nvl(qc.MSUMSLNOW,0)+nvl(m������1�����������ۼƹ�ҩ֧��,0) as m������1�����������ۼƹ�ҩ֧��,
    N���۹�ҩ֧��,
       nvl(q�����ۼƹ�ҩ����,qc.QSUMCS) as q�����ۼƹ�ҩ����,
       nvl(r�������һ�ι�ҩʱ��,qc.RLASTBUYTIME) as r�������һ�ι�ҩʱ��,
       nvl(s����ǰһ�ι�ҩʱ��,qc.SLAGBUYTIME) as s����ǰһ�ι�ҩʱ��,
       nvl(ac�����һ�ι�ҩʱ��,qc.firsttime) as ac�����һ�ι�ҩʱ��,rn
    from  a1
    left join d_luoshi_qcsj qc on a1.IDCARDNO=qc.IDCARDNO
    where rn=1
    )
select
aa.busno,
tb.CLASSNAME as ҩ������ʡ��,
tb1.CLASSNAME as ҩ�����ڳ���,
       aa.IDCARDNO, aa.USERNAME,
       files.ԭ��ҩ���� as ��ҩ����,
       files.�÷��������鵥���Ƿ�Ϊ����͡,
       files.��������,
       files.�Ƿ������¸�������,
       k���߱����ܹ�ҩ֧��,
       l������1����ǰ�ۼƹ�ҩ����,
       m������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��,
       case when N���۹�ҩ֧�� - m������1�����������ۼƹ�ҩ֧�� >= 1 then '�зǱ��깺�����' else '���ڱ��깺��' end as oʵ��ҩ����ҩ�ڼ����ƫ�����,
       case when m������1�����������ۼƹ�ҩ֧�� - q�����ۼƹ�ҩ���� < 0 then '���º˲����' else '0' end as p���깺������˲�,
       q�����ۼƹ�ҩ����,
       r�������һ�ι�ҩʱ��,
       s����ǰһ�ι�ҩʱ��,
       r�������һ�ι�ҩʱ�� - s����ǰһ�ι�ҩʱ�� as t������ι�ҩ����,
       r�������һ�ι�ҩʱ�� + 21 as u�����´����۹�ҩʱ��,
       case when k���߱����ܹ�ҩ֧�� >= 19 then 'Y' else 'N' end as v�Ʋ��Ƿ�������Ƴ�,
       trunc(sysdate - r�������һ�ι�ҩʱ��) as w���һ�ι�ҩ�����������,
       trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��) as x�����ҩ���״ι�ҩ�ۼ�ʱ��,
       case when q�����ۼƹ�ҩ����<=1 then null else (trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��)) / (q�����ۼƹ�ҩ���� - 1) end as y2022����������ƽ����ҩ����,
       null as ���ʱ��,null as ��÷���,null as ��ñ�ע,
--        hf.sfday as ���ʱ��, hf.sfresult as ��÷���, hf.notes as ��ñ�ע,
       ac�����һ�ι�ҩʱ��,rn
from add_qc aa
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO;

--����
select a.BUSNO, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, a.IDCARDNO, a.USERNAME, fi.ԭ��ҩ���� as ��ҩ����, fi.�÷��������鵥���Ƿ�Ϊ����͡,
       fi.��������, fi.�Ƿ������¸�������, K���߱����ܹ�ҩ֧��, L������1����ǰ�ۼƹ�ҩ����, M������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��, Oʵ��ҩ����ҩ�ڼ����ƫ�����, P���깺������˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��,
       S����ǰһ�ι�ҩʱ��, T������ι�ҩ����, U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������,
       X�����ҩ���״ι�ҩ�ۼ�ʱ��, Y2022����������ƽ����ҩ����, ���ʱ��, ��÷���, ��ñ�ע, AC�����һ�ι�ҩʱ��,
       RN
from D_LUOSHI_JMSF_1 a
left join d_patient_files fi on a.idcardno=fi.idcardno;

MERGE INTO d_luoshi_jmsf_1 T1
USING
(
select busno, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO, USERNAME, ��ҩ����,
                                    �÷��������鵥���Ƿ�Ϊ����͡, ��������, �Ƿ������¸�������, k���߱����ܹ�ҩ֧��,
                                    l������1����ǰ�ۼƹ�ҩ����, m������1�����������ۼƹ�ҩ֧��, N���۹�ҩ֧��,
                                    oʵ��ҩ����ҩ�ڼ����ƫ�����, p���깺������˲�, q�����ۼƹ�ҩ����, r�������һ�ι�ҩʱ��,
                                    s����ǰһ�ι�ҩʱ��, t������ι�ҩ����, u�����´����۹�ҩʱ��, v�Ʋ��Ƿ�������Ƴ�,
                                    w���һ�ι�ҩ�����������, x�����ҩ���״ι�ҩ�ۼ�ʱ��, y2022����������ƽ����ҩ����,
                                    ���ʱ��, ��÷���, ��ñ�ע, ac�����һ�ι�ҩʱ��, rn
                             from v_luoshi_jmsf where IDCARDNO is not null
)  T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
WHEN MATCHED THEN
UPDATE SET
           T1.k���߱����ܹ�ҩ֧��= T2.k���߱����ܹ�ҩ֧��,
           T1.l������1����ǰ�ۼƹ�ҩ����= T2.l������1����ǰ�ۼƹ�ҩ����,
           T1.m������1�����������ۼƹ�ҩ֧��= T2.m������1�����������ۼƹ�ҩ֧��,
           T1.N���۹�ҩ֧��= T2.N���۹�ҩ֧��,
           T1.oʵ��ҩ����ҩ�ڼ����ƫ�����= T2.oʵ��ҩ����ҩ�ڼ����ƫ�����,
           T1.p���깺������˲�= T2.p���깺������˲�,
           T1.q�����ۼƹ�ҩ����= T2.q�����ۼƹ�ҩ����,
           T1.r�������һ�ι�ҩʱ��= T2.r�������һ�ι�ҩʱ��,
           T1.s����ǰһ�ι�ҩʱ��= T2.s����ǰһ�ι�ҩʱ��,
           T1.t������ι�ҩ����= T2.t������ι�ҩ����,
           T1.u�����´����۹�ҩʱ��= T2.u�����´����۹�ҩʱ��,
           T1.v�Ʋ��Ƿ�������Ƴ�= T2.v�Ʋ��Ƿ�������Ƴ�,
           T1.w���һ�ι�ҩ�����������= T2.w���һ�ι�ҩ�����������,
           T1.x�����ҩ���״ι�ҩ�ۼ�ʱ��= T2.x�����ҩ���״ι�ҩ�ۼ�ʱ��,
           T1.y2022����������ƽ����ҩ����= T2.y2022����������ƽ����ҩ����,
           T1.ac�����һ�ι�ҩʱ��= T2.ac�����һ�ι�ҩʱ��

WHEN NOT MATCHED THEN
INSERT (busno, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO, USERNAME, ��ҩ����,
                                    �÷��������鵥���Ƿ�Ϊ����͡, ��������, �Ƿ������¸�������, k���߱����ܹ�ҩ֧��,
                                    l������1����ǰ�ۼƹ�ҩ����, m������1�����������ۼƹ�ҩ֧��, N���۹�ҩ֧��,
                                    oʵ��ҩ����ҩ�ڼ����ƫ�����, p���깺������˲�, q�����ۼƹ�ҩ����, r�������һ�ι�ҩʱ��,
                                    s����ǰһ�ι�ҩʱ��, t������ι�ҩ����, u�����´����۹�ҩʱ��, v�Ʋ��Ƿ�������Ƴ�,
                                    w���һ�ι�ҩ�����������, x�����ҩ���״ι�ҩ�ۼ�ʱ��, y2022����������ƽ����ҩ����,
                                    ���ʱ��, ��÷���, ��ñ�ע, ac�����һ�ι�ҩʱ��, rn)
VALUES(T2.busno, T2.ORGNAME, T2.ҩ������ʡ��, T2.ҩ�����ڳ���, T2.IDCARDNO, T2.USERNAME, T2.��ҩ����,
        T2.�÷��������鵥���Ƿ�Ϊ����͡, T2.��������, T2.�Ƿ������¸�������, T2.k���߱����ܹ�ҩ֧��,
        T2.l������1����ǰ�ۼƹ�ҩ����, T2.m������1�����������ۼƹ�ҩ֧��, T2.N���۹�ҩ֧��,
        T2.oʵ��ҩ����ҩ�ڼ����ƫ�����, T2.p���깺������˲�, T2.q�����ۼƹ�ҩ����, T2.r�������һ�ι�ҩʱ��,
        T2.s����ǰһ�ι�ҩʱ��, T2.t������ι�ҩ����, T2.u�����´����۹�ҩʱ��, T2.v�Ʋ��Ƿ�������Ƴ�,
        T2.w���һ�ι�ҩ�����������, T2.x�����ҩ���״ι�ҩ�ۼ�ʱ��, T2.y2022����������ƽ����ҩ����,
        T2.���ʱ��, T2.��÷���, T2.��ñ�ע, T2.ac�����һ�ι�ҩʱ��, T2.rn);


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
UPDATE v_luoshi_jmsf SET ��÷���='1215',��ñ�ע='qq' WHERE busno=81248 AND idcardno='332601197804065168';

select *
from d_luoshi_jm_hf;

select *
from ;







--ÿ���˵�һ�ι���Ƥ�µ�ʱ��
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
             :new.���ʱ�� ���ʱ��,
             :new.��÷��� ��÷���,
             :new.��ñ�ע ��ñ�ע,
             :new.���淶��¼ ���淶��¼
         FROM dual) T2
    ON (T1.idcard = T2.IDCARDNO)
    WHEN MATCHED THEN
        UPDATE SET
        T1.sfday= T2.���ʱ��,
        T1.sfresult= T2.��÷���,
        T1.notes= T2.��ñ�ע,
        T1.BGFJL= T2.���淶��¼
    WHEN NOT MATCHED THEN
        INSERT (idcard, sfday,sfresult,notes,BGFJL) VALUES (
             :new.IDCARDNO,
             :new.���ʱ��,
             :new.��÷���,
             :new.��ñ�ע,
             :new.���淶��¼);
end;
GRANT CREATE TRIGGER TO h2;
call proc_luoshi_trigger_daily();
delete from d_luoshi_jm_hf ;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
     job_name        => 'ÿ���ؽ����ϵĴ�����',
     job_type        => 'PLSQL_BLOCK',
     job_action      => 'BEGIN proc_luoshi_trigger_daily; END;',
     start_date      => SYSTIMESTAMP,
     repeat_interval => 'FREQ=DAILY;BYHOUR=0', -- ÿ���賿ִ��
     enabled         => TRUE,
     comments        => 'ÿ���ؽ����ϵĴ�����');
END;

